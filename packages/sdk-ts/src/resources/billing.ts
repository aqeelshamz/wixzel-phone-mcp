import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { Balance, CreateTopup, LedgerEntry, PaginationQuery, Topup } from '../types.js';

/** Billing: the prepaid balance, its history, and adding to it. */
export class Billing {
    constructor(private readonly http: Http) {}

    /** `balance_micros`, `held_micros` (reserved by live calls) and `available_micros`. */
    balance(opts?: RequestOptions): Promise<Balance> {
        return this.http.request<Balance>('GET', '/v1/billing/balance', opts);
    }

    /** Every movement on the account. Balances reconcile exactly. */
    ledger(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<LedgerEntry>> {
        return this.http.list<LedgerEntry>('/v1/billing/ledger', query, opts);
    }

    /**
     * Start a top-up. Returns a `checkout_url` a person must open; credit
     * lands once payment settles. An `Idempotency-Key` is generated unless
     * `opts.idempotencyKey` is given.
     */
    createTopup(body: CreateTopup, opts?: RequestOptions): Promise<Topup> {
        return this.http.request<Topup>('POST', '/v1/billing/topups', { ...opts, body, idempotent: true });
    }
}
