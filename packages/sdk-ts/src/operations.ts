/**
 * Every operation in the OpenAPI document, and the SDK method that wraps it.
 *
 * Not used at runtime. The spec-coverage test compares this table against
 * `docs/openapi.json` in both directions and checks each named method exists
 * and calls what it claims, so an endpoint added to the API fails the build
 * here until it gets a method, and a method cannot claim an endpoint that is
 * not there. The Dart SDK carries the same table with the same names.
 */
export const OPERATIONS = {
    'GET /v1/engines': 'engines.list',

    'GET /v1/agents': 'agents.list',
    'POST /v1/agents': 'agents.create',
    'GET /v1/agents/{id}': 'agents.retrieve',
    'PATCH /v1/agents/{id}': 'agents.update',
    'DELETE /v1/agents/{id}': 'agents.delete',

    'POST /v1/calls': 'calls.create',
    'GET /v1/calls': 'calls.list',
    'GET /v1/calls/{id}': 'calls.retrieve',
    'DELETE /v1/calls/{id}': 'calls.delete',
    'POST /v1/calls/{id}/hangup': 'calls.hangup',
    'GET /v1/calls/{id}/transcript': 'calls.transcript',

    'GET /v1/leads': 'leads.list',
    'POST /v1/leads': 'leads.create',
    'POST /v1/leads/bulk': 'leads.bulkCreate',
    'GET /v1/leads/{id}': 'leads.retrieve',
    'PATCH /v1/leads/{id}': 'leads.update',
    'DELETE /v1/leads/{id}': 'leads.delete',

    'GET /v1/campaigns': 'campaigns.list',
    'POST /v1/campaigns': 'campaigns.create',
    'GET /v1/campaigns/{id}': 'campaigns.retrieve',
    'DELETE /v1/campaigns/{id}': 'campaigns.delete',
    'POST /v1/campaigns/{id}/start': 'campaigns.start',
    'POST /v1/campaigns/{id}/pause': 'campaigns.pause',

    'GET /v1/knowledge-bases': 'knowledgeBases.list',
    'POST /v1/knowledge-bases': 'knowledgeBases.create',
    'GET /v1/knowledge-bases/{id}': 'knowledgeBases.retrieve',
    'PATCH /v1/knowledge-bases/{id}': 'knowledgeBases.update',
    'DELETE /v1/knowledge-bases/{id}': 'knowledgeBases.delete',

    'GET /v1/phone-numbers': 'phoneNumbers.list',
    'POST /v1/phone-numbers': 'phoneNumbers.create',
    'GET /v1/phone-numbers/{id}': 'phoneNumbers.retrieve',
    'PATCH /v1/phone-numbers/{id}': 'phoneNumbers.update',
    'DELETE /v1/phone-numbers/{id}': 'phoneNumbers.delete',

    'GET /v1/sip-trunks': 'sipTrunks.list',
    'POST /v1/sip-trunks': 'sipTrunks.create',
    'GET /v1/sip-trunks/{id}': 'sipTrunks.retrieve',
    'PATCH /v1/sip-trunks/{id}': 'sipTrunks.update',
    'DELETE /v1/sip-trunks/{id}': 'sipTrunks.delete',
    'GET /v1/sip-trunks/{id}/status': 'sipTrunks.status',
    'GET /v1/sip-trunks/{id}/logs': 'sipTrunks.logs',
    'POST /v1/sip-trunks/{id}/test': 'sipTrunks.test',

    'GET /v1/appointments': 'appointments.list',
    'POST /v1/appointments': 'appointments.create',
    'GET /v1/appointments/{id}': 'appointments.retrieve',
    'PATCH /v1/appointments/{id}': 'appointments.update',
    'DELETE /v1/appointments/{id}': 'appointments.delete',

    'GET /v1/usage/events': 'usage.events',
    'GET /v1/usage/summary': 'usage.summary',

    'GET /v1/billing/balance': 'billing.balance',
    'GET /v1/billing/ledger': 'billing.ledger',
    'POST /v1/billing/topups': 'billing.createTopup',

    'GET /v1/api-keys': 'apiKeys.list',
    'POST /v1/api-keys': 'apiKeys.create',
    'DELETE /v1/api-keys/{id}': 'apiKeys.revoke',
    'POST /v1/api-keys/{id}/rotate': 'apiKeys.rotate',
} as const;

export type Operation = keyof typeof OPERATIONS;

/** Every API key scope, in the API's own order. Verified against the spec by a test. */
export const SCOPES = [
    'agents:read', 'agents:write',
    'calls:read', 'calls:write',
    'leads:read', 'leads:write',
    'campaigns:read', 'campaigns:write',
    'knowledge_bases:read', 'knowledge_bases:write',
    'phone_numbers:read', 'phone_numbers:write',
    'sip_trunks:read', 'sip_trunks:write',
    'appointments:read', 'appointments:write',
    'webhooks:read', 'webhooks:write',
    'api_keys:read', 'api_keys:write',
    'usage:read', 'billing:read', 'billing:write',
] as const;
