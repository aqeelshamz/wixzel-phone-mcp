import { z } from 'zod';
import { annotate, compact, defineTool } from '../tooling.js';
import { e164, id, isoDate, pagination } from '../schemas.js';

export const appointmentTools = [
    defineTool({
        name: 'list_appointments',
        title: 'List appointments',
        description: 'List appointments booked by agents or created directly, with status scheduled, completed or canceled.',
        input: { ...pagination },
        annotations: annotate.read,
        scope: 'appointments:read',
        handler: (client, args) => client.get('/v1/appointments', args),
    }),
    defineTool({
        name: 'get_appointment',
        title: 'Retrieve an appointment',
        description: 'Fetch one appointment by id.',
        input: { id },
        annotations: annotate.read,
        scope: 'appointments:read',
        handler: (client, { id }) => client.get(`/v1/appointments/${encodeURIComponent(id)}`),
    }),
    defineTool({
        name: 'create_appointment',
        title: 'Create an appointment',
        description: 'Book an appointment against a lead and agent.',
        input: {
            phone_number: e164,
            date_time: isoDate.describe('Start time, ISO 8601 UTC.'),
            agent_id: z.string(),
            lead_id: z.string(),
            client_name: z.string().optional(),
            duration_minutes: z.number().int().min(1).optional(),
            notes: z.string().optional(),
        },
        annotations: annotate.write,
        scope: 'appointments:write',
        handler: (client, args) => client.post('/v1/appointments', compact(args)),
    }),
    defineTool({
        name: 'update_appointment',
        title: 'Update an appointment',
        description: 'Reschedule or annotate an appointment. Only the fields you send are changed.',
        input: {
            id,
            phone_number: e164.optional(),
            date_time: isoDate.optional(),
            agent_id: z.string().optional(),
            lead_id: z.string().optional(),
            client_name: z.string().optional(),
            duration_minutes: z.number().int().min(1).optional(),
            notes: z.string().optional(),
            status: z.enum(['scheduled', 'completed', 'canceled']).optional(),
        },
        annotations: annotate.write,
        scope: 'appointments:write',
        handler: (client, { id, ...rest }) =>
            client.patch(`/v1/appointments/${encodeURIComponent(id)}`, compact(rest)),
    }),
    defineTool({
        name: 'delete_appointment',
        title: 'Delete an appointment',
        description: 'Permanently delete an appointment. To cancel but keep the record, update its status to canceled instead. Not reversible.',
        input: { id },
        annotations: annotate.destructive,
        scope: 'appointments:write',
        handler: async (client, { id }) => {
            await client.delete(`/v1/appointments/${encodeURIComponent(id)}`);
            return { deleted: true, id };
        },
    }),
];
