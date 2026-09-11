import { z } from 'zod/v4';
import { annotate, compact, defineTool } from '../tooling.js';
import { arbitraryFields } from '../schemas.js';

export const realtimeTools = [
    defineTool({
        name: 'create_realtime_session',
        endpoint: 'POST /v1/realtime/sessions',
        title: 'Create a realtime (browser/app) session',
        description:
            'Mint a one-minute, single-use client secret that lets a web page or app talk to an agent over wss://…/v1/realtime, with no SIP trunk or phone number. ' +
            'Nothing is charged when minting; once a client connects, the session bills at the same per-minute price as a phone call on that engine, counts toward the concurrent-call limit and appears in list_calls with channel "web". ' +
            'Use it to hand the user a working secret for testing their integration, or to explain the flow. The secret belongs in the client; the API key never does. ' +
            'Human transfer is not available on web sessions.',
        input: {
            agent_id: z.string().describe('The agent the user will talk to.'),
            lead_id: z.string().optional().describe('Existing lead to attribute the session to. Merge fields resolve from it.'),
            metadata: arbitraryFields.describe('Echoed on the resulting call and its callCompleted webhook. Not shown to the model.'),
            max_duration_seconds: z.number().int().min(10).max(3600).optional().describe('Hard cap on the conversation. Default 600.'),
            allowed_origins: z.array(z.string()).max(10).optional()
                .describe('Browser origins allowed to open the socket, e.g. "https://app.example.com". Recommended for web use.'),
        },
        // Not `spend`: minting charges nothing and reaches no one. The money
        // moves when a client connects, which this tool does not do.
        annotations: annotate.write,
        scope: 'calls:write',
        handler: (client, args) => client.post('/v1/realtime/sessions', compact(args)),
    }),
];
