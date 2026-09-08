import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { CreateAppointment, Appointment, PaginationQuery, UpdateAppointment } from '../types.js';

const enc = encodeURIComponent;

/** Appointments booked by agents or created directly. */
export class Appointments {
    constructor(private readonly http: Http) {}

    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<Appointment>> {
        return this.http.list<Appointment>('/v1/appointments', query, opts);
    }

    create(body: CreateAppointment, opts?: RequestOptions): Promise<Appointment> {
        return this.http.request<Appointment>('POST', '/v1/appointments', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<Appointment> {
        return this.http.request<Appointment>('GET', `/v1/appointments/${enc(id)}`, opts);
    }

    /** Only the fields sent are changed. */
    update(id: string, body: UpdateAppointment, opts?: RequestOptions): Promise<Appointment> {
        return this.http.request<Appointment>('PATCH', `/v1/appointments/${enc(id)}`, { ...opts, body });
    }

    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/appointments/${enc(id)}`, opts);
    }
}
