import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { CreateSipTrunk, PaginationQuery, SipLogList, SipTrunk, SipTrunkLogsQuery, SipTrunkStatus, SipTrunkTest, UpdateSipTrunk } from '../types.js';

const enc = encodeURIComponent;

/** SIP trunks: your own carrier, connected. */
export class SipTrunks {
    constructor(private readonly http: Http) {}

    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<SipTrunk>> {
        return this.http.list<SipTrunk>('/v1/sip-trunks', query, opts);
    }

    /**
     * Connect a carrier. The password is stored encrypted and never returned.
     * Allowlist the returned `platform_ip` with the carrier for outbound, and
     * point the carrier at `origination_uri` for inbound.
     */
    create(body: CreateSipTrunk, opts?: RequestOptions): Promise<SipTrunk> {
        return this.http.request<SipTrunk>('POST', '/v1/sip-trunks', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<SipTrunk> {
        return this.http.request<SipTrunk>('GET', `/v1/sip-trunks/${enc(id)}`, opts);
    }

    /** Only the fields sent are changed. */
    update(id: string, body: UpdateSipTrunk, opts?: RequestOptions): Promise<SipTrunk> {
        return this.http.request<SipTrunk>('PATCH', `/v1/sip-trunks/${enc(id)}`, { ...opts, body });
    }

    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/sip-trunks/${enc(id)}`, opts);
    }

    /** Asterisk's own view and a live probe, side by side. Free and read-only; start here when calls fail. */
    status(id: string, opts?: RequestOptions): Promise<SipTrunkStatus> {
        return this.http.request<SipTrunkStatus>('GET', `/v1/sip-trunks/${enc(id)}/status`, opts);
    }

    /** Recent SIP events from an in-memory ring buffer. Poll with `since_id` set to the previous `last_id`. */
    logs(id: string, query: SipTrunkLogsQuery = {}, opts?: RequestOptions): Promise<SipLogList> {
        return this.http.request<SipLogList>('GET', `/v1/sip-trunks/${enc(id)}/logs`, { ...opts, query });
    }

    /** Send an unauthenticated probe to the carrier. A negative result is not proof the trunk is broken. */
    test(id: string, opts?: RequestOptions): Promise<SipTrunkTest> {
        return this.http.request<SipTrunkTest>('POST', `/v1/sip-trunks/${enc(id)}/test`, opts);
    }
}
