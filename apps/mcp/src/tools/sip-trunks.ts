import { z } from 'zod/v4';
import { annotate, compact, defineTool } from '../tooling.js';
import { id, pagination } from '../schemas.js';

const trunkFields = {
    name: z.string().min(1).describe('A label, e.g. "Twilio" or "My carrier".'),
    host: z.string().min(1).describe('The carrier\'s SIP host, e.g. "sip.carrier.example".'),
    port: z.number().int().min(1).max(65535).optional().describe('Default 5060 (5061 for tls).'),
    transport: z.enum(['udp', 'tcp', 'tls']).optional(),
    username: z.string().optional(),
    password: z
        .string()
        .optional()
        .describe('Stored encrypted and never returned by the API again. Ask the user for it; do not invent one.'),
    auth_realm: z.string().optional(),
    default_caller_id: z.string().optional().describe('Caller id to present when no phone number is chosen.'),
    dial_prefix: z.string().optional().describe('Digits prepended to every dialled number, if the carrier needs them.'),
    send_plus: z
        .boolean()
        .optional()
        .describe('Keep the leading "+" when dialling, so the request URI reads sip:+15551234567@host. Twilio, Telnyx and Vobiz want true; many wholesale carriers answer 408 unless it is false.'),
    provider_name: z.string().optional().describe('Free text, e.g. "twilio", "telnyx", "plivo", "vonage", "bandwidth", "exotel", "vobiz".'),
};

export const sipTrunkTools = [
    defineTool({
        name: 'list_sip_trunks',
        endpoint: 'GET /v1/sip-trunks',
        title: 'List SIP trunks',
        description: 'List the account\'s SIP trunks. Each carries platform_ip (allowlist it with the carrier for outbound) and origination_uri (point the carrier at it for inbound).',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'sip_trunks:read',
        handler: (client, args) => client.get('/v1/sip-trunks', args),
    }),
    defineTool({
        name: 'get_sip_trunk',
        endpoint: 'GET /v1/sip-trunks/{id}',
        title: 'Retrieve a SIP trunk',
        description: 'Fetch one SIP trunk by id. The password is never returned.',
        input: { id },
        annotations: annotate.read,
        scope: 'sip_trunks:read',
        handler: (client, { id }) => client.get(`/v1/sip-trunks/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_sip_trunk',
        endpoint: 'POST /v1/sip-trunks',
        title: 'Create a SIP trunk',
        description:
            'Connect the user\'s own carrier (Twilio, Telnyx, Plivo, Vonage, Bandwidth, Exotel, Vobiz, any SIP provider). Wixzel does not resell telephony. ' +
            'After creating, tell the user to allowlist the returned platform_ip with their carrier (for outbound) and to set the carrier\'s origination URI to origination_uri (for inbound). ' +
            'Then run check_sip_trunk_status.',
        input: trunkFields,
        annotations: annotate.write,
        scope: 'sip_trunks:write',
        handler: (client, args) => client.post('/v1/sip-trunks', compact(args)),
    }),
    defineTool({
        name: 'update_sip_trunk',
        endpoint: 'PATCH /v1/sip-trunks/{id}',
        title: 'Update a SIP trunk',
        description: 'Change a SIP trunk. Only the fields you send are changed.',
        input: { id, ...trunkFields, name: trunkFields.name.optional(), host: trunkFields.host.optional() },
        annotations: annotate.write,
        scope: 'sip_trunks:write',
        handler: (client, { id, ...rest }) => client.patch(`/v1/sip-trunks/${encodeURIComponent(id)}`, compact(rest)),
    }),
    defineTool({
        name: 'delete_sip_trunk',
        endpoint: 'DELETE /v1/sip-trunks/{id}',
        title: 'Delete a SIP trunk',
        description: 'Remove a SIP trunk. Phone numbers on it can no longer make or take calls. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'sip_trunks:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/sip-trunks/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
    defineTool({
        name: 'check_sip_trunk_status',
        endpoint: 'GET /v1/sip-trunks/{id}/status',
        title: 'Check a SIP trunk',
        description:
            'Diagnose a trunk: Asterisk\'s own qualify result and a live network probe, side by side. Where they disagree is the diagnosis. ' +
            'A carrier that ignores unauthenticated OPTIONS shows probe.reachable false while Asterisk reports it healthy; that is normal. ' +
            'Read-only and free. Use this first when calls fail with carrier rejections.',
        input: { id },
        annotations: annotate.read,
        scope: 'sip_trunks:read',
        handler: (client, { id }) => client.get(`/v1/sip-trunks/${encodeURIComponent(id)}/status`),
    }),
    defineTool({
        name: 'test_sip_trunk',
        endpoint: 'POST /v1/sip-trunks/{id}/test',
        title: 'Test a SIP trunk',
        description:
            'Send a TCP connect or unauthenticated SIP OPTIONS to the carrier from the platform and record the outcome on the trunk. ' +
            'Puts traffic on a third party. A negative result is not proof the trunk is broken: many carriers drop unauthenticated probes. Prefer check_sip_trunk_status.',
        input: { id },
        annotations: annotate.probe,
        scope: 'sip_trunks:write',
        handler: (client, { id }) => client.post(`/v1/sip-trunks/${encodeURIComponent(id)}/test`),
    }),
    defineTool({
        name: 'get_sip_trunk_logs',
        endpoint: 'GET /v1/sip-trunks/{id}/logs',
        title: 'Recent SIP events',
        description:
            'The SIP engine\'s recent events for this account: registration, call setup, and carrier rejections with their cause. ' +
            'A live in-memory ring buffer, not an audit trail. Poll with since_id set to the last_id of the previous response to get only new entries.',
        input: {
            id,
            since_id: z.number().int().optional().describe('Return only entries newer than this id.'),
            limit: z.number().int().min(1).max(500).optional(),
        },
        annotations: annotate.read,
        scope: 'sip_trunks:read',
        handler: (client, { id, ...query }) => client.get(`/v1/sip-trunks/${encodeURIComponent(id)}/logs`, query),
    }),
];
