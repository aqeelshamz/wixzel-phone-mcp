import { z } from 'zod/v4';
import { annotate, compact, defineTool } from '../tooling.js';
import { isoDate, pagination } from '../schemas.js';

const EVENTS = [
    'inboundCall',
    'outboundCall',
    'callCompleted',
    'leadCreated',
    'leadQualified',
    'campaignCompleted',
    'appointmentBooked',
    'appointmentCanceled',
    'callTransferred',
    'transferFailed',
] as const;

const event = z.enum(EVENTS).describe(
    'An event id. These are camelCase because they are the literal `event` field of the JSON we POST, not API fields.',
);

export const webhookTools = [
    defineTool({
        name: 'get_webhook',
        endpoint: 'GET /v1/webhook',
        title: 'Retrieve the webhook endpoint',
        description:
            'Where events are sent for this account, whether delivery is on, and which events are subscribed. ' +
            'One endpoint per account, so there is nothing to list. The signing secret is never returned — only whether one is set.',
        input: {},
        annotations: annotate.read,
        scope: 'webhooks:read',
        handler: (client) => client.get('/v1/webhook'),
    }),
    defineTool({
        name: 'update_webhook',
        endpoint: 'PATCH /v1/webhook',
        title: 'Update the webhook endpoint',
        description:
            'Set the URL, turn delivery on or off, or change the event subscription. Only the fields you send change, ' +
            'EXCEPT events, which replaces the subscription entirely — send the full list you want, not a delta. ' +
            'The URL must be publicly resolvable; one pointing at loopback or a private network is refused. ' +
            'Enabling with no URL set is refused rather than silently saved.',
        input: {
            url: z.string().url().optional().describe('HTTPS endpoint we POST events to.'),
            enabled: z.boolean().optional().describe('Master switch. False sends nothing regardless of the event list.'),
            events: z.array(event).min(1).optional().describe('The complete set of events to receive.'),
        },
        annotations: annotate.write,
        scope: 'webhooks:write',
        handler: (client, args) => client.patch('/v1/webhook', compact(args)),
    }),
    defineTool({
        name: 'rotate_webhook_secret',
        endpoint: 'POST /v1/webhook/rotate-secret',
        title: 'Rotate the webhook signing secret',
        description:
            'Mint a new signing secret and return it ONCE. The old secret stops verifying immediately, so a receiver ' +
            'that checks signatures will reject every event until it has been redeployed with the new one. ' +
            'Do this when a secret has leaked, not as routine maintenance, and hand the value to the user right away.',
        input: {},
        annotations: annotate.write,
        scope: 'webhooks:write',
        handler: (client) => client.post('/v1/webhook/rotate-secret'),
    }),
    defineTool({
        name: 'test_webhook',
        endpoint: 'POST /v1/webhook/test',
        title: 'Send a test webhook event',
        description:
            'POST one sample payload to the configured URL right now and report what came back. This is how to check ' +
            'a webhook works BEFORE enabling it: it deliberately ignores the enabled flag and the event subscription. ' +
            'It reaches a real third-party endpoint but spends no credit. The payload is obviously fake sample data.',
        input: { event },
        annotations: annotate.probe,
        scope: 'webhooks:write',
        handler: (client, args) => client.post('/v1/webhook/test', args),
    }),
    defineTool({
        name: 'list_webhook_deliveries',
        endpoint: 'GET /v1/webhook/deliveries',
        title: 'List webhook delivery attempts',
        description:
            'What was sent and what came back, newest first — the answer to "did my webhook fire?". One record per ' +
            'attempt, so an event delivered on its third try appears three times. A null response_status means nothing ' +
            'answered at all (DNS, refused connection, timeout), which is what tells a wrong URL apart from a handler ' +
            'that threw. Filter with status: "failed" to see only what broke.',
        input: {
            event: event.optional(),
            status: z.enum(['delivered', 'failed']).optional().describe('Filter by outcome.'),
            start: isoDate.optional().describe('Only attempts at or after this time.'),
            end: isoDate.optional().describe('Only attempts at or before this time.'),
            ...pagination,
        },
        annotations: annotate.read,
        scope: 'webhooks:read',
        handler: (client, args) => client.get('/v1/webhook/deliveries', compact(args)),
    }),
];
