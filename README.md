# Wixzel Phone SDKs

Public source for the packages [Wixzel Phone](https://phone.wixzel.com) publishes: AI voice agents that place and answer real phone calls over your own SIP trunk.

| Package | Registry | Source |
|---|---|---|
| `wixzel-phone` | [npm](https://www.npmjs.com/package/wixzel-phone) | [`packages/sdk-ts`](packages/sdk-ts) |
| `wixzel_phone` | [pub.dev](https://pub.dev/packages/wixzel_phone) | [`packages/sdk-dart`](packages/sdk-dart) |
| `wixzel-phone-mcp` | [npm](https://www.npmjs.com/package/wixzel-phone-mcp) | [`apps/mcp`](apps/mcp) |

The two SDKs cover every `/v1` endpoint under one shared method table, page through cursor lists, send idempotency keys on the paths that spend money, retry rate limits honouring `Retry-After`, and raise errors carrying the API's stable `code`, `request_id` and `doc_url`. The MCP server puts the same surface in front of Claude Code, claude.ai and Claude Desktop.

- Documentation: [docs.phone.wixzel.com/sdks](https://docs.phone.wixzel.com/sdks) and [/mcp-server](https://docs.phone.wixzel.com/mcp-server)
- API reference: [docs.phone.wixzel.com/api-reference](https://docs.phone.wixzel.com/api-reference)

## Running the tests

`docs/openapi.json` is the API's own OpenAPI document, copied here because each package's coverage test reads it and asserts that every operation has a method and every method names a real operation.

```bash
npm install
npm test                       # the TypeScript SDK and the MCP server
cd packages/sdk-dart && dart test
```

## About this repository

This is a **mirror**. The packages are developed in the Wixzel Phone monorepo alongside the API they wrap, so that a change to an endpoint and the change to its client land together, and are synced here on release.

Issues and pull requests are welcome and are read. A pull request will be applied upstream and appear here on the next sync rather than merged directly, so it may arrive under a different commit.

## Licence

MIT for everything in this repository. Wixzel Phone itself is a hosted service; see [phone.wixzel.com](https://phone.wixzel.com) for its terms.
