import type { Http, RequestOptions } from '../core/http.js';
import type { Page } from '../core/page.js';
import type { CreateKnowledgeBase, KnowledgeBase, PaginationQuery, UpdateKnowledgeBase } from '../types.js';

const enc = encodeURIComponent;

/** Knowledge bases: facts and FAQs an agent can draw on. */
export class KnowledgeBases {
    constructor(private readonly http: Http) {}

    list(query: PaginationQuery = {}, opts?: RequestOptions): Promise<Page<KnowledgeBase>> {
        return this.http.list<KnowledgeBase>('/v1/knowledge-bases', query, opts);
    }

    create(body: CreateKnowledgeBase, opts?: RequestOptions): Promise<KnowledgeBase> {
        return this.http.request<KnowledgeBase>('POST', '/v1/knowledge-bases', { ...opts, body });
    }

    retrieve(id: string, opts?: RequestOptions): Promise<KnowledgeBase> {
        return this.http.request<KnowledgeBase>('GET', `/v1/knowledge-bases/${enc(id)}`, opts);
    }

    /** Only the fields sent are changed. */
    update(id: string, body: UpdateKnowledgeBase, opts?: RequestOptions): Promise<KnowledgeBase> {
        return this.http.request<KnowledgeBase>('PATCH', `/v1/knowledge-bases/${enc(id)}`, { ...opts, body });
    }

    delete(id: string, opts?: RequestOptions): Promise<void> {
        return this.http.request<void>('DELETE', `/v1/knowledge-bases/${enc(id)}`, opts);
    }
}
