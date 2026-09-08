import type { ListResponse } from '../types.js';

/**
 * One page of a cursor-paginated list, and the way to the next.
 *
 *   const page = await client.calls.list({ limit: 100 });
 *   page.data                           // this page
 *   for await (const call of page) …    // every call, page after page
 *   for await (const p of page.pages()) // page by page
 *
 * Auto-paging follows `next_cursor` forward. Cursors are opaque; the SDK
 * passes them back as `starting_after` with the rest of the query unchanged.
 */
export class Page<T> implements AsyncIterable<T> {
    readonly object = 'list' as const;
    readonly data: T[];
    readonly hasMore: boolean;
    readonly nextCursor: string | null;

    constructor(
        body: ListResponse<T>,
        private readonly fetchNext: (cursor: string) => Promise<Page<T>>,
    ) {
        this.data = body.data;
        this.hasMore = body.has_more;
        this.nextCursor = body.next_cursor;
    }

    /** The page after this one, or null at the end. */
    nextPage(): Promise<Page<T> | null> {
        if (!this.hasMore || this.nextCursor === null) return Promise.resolve(null);
        return this.fetchNext(this.nextCursor);
    }

    /** This page and every page after it. */
    async *pages(): AsyncGenerator<Page<T>, void, undefined> {
        let page: Page<T> | null = this;
        while (page) {
            yield page;
            page = await page.nextPage();
        }
    }

    async *[Symbol.asyncIterator](): AsyncGenerator<T, void, undefined> {
        for await (const page of this.pages()) {
            yield* page.data;
        }
    }
}
