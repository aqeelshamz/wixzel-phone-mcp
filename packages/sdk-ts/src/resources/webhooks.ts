import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type {
    Webhook, UpdateWebhook, WebhookSecret, WebhookDelivery, WebhookDeliveryQuery, TestWebhook,
} from '../types.js';

/**
 * Webhooks: where events are sent, and what happened when they got there.
 *
 * A singleton, not a collection — one endpoint per account — so there is a
 * `retrieve()` and no `list()`. `deliveries()` is the list, and it lists
 * attempts rather than endpoints.
 */
export class Webhooks {
    constructor(private readonly http: Http) {}

    /** The signing secret is never returned; `secret_set` says whether one exists. */
    retrieve(opts?: RequestOptions): Promise<Webhook> {
        return this.http.request<Webhook>('GET', '/v1/webhook', opts);
    }

    /** Only the fields you send change — except `events`, which replaces the subscription. */
    update(body: UpdateWebhook, opts?: RequestOptions): Promise<Webhook> {
        return this.http.request<Webhook>('PATCH', '/v1/webhook', { ...opts, body });
    }

    /**
     * Mint a new signing secret, returned once.
     *
     * The old secret stops verifying immediately, so a receiver that checks
     * signatures rejects events until it has been redeployed with the new one.
     */
    rotateSecret(opts?: RequestOptions): Promise<WebhookSecret> {
        return this.http.request<WebhookSecret>('POST', '/v1/webhook/rotate-secret', opts);
    }

    /**
     * Send one sample event now and get back what the endpoint answered.
     *
     * Ignores `enabled` and the event subscription on purpose: this is how you
     * check an endpoint works before turning delivery on.
     */
    test(body: TestWebhook, opts?: RequestOptions): Promise<WebhookDelivery> {
        return this.http.request<WebhookDelivery>('POST', '/v1/webhook/test', { ...opts, body });
    }

    /**
     * Every POST we made, newest first.
     *
     * One record per attempt, so an event delivered on its third try is three
     * records. A null `response_status` means nothing answered at all.
     */
    deliveries(query: WebhookDeliveryQuery = {}, opts?: RequestOptions): Promise<Page<WebhookDelivery>> {
        return this.http.list<WebhookDelivery>('/v1/webhook/deliveries', query, opts);
    }
}
