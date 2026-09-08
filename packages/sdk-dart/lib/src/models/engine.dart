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
