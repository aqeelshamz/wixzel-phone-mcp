import { z } from 'zod/v4';
import { annotate, compact, defineTool } from '../tooling.js';
import { idempotencyKey, isoDate, pagination } from '../schemas.js';

const component = z.enum(['stt', 'llm', 'tts', 'realtime', 'telephony', 'platform_fee', 'platform_api']);

export const billingTools = [
    defineTool({
        name: 'get_balance',
        endpoint: 'GET /v1/billing/balance',
        title: 'Retrieve the balance',
        description:
            'The account\'s prepaid credit: balance_micros, held_micros (reserved by live calls) and available_micros. Micro-USD: 1,000,000 = $1.00. ' +
            'Check this before placing calls or starting campaigns.',
        input: {},
        annotations: annotate.read,
        scope: 'billing:read',
        handler: (client) => client.get('/v1/billing/balance'),
    }),
    defineTool({
        name: 'list_ledger_entries',
        endpoint: 'GET /v1/billing/ledger',
        title: 'List ledger entries',
        description: 'Every movement on the account (topup, usage, refund, adjustment, promo, overage, chargeback), with balance_after_micros. Balances reconcile exactly.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'billing:read',
        handler: (client, args) => client.get('/v1/billing/ledger', args),
    }),
    defineTool({
        name: 'create_topup',
        endpoint: 'POST /v1/billing/topups',
        title: 'Add credit',
        description:
            'Start a top-up. Returns a checkout_url that a HUMAN must open to pay; credit lands once payment settles, not when this returns. ' +
            'Never open the URL or attempt payment yourself. Confirm the amount with the user first.',
        input: {
            amount_usd: z.number().positive().describe('Amount to add, in US dollars.'),
            return_url: z.string().url().optional().describe('Where to send the customer after checkout.'),
            idempotency_key: idempotencyKey,
        },
        annotations: annotate.spend,
        scope: 'billing:write',
        handler: (client, { idempotency_key, ...body }) =>
            client.post('/v1/billing/topups', compact(body), { idempotencyKey: idempotency_key, idempotent: true }),
    }),
    defineTool({
        name: 'get_usage_summary',
        endpoint: 'GET /v1/usage/summary',
        title: 'Summarise usage',
        description: 'Total spend over a period, broken down by component, provider and model. total_micros is micro-USD; total_display is human-readable.',
        input: {
            start: isoDate.optional().describe('Period start. Defaults to the start of the current month.'),
            end: isoDate.optional().describe('Period end. Defaults to now.'),
        },
        annotations: annotate.read,
        scope: 'usage:read',
        handler: (client, args) => client.get('/v1/usage/summary', args),
    }),
    defineTool({
        name: 'list_usage_events',
        endpoint: 'GET /v1/usage/events',
        title: 'List usage events',
        description:
            'Every billable line, itemised. Filter by session_id (from a call record) to see exactly what one call cost and why: the sum of a call\'s events equals what was debited.',
        input: {
            ...pagination,
            session_id: z.string().optional().describe('The call\'s session_id (not its id).'),
            component: component.optional(),
            start: isoDate.optional(),
            end: isoDate.optional(),
        },
        annotations: annotate.read,
        scope: 'usage:read',
        handler: (client, args) => client.get('/v1/usage/events', args),
    }),
];
