import '../models/engine.dart';
import '../transport.dart';

/// Engines: what the platform can serve right now, with prices.
class Engines {
  /// Binds the resource to a transport.
  const Engines(this._transport);

  final Transport _transport;

  /// Use this rather than hardcoding model ids: a degraded provider
  /// disappears here before calls start failing.
  Future<EngineList> list() =>
      _transport.request('GET', '/v1/engines', EngineList.fromJson);
}
