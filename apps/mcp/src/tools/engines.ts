import { z } from 'zod/v4';
import { annotate, defineTool } from '../tooling.js';

const engineName = {
    engine: z.string().describe('An engine id from list_engines, e.g. "classic", "sarvam", "gemini_live", "deepgram_agent".'),
};

export const engineTools = [
    defineTool({
        name: 'list_engines',
        endpoint: 'GET /v1/engines',
        title: 'List available engines and models',
        description:
            'What the platform can serve right now, with per-unit prices in micro-USD. Each engine is composed (needs stt + llm + tts models) or realtime (one model). ' +
            'Call this before create_agent rather than guessing model ids: an engine whose provider is degraded disappears from this list before calls start failing. ' +
            'No scope needed beyond a valid key.',
        input: {},
        annotations: annotate.read,
        handler: (client) => client.get('/v1/engines'),
    }),
    defineTool({
        name: 'list_engine_languages',
        endpoint: 'GET /v1/engines/{engine}/languages',
        title: "List an engine's languages",
        description:
            'Which languages an engine can hold a conversation in. Call this before create_agent when the user names a language: ' +
            'a composed engine only lists a language when both its speech-to-text and its text-to-speech serve it, so this is the ' +
            'list that is true end to end rather than a guess from the model names. Use a code from here as the agent\'s language ' +
            'or as voice.stt.language / voice.realtime.language. No scope needed beyond a valid key.',
        input: engineName,
        annotations: annotate.read,
        handler: (client, args) => client.get(`/v1/engines/${encodeURIComponent(args.engine)}/languages`),
    }),
    defineTool({
        name: 'list_engine_voices',
        endpoint: 'GET /v1/engines/{engine}/voices',
        title: "List an engine's speaker voices",
        description:
            'The voices an engine can speak as — the voice the caller actually hears. Use an id from here as voice.tts.voice ' +
            '(composed engines) or voice.realtime.voice (realtime engines). Never invent a voice id; an unknown one is rejected. ' +
            'A response with stale: true means the provider could not be reached and this is the last known list. ' +
            'No scope needed beyond a valid key.',
        input: engineName,
        annotations: annotate.read,
        handler: (client, args) => client.get(`/v1/engines/${encodeURIComponent(args.engine)}/voices`),
    }),
];
