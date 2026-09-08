import { z } from 'zod';
import { annotate, compact, defineTool } from '../tooling.js';
import { arbitraryFields, e164, id, idempotencyKey, isoDate, pagination } from '../schemas.js';

const callStatus = z.enum(['queued', 'ringing', 'in-progress', 'completed', 'failed', 'busy', 'no-answer', 'canceled']);

export const callTools = [
    defineTool({
        name: 'place_call',
        title: 'Place an outbound call',
        description:
            'Dial a real phone number over the account\'s SIP trunk and connect the agent. THIS SPENDS MONEY AND MAKES A PHONE RING: confirm with the user before calling it. ' +
            'Credit is reserved up front; an underfunded account is refused with insufficient_credits and nothing is dialled. ' +
            'Returns the call record immediately with status queued or ringing; poll get_call for progress, transcript and cost. ' +
            'Needs an agent (create_agent), a SIP trunk (create_sip_trunk) and a phone number on it (create_phone_number), either as from_number_id or as the agent\'s outbound_phone_number_id.',
        input: {
            to: e164.describe('Destination in E.164 form, e.g. "+14155551234".'),
            agent_id: z.string().describe('The agent that will hold the conversation.'),
            from_number_id: z
                .string()
                .optional()
                .describe('Phone number id to call from. Defaults to the agent\'s outbound_phone_number_id.'),
            lead_id: z.string().optional().describe('Existing lead to attribute the call to. One is created if omitted.'),
            lead_name: z.string().optional().describe('Name for the auto-created lead; available as {{name}} in the opening message.'),
            metadata: arbitraryFields.describe('Echoed back on the call and in webhooks. Not shown to the model.'),
            idempotency_key: idempotencyKey,
        },
        annotations: annotate.spend,
        scope: 'calls:write',
        handler: (client, { idempotency_key, ...body }) =>
            client.post('/v1/calls', compact(body), { idempotencyKey: idempotency_key, idempotent: true }),
    }),
    defineTool({
        name: 'list_calls',
        title: 'List calls',
        description:
            'List calls in summary form (no transcript). Filter by status, direction, agent, campaign, engine, phone number or time window. ' +
            'Use get_call for the full record of one call.',
        input: {
            ...pagination,
            status: callStatus.optional(),
            direction: z.enum(['inbound', 'outbound']).optional(),
            agent_id: z.string().optional(),
            campaign_id: z.string().optional(),
            engine: z.string().optional().describe('Engine id as returned by list_engines.'),
            phone_number: z.string().optional().describe('Match either party\'s number.'),
            started_after: isoDate.optional(),
            started_before: isoDate.optional(),
            failed_only: z.boolean().optional().describe('Only calls that did not connect.'),
        },
        annotations: annotate.read,
        scope: 'calls:read',
        handler: (client, args) => client.get('/v1/calls', args),
    }),
    defineTool({
        name: 'get_call',
        title: 'Retrieve a call',
        description:
            'The full call record: status, duration, cost_micros, recording_url, summary, transcript, transfers, and any provider errors. ' +
            'If the call did not connect, failure_code (a Q.850 cause: 17 busy, 19 no answer, 21 rejected by carrier, 34 congestion, 102 timeout) and failure_reason say what to do about it.',
        input: { id: id.describe('The call id (not the session_id).') },
        annotations: annotate.read,
        scope: 'calls:read',
        handler: (client, { id }) => client.get(`/v1/calls/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'get_call_transcript',
        title: 'Retrieve a call transcript',
        description: 'Just the transcript of a call, as a list of {role, content, timestamp} turns.',
        input: { id },
        annotations: annotate.read,
        scope: 'calls:read',
        handler: (client, { id }) => client.get(`/v1/calls/${encodeURIComponent(id)}/transcript`),
    }),
    defineTool({
        name: 'hangup_call',
        title: 'End a call in progress',
        description: 'Hang up a live call. Billing stops when the call ends. Returns the updated call record.',
        input: { id },
        annotations: annotate.writeIdempotent,
        scope: 'calls:write',
        handler: (client, { id }) => client.post(`/v1/calls/${encodeURIComponent(id)}/hangup`),
    }),
    defineTool({
        name: 'delete_call',
        title: 'Delete a call record',
        description:
            'Remove a call log with its transcript and recording, as a caller\'s erasure request needs. The usage rows that billed it are kept (they carry no content). ' +
            'A call still in progress cannot be deleted; hang it up first. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'calls:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/calls/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
];
