## 0.3.0

Realtime: talk to an agent from a Flutter or Dart app, with no SIP trunk.

- `client.realtime.createSession()` with `CreateRealtimeSession` and
  `RealtimeSession` — server-side. Mints a one-minute, single-use client
  secret for `wss /v1/realtime`.
- `RealtimeConnection` — the protocol client, over `web_socket_channel`:
  `sendAudio`, a typed `events` stream (`RealtimeStarted`, `RealtimeAudio`,
  `RealtimeAudioClear`, `RealtimeTranscript`, `RealtimeWarning`,
  `RealtimeError`, `RealtimeEnded`), `end()` and the close code. Microphone and
  speaker stay with the app; `pcm16ToMulaw` and `mulawToPcm16` convert.
- `Call.channel` (`phone` or `web`).
- New dependency: `web_socket_channel`.

## 0.2.0

Eight operations the published 0.1.0 did not have, which is the whole reason
for a minor rather than a patch: 0.1.0 claimed to cover every `/v1` operation
and, as the API grew, stopped doing so.

- `client.webhooks` — `retrieve`, `update`, `rotateSecret`, `test` and
  `deliveries`, with `WebhookEvent`, `Webhook`, `UpdateWebhook`,
  `WebhookSecret` and `WebhookDelivery`. A singleton, so there is no `list`.
- `client.engines.languages()` and `client.engines.voices()`.
- `client.agents.testCall()`.

## 0.1.0

First release. Every `/v1` operation as a typed method, cursor pagination with `autoPaging()`, automatic idempotency keys on the money paths, retries on rate limits and transient failures, and a `WixzelException` carrying the API's `code`, `requestId` and `docUrl`.
