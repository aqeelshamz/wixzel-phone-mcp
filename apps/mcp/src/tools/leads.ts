import { z } from 'zod/v4';
import { annotate, compact, defineTool } from '../tooling.js';
import { arbitraryFields, e164, id, pagination } from '../schemas.js';

const leadFields = {
    name: z.string().min(1),
    phone_number: e164,
    fields: arbitraryFields.describe('Arbitrary key/value data, usable as {{merge}} fields in prompts and opening messages.'),
    tags: z.array(z.string()).optional(),
};

export const leadTools = [
    defineTool({
        name: 'list_leads',
        endpoint: 'GET /v1/leads',
        title: 'List leads',
        description: 'List leads (contacts). Filter by tag or free-text search. Cursor-paginated.',
        input: {
            ...pagination,
            tag: z.string().optional(),
            search: z.string().optional().describe('Matches name or phone number.'),
        },
        annotations: annotate.read,
        scope: 'leads:read',
        handler: (client, args) => client.get('/v1/leads', args),
    }),
    defineTool({
        name: 'get_lead',
        endpoint: 'GET /v1/leads/{id}',
        title: 'Retrieve a lead',
        description: 'Fetch one lead by id.',
        input: { id },
        annotations: annotate.read,
        scope: 'leads:read',
        handler: (client, { id }) => client.get(`/v1/leads/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_lead',
        endpoint: 'POST /v1/leads',
        title: 'Create a lead',
        description: 'Create one lead. For many at once use import_leads.',
        input: leadFields,
        annotations: annotate.write,
        scope: 'leads:write',
        handler: (client, args) => client.post('/v1/leads', compact(args)),
    }),
    defineTool({
        name: 'update_lead',
        endpoint: 'PATCH /v1/leads/{id}',
        title: 'Update a lead',
        description: 'Change a lead. Only the fields you send are changed.',
        input: {
            id,
            name: leadFields.name.optional(),
            phone_number: leadFields.phone_number.optional(),
            fields: leadFields.fields,
            tags: leadFields.tags,
        },
        annotations: annotate.write,
        scope: 'leads:write',
        handler: (client, { id, ...rest }) => client.patch(`/v1/leads/${encodeURIComponent(id)}`, compact(rest)),
    }),
    defineTool({
        name: 'delete_lead',
        endpoint: 'DELETE /v1/leads/{id}',
        title: 'Delete a lead',
        description: 'Permanently delete a lead. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'leads:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/leads/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
    defineTool({
        name: 'import_leads',
        endpoint: 'POST /v1/leads/bulk',
        title: 'Import many leads',
        description:
            'Create up to 1,000 leads in one request. Rows are validated individually: malformed rows come back in errors with their index, and the rest are still created. ' +
            'Check failed_count in the result.',
        input: {
            leads: z.array(z.object(leadFields)).min(1).max(1000),
        },
        annotations: annotate.write,
        scope: 'leads:write',
        handler: (client, { leads }) => client.post('/v1/leads/bulk', { leads: leads.map((l) => compact(l)) }),
    }),
];
