/**
 * The operating guide an agent reads before it touches the account. Served
 * as the server's `instructions`, as a resource, and reused by the prompts,
 * so there is one place to keep it true.
 */

export const GUIDE = `# Wixzel Phone, for AI agents

Wixzel Phone is an API for AI voice agents that make and take real phone calls.
One API key, one prepaid credit balance, every voice engine. https://phone.wixzel.com

## The mental model

- An AGENT is a prompt plus a voice engine (speech-to-text, LLM, text-to-speech,
  or one realtime model that does all three).
- A SIP TRUNK is the user's own carrier account (Twilio, Telnyx, Plivo, Vonage,
  Bandwidth, Exotel, Vobiz, any SIP provider). Wixzel does not sell numbers or
  minutes; the carrier's rates stay theirs.
- A PHONE NUMBER is a number the user owns at that carrier, registered on the trunk.
  Give it an inbound_agent_id and inbound calls are answered by that agent.
- A CALL connects an agent to a real phone over the trunk. Outbound calls are placed
  with place_call; campaigns place one call per lead.
- CREDIT is a dollar balance. Cost accrues per second while a call is live and is
  itemised in usage events. Amounts are micro-USD: 1,000,000 = $1.00.

## The order things go in

1. list_engines: see which models are available right now and what they cost.
   Never guess a model id.
2. create_sip_trunk with the user's carrier credentials, then tell the user to
   allowlist platform_ip with the carrier (outbound) and to point the carrier at
   origination_uri (inbound). check_sip_trunk_status shows whether it is reachable.
3. create_phone_number on that trunk.
4. create_agent with a short spoken-style system_prompt, an opening_message, and a
   voice from step 1. Set outbound_phone_number_id so calls have a caller id.
5. get_balance. Then place_call.
6. get_call to watch status, read the transcript, and see cost_micros. If it did not
   connect, failure_code and failure_reason say why and what to do.

## Money and the real world

place_call, start_campaign and create_topup spend money or make real phones ring.
Confirm with the user before calling them, say what it will do, and never retry one
with a different idempotency_key: the same key returns the original result, a new
key is a second call. create_topup returns a checkout URL that a human must open;
never try to pay.

Delete and revoke tools are permanent. revoke_api_key on the key this server is
using will cut this server off.

## Reading results

- Errors carry a machine-readable code; act on the code and the Hint line.
- Lists are cursor-paginated: pass next_cursor as starting_after until has_more is false.
- 404 means "not on this account", including records owned by someone else.
- The key's scopes decide what works. A permission error names the missing scope;
  the fix is a new key from Dashboard -> API keys, not a retry.

Docs: https://docs.phone.wixzel.com
`;
