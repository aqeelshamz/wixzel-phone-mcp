/**
 * zod shapes shared across tools. Kept loose on purpose where the API already
 * gives a better error than a client could — the mutually-exclusive voice
 * rule, for instance, is enforced server-side with a message that names the
 * block to delete.
 */

import { z } from 'zod';

export const id = z.string().min(1).describe('The record id, e.g. "6a96a3ead6e886d42462dd3e".');

export const pagination = {
    limit: z.number().int().min(1).max(100).optional().describe('Page size, 1–100. Default 20.'),
    starting_after: z
        .string()
        .optional()
        .describe('Cursor from a previous response\'s next_cursor. Fetches the page after it.'),
    ending_before: z
        .string()
        .optional()
        .describe('Cursor from a previous response. Fetches the page before it. Not with starting_after.'),
};

export const isoDate = z
    .string()
    .describe('ISO 8601 timestamp, UTC, e.g. "2026-09-01T12:00:00.000Z".');

export const e164 = z
    .string()
    .min(3)
    .describe('Phone number in E.164 form, e.g. "+14155551234".');

const providerModel = z
    .string()
    .regex(/^[a-z0-9_-]+\/[a-zA-Z0-9._-]+$/, 'must be "provider/model", e.g. deepgram/nova-3')
    .describe('"provider/model", e.g. "deepgram/nova-3". Call list_engines for what is available and priced.');

export const sttConfig = z.object({
    model: providerModel,
    language: z.string().optional().describe('BCP-47 tag, or "multi" for automatic detection. Default en-US.'),
    endpointing_ms: z
        .number()
        .int()
        .min(50)
        .max(3000)
        .optional()
        .describe('Silence before a turn is considered finished. Lower is snappier and more prone to cutting people off.'),
});

export const llmConfig = z.object({
    model: providerModel,
    temperature: z.number().min(0).max(2).optional(),
    max_tokens: z
        .number()
        .int()
        .min(1)
        .max(4096)
        .optional()
        .describe('Caps reply length. Long replies cost the caller waiting time as well as money.'),
});

export const ttsConfig = z.object({
    model: providerModel,
    voice: z.string().optional().describe('Provider voice id, e.g. an ElevenLabs voice id.'),
    stability: z.number().min(0).max(1).optional(),
    similarity_boost: z.number().min(0).max(1).optional(),
    speed: z.number().min(0.5).max(2).optional(),
});

export const realtimeConfig = z.object({
    model: providerModel.describe('A realtime model, e.g. "google/gemini-live-2.5-flash".'),
    voice: z.string().optional().describe('Provider voice name, e.g. "Charon".'),
    language: z.string().optional().describe('Default "auto".'),
});

export const turnTaking = z.object({
    interrupt_sensitivity: z
        .enum(['low', 'normal', 'high'])
        .optional()
        .describe('How readily the agent stops talking when the caller speaks. Default normal.'),
    silence_wait_ms: z.number().int().min(100).max(5000).optional(),
});

export const voiceConfig = z
    .object({
        stt: sttConfig.optional(),
        llm: llmConfig.optional(),
        tts: ttsConfig.optional(),
        realtime: realtimeConfig.optional(),
        turn_taking: turnTaking.optional(),
    })
    .describe(
        'Either a COMPOSED pipeline {stt, llm, tts} (all three required together) or a single REALTIME model {realtime}. Never both. Use list_engines to pick models that are available right now.',
    );

export const scopes = [
    'agents:read',
    'agents:write',
    'calls:read',
    'calls:write',
    'leads:read',
    'leads:write',
    'campaigns:read',
    'campaigns:write',
    'knowledge_bases:read',
    'knowledge_bases:write',
    'phone_numbers:read',
    'phone_numbers:write',
    'sip_trunks:read',
    'sip_trunks:write',
    'appointments:read',
    'appointments:write',
    'webhooks:read',
    'webhooks:write',
    'api_keys:read',
    'api_keys:write',
    'usage:read',
    'billing:read',
    'billing:write',
] as const;

export const scope = z.enum(scopes);

export const arbitraryFields = z
    .record(z.string(), z.unknown())
    .optional()
    .describe('Arbitrary key/value data.');

export const idempotencyKey = z
    .string()
    .max(255)
    .optional()
    .describe(
        'Idempotency-Key for safe retries. Generated automatically when omitted. Reuse the SAME value when retrying the SAME logical request; never reuse it for a different one.',
    );
