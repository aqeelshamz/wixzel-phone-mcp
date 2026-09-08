import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { BulkCreateLeads, BulkLeadResult, CreateLead, Lead, LeadListQuery, UpdateLead } from '../types.js';

const enc = encodeURIComponent;

/** Leads: the contacts agents call. */
export class Leads {
    constructor(private readonly http: Http) {}

    list(query: LeadListQuery = {}, opts?: RequestOptions): Promise<Page<Lead>> {
        return this.http.list<Lead>('/v1/leads', query, opts);
    }

    create(body: CreateLead, opts?: RequestOptions): Promise<Lead> {
        return this.http.request<Lead>('POST', '/v1/leads', { ...opts, body });
    }

    /** Up to 1,000 at once. Rows are validated individually; check `failed_count` and `errors`. */
    bulkCreate(body: BulkCreateLeads, opts?: RequestOptions): Promise<BulkLeadResult> {
        return this.http.request<BulkLeadResult>('POST', '/v1/leads/bulk', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<Lead> {
        return this.http.request<Lead>('GET', `/v1/leads/${enc(id)}`, opts);
    }

    /** Only the fields sent are changed. */
    update(id: string, body: UpdateLead, opts?: RequestOptions): Promise<Lead> {
        return this.http.request<Lead>('PATCH', `/v1/leads/${enc(id)}`, { ...opts, body });
    }

    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/leads/${enc(id)}`, opts);
    }
}
