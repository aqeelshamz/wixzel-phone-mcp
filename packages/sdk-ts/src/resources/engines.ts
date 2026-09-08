import type { Http, RequestOptions } from '../core/http.js';
import type { EngineList } from '../types.js';

/** Engines: what the platform can serve right now, with prices. */
export class Engines {
    constructor(private readonly http: Http) {}

    /** Use this rather than hardcoding model ids: a degraded provider disappears here before calls start failing. */
    list(opts?: RequestOptions): Promise<EngineList> {
        return this.http.request<EngineList>('GET', '/v1/engines', opts);
    }
}
