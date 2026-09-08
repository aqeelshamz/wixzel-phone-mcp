/// A result with the HTTP details that came with it.
///
/// Most methods return the model alone. The two that spend money also offer
/// a `…WithResponse` variant returning this, because whether the server
/// replayed an earlier request is worth knowing and an immutable model has
/// nowhere to carry it.
class WixzelResponse<T> {
  /// Wraps [data] with the metadata from its response.
  const WixzelResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
    this.requestId,
    this.idempotentReplay = false,
  });

  /// The parsed result.
  final T data;

  /// The HTTP status.
  final int statusCode;

  /// Every response header, lower-cased.
  final Map<String, String> headers;

  /// The `request_id` the API stamps on responses, when present.
  final String? requestId;

  /// True when the server answered from its idempotency cache rather than
  /// acting again (`Idempotent-Replay: true`).
  final bool idempotentReplay;
}
