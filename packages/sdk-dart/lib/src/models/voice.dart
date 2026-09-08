import '../json.dart';

/// How readily the agent stops talking when the caller speaks.
enum InterruptSensitivity {
  /// Rarely interrupted.
  low('low'),

  /// The default.
  normal('normal'),

  /// Stops at the slightest sound.
  high('high'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const InterruptSensitivity(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [InterruptSensitivity.unknown].
  static InterruptSensitivity parse(String? raw) =>
      InterruptSensitivity.values.firstWhere((v) => v.value == raw,
          orElse: () => InterruptSensitivity.unknown);
}

/// Speech-to-text settings.
class SttConfig {
  /// Builds a speech-to-text stage.
  const SttConfig({required this.model, this.language, this.endpointingMs});

  /// Parses the API's shape.
  factory SttConfig.fromJson(Json json) => SttConfig(
        model: readString(json, 'model'),
        language: readStringOrNull(json, 'language'),
        endpointingMs: readIntOrNull(json, 'endpointing_ms'),
      );

  /// `provider/model`, e.g. `deepgram/nova-3`.
  final String model;

  /// BCP-47 tag, or `multi` for automatic detection.
  final String? language;

  /// Silence before a turn is considered finished. Lower is snappier and
  /// more prone to cutting people off.
  final int? endpointingMs;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'model': model,
        'language': language,
        'endpointing_ms': endpointingMs,
      });
}

/// The language model settings.
class LlmConfig {
  /// Builds an LLM stage.
  const LlmConfig({required this.model, this.temperature, this.maxTokens});

  /// Parses the API's shape.
  factory LlmConfig.fromJson(Json json) => LlmConfig(
        model: readString(json, 'model'),
        temperature: readDoubleOrNull(json, 'temperature'),
        maxTokens: readIntOrNull(json, 'max_tokens'),
      );

  /// `provider/model`, e.g. `openrouter/gpt-4o-mini`.
  final String model;

  /// Sampling temperature, 0 to 2.
  final double? temperature;

  /// Caps reply length. Long replies cost the caller waiting time as well
  /// as money.
  final int? maxTokens;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'model': model,
        'temperature': temperature,
        'max_tokens': maxTokens,
      });
}

/// Text-to-speech settings.
class TtsConfig {
  /// Builds a speech-out stage.
  const TtsConfig({
    required this.model,
    this.voice,
    this.stability,
    this.similarityBoost,
    this.speed,
  });

  /// Parses the API's shape.
  factory TtsConfig.fromJson(Json json) => TtsConfig(
        model: readString(json, 'model'),
        voice: readStringOrNull(json, 'voice'),
        stability: readDoubleOrNull(json, 'stability'),
        similarityBoost: readDoubleOrNull(json, 'similarity_boost'),
        speed: readDoubleOrNull(json, 'speed'),
      );

  /// `provider/model`, e.g. `elevenlabs/eleven_turbo_v2_5`.
  final String model;

  /// The provider's voice id.
  final String? voice;

  /// How steady the delivery is, 0 to 1.
  final double? stability;

  /// How closely the voice matches its reference, 0 to 1.
  final double? similarityBoost;

  /// Playback rate, 0.5 to 2.
  final double? speed;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'model': model,
        'voice': voice,
        'stability': stability,
        'similarity_boost': similarityBoost,
        'speed': speed,
      });
}

/// A single model that does speech in, reasoning and speech out.
class RealtimeConfig {
  /// Builds a realtime stage.
  const RealtimeConfig({required this.model, this.voice, this.language});

  /// Parses the API's shape.
  factory RealtimeConfig.fromJson(Json json) => RealtimeConfig(
        model: readString(json, 'model'),
        voice: readStringOrNull(json, 'voice'),
        language: readStringOrNull(json, 'language'),
      );

  /// `provider/model`, e.g. `google/gemini-live-2.5-flash`.
  final String model;

  /// The provider's voice name, e.g. `Charon`.
  final String? voice;

  /// Conversation language, or `auto`.
  final String? language;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'model': model,
        'voice': voice,
        'language': language,
      });
}

/// When the agent yields the floor.
class TurnTaking {
  /// Builds turn-taking settings.
  const TurnTaking({this.interruptSensitivity, this.silenceWaitMs});

  /// Parses the API's shape.
  factory TurnTaking.fromJson(Json json) => TurnTaking(
        interruptSensitivity: json['interrupt_sensitivity'] == null
            ? null
            : InterruptSensitivity.parse(
                readStringOrNull(json, 'interrupt_sensitivity')),
        silenceWaitMs: readIntOrNull(json, 'silence_wait_ms'),
      );

  /// How readily the agent stops talking when the caller speaks.
  final InterruptSensitivity? interruptSensitivity;

  /// How long a silence must run before the agent speaks again.
  final int? silenceWaitMs;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'interrupt_sensitivity': interruptSensitivity?.value,
        'silence_wait_ms': silenceWaitMs,
      });
}

/// The voice engine: either a composed pipeline or one realtime model.
///
/// Exactly one shape per agent. A composed pipeline needs all three of
/// [stt], [llm] and [tts]; a realtime model needs only [realtime], because
/// it does every stage itself.
class VoiceConfig {
  /// Builds a voice configuration.
  const VoiceConfig(
      {this.stt, this.llm, this.tts, this.realtime, this.turnTaking});

  /// A composed pipeline: speech in, a model, speech out.
  factory VoiceConfig.composed({
    required SttConfig stt,
    required LlmConfig llm,
    required TtsConfig tts,
    TurnTaking? turnTaking,
  }) =>
      VoiceConfig(stt: stt, llm: llm, tts: tts, turnTaking: turnTaking);

  /// One model that handles the whole turn.
  factory VoiceConfig.realtimeModel(RealtimeConfig realtime,
          {TurnTaking? turnTaking}) =>
      VoiceConfig(realtime: realtime, turnTaking: turnTaking);

  /// Parses the API's shape.
  factory VoiceConfig.fromJson(Json json) => VoiceConfig(
        stt: readObject(json, 'stt', SttConfig.fromJson),
        llm: readObject(json, 'llm', LlmConfig.fromJson),
        tts: readObject(json, 'tts', TtsConfig.fromJson),
        realtime: readObject(json, 'realtime', RealtimeConfig.fromJson),
        turnTaking: readObject(json, 'turn_taking', TurnTaking.fromJson),
      );

  /// Speech-to-text, in a composed pipeline.
  final SttConfig? stt;

  /// The language model, in a composed pipeline.
  final LlmConfig? llm;

  /// Text-to-speech, in a composed pipeline.
  final TtsConfig? tts;

  /// A single realtime model instead of a pipeline.
  final RealtimeConfig? realtime;

  /// When the agent yields the floor.
  final TurnTaking? turnTaking;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'stt': stt?.toJson(),
        'llm': llm?.toJson(),
        'tts': tts?.toJson(),
        'realtime': realtime?.toJson(),
        'turn_taking': turnTaking?.toJson(),
      });
}
