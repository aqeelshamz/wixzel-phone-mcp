import { z } from 'zod/v4';
import { annotate, compact, defineTool } from '../tooling.js';
import { e164, id, idempotencyKey, pagination, voiceConfig } from '../schemas.js';

const agentFields = {
    name: z.string().min(1).describe('A label for your own reference, e.g. "Support line".'),
    system_prompt: z
        .string()
        .min(1)
        .describe('The agent\'s instructions. This is a spoken conversation, so keep it short, concrete, and free of markdown.'),
    opening_message: z
        .string()
        .min(1)
        .describe('Spoken as soon as the call connects. Supports {{name}} style merge fields from the lead. Required: an agent without one answers in silence.'),
    voice: voiceConfig,
    language: z.string().optional().describe('BCP-47 tag for the conversation, e.g. "en-US" or "hi-IN".'),
    knowledge_base_id: z.string().optional().describe('A knowledge base the agent can draw on. See list_knowledge_bases.'),
    outbound_phone_number_id: z
        .string()
        .optional()
        .describe('Default caller id for outbound calls placed with this agent. See list_phone_numbers.'),
    appointment_booking_enabled: z
        .boolean()
        .optional()
        .describe('Let the agent book appointments during a call.'),
};

export const agentTools = [
    defineTool({
        name: 'list_agents',
        endpoint: 'GET /v1/agents',
        title: 'List agents',
        description: 'List the voice agents on this account. Cursor-paginated: pass next_cursor as starting_after for the next page.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'agents:read',
        handler: (client, args) => client.get('/v1/agents', args),
    }),
    defineTool({
        name: 'get_agent',
        endpoint: 'GET /v1/agents/{id}',
        title: 'Retrieve an agent',
        description: 'Fetch one agent by id, including its full voice configuration and prompt.',
        input: { id },
        annotations: annotate.read,
        scope: 'agents:read',
        handler: (client, { id }) => client.get(`/v1/agents/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_agent',
        endpoint: 'POST /v1/agents',
        title: 'Create an agent',
        description:
            'Create a voice agent. Pick models with list_engines first: an unavailable or mistyped model is rejected with unsupported_model. ' +
            'voice is either a composed pipeline {stt, llm, tts} or a single {realtime} model, never both.',
        input: agentFields,
        annotations: annotate.write,
        scope: 'agents:write',
        handler: (client, args) => client.post('/v1/agents', compact(args)),
    }),
    defineTool({
        name: 'test_call_agent',
        endpoint: 'POST /v1/agents/{id}/test-call',
        title: 'Place a test call',
        description:
            'Ring a number and have the agent speak one phrase, then hang up. A probe, not a conversation: it answers ' +
            '"is the trunk configured and does this agent sound right" in seconds. For a real conversation use place_call. ' +
            'THIS RINGS A REAL PHONE AND SPENDS REAL CREDIT — the meter runs on a test call exactly as on any other, so ' +
            'confirm the number with the user first. Human transfer is not offered during a test call, so this cannot check ' +
            'that a transfer destination answers. Needs calls:write.',
        input: {
            id,
            to: e164.describe('Destination in E.164 form, e.g. "+14155551234". A real phone will ring.'),
            from_number_id: z.string().optional().describe("Defaults to the agent's own outbound number. See list_phone_numbers."),
            phrase: z.string().optional().describe("What to say. Defaults to the agent's opening message, which is usually what you want to hear."),
            idempotency_key: idempotencyKey,
        },
        annotations: annotate.spend,
        scope: 'calls:write',
        handler: (client, { id, idempotency_key, ...body }) =>
            client.post(`/v1/agents/${encodeURIComponent(id)}/test-call`, compact(body), { idempotencyKey: idempotency_key, idempotent: true }),
    }),
    defineTool({
        name: 'update_agent',
        endpoint: 'PATCH /v1/agents/{id}',
        title: 'Update an agent',
        description: 'Change an agent. Only the fields you send are changed; omit the rest. Sending voice replaces the whole voice object.',
        input: {
            id,
            ...Object.fromEntries(Object.entries(agentFields).map(([k, v]) => [k, v.optional()])),
        } as { id: typeof id } & { [K in keyof typeof agentFields]: z.ZodOptional<(typeof agentFields)[K]> },
        annotations: annotate.write,
        scope: 'agents:write',
        handler: (client, { id, ...rest }) => client.patch(`/v1/agents/${encodeURIComponent(id)}`, compact(rest)),
    }),
    defineTool({
        name: 'delete_agent',
        endpoint: 'DELETE /v1/agents/{id}',
        title: 'Delete an agent',
        description: 'Permanently delete an agent. Phone numbers and campaigns pointing at it stop working. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'agents:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/agents/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
];
