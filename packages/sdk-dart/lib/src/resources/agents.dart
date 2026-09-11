import '../models/agent.dart';
import '../models/call.dart';
import '../page.dart';
import '../transport.dart';

/// Voice agents: a prompt plus a voice engine.
class Agents {
  /// Binds the resource to a transport.
  const Agents(this._transport);

  final Transport _transport;

  /// Lists agents, newest first.
  Future<Page<Agent>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/agents', Agent.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Creates an agent. Pick models from `engines.list()`; an unknown model
  /// is refused with `unsupported_model`.
  Future<Agent> create(CreateAgent body) => _transport
      .request('POST', '/v1/agents', Agent.fromJson, body: body.toJson());

  /// Fetches one agent.
  Future<Agent> retrieve(String id) => _transport.request(
      'GET', '/v1/agents/${Uri.encodeComponent(id)}', Agent.fromJson);

  /// Changes an agent. Only the fields you set are changed.
  Future<Agent> update(String id, UpdateAgent body) => _transport.request(
      'PATCH', '/v1/agents/${Uri.encodeComponent(id)}', Agent.fromJson,
      body: body.toJson());

  /// Rings a number and has the agent speak one phrase, then hangs up.
  ///
  /// A probe, not a conversation. It rings a real phone and spends real
  /// credit, so an `Idempotency-Key` is generated unless [idempotencyKey] is
  /// given. Human transfer is not offered during a test call.
  Future<Call> testCall(String id, TestCall body, {String? idempotencyKey}) =>
      _transport.request(
        'POST',
        '/v1/agents/${Uri.encodeComponent(id)}/test-call',
        Call.fromJson,
        body: body.toJson(),
        idempotent: true,
        idempotencyKey: idempotencyKey,
      );

  /// Deletes an agent. Numbers and campaigns pointing at it stop working.
  Future<void> delete(String id) =>
      _transport.requestVoid('DELETE', '/v1/agents/${Uri.encodeComponent(id)}');
}
