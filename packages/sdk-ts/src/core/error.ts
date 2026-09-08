import type { ApiErrorBody, ErrorType } from '../types.js';

/**
 * A failure the API answered. Match on `code`, never on `message`: the docs
 * promise the code is stable and the message may be reworded.
 *
 *   try { await client.calls.create(...) }
 *   catch (err) {
 *     if (WixzelError.is(err) && err.is('insufficient_credits')) topUp(err.balance);
 *   }
 */
export class WixzelError extends Error {
    readonly status: number;
    /** One of the eight documented types, or whatever the server sent. */
    readonly type: ErrorType | string;
    /** Stable machine-readable code, e.g. `agent_not_found`. */
    readonly code: string;
    /** Which field caused the failure, when the server says. */
    readonly param: string | null;
    /** Quote this when asking for help. */
    readonly requestId: string | null;
    /** Where the code is documented, when the server says. */
    readonly docUrl: string | null;
    /** Seconds to wait, from `Retry-After` on a 429. */
    readonly retryAfter: number | null;
    /** The `X-Wixzel-Balance` header on `insufficient_credits`, as sent. */
    readonly balance: string | null;
    readonly headers: Headers;

    constructor(status: number, body: Partial<ApiErrorBody>, headers: Headers) {
        super(body.message ?? `HTTP ${status}`);
        this.name = 'WixzelError';
        this.status = status;
        this.type = body.type ?? (status >= 500 ? 'api_error' : 'invalid_request_error');
        this.code = body.code ?? `http_${status}`;
        this.param = body.param ?? null;
        this.requestId = body.request_id ?? null;
        this.docUrl = body.doc_url ?? null;
        const retryAfter = headers.get('retry-after');
        this.retryAfter = retryAfter !== null && Number.isFinite(Number(retryAfter)) ? Number(retryAfter) : null;
        this.balance = headers.get('x-wixzel-balance');
        this.headers = headers;
    }

    /** Narrow an unknown catch value. */
    static is(err: unknown): err is WixzelError {
        return err instanceof WixzelError;
    }

    /** `err.is('insufficient_credits')` reads better than comparing strings. */
    is(code: string): boolean {
        return this.code === code;
    }
}

/**
 * The request never got an answer: a network failure or a timeout, after
 * every retry the policy allowed. Whether the server acted is unknown; for a
 * request that carried an idempotency key, retrying with the same key is safe.
 */
export class WixzelConnectionError extends Error {
    override readonly cause: unknown;

    constructor(message: string, cause: unknown) {
        super(message);
        this.name = 'WixzelConnectionError';
        this.cause = cause;
    }
}
