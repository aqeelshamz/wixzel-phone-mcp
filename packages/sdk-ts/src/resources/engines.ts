import type { Http, RequestOptions } from '../core/http.js';
import type { EngineLanguageList, EngineList, EngineVoiceList } from '../types.js';

/** Engines: what the platform can serve right now, with prices. */
export class Engines {
    constructor(private readonly http: Http) {}

    /** Use this rather than hardcoding model ids: a degraded provider disappears here before calls start failing. */
    list(opts?: RequestOptions): Promise<EngineList> {
        return this.http.request<EngineList>('GET', '/v1/engines', opts);
    }

    /**
     * Languages an engine can hold a conversation in.
     *
     * A composed engine lists one only when both its speech-to-text and its
     * text-to-speech serve it, so this is the list that holds end to end.
     */
    languages(engine: string, opts?: RequestOptions): Promise<EngineLanguageList> {
        return this.http.request<EngineLanguageList>('GET', `/v1/engines/${encodeURIComponent(engine)}/languages`, opts);
    }

    /**
     * Voices an engine can speak as — the voice the caller hears.
     *
     * `stale: true` means the provider could not be reached and this is the last
     * list that was fetched, which the API prefers to failing the request.
     */
    voices(engine: string, opts?: RequestOptions): Promise<EngineVoiceList> {
        return this.http.request<EngineVoiceList>('GET', `/v1/engines/${encodeURIComponent(engine)}/voices`, opts);
    }
}
