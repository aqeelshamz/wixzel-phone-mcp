import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { Agent, Call, CreateAgent, PaginationQuery, TestCall, UpdateAgent } from '../types.js';

const enc = encodeURIComponent;

/** Voice agents: a prompt plus a voice engine. */
export class Agents {
    constructor(private readonly http: Http) {}

    /** List agents, newest first. Iterate the result to walk every page. */
    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<Agent>> {
        return this.http.list<Agent>('/v1/agents', query, opts);
    }

    /** Create an agent. Pick models from `engines.list()`; an unknown model is refused with `unsupported_model`. */
    create(body: CreateAgent, opts?: RequestOptions): Promise<Agent> {
        return this.http.request<Agent>('POST', '/v1/agents', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<Agent> {
        return this.http.request<Agent>('GET', `/v1/agents/${enc(id)}`, opts);
    }

    /** Only the fields sent are changed. Sending `voice` replaces the whole voice object. */
    update(id: string, body: UpdateAgent, opts?: RequestOptions): Promise<Agent> {
        return this.http.request<Agent>('PATCH', `/v1/agents/${enc(id)}`, { ...opts, body });
    }

    /**
     * Ring a number and have the agent speak one phrase, then hang up.
     *
     * A probe, not a conversation — it answers "is the trunk configured and does
     * this agent sound right". It rings a real phone and spends real credit, so
     * an `Idempotency-Key` is generated unless `opts.idempotencyKey` supplies
     * one. Human transfer is not offered during a test call.
     */
    testCall(id: string, body: TestCall, opts?: RequestOptions): Promise<Call> {
        return this.http.request<Call>('POST', `/v1/agents/${enc(id)}/test-call`, { ...opts, body, idempotent: true });
    }

    /** Permanent. Numbers and campaigns pointing at the agent stop working. */
    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/agents/${enc(id)}`, opts);
    }
}
