import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { UsageEvent, UsageEventsQuery, UsageSummary, UsageSummaryQuery } from '../types.js';

/** Usage: every billable line, and the totals. */
export class Usage {
    constructor(private readonly http: Http) {}

    /** Itemised events. Filter by `session_id` to see exactly what one call cost; the sum equals what was debited. */
    events(query: UsageEventsQuery = {}, opts?: RequestOptions): Promise<Page<UsageEvent>> {
        return this.http.list<UsageEvent>('/v1/usage/events', query, opts);
    }

    /** Spend over a period by component, provider and model. Micro-USD: 1,000,000 = $1.00. */
    summary(query: UsageSummaryQuery = {}, opts?: RequestOptions): Promise<UsageSummary> {
        return this.http.request<UsageSummary>('GET', '/v1/usage/summary', { ...opts, query });
    }
}
