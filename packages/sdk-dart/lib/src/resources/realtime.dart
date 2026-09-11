import '../models/realtime.dart';
import '../transport.dart';

/// Realtime: an agent in an app or a browser, with no phone line.
///
/// Call [createSession] on your SERVER and pass the result to your app, which
/// connects with `RealtimeConnection`.
class Realtime {
  /// Binds the resource to a transport.
  const Realtime(this._transport);

  final Transport _transport;

  /// Mints a one-minute, single-use client secret for `wss /v1/realtime`.
  ///
  /// Nothing is charged until the socket connects; from then on the session
  /// bills, counts toward concurrency and is logged exactly like a call.
  Future<RealtimeSession> createSession(CreateRealtimeSession body) =>
      _transport.request(
        'POST',
        '/v1/realtime/sessions',
        RealtimeSession.fromJson,
        body: body.toJson(),
      );
}
