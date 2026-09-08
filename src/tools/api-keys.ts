import { z } from 'zod';
import { annotate, compact, defineTool } from '../tooling.js';
import { id, isoDate, pagination, scope } from '../schemas.js';

export const apiKeyTools = [
    defineTool({
        name: 'list_api_keys',
        title: 'List API keys',
        description: 'List the account\'s API keys with their scopes, spend limits and last use. Secrets are never returned, only a prefix and last four characters.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'api_keys:read',
        handler: (client, args) => client.get('/v1/api-keys', args),
    }),
    defineTool({
        name: 'create_api_key',
        title: 'Create an API key',
        description:
            'Mint a new scoped key. The secret is returned ONCE in the result and cannot be retrieved again: hand it to the user immediately and do not log it elsewhere. ' +
            'A key cannot grant scopes the calling key does not hold (scope_escalation). Grant only what the integration needs; billing:write authorises spending money.',
        input: {
            name: z.string().min(1).describe('For the user\'s reference, e.g. "production backend".'),
            scopes: z.array(scope).min(1).describe('No wildcard; agents:write does not imply agents:read.'),
            spend_limit_micros: z
                .number()
                .int()
                .positive()
                .optional()
                .describe('Guardrail in micro-USD, enforced within about a minute. Not a hard cap.'),
            expires_at: isoDate.optional(),
        },
        annotations: annotate.write,
        scope: 'api_keys:write',
        handler: (client, args) => client.post('/v1/api-keys', compact(args)),
    }),
    defineTool({
        name: 'rotate_api_key',
        title: 'Rotate an API key',
        description:
            'Issue a replacement secret. The old key keeps working for 24 hours so a deploy can roll over without a gap. ' +
            'The new secret is returned once; hand it to the user immediately.',
        input: { id },
        annotations: annotate.write,
        scope: 'api_keys:write',
        handler: (client, { id }) => client.post(`/v1/api-keys/${encodeURIComponent(id)}/rotate`),
    }),
    defineTool({
        name: 'revoke_api_key',
        title: 'Revoke an API key',
        description:
            'Revoke immediately, with no grace period. Anything still using it starts failing at once, including this MCP server if it is the key in use. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'api_keys:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/api-keys/${encodeURIComponent(id)}`);
            return { revoked: true, id };
        },
    }),
];
