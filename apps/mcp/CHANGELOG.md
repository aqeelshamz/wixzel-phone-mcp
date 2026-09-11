# Changelog

## 0.3.0

`create_realtime_session`: mint a one-minute, single-use client secret so a
web page or app can talk to an agent over `wss /v1/realtime`, with no SIP
trunk. Annotated as a write, not a spend — minting charges nothing; the
session bills when a client connects. 65 tools.

## 0.2.2

Five webhook tools: `get_webhook`, `update_webhook`, `rotate_webhook_secret`,
`test_webhook` and `list_webhook_deliveries`. The `webhooks:read` and
`webhooks:write` scopes were already in the scope list and reached nothing;
they now reach a real resource. 64 tools.

`test_webhook` is annotated as reaching the outside world — it POSTs to a
third-party endpoint — but it spends no credit.

## 0.2.1

Point `repository` at the public mirror, github.com/aqeelshamz/wixzel-phone-sdks. The 0.2.0 metadata named the private monorepo, so the link on the npm page did not resolve. No code changes.

## 0.2.0

Moved into the monorepo, added Streamable HTTP mode with OAuth discovery, protected-resource metadata and a token probe.

## 0.1.0

First release: 56 tools, three prompts, two resources, over stdio.
