import '../json.dart';
import 'billing.dart';

/// Whether an engine is assembled from parts or is one model.
enum EngineKind {
  /// Speech-to-text, a model and speech-out, wired together.
  composed('composed'),

  /// One model that does the whole turn.
  realtime('realtime'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const EngineKind(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [EngineKind.unknown].
  static EngineKind parse(String? raw) => EngineKind.values
      .firstWhere((v) => v.value == raw, orElse: () => EngineKind.unknown);
}

/// One priced model inside an engine.
class EngineModel {
  /// Builds a priced model.
  const EngineModel({
    required this.component,
    required this.model,
    required this.unit,
    required this.priceMicros,
  });

  /// Parses the API's shape.
  factory EngineModel.fromJson(Json json) => EngineModel(
        component: UsageComponent.parse(readStringOrNull(json, 'component')),
        model: readString(json, 'model'),
        unit: readString(json, 'unit'),
        priceMicros: readDouble(json, 'price_micros'),
      );

  /// Which stage this model serves.
  final UsageComponent component;

  /// `provider/model`, e.g. `deepgram/nova-3`.
  final String model;

  /// What is charged for: a second, a token, a character.
  final String unit;

  /// The price per unit, in micro-USD. Fractional.
  final double priceMicros;
}

/// A voice engine the platform can serve.
class Engine {
  /// Builds an engine record.
  const Engine({
    required this.id,
    required this.kind,
    required this.available,
    required this.models,
  });

  /// Parses the API's shape.
  factory Engine.fromJson(Json json) => Engine(
        id: readString(json, 'id'),
        kind: EngineKind.parse(readStringOrNull(json, 'kind')),
        available: readBool(json, 'available'),
        models: readList(json, 'models', EngineModel.fromJson),
      );

  /// The engine's id.
  final String id;

  /// Composed or realtime.
  final EngineKind kind;

  /// Whether it can be used right now. A degraded provider disappears from
  /// this list before calls start failing.
  final bool available;

  /// The models it offers, with prices.
  final List<EngineModel> models;
}

/// What the platform can serve right now, with prices.
class EngineList {
  /// Builds an engine list.
  const EngineList(this.data);

  /// Parses the API's shape.
  factory EngineList.fromJson(Json json) =>
      EngineList(readList(json, 'data', Engine.fromJson));

  /// The engines.
  final List<Engine> data;
}

/// One language an engine can hold a conversation in.
class EngineLanguage {
  /// Builds a language record.
  const EngineLanguage({
    required this.code,
    required this.name,
    required this.components,
  });

  /// Parses the API's shape.
  factory EngineLanguage.fromJson(Json json) => EngineLanguage(
        code: readString(json, 'code'),
        name: readString(json, 'name'),
        components: readStringList(json, 'components'),
      );

  /// The value to send as an agent's `language`, or as `voice.stt.language`
  /// / `voice.realtime.language`. Regional variants of a listed code are
  /// accepted, so `en-GB` works wherever `en` is listed.
  final String code;

  /// English name of the language.
  final String name;

  /// Which stages serve it: `stt`, `tts` or `realtime`.
  final List<String> components;
}

/// The languages one engine serves.
class EngineLanguageList {
  /// Builds a language list.
  const EngineLanguageList({
    required this.engine,
    required this.available,
    required this.data,
  });

  /// Parses the API's shape.
  factory EngineLanguageList.fromJson(Json json) => EngineLanguageList(
        engine: readString(json, 'engine'),
        available: readBool(json, 'available'),
        data: readList(json, 'data', EngineLanguage.fromJson),
      );

  /// The engine these languages belong to.
  final String engine;

  /// Whether the engine can carry a call right now. The list is returned
  /// either way, so a picker still renders during a provider outage.
  final bool available;

  /// The languages.
  final List<EngineLanguage> data;
}

/// One voice an engine can speak as.
class EngineVoice {
  /// Builds a voice record.
  const EngineVoice({
    required this.id,
    required this.name,
    required this.provider,
    this.description,
    this.previewUrl,
  });

  /// Parses the API's shape.
  factory EngineVoice.fromJson(Json json) => EngineVoice(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        provider: readString(json, 'provider'),
        description: readStringOrNull(json, 'description'),
        previewUrl: readStringOrNull(json, 'preview_url'),
      );

  /// The value to send as `voice.tts.voice` or `voice.realtime.voice`.
  final String id;

  /// The voice's name.
  final String name;

  /// Which provider speaks it: `elevenlabs`, `sarvam` or `google`.
  final String provider;

  /// The provider's own description, where it publishes one. Null rather
  /// than inferred.
  final String? description;

  /// A sample of the voice, where the provider hosts one.
  final String? previewUrl;
}

/// The voices one engine can speak as.
class EngineVoiceList {
  /// Builds a voice list.
  const EngineVoiceList({
    required this.engine,
    required this.available,
    required this.stale,
    required this.data,
    this.refreshedAt,
  });

  /// Parses the API's shape.
  factory EngineVoiceList.fromJson(Json json) => EngineVoiceList(
        engine: readString(json, 'engine'),
        available: readBool(json, 'available'),
        stale: readBool(json, 'stale'),
        refreshedAt: readDateTime(json, 'refreshed_at'),
        data: readList(json, 'data', EngineVoice.fromJson),
      );

  /// The engine these voices belong to.
  final String engine;

  /// Whether the engine can carry a call right now.
  final bool available;

  /// True when the provider could not be reached and this is the last list
  /// that was fetched. The API prefers a stale answer to an error.
  final bool stale;

  /// When the provider list was fetched. Null for engines whose roster is
  /// fixed and needs no fetching, such as Sarvam and Gemini.
  final DateTime? refreshedAt;

  /// The voices.
  final List<EngineVoice> data;
}
