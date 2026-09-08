import 'json.dart';

/// The eight error types the API documents, plus a fallback.
///
/// The fallback exists so a type introduced on the server does not throw in a
/// client shipped before it; [WixzelException.rawType] keeps the original.
enum WixzelErrorType {
  /// Something about the request was wrong.
  invalidRequest('invalid_request_error'),

  /// Missing, malformed, revoked or expired key.
  authentication('authentication_error'),

  /// The key lacks the scope for this endpoint.
  permission('permission_error'),

  /// Too many requests. Never charged.
  rateLimit('rate_limit_error'),

  /// Not enough balance to place the call.
  insufficientCredits('insufficient_credits'),

  /// No such record, or it belongs to another account.
  notFound('not_found_error'),

  /// The request conflicts with the current state.
  conflict('conflict_error'),

  /// Something failed on the API's side.
  api('api_error'),

  /// A type this version of the SDK does not know.
  unknown('unknown');

  const WixzelErrorType(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [WixzelErrorType.unknown].
  static WixzelErrorType parse(String? raw) =>
      WixzelErrorType.values.firstWhere(
        (type) => type.value == raw,
        orElse: () => WixzelErrorType.unknown,
      );
}

/// A failure the API answered.
///
/// Match on [code], never on [message]: the code is stable, the message is
/// written for people and may be reworded.
///
/// ```dart
/// try {
///   await client.calls.create(CreateCall(to: to, agentId: agentId));
/// } on WixzelException catch (e) {
///   if (e.code == 'insufficient_credits') print('balance: ${e.balance}');
/// }
/// ```
class WixzelException implements Exception {
  /// Builds an exception from the API's error envelope.
  WixzelException({
    required this.statusCode,
    required this.code,
    required this.message,
    required this.headers,
    this.rawType,
    this.param,
    this.requestId,
    this.docUrl,
    this.retryAfter,
    this.balance,
  }) : type = WixzelErrorType.parse(rawType);

  /// Parses `{"error": {...}}`, tolerating a body that is not that shape.
  factory WixzelException.fromResponse({
    required int statusCode,
    required Json? body,
    required Map<String, String> headers,
    String? rawBody,
  }) {
    final error = body?['error'];
    final envelope =
        error is Map<String, dynamic> ? error : const <String, dynamic>{};
    final retryAfterRaw = headers['retry-after'];
    final retryAfterSeconds =
        retryAfterRaw == null ? null : int.tryParse(retryAfterRaw);
    return WixzelException(
      statusCode: statusCode,
      rawType: readStringOrNull(envelope, 'type') ??
          (statusCode >= 500 ? 'api_error' : 'invalid_request_error'),
      code: readStringOrNull(envelope, 'code') ?? 'http_$statusCode',
      message: readStringOrNull(envelope, 'message') ??
          (rawBody != null && rawBody.isNotEmpty
              ? rawBody
              : 'HTTP $statusCode'),
      param: readStringOrNull(envelope, 'param'),
      requestId: readStringOrNull(envelope, 'request_id'),
      docUrl: readStringOrNull(envelope, 'doc_url'),
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds),
      balance: headers['x-wixzel-balance'],
      headers: headers,
    );
  }

  /// The HTTP status.
  final int statusCode;

  /// The documented type, or [WixzelErrorType.unknown].
  final WixzelErrorType type;

  /// The type exactly as the server sent it.
  final String? rawType;

  /// Stable machine-readable code, e.g. `agent_not_found`. Match on this.
  final String code;

  /// Human-readable explanation. Do not match on it.
  final String message;

  /// Which field caused the failure, when the server says.
  final String? param;

  /// Quote this when asking for help.
  final String? requestId;

  /// Where the code is documented, when the server says.
  final String? docUrl;

  /// How long to wait, from `Retry-After` on a 429.
  final Duration? retryAfter;

  /// The `X-Wixzel-Balance` header on `insufficient_credits`, as sent.
  final String? balance;

  /// Every response header, lower-cased.
  final Map<String, String> headers;

  @override
  String toString() =>
      'WixzelException($code, status: $statusCode${requestId == null ? '' : ', request_id: $requestId'}): $message';
}

/// The request never got an answer: a network failure or a timeout, after
/// every retry the policy allowed.
///
/// Whether the server acted is unknown. For a request that carried an
/// idempotency key, retrying with the same key is safe.
class WixzelConnectionException implements Exception {
  /// Builds a connection failure around its [cause].
  WixzelConnectionException(this.message, this.cause);

  /// What went wrong, including how many attempts were made.
  final String message;

  /// The underlying error.
  final Object cause;

  @override
  String toString() => 'WixzelConnectionException: $message';
}
