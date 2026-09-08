#!/usr/bin/env node
/**
 * wixzel-phone-mcp
 *
 *   wixzel-phone-mcp                 stdio transport, key from WIXZEL_API_KEY
 *   wixzel-phone-mcp --http [port]   Streamable HTTP on /mcp, key from each
 *                                    request's Authorization: Bearer header
 *                                    (falls back to WIXZEL_API_KEY when unset)
 *
 * Environment:
 *   WIXZEL_API_KEY        wv_live_… or wv_test_… (required for stdio)
 *   WIXZEL_API_BASE_URL   default https://api.phone.wixzel.com
 *   WIXZEL_API_VERSION    optional Wixzel-Version date pin
 *   PORT                  HTTP port when --http is given without one (default 3939)
 */

import { createServer as createHttpServer, type IncomingMessage, type ServerResponse } from 'node:http';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import { DEFAULT_BASE_URL, type WixzelClientOptions } from './client.js';
import { createServer, SERVER_VERSION } from './server.js';

const HELP = `wixzel-phone-mcp ${SERVER_VERSION}

Usage:
  wixzel-phone-mcp                Run over stdio (for Claude Code, Claude Desktop, Cursor…)
  wixzel-phone-mcp --http [port]  Run a Streamable HTTP server on http://localhost:<port>/mcp
  wixzel-phone-mcp --help

Environment:
  WIXZEL_API_KEY       Your API key. Required for stdio; the HTTP fallback when a request has no bearer.
  WIXZEL_API_BASE_URL  Defaults to ${DEFAULT_BASE_URL}
  WIXZEL_API_VERSION   Optional Wixzel-Version date pin, e.g. 2026-09-01
`;

function baseClientOptions(apiKey: string): WixzelClientOptions {
    return {
        apiKey,
        baseUrl: process.env.WIXZEL_API_BASE_URL || undefined,
        apiVersion: process.env.WIXZEL_API_VERSION || undefined,
    };
}

async function runStdio(): Promise<void> {
    const apiKey = process.env.WIXZEL_API_KEY;
    if (!apiKey) {
        process.stderr.write(
            'wixzel-phone-mcp: WIXZEL_API_KEY is not set.\n' +
                'Create a key at https://phone.wixzel.com (Dashboard → API keys) and pass it as an environment variable.\n',
        );
        process.exit(1);
    }
    const server = createServer({ client: baseClientOptions(apiKey) });
    const transport = new StdioServerTransport();
    await server.connect(transport);
    // stdout is the protocol channel; everything human goes to stderr.
    process.stderr.write(`wixzel-phone-mcp ${SERVER_VERSION} ready on stdio (${apiKey.slice(0, 8)}…)\n`);
}

function bearerFrom(req: IncomingMessage): string | undefined {
    const header = req.headers.authorization;
    if (!header) return undefined;
    const match = /^Bearer\s+(.+)$/i.exec(header);
    return match?.[1]?.trim() || undefined;
}

async function runHttp(port: number): Promise<void> {
    const fallbackKey = process.env.WIXZEL_API_KEY;

    const http = createHttpServer(async (req: IncomingMessage, res: ServerResponse) => {
        const url = new URL(req.url ?? '/', 'http://localhost');
        if (url.pathname === '/healthz') {
            res.writeHead(200, { 'content-type': 'application/json' });
            res.end(JSON.stringify({ ok: true, name: 'wixzel-phone-mcp', version: SERVER_VERSION }));
            return;
        }
        if (url.pathname !== '/mcp') {
            res.writeHead(404, { 'content-type': 'application/json' });
            res.end(JSON.stringify({ error: 'not_found', message: 'MCP is served at /mcp' }));
            return;
        }

        const apiKey = bearerFrom(req) ?? fallbackKey;
        if (!apiKey) {
            res.writeHead(401, {
                'content-type': 'application/json',
                'www-authenticate': 'Bearer realm="wixzel-phone-mcp"',
            });
            res.end(
                JSON.stringify({
                    error: 'missing_api_key',
                    message: 'Send your Wixzel Phone API key as "Authorization: Bearer wv_live_…".',
                }),
            );
            return;
        }

        // Stateless: one server and transport per request, bound to the key
        // that arrived with it. No session table, nothing to leak between users.
        const server = createServer({ client: baseClientOptions(apiKey) });
        const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined });
        res.on('close', () => {
            void transport.close();
            void server.close();
        });
        try {
            await server.connect(transport);
            await transport.handleRequest(req, res);
        } catch (error) {
            process.stderr.write(`wixzel-phone-mcp: request failed: ${(error as Error).message}\n`);
            if (!res.headersSent) {
                res.writeHead(500, { 'content-type': 'application/json' });
                res.end(JSON.stringify({ error: 'internal_error' }));
            }
        }
    });

    await new Promise<void>((resolve) => http.listen(port, resolve));
    process.stderr.write(
        `wixzel-phone-mcp ${SERVER_VERSION} listening on http://localhost:${port}/mcp` +
            (fallbackKey ? ' (WIXZEL_API_KEY fallback set)' : ' (bearer required per request)') +
            '\n',
    );
}

async function main(): Promise<void> {
    const args = process.argv.slice(2);
    if (args.includes('--help') || args.includes('-h')) {
        process.stdout.write(HELP);
        return;
    }
    if (args.includes('--version') || args.includes('-v')) {
        process.stdout.write(`${SERVER_VERSION}\n`);
        return;
    }
    const httpIndex = args.indexOf('--http');
    if (httpIndex !== -1) {
        const explicit = args[httpIndex + 1];
        const port = explicit && /^\d+$/.test(explicit) ? Number(explicit) : Number(process.env.PORT) || 3939;
        await runHttp(port);
        return;
    }
    await runStdio();
}

main().catch((error) => {
    process.stderr.write(`wixzel-phone-mcp: ${(error as Error).stack ?? error}\n`);
    process.exit(1);
});
