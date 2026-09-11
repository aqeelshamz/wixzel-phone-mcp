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

  /// Languages [engine] can hold a conversation in.
  ///
  /// A composed engine lists one only when both its speech-to-text and its
  /// text-to-speech serve it, so this is the list that holds end to end.
  Future<EngineLanguageList> languages(String engine) => _transport.request(
        'GET',
        '/v1/engines/${Uri.encodeComponent(engine)}/languages',
        EngineLanguageList.fromJson,
      );

  /// Voices [engine] can speak as — the voice the caller hears.
  ///
  /// A result with `stale` set means the provider could not be reached and
  /// this is the last list that was fetched.
  Future<EngineVoiceList> voices(String engine) => _transport.request(
        'GET',
        '/v1/engines/${Uri.encodeComponent(engine)}/voices',
        EngineVoiceList.fromJson,
      );
}
