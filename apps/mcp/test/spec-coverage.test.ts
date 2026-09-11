import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { allTools } from '../src/tools/index.js';
import { scopes } from '../src/schemas.js';
import { SERVER_VERSION } from '../src/server.js';

/**
 * The tools are hand-written, so this is what keeps them honest: every
 * operation in the committed OpenAPI document has a tool, every tool names a
 * real operation, and the scope enum matches the API's.
 */
const here = dirname(fileURLToPath(import.meta.url));
const pkg = JSON.parse(readFileSync(resolve(here, '../package.json'), 'utf8')) as { version: string };
const spec = JSON.parse(readFileSync(resolve(here, '../../../docs/openapi.json'), 'utf8')) as {
    paths: Record<string, Record<string, unknown>>;
    components: { schemas: { CreateApiKey: { properties: { scopes: { items: { enum: string[] } } } } } };
};

describe('spec coverage', () => {
    test('every OpenAPI operation has exactly one tool, and every tool names a real operation', () => {
        const operations = new Set<string>();
        for (const [path, methods] of Object.entries(spec.paths)) {
            for (const method of Object.keys(methods)) operations.add(`${method.toUpperCase()} ${path}`);
        }
        const endpoints = allTools.map((t) => t.endpoint);

        const missing = [...operations].filter((op) => !endpoints.includes(op));
        const phantom = endpoints.filter((ep) => !operations.has(ep));
        const duplicates = endpoints.filter((ep, i) => endpoints.indexOf(ep) !== i);

        assert.deepEqual(missing, [], `operations in docs/openapi.json with no tool: ${missing.join(', ')}`);
        assert.deepEqual(phantom, [], `tools naming an endpoint the spec does not have: ${phantom.join(', ')}`);
        assert.deepEqual(duplicates, [], `two tools claim the same endpoint: ${duplicates.join(', ')}`);
        assert.equal(allTools.length, operations.size);
    });

    test('each tool actually calls the endpoint it claims', () => {
        for (const tool of allTools) {
            const [method, path] = tool.endpoint.split(' ') as [string, string];
            const source = tool.handler.toString();
            assert.match(source, new RegExp(`client\\.${method.toLowerCase()}\\(`), `${tool.name} should call client.${method.toLowerCase()}`);
            const staticPrefix = path.split('{')[0]!.replace(/\/$/, '');
            assert.ok(source.includes(staticPrefix), `${tool.name} should reference ${staticPrefix}`);
        }
    });

    test('the scope list matches the API\'s enum exactly', () => {
        assert.deepEqual([...scopes], spec.components.schemas.CreateApiKey.properties.scopes.items.enum);
    });

    /**
     * The version the server announces is a hand-typed constant, so nothing
     * kept it in step with package.json — and it drifted: 0.2.2 shipped to npm
     * announcing itself as 0.2.1 in the MCP handshake and on /health, which is
     * the one place a client looks to find out what it is talking to.
     */
    test('the announced version matches package.json', () => {
        assert.equal(SERVER_VERSION, pkg.version);
    });
});
