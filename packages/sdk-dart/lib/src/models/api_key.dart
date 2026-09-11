import '../json.dart';

/// What a key may do. There is no admin scope, and one cannot be created.
enum ApiScope {
  /// Read agents.
  agentsRead('agents:read'),

  /// Create, change and delete agents.
  agentsWrite('agents:write'),

  /// Read calls and transcripts.
  callsRead('calls:read'),

  /// Place and end calls.
  callsWrite('calls:write'),

  /// Read leads.
  leadsRead('leads:read'),

  /// Create, change and delete leads.
  leadsWrite('leads:write'),

  /// Read campaigns.
  campaignsRead('campaigns:read'),

  /// Create, start and pause campaigns.
  campaignsWrite('campaigns:write'),

  /// Read knowledge bases.
  knowledgeBasesRead('knowledge_bases:read'),

  /// Create, change and delete knowledge bases.
  knowledgeBasesWrite('knowledge_bases:write'),

  /// Read phone numbers.
  phoneNumbersRead('phone_numbers:read'),

  /// Register and change phone numbers.
  phoneNumbersWrite('phone_numbers:write'),

  /// Read SIP trunks.
  sipTrunksRead('sip_trunks:read'),

  /// Create, change and test SIP trunks.
  sipTrunksWrite('sip_trunks:write'),

  /// Read appointments.
  appointmentsRead('appointments:read'),

  /// Create and change appointments.
  appointmentsWrite('appointments:write'),

  /// Read the webhook endpoint and its delivery history.
  webhooksRead('webhooks:read'),

  /// Change the webhook endpoint, rotate its secret and send test events.
  webhooksWrite('webhooks:write'),

  /// List API keys.
  apiKeysRead('api_keys:read'),

  /// Mint, rotate and revoke API keys.
  apiKeysWrite('api_keys:write'),

  /// Read usage.
  usageRead('usage:read'),

  /// Read the balance and ledger.
  billingRead('billing:read'),

  /// Start a top-up. This authorises spending money.
  billingWrite('billing:write'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const ApiScope(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [ApiScope.unknown].
  static ApiScope parse(String? raw) => ApiScope.values
      .firstWhere((v) => v.value == raw, orElse: () => ApiScope.unknown);
}

/// A scoped credential. The secret is never returned after creation.
class ApiKey {
  /// Builds an API key record.
  const ApiKey({
    required this.id,
    required this.name,
    required this.prefix,
    required this.last4,
    required this.scopes,
    required this.createdAt,
    this.spendLimitMicros,
    this.lastUsedAt,
    this.expiresAt,
  });

  /// Parses the API's shape.
  factory ApiKey.fromJson(Json json) => ApiKey(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        prefix: readString(json, 'prefix'),
        last4: readString(json, 'last4'),
        scopes: readStringList(json, 'scopes')
            .map(ApiScope.parse)
            .toList(growable: false),
        spendLimitMicros: readIntOrNull(json, 'spend_limit_micros'),
        lastUsedAt: readDateTime(json, 'last_used_at'),
        expiresAt: readDateTime(json, 'expires_at'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The key's id.
  final String id;

  /// For your own reference.
  final String name;

  /// `wv_live_` or `wv_test_`.
  final String prefix;

  /// The last four characters, for recognition.
  final String last4;

  /// What the key may do.
  final List<ApiScope> scopes;

  /// A guardrail in micro-USD, enforced within about a minute.
  final int? spendLimitMicros;

  /// When it was last used. UTC.
  final DateTime? lastUsedAt;

  /// When it stops working. UTC.
  final DateTime? expiresAt;

  /// When it was created. UTC.
  final DateTime createdAt;
}

/// A key with its secret. Returned once, at creation or rotation.
class CreatedApiKey extends ApiKey {
  /// Builds a newly minted key.
  const CreatedApiKey({
    required super.id,
    required super.name,
    required super.prefix,
    required super.last4,
    required super.scopes,
    required super.createdAt,
    required this.key,
    super.spendLimitMicros,
    super.lastUsedAt,
    super.expiresAt,
  });

  /// Parses the API's shape.
  factory CreatedApiKey.fromJson(Json json) {
    final base = ApiKey.fromJson(json);
    return CreatedApiKey(
      id: base.id,
      name: base.name,
      prefix: base.prefix,
      last4: base.last4,
      scopes: base.scopes,
      spendLimitMicros: base.spendLimitMicros,
      lastUsedAt: base.lastUsedAt,
      expiresAt: base.expiresAt,
      createdAt: base.createdAt,
      key: readString(json, 'key'),
    );
  }

  /// The secret. Shown once and never again: store it now.
  final String key;
}

/// The body of `apiKeys.create`.
class CreateApiKey {
  /// Builds a create-key request.
  const CreateApiKey({
    required this.name,
    required this.scopes,
    this.spendLimitMicros,
    this.expiresAt,
  });

  /// For your own reference, e.g. `production backend`.
  final String name;

  /// Grant only what the key needs. A key cannot grant scopes it does not
  /// itself hold.
  final List<ApiScope> scopes;

  /// A guardrail in micro-USD. Not a hard cap.
  final int? spendLimitMicros;

  /// When the key should stop working. UTC.
  final DateTime? expiresAt;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'scopes': scopes.map((s) => s.value).toList(),
        'spend_limit_micros': spendLimitMicros,
        'expires_at': expiresAt == null ? null : isoUtc(expiresAt!),
      });
}
