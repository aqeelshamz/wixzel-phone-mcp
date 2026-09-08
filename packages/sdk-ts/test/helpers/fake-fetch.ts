/**
 * A scripted fetch: records every request, answers from a queue, and falls
 * back to an echo so a test only has to script what it cares about.
 */

export interface Recorded {
    method: string;
    url: URL;
    path: string;
    query: Record<string, string>;
    headers: Record<string, string>;
    body: unknown;
}

export interface Scripted {
    status?: number;
    body?: unknown;
    headers?: Record<string, string>;
    /** Throw this instead of answering (network failure). */
    throws?: Error;
}

export function fakeFetch() {
    const requests: Recorded[] = [];
    const queue: Scripted[] = [];
    let sleeps: number[] = [];

    const fetchImpl = (async (input: string | URL | Request, init?: RequestInit) => {
        const url = new URL(typeof input === 'string' ? input : input instanceof URL ? input.href : input.url);
        const headers: Record<string, string> = {};
        for (const [k, v] of Object.entries((init?.headers as Record<string, string>) ?? {})) headers[k.toLowerCase()] = v;
        requests.push({
            method: init?.method ?? 'GET',
            url,
            path: url.pathname,
            query: Object.fromEntries(url.searchParams.entries()),
            headers,
            body: typeof init?.body === 'string' ? JSON.parse(init.body) : undefined,
        });
        const next = queue.shift() ?? { status: 200, body: { echoed: true, path: url.pathname } };
        if (next.throws) throw next.throws;
        const status = next.status ?? 200;
        if (status === 204) return new Response(null, { status, headers: next.headers });
        const text = typeof next.body === 'string' ? next.body : JSON.stringify(next.body ?? {});
        return new Response(text, {
            status,
            headers: { 'content-type': typeof next.body === 'string' ? 'text/plain' : 'application/json', ...(next.headers ?? {}) },
        });
    }) as typeof fetch;

    const sleep = async (ms: number) => {
        sleeps.push(ms);
    };

    return {
        requests,
        queue,
        fetchImpl,
        sleep,
        get sleeps() {
            return sleeps;
        },
        reset() {
            requests.length = 0;
            queue.length = 0;
            sleeps = [];
        },
        last: () => requests[requests.length - 1]!,
    };
}

export const apiError = (status: number, type: string, code: string, message = 'nope', extra: Record<string, unknown> = {}) => ({
    status,
    body: { error: { type, code, message, request_id: 'req_test', ...extra } },
});
