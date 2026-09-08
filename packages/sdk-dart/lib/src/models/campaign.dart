import '../json.dart';

/// Where a campaign is in its life.
enum CampaignStatus {
  /// Created, not started.
  idle('idle'),

  /// Waiting for its start time.
  scheduled('scheduled'),

  /// Placing calls now.
  running('running'),

  /// Every lead has been called.
  completed('completed'),

  /// Stopped and will not resume.
  stopped('stopped'),

  /// Paused; can be started again.
  paused('paused'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const CampaignStatus(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [CampaignStatus.unknown].
  static CampaignStatus parse(String? raw) => CampaignStatus.values
      .firstWhere((v) => v.value == raw, orElse: () => CampaignStatus.unknown);
}

/// One agent calling a list of leads.
class Campaign {
  /// Builds a campaign record.
  const Campaign({
    required this.id,
    required this.name,
    required this.agentId,
    required this.status,
    required this.leadCount,
    required this.createdAt,
    this.pausedReason,
    this.scheduledAt,
  });

  /// Parses the API's shape.
  factory Campaign.fromJson(Json json) => Campaign(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        agentId: readString(json, 'agent_id'),
        status: CampaignStatus.parse(readStringOrNull(json, 'status')),
        pausedReason: readStringOrNull(json, 'paused_reason'),
        leadCount: readInt(json, 'lead_count'),
        scheduledAt: readDateTime(json, 'scheduled_at'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The campaign's id.
  final String id;

  /// A label for your own reference.
  final String name;

  /// The agent that holds the conversations.
  final String agentId;

  /// Where the campaign is in its life.
  final CampaignStatus status;

  /// Why it paused, when it did so by itself (an empty balance, say).
  final String? pausedReason;

  /// How many leads it will call.
  final int leadCount;

  /// When it starts, when scheduled. UTC.
  final DateTime? scheduledAt;

  /// When it was created. UTC.
  final DateTime createdAt;
}

/// The body of `campaigns.create`. Creating does not dial anyone.
class CreateCampaign {
  /// Builds a create-campaign request.
  const CreateCampaign({
    required this.name,
    required this.agentId,
    required this.leadIds,
    this.scheduledAt,
  });

  /// A label for your own reference.
  final String name;

  /// The agent that will hold the conversations.
  final String agentId;

  /// The leads to call.
  final List<String> leadIds;

  /// When to begin. Omit to start on demand with `campaigns.start`.
  final DateTime? scheduledAt;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'agent_id': agentId,
        'lead_ids': leadIds,
        'scheduled_at': scheduledAt == null ? null : isoUtc(scheduledAt!),
      });
}
