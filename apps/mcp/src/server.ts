import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { WixzelClient, type WixzelClientOptions } from './client.js';
import { GUIDE } from './guide.js';
import { registerPrompts } from './prompts.js';
import { allTools } from './tools/index.js';
import { registerTools } from './tooling.js';

export const SERVER_NAME = 'wixzel-phone';
export const SERVER_VERSION = '0.2.1';

export interface CreateServerOptions {
    /** An already-constructed client, or the options to build one. */
    client: WixzelClient | WixzelClientOptions;
}

/**
 * Build an MCP server bound to one Wixzel Phone API key. Cheap enough to
 * construct per request in HTTP mode, where the key arrives with each call.
 */
export function createServer(opts: CreateServerOptions): McpServer {
    const client = opts.client instanceof WixzelClient ? opts.client : new WixzelClient(opts.client);

    const server = new McpServer(
        {
            name: SERVER_NAME,
            version: SERVER_VERSION,
            title: 'Wixzel Phone',
            websiteUrl: 'https://phone.wixzel.com',
            // Shown by clients that render a connector icon (claude.ai does).
            icons: [
                { src: 'https://phone.wixzel.com/icon-192.png', mimeType: 'image/png', sizes: ['192x192'] },
                { src: 'https://phone.wixzel.com/icon-512.png', mimeType: 'image/png', sizes: ['512x512'] },
            ],
        },
        {
            instructions: GUIDE,
            capabilities: { tools: {}, prompts: {}, resources: {} },
        },
    );

    registerTools(server, client, allTools);
    registerPrompts(server);

    server.registerResource(
        'guide',
        'wixzel://guide',
        {
            title: 'Wixzel Phone operating guide',
            description: 'How the pieces fit together, the order to set them up in, and which tools spend money.',
            mimeType: 'text/markdown',
        },
        async (uri) => ({
            contents: [{ uri: uri.href, mimeType: 'text/markdown', text: GUIDE }],
        }),
    );

    server.registerResource(
        'connection',
        'wixzel://connection',
        {
            title: 'Current connection',
            description: 'Which API base URL this server talks to and whether the key is live or test. Never includes the key.',
            mimeType: 'application/json',
        },
        async (uri) => ({
            contents: [
                {
                    uri: uri.href,
                    mimeType: 'application/json',
                    text: JSON.stringify(
                        { base_url: client.baseUrl, key_mode: client.keyMode, tools: allTools.length },
                        null,
                        2,
                    ),
                },
            ],
        }),
    );

    return server;
}

export { WixzelClient, WixzelApiError } from './client.js';
export { allTools } from './tools/index.js';
export { GUIDE } from './guide.js';
