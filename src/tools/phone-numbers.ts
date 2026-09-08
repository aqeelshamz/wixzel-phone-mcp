import { z } from 'zod';
import { annotate, compact, defineTool } from '../tooling.js';
import { e164, id, pagination } from '../schemas.js';

export const phoneNumberTools = [
    defineTool({
        name: 'list_phone_numbers',
        title: 'List phone numbers',
        description: 'List the phone numbers registered on this account, with the SIP trunk each rides on and the agent (if any) answering inbound calls.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'phone_numbers:read',
        handler: (client, args) => client.get('/v1/phone-numbers', args),
    }),
    defineTool({
        name: 'get_phone_number',
        title: 'Retrieve a phone number',
        description: 'Fetch one phone number record by id.',
        input: { id },
        annotations: annotate.read,
        scope: 'phone_numbers:read',
        handler: (client, { id }) => client.get(`/v1/phone-numbers/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_phone_number',
        title: 'Register a phone number',
        description:
            'Register a number you already own with your carrier, on one of your SIP trunks. Wixzel does not sell numbers. ' +
            'Set inbound_agent_id to have an agent answer calls to it; without it inbound calls are rejected. ' +
            'For inbound to ring at all, the carrier must also be pointed at the trunk\'s origination_uri (see get_sip_trunk).',
        input: {
            phone_number: e164,
            sip_trunk_id: z.string().describe('The trunk this number is routed through. See list_sip_trunks.'),
            name: z.string().optional().describe('A label, e.g. "Main line".'),
            inbound_agent_id: z.string().optional().describe('Agent that answers inbound calls to this number.'),
        },
        annotations: annotate.write,
        scope: 'phone_numbers:write',
        handler: (client, args) => client.post('/v1/phone-numbers', compact(args)),
    }),
    defineTool({
        name: 'update_phone_number',
        title: 'Update a phone number',
        description: 'Change a phone number\'s label, trunk or inbound agent. Only the fields you send are changed.',
        input: {
            id,
            phone_number: e164.optional(),
            sip_trunk_id: z.string().optional(),
            name: z.string().optional(),
            inbound_agent_id: z.string().optional(),
        },
        annotations: annotate.write,
        scope: 'phone_numbers:write',
        handler: (client, { id, ...rest }) =>
            client.patch(`/v1/phone-numbers/${encodeURIComponent(id)}`, compact(rest)),
    }),
    defineTool({
        name: 'delete_phone_number',
        title: 'Delete a phone number',
        description: 'Remove a phone number from the account. Agents using it as their outbound number can no longer place calls. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'phone_numbers:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/phone-numbers/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
];
