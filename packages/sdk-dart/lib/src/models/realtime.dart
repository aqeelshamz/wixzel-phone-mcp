import '../json.dart';

/// What to create with `realtime.createSession`.
class CreateRealtimeSession {
  /// Describes a realtime session to mint.
  const CreateRealtimeSession({
    required this.agentId,
    this.leadId,
    this.metadata,
    this.maxDurationSeconds,
    this.allowedOrigins,
  });

  /// The agent the user will talk to.
  final String agentId;

  /// Existing lead to attribute the session to. Without one, merge fields
  /// resolve to nothing and the call has no lead.
  final String? leadId;

  /// Your own identifiers, echoed on the resulting call and its webhooks.
  final Map<String, String>? metadata;

  /// Hard cap on the conversation, 10–3600 seconds. Defaults to 600.
  final int? maxDurationSeconds;

  /// Browser origins allowed to open the socket. Irrelevant for a native app.
  final List<String>? allowedOrigins;

  /// The request body.
  Json toJson() => omitNulls({
        'agent_id': agentId,
        'lead_id': leadId,
        'metadata': metadata,
        'max_duration_seconds': maxDurationSeconds,
        'allowed_origins': allowedOrigins,
      });
}

/// A minted realtime session: where to connect and the one-time secret to use.
///
/// Mint it on your server — it needs your API key — and hand [url] and
/// [clientSecret] to the app. The secret works once, for a minute.
class RealtimeSession {
  /// Builds a session from its parts.
  const RealtimeSession({
    required this.id,
    required this.clientSecret,
    required this.expiresAt,
    required this.url,
    required this.agentId,
    required this.engine,
    required this.maxDurationSeconds,
    required this.audioFormat,
  });

  /// Maps the API's JSON.
  factory RealtimeSession.fromJson(Json json) {
    final secret = (json['client_secret'] as Map?)?.cast<String, dynamic>() ?? const {};
    return RealtimeSession(
      id: readString(json, 'id'),
      clientSecret: readString(secret, 'value'),
      expiresAt: readDateTimeRequired(secret, 'expires_at'),
      url: readString(json, 'url'),
      agentId: readString(json, 'agent_id'),
      engine: readString(json, 'engine'),
      maxDurationSeconds: readInt(json, 'max_duration_seconds'),
      audioFormat: readString(json, 'audio_format'),
    );
  }

  /// Becomes the `session_id` of the resulting call.
  final String id;

  /// Pass as `client_secret` when connecting. Single use.
  final String clientSecret;

  /// Connect before this.
  final DateTime expiresAt;

  /// `wss://…/v1/realtime`.
  final String url;

  /// The agent.
  final String agentId;

  /// The agent's voice engine.
  final String engine;

  /// Hard cap on the conversation.
  final int maxDurationSeconds;

  /// Always `mulaw_8000`: base64 G.711 µ-law, 8 kHz mono, both directions.
  final String audioFormat;
}
