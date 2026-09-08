import '../models/call.dart';
import '../page.dart';
import '../response.dart';
import '../transport.dart';

/// Calls: placing, watching and reading them.
class Calls {
  /// Binds the resource to a transport.
  const Calls(this._transport);

  final Transport _transport;

  /// Dials a real number over your SIP trunk and connects an agent.
  ///
  /// Spends credit. An `Idempotency-Key` is generated unless
  /// [idempotencyKey] is given; retrying with the same key returns the
  /// original call rather than dialling twice.
  Future<Call> create(CreateCall body, {String? idempotencyKey}) =>
      _transport.request(
        'POST',
        '/v1/calls',
        Call.fromJson,
        body: body.toJson(),
        idempotent: true,
        idempotencyKey: idempotencyKey,
      );

  /// As [create], but keeps the request id and whether the server replayed
  /// an earlier request rather than placing a new call.
  Future<WixzelResponse<Call>> createWithResponse(CreateCall body,
          {String? idempotencyKey}) =>
      _transport.requestWithResponse(
        'POST',
        '/v1/calls',
        Call.fromJson,
        body: body.toJson(),
        idempotent: true,
        idempotencyKey: idempotencyKey,
      );

  /// Lists calls in summary form. Use [retrieve] for the transcript.
  Future<Page<Call>> list({
    int? limit,
    String? startingAfter,
    String? endingBefore,
    CallStatus? status,
    CallDirection? direction,
    String? agentId,
    String? campaignId,
    String? engine,
    DateTime? startedAfter,
    DateTime? startedBefore,
    bool? failedOnly,
    String? phoneNumber,
  }) =>
      _transport.list('/v1/calls', Call.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
        'status': status?.value,
        'direction': direction?.value,
        'agent_id': agentId,
        'campaign_id': campaignId,
        'engine': engine,
        'started_after': startedAfter,
        'started_before': startedBefore,
        'failed_only': failedOnly,
        'phone_number': phoneNumber,
      });

  /// The full record: transcript, recording, transfers, provider errors,
  /// and `failureCode`/`failureReason` when the call did not connect.
  Future<CallDetail> retrieve(String id) => _transport.request(
      'GET', '/v1/calls/${Uri.encodeComponent(id)}', CallDetail.fromJson);

  /// Removes the log, transcript and recording. Usage rows are kept. A live
  /// call cannot be deleted; hang it up first.
  Future<void> delete(String id) =>
      _transport.requestVoid('DELETE', '/v1/calls/${Uri.encodeComponent(id)}');

  /// Ends a call in progress. Billing stops when it ends.
  Future<Call> hangup(String id) => _transport.request(
      'POST', '/v1/calls/${Uri.encodeComponent(id)}/hangup', Call.fromJson);

  /// Just the transcript.
  Future<Transcript> transcript(String id) => _transport.request('GET',
      '/v1/calls/${Uri.encodeComponent(id)}/transcript', Transcript.fromJson);
}
