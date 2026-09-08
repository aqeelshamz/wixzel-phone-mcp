import '../models/telephony.dart';
import '../page.dart';
import '../transport.dart';

/// SIP trunks: your own carrier, connected.
class SipTrunks {
  /// Binds the resource to a transport.
  const SipTrunks(this._transport);

  final Transport _transport;

  /// Lists trunks. Each carries `platformIp` (allowlist it for outbound)
  /// and `originationUri` (point the carrier at it for inbound).
  Future<Page<SipTrunk>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/sip-trunks', SipTrunk.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Connects a carrier. The password is stored encrypted and never
  /// returned.
  Future<SipTrunk> create(CreateSipTrunk body) =>
      _transport.request('POST', '/v1/sip-trunks', SipTrunk.fromJson,
          body: body.toJson());

  /// Fetches one trunk.
  Future<SipTrunk> retrieve(String id) => _transport.request(
      'GET', '/v1/sip-trunks/${Uri.encodeComponent(id)}', SipTrunk.fromJson);

  /// Changes a trunk. Only the fields you set are changed.
  Future<SipTrunk> update(String id, UpdateSipTrunk body) => _transport.request(
      'PATCH', '/v1/sip-trunks/${Uri.encodeComponent(id)}', SipTrunk.fromJson,
      body: body.toJson());

  /// Deletes a trunk. Numbers on it can no longer make or take calls.
  Future<void> delete(String id) => _transport.requestVoid(
      'DELETE', '/v1/sip-trunks/${Uri.encodeComponent(id)}');

  /// Asterisk's own view and a live probe, side by side. Free and
  /// read-only; start here when calls fail.
  Future<SipTrunkStatus> status(String id) => _transport.request(
      'GET',
      '/v1/sip-trunks/${Uri.encodeComponent(id)}/status',
      SipTrunkStatus.fromJson);

  /// Recent SIP events. Poll with [sinceId] set to the previous `lastId`.
  Future<SipLogList> logs(String id, {int? sinceId, int? limit}) =>
      _transport.request(
        'GET',
        '/v1/sip-trunks/${Uri.encodeComponent(id)}/logs',
        SipLogList.fromJson,
        query: {'since_id': sinceId, 'limit': limit},
      );

  /// Sends an unauthenticated probe to the carrier. A negative result is
  /// not proof the trunk is broken.
  Future<SipTrunkTest> test(String id) => _transport.request('POST',
      '/v1/sip-trunks/${Uri.encodeComponent(id)}/test', SipTrunkTest.fromJson);
}
