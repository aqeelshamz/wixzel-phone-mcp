import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { ApiKey, CreateApiKey, CreatedApiKey, PaginationQuery } from '../types.js';

const enc = encodeURIComponent;

/** API keys: scoped credentials. Secrets are returned once, at creation and rotation. */
export class ApiKeys {
    constructor(private readonly http: Http) {}

    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<ApiKey>> {
        return this.http.list<ApiKey>('/v1/api-keys', query, opts);
    }

    /** The `key` in the result is shown once and cannot be retrieved again. A key cannot grant scopes the calling key lacks. */
    create(body: CreateApiKey, opts?: RequestOptions): Promise<CreatedApiKey> {
        return this.http.request<CreatedApiKey>('POST', '/v1/api-keys', { ...opts, body });
    }

    /** Immediate, with no grace period. */
    revoke(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/api-keys/${enc(id)}`, opts);
    }

    /** A replacement is issued now; the old key keeps working for 24 hours. */
    rotate(id: string, opts?: RequestOptions): Promise<CreatedApiKey> {
        return this.http.request<CreatedApiKey>('POST', `/v1/api-keys/${enc(id)}/rotate`, opts);
    }
}
