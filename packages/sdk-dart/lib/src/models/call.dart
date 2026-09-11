import '../json.dart';

/// Where a call is in its life.
enum CallStatus {
  /// Accepted, not yet dialled.
  queued('queued'),

  /// The far end is ringing.
  ringing('ringing'),

  /// Connected and talking.
  inProgress('in-progress'),

  /// Finished normally.
  completed('completed'),

  /// Did not connect. See `failureCode`.
  failed('failed'),

  /// The far end was busy.
  busy('busy'),

  /// Nobody answered.
  noAnswer('no-answer'),

  /// Cancelled before it connected.
  canceled('canceled'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const CallStatus(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [CallStatus.unknown].
  static CallStatus parse(String? raw) => CallStatus.values
      .firstWhere((v) => v.value == raw, orElse: () => CallStatus.unknown);
}

/// Which way a call went.
enum CallDirection {
  /// Someone called one of your numbers.
  inbound('inbound'),

  /// You called someone.
  outbound('outbound'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const CallDirection(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [CallDirection.unknown].
  static CallDirection parse(String? raw) => CallDirection.values
      .firstWhere((v) => v.value == raw, orElse: () => CallDirection.unknown);
}

/// Who said a line.
enum TranscriptRole {
  /// The caller.
  user('user'),

  /// The agent.
  assistant('assistant'),

  /// The system.
  system('system'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const TranscriptRole(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [TranscriptRole.unknown].
  static TranscriptRole parse(String? raw) => TranscriptRole.values
      .firstWhere((v) => v.value == raw, orElse: () => TranscriptRole.unknown);
}

/// One line of a conversation.
class TranscriptEntry {
  /// Builds a transcript line.
  const TranscriptEntry(
      {required this.role, required this.content, this.timestamp});

  /// Parses the API's shape.
  factory TranscriptEntry.fromJson(Json json) => TranscriptEntry(
        role: TranscriptRole.parse(readStringOrNull(json, 'role')),
        content: readString(json, 'content'),
        timestamp: readDateTime(json, 'timestamp'),
      );

  /// Who spoke.
  final TranscriptRole role;

  /// What was said.
  final String content;

  /// When. UTC.
  final DateTime? timestamp;
}

/// A whole conversation.
class Transcript {
  /// Builds a transcript.
  const Transcript(this.data);

  /// Parses the API's shape.
  factory Transcript.fromJson(Json json) =>
      Transcript(readList(json, 'data', TranscriptEntry.fromJson));

  /// The lines, in order.
  final List<TranscriptEntry> data;
}

/// Something a provider reported while the call was running.
class CallError {
  /// Builds a provider error.
  const CallError({required this.message, this.service, this.code, this.at});

  /// Parses the API's shape.
  factory CallError.fromJson(Json json) => CallError(
        service: readStringOrNull(json, 'service'),
        code: readStringOrNull(json, 'code'),
        message: readString(json, 'message'),
        at: readDateTime(json, 'at'),
      );

  /// Which provider.
  final String? service;

  /// Their code for it.
  final String? code;

  /// What they said.
  final String message;

  /// When. UTC.
  final DateTime? at;
}

/// An attempt to hand the call to a person.
class CallTransfer {
  /// Builds a transfer attempt.
  const CallTransfer({
    required this.status,
    required this.attempt,
    this.destinationName,
    this.reason,
    this.requestedAt,
    this.answeredAt,
    this.failureCode,
    this.sipCause,
  });

  /// Parses the API's shape.
  factory CallTransfer.fromJson(Json json) => CallTransfer(
        destinationName: readStringOrNull(json, 'destination_name'),
        status: readString(json, 'status'),
        reason: readStringOrNull(json, 'reason'),
        attempt: readInt(json, 'attempt'),
        requestedAt: readDateTime(json, 'requested_at'),
        answeredAt: readDateTime(json, 'answered_at'),
        failureCode: readStringOrNull(json, 'failure_code'),
        sipCause: readIntOrNull(json, 'sip_cause'),
      );

  /// Where it was going.
  final String? destinationName;

  /// How it went.
  final String status;

  /// Why it was attempted.
  final String? reason;

  /// Which attempt this was.
  final int attempt;

  /// When it was requested. UTC.
  final DateTime? requestedAt;

  /// When it was answered, if it was. UTC.
  final DateTime? answeredAt;

  /// Why it failed, if it did.
  final String? failureCode;

  /// The SIP cause code, if there was one.
  final int? sipCause;
}

/// A call, in summary. `calls.list` returns these.
class Call {
  /// Builds a call record.
  const Call({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.direction,
    this.channel = 'phone',
    this.agentId,
    this.leadId,
    this.campaignId,
    this.from,
    this.to,
    this.durationSeconds,
    this.engine,
    this.recordingUrl,
    this.summary,
    this.costMicros,
    this.metadata,
    this.failureCode,
    this.failureReason,
    this.startedAt,
    this.endedAt,
  });

  /// Parses the API's shape.
  factory Call.fromJson(Json json) => Call(
        id: readString(json, 'id'),
        sessionId: readString(json, 'session_id'),
        status: CallStatus.parse(readStringOrNull(json, 'status')),
        direction: CallDirection.parse(readStringOrNull(json, 'direction')),
        channel: readStringOrNull(json, 'channel') ?? 'phone',
        agentId: readStringOrNull(json, 'agent_id'),
        leadId: readStringOrNull(json, 'lead_id'),
        campaignId: readStringOrNull(json, 'campaign_id'),
        from: readStringOrNull(json, 'from'),
        to: readStringOrNull(json, 'to'),
        durationSeconds: readIntOrNull(json, 'duration_seconds'),
        engine: readStringOrNull(json, 'engine'),
        recordingUrl: readStringOrNull(json, 'recording_url'),
        summary: readStringOrNull(json, 'summary'),
        costMicros: readIntOrNull(json, 'cost_micros'),
        metadata: readMap(json, 'metadata'),
        failureCode: readIntOrNull(json, 'failure_code'),
        failureReason: readStringOrNull(json, 'failure_reason'),
        startedAt: readDateTime(json, 'started_at'),
        endedAt: readDateTime(json, 'ended_at'),
      );

  /// The call's id.
  final String id;

  /// Stable id for this call across logs, usage and webhooks.
  final String sessionId;

  /// Where the call is in its life.
  final CallStatus status;

  /// Which way it went.
  final CallDirection direction;

  /// `phone` for a call over your SIP trunk, `web` for a realtime session
  /// from a browser or app.
  final String channel;

  /// The agent that held the conversation.
  final String? agentId;

  /// The lead it was attributed to.
  final String? leadId;

  /// The campaign that placed it, if any.
  final String? campaignId;

  /// The caller id presented.
  final String? from;

  /// The number dialled.
  final String? to;

  /// How long it lasted.
  final int? durationSeconds;

  /// Which engine served it.
  final String? engine;

  /// Where the recording is, when there is one.
  final String? recordingUrl;

  /// A summary of the conversation.
  final String? summary;

  /// What it cost, in micro-USD. 1,000,000 = $1.00.
  final int? costMicros;

  /// Whatever you attached to `calls.create`, returned verbatim. Null if you
  /// attached none.
  final Map<String, dynamic>? metadata;

  /// The Q.850 hangup cause, or null if the call connected. Branch on this
  /// rather than on [failureReason], which is prose: 17 busy, 19 no answer,
  /// 21 rejected by the carrier, 34 congestion, 102 timeout.
  final int? failureCode;

  /// What to do about the failure, in plain language.
  final String? failureReason;

  /// When it started. UTC.
  final DateTime? startedAt;

  /// When it ended. UTC.
  final DateTime? endedAt;
}

/// A call in full: the summary plus the transcript, provider errors and
/// transfers. `calls.retrieve` returns this.
class CallDetail extends Call {
  /// Builds a detailed call record.
  const CallDetail({
    required super.id,
    required super.sessionId,
    required super.status,
    required super.direction,
    super.channel,
    required this.errors,
    required this.transcript,
    required this.transfers,
    super.agentId,
    super.leadId,
    super.campaignId,
    super.from,
    super.to,
    super.durationSeconds,
    super.engine,
    super.recordingUrl,
    super.summary,
    super.costMicros,
    super.metadata,
    super.failureCode,
    super.failureReason,
    super.startedAt,
    super.endedAt,
  });

  /// Parses the API's shape.
  factory CallDetail.fromJson(Json json) {
    final base = Call.fromJson(json);
    return CallDetail(
      id: base.id,
      sessionId: base.sessionId,
      status: base.status,
      direction: base.direction,
      channel: base.channel,
      agentId: base.agentId,
      leadId: base.leadId,
      campaignId: base.campaignId,
      from: base.from,
      to: base.to,
      durationSeconds: base.durationSeconds,
      engine: base.engine,
      recordingUrl: base.recordingUrl,
      summary: base.summary,
      costMicros: base.costMicros,
      metadata: base.metadata,
      failureCode: base.failureCode,
      failureReason: base.failureReason,
      startedAt: base.startedAt,
      endedAt: base.endedAt,
      errors: readList(json, 'errors', CallError.fromJson),
      transcript: readList(json, 'transcript', TranscriptEntry.fromJson),
      transfers: readList(json, 'transfers', CallTransfer.fromJson),
    );
  }

  /// What providers reported while the call ran.
  final List<CallError> errors;

  /// The conversation.
  final List<TranscriptEntry> transcript;

  /// Attempts to hand the call to a person.
  final List<CallTransfer> transfers;
}

/// The body of `calls.create`. Spends credit and rings a real phone.
class CreateCall {
  /// Builds a place-call request.
  const CreateCall({
    required this.to,
    required this.agentId,
    this.fromNumberId,
    this.leadId,
    this.leadName,
    this.metadata,
  });

  /// The destination, E.164, e.g. `+14155551234`.
  final String to;

  /// The agent that will hold the conversation.
  final String agentId;

  /// Which of your numbers to call from. Defaults to the agent's own.
  final String? fromNumberId;

  /// An existing lead to attribute the call to. One is created if omitted.
  final String? leadId;

  /// Name for the auto-created lead; available as `{{name}}`.
  final String? leadName;

  /// Echoed back on the call and in webhooks. Not shown to the model.
  final Map<String, dynamic>? metadata;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'to': to,
        'agent_id': agentId,
        'from_number_id': fromNumberId,
        'lead_id': leadId,
        'lead_name': leadName,
        'metadata': metadata,
      });
}
