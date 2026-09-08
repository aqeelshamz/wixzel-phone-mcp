import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { Campaign, CreateCampaign, PaginationQuery } from '../types.js';

const enc = encodeURIComponent;

/** Campaigns: one agent calling a list of leads. */
export class Campaigns {
    constructor(private readonly http: Http) {}

    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<Campaign>> {
        return this.http.list<Campaign>('/v1/campaigns', query, opts);
    }

    /** Creating does not dial anyone; call `start()` when ready to spend. */
    create(body: CreateCampaign, opts?: RequestOptions): Promise<Campaign> {
        return this.http.request<Campaign>('POST', '/v1/campaigns', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<Campaign> {
        return this.http.request<Campaign>('GET', `/v1/campaigns/${enc(id)}`, opts);
    }

    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/campaigns/${enc(id)}`, opts);
    }

    /** Begin calling every lead. Spends credit; refused with `insufficient_credits` when the balance cannot cover the run. */
    start(id: string, opts?: RequestOptions): Promise<Campaign> {
        return this.http.request<Campaign>('POST', `/v1/campaigns/${enc(id)}/start`, opts);
    }

    /** Stop placing new calls and hang up any in flight. */
    pause(id: string, opts?: RequestOptions): Promise<Campaign> {
        return this.http.request<Campaign>('POST', `/v1/campaigns/${enc(id)}/pause`, opts);
    }
}
