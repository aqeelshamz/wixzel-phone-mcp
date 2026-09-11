import { test, describe, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StreamableHTTPClientTransport } from '@modelcontextprotocol/sdk/client/streamableHttp.js';
import { resolveHttpOptions, resourceMetadataUrl, startHttp, type RunningHttpServer } from '../src/http.js';
import { allTools } from '../src/tools/index.js';

/**
 * A fake Wixzel Phone API behind the MCP host. Keys starting with "good" are
 * accepted; anything else is a 401, which is what a revoked key looks like.
 */
function fakeApi() {
    const seen: string[] = [];
    const fetchImpl: typeof fetch = async (input, init) => {
        const url = new URL(typeof input === 'string' ? input : input instanceof URL ? input.href : input.url);
        const auth = String((init?.headers as Record<string, string>)?.Authorization ?? '');
        seen.push(`${init?.method ?? 'GET'} ${url.pathname} ${auth}`);
        if (!auth.startsWith('Bearer good')) {
            return new Response(JSON.stringify({ error: { type: 'authentication_error', code: 'invalid_api_key', message: 'no' } }), {
                status: 401, headers: { 'content-type': 'application/json' },
            });
        }
        return new Response(JSON.stringify({ object: 'list', data: [{ id: 'composed', kind: 'composed' }] }), {
            status: 200, headers: { 'content-type': 'application/json' },
        });
    };
    return { seen, fetchImpl };
}

describe('HTTP mode', () => {
    const api = fakeApi();
    let running: RunningHttpServer;
    let base: string;

    before(async () => {
        running = await startHttp({
            port: 0,
            bind: '127.0.0.1',
            publicUrl: 'https://mcp.example.test/mcp',
            apiBaseUrl: 'https://api.example.test',
            fetch: api.fetchImpl,
            log: () => { },
        });
        base = `http://127.0.0.1:${running.port}`;
    });

    after(async () => {
        await running.close();
    });

    test('serves protected-resource metadata at both RFC 9728 paths', async () => {
        for (const path of ['/.well-known/oauth-protected-resource', '/.well-known/oauth-protected-resource/mcp']) {
            const res = await fetch(base + path);
            assert.equal(res.status, 200);
            const body = await res.json();
            assert.equal(body.resource, 'https://mcp.example.test/mcp');
            assert.deepEqual(body.authorization_servers, ['https://api.example.test']);
            assert.ok(body.scopes_supported.includes('agents:read'));
            assert.equal(res.headers.get('access-control-allow-origin'), '*');
        }
        assert.equal(resourceMetadataUrl('https://mcp.example.test/mcp'), 'https://mcp.example.test/.well-known/oauth-protected-resource/mcp');
        assert.equal(resourceMetadataUrl('https://mcp.example.test'), 'https://mcp.example.test/.well-known/oauth-protected-resource');
    });

    test('answers OPTIONS preflight with CORS headers and no body', async () => {
        const res = await fetch(`${base}/mcp`, { method: 'OPTIONS' });
        assert.equal(res.status, 204);
        assert.match(res.headers.get('access-control-allow-headers') ?? '', /Authorization/);
        assert.match(res.headers.get('access-control-expose-headers') ?? '', /WWW-Authenticate/);
    });

    test('a request without a bearer gets a 401 that points at the metadata', async () => {
        const res = await fetch(`${base}/mcp`, { method: 'POST', body: '{}', headers: { 'content-type': 'application/json' } });
        assert.equal(res.status, 401);
        const challenge = res.headers.get('www-authenticate') ?? '';
        assert.match(challenge, /^Bearer realm="wixzel-phone-mcp"/);
        assert.match(challenge, /resource_metadata="https:\/\/mcp\.example\.test\/\.well-known\/oauth-protected-resource\/mcp"/);
        assert.doesNotMatch(challenge, /error=/);
    });

    test('a bearer the API rejects gets a 401 with error="invalid_token"', async () => {
        const res = await fetch(`${base}/mcp`, {
            method: 'POST', body: '{}',
            headers: { 'content-type': 'application/json', Authorization: 'Bearer wv_live_revoked' },
        });
        assert.equal(res.status, 401);
        assert.match(res.headers.get('www-authenticate') ?? '', /error="invalid_token"/);
        assert.ok(api.seen.some((s) => s.startsWith('GET /v1/engines Bearer wv_live_revoked')), 'the key was probed against the API');
    });

    test('an accepted bearer reaches the MCP server and can list tools', async () => {
        const transport = new StreamableHTTPClientTransport(new URL(`${base}/mcp`), {
            requestInit: { headers: { Authorization: 'Bearer good_key_1' } },
        });
        const client = new Client({ name: 'http-test', version: '0' });
        await client.connect(transport);
        const { tools } = await client.listTools();
        // Against the registry, not a literal: the invariant is that the HTTP
        // host exposes every registered tool, and a hardcoded count only ever
        // fails later, in an unrelated change, for a reason nobody remembers.
        assert.equal(tools.length, allTools.length);

        const engines = await client.callTool({ name: 'list_engines', arguments: {} });
        assert.equal(engines.isError, undefined);
        const text = (engines.content as Array<{ text: string }>)[0]!.text;
        assert.match(text, /"composed"/);
        await client.close();

        // The probe is cached: one /v1/engines probe per key, not one per request.
        const probes = api.seen.filter((s) => s === 'GET /v1/engines Bearer good_key_1').length;
        assert.ok(probes >= 1 && probes <= 2, `expected the probe to be cached, saw ${probes}`);
    });

    test('the bare host serves a landing page that declares the icon', async () => {
        const res = await fetch(`${base}/`);
        assert.equal(res.status, 200);
        assert.match(res.headers.get('content-type') ?? '', /text\/html/);
        const html = await res.text();
        assert.match(html, /rel="icon" href="\/favicon.ico"/);
        assert.match(html, /Model Context Protocol at <code>\/mcp<\/code>/);
    });

    test('unknown paths are 404 and /healthz is alive', async () => {
        assert.equal((await fetch(`${base}/nope`)).status, 404);
        const health = await fetch(`${base}/healthz`);
        assert.equal(health.status, 200);
        assert.equal((await health.json()).ok, true);
    });
});

describe('resolveHttpOptions', () => {
    test('defaults to loopback on 3939 with a localhost public URL', () => {
        const opts = resolveHttpOptions({});
        assert.equal(opts.port, 3939);
        assert.equal(opts.bind, '127.0.0.1');
        assert.equal(opts.publicUrl, 'http://localhost:3939/mcp');
        assert.equal(opts.apiBaseUrl, 'https://api.phone.wixzel.com');
    });

    test('reads MCP_* and never the API\'s PORT', () => {
        const opts = resolveHttpOptions({ MCP_PORT: '5102', MCP_BIND: '0.0.0.0', MCP_PUBLIC_URL: 'https://mcp.x.test/mcp/', PORT: '5101' });
        assert.equal(opts.port, 5102);
        assert.equal(opts.bind, '0.0.0.0');
        assert.equal(opts.publicUrl, 'https://mcp.x.test/mcp');
        assert.equal(resolveHttpOptions({ MCP_PORT: '5102' }, 4000).port, 4000, 'the CLI port wins');
    });

    test('refuses a fallback key on a public host', () => {
        assert.throws(
            () => resolveHttpOptions({ WIXZEL_API_KEY: 'wv_live_x', MCP_PUBLIC_URL: 'https://mcp.x.test/mcp' }),
            /fallback key on a public host/,
        );
        assert.equal(resolveHttpOptions({ WIXZEL_API_KEY: 'wv_live_x' }).fallbackKey, 'wv_live_x');
    });
});
