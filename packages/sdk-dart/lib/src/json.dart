/// Reading JSON the API sends, defensively.
///
/// A field the server adds tomorrow must not break a client shipped today,
/// and a field it stops sending must not throw halfway through parsing a
/// page. Every reader below tolerates a missing or mistyped value; only the
/// fields the spec marks required are read with the non-null helpers.
library;

/// The JSON object shape used throughout the SDK.
typedef Json = Map<String, dynamic>;

/// Reads a required string, falling back to `''` rather than throwing.
String readString(Json json, String key) {
  final value = json[key];
  return value is String ? value : '';
}

/// Reads an optional string. Anything that is not a string reads as null.
String? readStringOrNull(Json json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

/// Reads a required int. Accepts a JSON number that arrived as a double.
int readInt(Json json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

/// Reads an optional int.
int? readIntOrNull(Json json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

/// Reads a required number.
double readDouble(Json json, String key, {double fallback = 0}) {
  final value = json[key];
  return value is num ? value.toDouble() : fallback;
}

/// Reads an optional number.
double? readDoubleOrNull(Json json, String key) {
  final value = json[key];
  return value is num ? value.toDouble() : null;
}

/// Reads a required boolean.
bool readBool(Json json, String key, {bool fallback = false}) {
  final value = json[key];
  return value is bool ? value : fallback;
}

/// Reads an optional boolean.
bool? readBoolOrNull(Json json, String key) {
  final value = json[key];
  return value is bool ? value : null;
}

/// Reads an ISO 8601 timestamp. The API always sends UTC.
DateTime? readDateTime(Json json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

/// Reads a required timestamp, falling back to the epoch when absent.
DateTime readDateTimeRequired(Json json, String key) =>
    readDateTime(json, key) ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

/// Reads a list of strings, skipping anything that is not one.
List<String> readStringList(Json json, String key) {
  final value = json[key];
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}

/// Reads a list of objects and maps each through [fromJson].
List<T> readList<T>(Json json, String key, T Function(Json) fromJson) {
  final value = json[key];
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}

/// Reads a nested object, or null when it is absent.
T? readObject<T>(Json json, String key, T Function(Json) fromJson) {
  final value = json[key];
  return value is Map<String, dynamic> ? fromJson(value) : null;
}

/// Reads a free-form map, e.g. a lead's merge fields.
Map<String, dynamic>? readMap(Json json, String key) {
  final value = json[key];
  return value is Map<String, dynamic>
      ? Map<String, dynamic>.unmodifiable(value)
      : null;
}

/// Builds a request body with the null entries removed.
///
/// The API treats an absent field as "leave it alone", so a null in a Dart
/// request object must not become a JSON null that clears a value.
Json omitNulls(Json json) {
  final out = <String, dynamic>{};
  json.forEach((key, value) {
    if (value != null) out[key] = value;
  });
  return out;
}

/// Formats a timestamp the way the API expects: ISO 8601, UTC, with a `Z`.
String isoUtc(DateTime value) => value.toUtc().toIso8601String();
