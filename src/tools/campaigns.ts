import { z } from 'zod';
import { annotate, compact, defineTool } from '../tooling.js';
import { id, isoDate, pagination } from '../schemas.js';

export const campaignTools = [
    defineTool({
        name: 'list_campaigns',
        title: 'List campaigns',
        description: 'List outbound calling campaigns with their status (idle, scheduled, running, completed, stopped, paused) and lead_count.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'campaigns:read',
        handler: (client, args) => client.get('/v1/campaigns', args),
    }),
    defineTool({
        name: 'get_campaign',
        title: 'Retrieve a campaign',
        description: 'Fetch one campaign by id.',
        input: { id },
        annotations: annotate.read,
        scope: 'campaigns:read',
        handler: (client, { id }) => client.get(`/v1/campaigns/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_campaign',
        title: 'Create a campaign',
        description:
            'Create a campaign that will call every listed lead with an agent. Creating does NOT dial anyone: call start_campaign when the user is ready to spend. ' +
            'Without scheduled_at the campaign is ready to start immediately.',
        input: {
            name: z.string().min(1),
            agent_id: z.string(),
            lead_ids: z.array(z.string()).min(1).describe('Lead ids from list_leads or import_leads.'),
            scheduled_at: isoDate.optional().describe('When to begin. Omit to start on demand.'),
        },
        annotations: annotate.write,
        scope: 'campaigns:write',
        handler: (client, args) => client.post('/v1/campaigns', compact(args)),
    }),
    defineTool({
        name: 'start_campaign',
        title: 'Start a campaign',
        description:
            'Begin calling every lead on the campaign. THIS SPENDS MONEY AND MAKES REAL PHONES RING, one call per lead: confirm with the user before calling it. ' +
            'Refused with insufficient_credits when the balance cannot cover the run.',
        input: { id },
        annotations: annotate.spend,
        scope: 'campaigns:write',
        handler: (client, { id }) => client.post(`/v1/campaigns/${encodeURIComponent(id)}/start`),
    }),
    defineTool({
        name: 'pause_campaign',
        title: 'Pause a campaign',
        description: 'Stop placing new calls and hang up any the campaign still has in flight.',
        input: { id },
        annotations: annotate.writeIdempotent,
        scope: 'campaigns:write',
        handler: (client, { id }) => client.post(`/v1/campaigns/${encodeURIComponent(id)}/pause`),
    }),
    defineTool({
        name: 'delete_campaign',
        title: 'Delete a campaign',
        description: 'Permanently delete a campaign. Pause it first if it is running. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'campaigns:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/campaigns/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
];
