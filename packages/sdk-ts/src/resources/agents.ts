import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { Agent, CreateAgent, PaginationQuery, UpdateAgent } from '../types.js';

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

    /** Permanent. Numbers and campaigns pointing at the agent stop working. */
    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/agents/${enc(id)}`, opts);
    }
}
