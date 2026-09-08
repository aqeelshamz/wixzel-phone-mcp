import 'json.dart';

/// One page of a cursor-paginated list, and the way to the next.
///
/// ```dart
/// final page = await client.calls.list(limit: 100);
/// page.data;                                    // this page
/// await for (final call in page.autoPaging()) … // every call, page after page
/// ```
///
/// Cursors are opaque. Auto-paging follows `next_cursor` forward, carrying
/// the rest of your query unchanged.
class Page<T> {
  /// Builds a page from the API's list envelope.
  Page({
    required this.data,
    required this.hasMore,
    required this.nextCursor,
    required Future<Page<T>> Function(String cursor) fetchNext,
  }) : _fetchNext = fetchNext;

  /// Parses `{object, data, has_more, next_cursor}`.
  factory Page.fromJson(
    Json json,
    T Function(Json) fromJson,
    Future<Page<T>> Function(String cursor) fetchNext,
  ) =>
      Page<T>(
        data: readList(json, 'data', fromJson),
        hasMore: readBool(json, 'has_more'),
        nextCursor: readStringOrNull(json, 'next_cursor'),
        fetchNext: fetchNext,
      );

  /// The records on this page.
  final List<T> data;

  /// Whether more records exist after this page.
  final bool hasMore;

  /// Pass as `startingAfter` to fetch the next page; null at the end.
  final String? nextCursor;

  final Future<Page<T>> Function(String cursor) _fetchNext;

  /// The page after this one, or null at the end.
  Future<Page<T>?> nextPage() async {
    final cursor = nextCursor;
    if (!hasMore || cursor == null) return null;
    return _fetchNext(cursor);
  }

  /// This page and every page after it.
  Stream<Page<T>> pages() async* {
    Page<T>? page = this;
    while (page != null) {
      yield page;
      page = await page.nextPage();
    }
  }

  /// Every record, page after page.
  Stream<T> autoPaging() async* {
    await for (final page in pages()) {
      yield* Stream<T>.fromIterable(page.data);
    }
  }
}
