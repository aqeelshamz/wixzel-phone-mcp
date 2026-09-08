import { annotate, defineTool } from '../tooling.js';

export const engineTools = [
    defineTool({
        name: 'list_engines',
        title: 'List available engines and models',
        description:
            'What the platform can serve right now, with per-unit prices in micro-USD. Each engine is composed (needs stt + llm + tts models) or realtime (one model). ' +
            'Call this before create_agent rather than guessing model ids: an engine whose provider is degraded disappears from this list before calls start failing. ' +
            'No scope needed beyond a valid key.',
        input: {},
        annotations: annotate.read,
        handler: (client) => client.get('/v1/engines'),
    }),
];
