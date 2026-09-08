import '../models/api_key.dart';
import '../page.dart';
import '../transport.dart';

/// API keys: scoped credentials. Secrets are returned once.
class ApiKeys {
  /// Binds the resource to a transport.
  const ApiKeys(this._transport);

  final Transport _transport;

  /// Lists keys. Secrets are never returned, only a prefix and last four.
  Future<Page<ApiKey>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/api-keys', ApiKey.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Mints a key. The `key` in the result is shown once and cannot be
  /// retrieved again. A key cannot grant scopes the calling key lacks.
  Future<CreatedApiKey> create(CreateApiKey body) =>
      _transport.request('POST', '/v1/api-keys', CreatedApiKey.fromJson,
          body: body.toJson());

  /// Revokes a key. Immediate, with no grace period.
  Future<void> revoke(String id) => _transport.requestVoid(
      'DELETE', '/v1/api-keys/${Uri.encodeComponent(id)}');

  /// Issues a replacement now; the old key keeps working for 24 hours.
  Future<CreatedApiKey> rotate(String id) => _transport.request('POST',
      '/v1/api-keys/${Uri.encodeComponent(id)}/rotate', CreatedApiKey.fromJson);
}
