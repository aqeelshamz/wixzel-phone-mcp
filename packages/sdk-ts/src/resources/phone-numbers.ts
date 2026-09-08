import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { CreatePhoneNumber, PhoneNumber, PaginationQuery, UpdatePhoneNumber } from '../types.js';

const enc = encodeURIComponent;

/** Phone numbers you own at your carrier, registered on a SIP trunk. */
export class PhoneNumbers {
    constructor(private readonly http: Http) {}

    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<PhoneNumber>> {
        return this.http.list<PhoneNumber>('/v1/phone-numbers', query, opts);
    }

    create(body: CreatePhoneNumber, opts?: RequestOptions): Promise<PhoneNumber> {
        return this.http.request<PhoneNumber>('POST', '/v1/phone-numbers', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<PhoneNumber> {
        return this.http.request<PhoneNumber>('GET', `/v1/phone-numbers/${enc(id)}`, opts);
    }

    /** Only the fields sent are changed. */
    update(id: string, body: UpdatePhoneNumber, opts?: RequestOptions): Promise<PhoneNumber> {
        return this.http.request<PhoneNumber>('PATCH', `/v1/phone-numbers/${enc(id)}`, { ...opts, body });
    }

    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/phone-numbers/${enc(id)}`, opts);
    }
}
