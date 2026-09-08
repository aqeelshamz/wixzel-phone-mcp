# wixzel-phone-mcp

**Wixzel Phone for AI agents.** A [Model Context Protocol](https://modelcontextprotocol.io) server that lets Claude Code, Claude Desktop, Cursor, and any other MCP client create voice agents, connect a carrier, place calls, run campaigns, and read what it all cost, using the [Wixzel Phone](https://phone.wixzel.com) API.

> Wixzel Phone: APIs for AI voice agents. One API key, one balance, every voice engine.

One tool per API operation, 56 in all, each annotated so a client knows which are read-only, which delete, and which **spend money or make a real phone ring**. Three prompts (`quickstart`, `diagnose_call`, `spend_report`) package the common workflows.

## Install

You need a Wixzel Phone API key: **Dashboard → API keys → Create key** at [phone.wixzel.com](https://phone.wixzel.com). Grant only the scopes the agent should have. Leave out `billing:write` unless you want it to be able to start top-ups.

### Claude Code

```bash
claude mcp add wixzel-phone -e WIXZEL_API_KEY=wv_live_... -- npx -y wixzel-phone-mcp
```

Or commit a `.mcp.json` to the project so every collaborator gets it:

```json
{
  "mcpServers": {
    "wixzel-phone": {
      "command": "npx",
      "args": ["-y", "wixzel-phone-mcp"],
      "env": { "WIXZEL_API_KEY": "${WIXZEL_API_KEY}" }
    }
  }
}
```

Then, in Claude Code:

```
/mcp__wixzel-phone__quickstart
```

### Claude Desktop

Add to `claude_desktop_config.json` (Settings → Developer → Edit Config):

```json
{
  "mcpServers": {
    "wixzel-phone": {
      "command": "npx",
      "args": ["-y", "wixzel-phone-mcp"],
      "env": { "WIXZEL_API_KEY": "wv_live_..." }
    }
  }
}
```

### Cursor, Windsurf, VS Code, others

Same shape: command `npx`, args `["-y", "wixzel-phone-mcp"]`, env `WIXZEL_API_KEY`. Any client that speaks MCP over stdio works.

### Remote (Streamable HTTP)

For clients that connect over HTTP, or to host one server for a team:

```bash
npx wixzel-phone-mcp --http 3939
```

The server listens on `http://localhost:3939/mcp`. Each request carries the caller's own key as `Authorization: Bearer wv_live_...`; the server is stateless and never mixes keys between requests. Set `WIXZEL_API_KEY` to provide a fallback key for requests that send none. `GET /healthz` reports liveness.

## What the agent can do

| Family | Tools |
|---|---|
| Engines | `list_engines` |
| Agents | `list_agents` `get_agent` `create_agent` `update_agent` `delete_agent` |
| Calls | `place_call` `list_calls` `get_call` `get_call_transcript` `hangup_call` `delete_call` |
| SIP trunks | `list_sip_trunks` `get_sip_trunk` `create_sip_trunk` `update_sip_trunk` `delete_sip_trunk` `check_sip_trunk_status` `test_sip_trunk` `get_sip_trunk_logs` |
| Phone numbers | `list_phone_numbers` `get_phone_number` `create_phone_number` `update_phone_number` `delete_phone_number` |
| Leads | `list_leads` `get_lead` `create_lead` `update_lead` `delete_lead` `import_leads` |
| Campaigns | `list_campaigns` `get_campaign` `create_campaign` `start_campaign` `pause_campaign` `delete_campaign` |
| Knowledge bases | `list_knowledge_bases` `get_knowledge_base` `create_knowledge_base` `update_knowledge_base` `delete_knowledge_base` |
| Appointments | `list_appointments` `get_appointment` `create_appointment` `update_appointment` `delete_appointment` |
| Billing & usage | `get_balance` `list_ledger_entries` `create_topup` `get_usage_summary` `list_usage_events` |
| API keys | `list_api_keys` `create_api_key` `rotate_api_key` `revoke_api_key` |

Prompts: `quickstart` (connect a carrier, register a number, build an agent, place a first call), `diagnose_call` (why did call X fail), `spend_report` (what did this month cost, and where).

Resources: `wixzel://guide` (the operating guide the server also sends as its instructions) and `wixzel://connection` (base URL and whether the key is live or test; never the key itself).

## How it keeps the agent honest

- **Money is explicit.** `place_call`, `start_campaign` and `create_topup` are annotated `openWorldHint: true` and their descriptions tell the model to confirm with the user first. Clients that gate on annotations will ask before running them.
- **Idempotency is automatic.** The two money paths require an `Idempotency-Key`; the server generates one per call and accepts an explicit `idempotency_key` for deliberate retries, so a network timeout never turns into two calls.
- **Errors are actionable.** Every failure returns the API's machine-readable `code`, the `request_id`, and a hint that says what to do: which scope is missing, that the balance is short, that a cursor was mangled.
- **Rate limits are absorbed.** A `429` is retried after `Retry-After` up to twice before the model sees it. Those requests are never charged.
- **Scopes do the gating.** The key decides what works. There is no admin scope, and a key cannot create one broader than itself.
- **Secrets stay put.** SIP passwords are write-only; API key secrets appear once, in the tool result, and nowhere else. The key this server runs with is never exposed through any tool or resource.

## Configuration

| Variable | Purpose |
|---|---|
| `WIXZEL_API_KEY` | Your key. Required for stdio; the fallback for HTTP. |
| `WIXZEL_API_BASE_URL` | Defaults to `https://api.phone.wixzel.com`. Point at a self-hosted API for development. |
| `WIXZEL_API_VERSION` | Optional `Wixzel-Version` date pin, e.g. `2026-09-01`. |
| `PORT` | HTTP port when `--http` is given without one. Default 3939. |

## Development

```bash
npm install
npm test          # offline: a fake API behind an in-memory MCP client
npm run build     # dist/
npm run inspect   # opens the MCP Inspector against the built server
```

Run the built server against a real key:

```bash
WIXZEL_API_KEY=wv_test_... node dist/index.js
```

Tool schemas are hand-written zod, derived from the API's OpenAPI spec at `docs/openapi.json` in the [wixzel-voice](https://github.com/aqeelshamz/wixzel-voice) repository. When an endpoint is added there, add a tool in `src/tools/`.

## License

MIT. Wixzel Phone itself is a hosted service; see [phone.wixzel.com](https://phone.wixzel.com) for terms.
