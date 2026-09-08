import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { Call, CallDetail, CallListQuery, CreateCall, Transcript } from '../types.js';

const enc = encodeURIComponent;

/** Calls: placing, watching and reading them. */
export class Calls {
    constructor(private readonly http: Http) {}

    /**
     * Dial a real number over your SIP trunk and connect an agent. Spends
     * credit. An `Idempotency-Key` is generated unless `opts.idempotencyKey`
     * is given; retrying with the same key returns the original call rather
     * than dialling twice. Refused with `insufficient_credits` when the
     * balance cannot cover it.
     */
    create(body: CreateCall, opts?: RequestOptions): Promise<Call> {
        return this.http.request<Call>('POST', '/v1/calls', { ...opts, body, idempotent: true });
    }

    /** Summary records (no transcript). Filter by status, direction, agent, campaign, engine, number or time window. */
    list(query: CallListQuery = {}, opts?: RequestOptions): Promise<Page<Call>> {
        return this.http.list<Call>('/v1/calls', query, opts);
    }

    /** The full record: transcript, recording, transfers, provider errors, and `failure_code`/`failure_reason` when it did not connect. */
    retrieve(id: string, opts?: RequestOptions): Promise<CallDetail> {
        return this.http.request<CallDetail>('GET', `/v1/calls/${enc(id)}`, opts);
    }

    /** Remove the log, transcript and recording. Usage rows are kept. A live call cannot be deleted. */
    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/calls/${enc(id)}`, opts);
    }

    /** End a call in progress. Billing stops when it ends. */
    hangup(id: string, opts?: RequestOptions): Promise<Call> {
        return this.http.request<Call>('POST', `/v1/calls/${enc(id)}/hangup`, opts);
    }

    transcript(id: string, opts?: RequestOptions): Promise<Transcript> {
        return this.http.request<Transcript>('GET', `/v1/calls/${enc(id)}/transcript`, opts);
    }
}
