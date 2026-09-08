import '../json.dart';

/// How a trunk talks to the carrier.
enum SipTransport {
  /// Plain UDP, the SIP default.
  udp('udp'),

  /// TCP.
  tcp('tcp'),

  /// TLS.
  tls('tls'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const SipTransport(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [SipTransport.unknown].
  static SipTransport parse(String? raw) => SipTransport.values
      .firstWhere((v) => v.value == raw, orElse: () => SipTransport.unknown);
}

/// A number you own at your carrier, registered on a trunk.
class PhoneNumber {
  /// Builds a phone-number record.
  const PhoneNumber({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.name,
    this.sipTrunkId,
    this.inboundAgentId,
  });

  /// Parses the API's shape.
  factory PhoneNumber.fromJson(Json json) => PhoneNumber(
        id: readString(json, 'id'),
        phoneNumber: readString(json, 'phone_number'),
        name: readStringOrNull(json, 'name'),
        sipTrunkId: readStringOrNull(json, 'sip_trunk_id'),
        inboundAgentId: readStringOrNull(json, 'inbound_agent_id'),
        status: readString(json, 'status'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The record's id.
  final String id;

  /// E.164, e.g. `+14155550100`.
  final String phoneNumber;

  /// A label, e.g. `Main line`.
  final String? name;

  /// The trunk this number is routed through.
  final String? sipTrunkId;

  /// The agent that answers inbound calls. Without one they are rejected.
  final String? inboundAgentId;

  /// The number's state.
  final String status;

  /// When it was registered. UTC.
  final DateTime createdAt;
}

/// The body of `phoneNumbers.create`.
class CreatePhoneNumber {
  /// Builds a create request.
  const CreatePhoneNumber({
    required this.phoneNumber,
    required this.sipTrunkId,
    this.name,
    this.inboundAgentId,
  });

  /// E.164, e.g. `+14155550100`.
  final String phoneNumber;

  /// The trunk this number is routed through.
  final String sipTrunkId;

  /// A label, e.g. `Main line`.
  final String? name;

  /// The agent that answers inbound calls to this number.
  final String? inboundAgentId;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'phone_number': phoneNumber,
        'sip_trunk_id': sipTrunkId,
        'name': name,
        'inbound_agent_id': inboundAgentId,
      });
}

/// The body of `phoneNumbers.update`. Only the fields you set are changed.
class UpdatePhoneNumber {
  /// Builds a partial update.
  const UpdatePhoneNumber(
      {this.phoneNumber, this.sipTrunkId, this.name, this.inboundAgentId});

  /// E.164, e.g. `+14155550100`.
  final String? phoneNumber;

  /// The trunk this number is routed through.
  final String? sipTrunkId;

  /// A label.
  final String? name;

  /// The agent that answers inbound calls.
  final String? inboundAgentId;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'phone_number': phoneNumber,
        'sip_trunk_id': sipTrunkId,
        'name': name,
        'inbound_agent_id': inboundAgentId,
      });
}

/// Your own carrier, connected. Wixzel does not resell telephony.
class SipTrunk {
  /// Builds a SIP trunk record.
  const SipTrunk({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.transport,
    required this.sendPlus,
    required this.status,
    required this.createdAt,
    this.username,
    this.platformIp,
    this.originationUri,
    this.providerName,
  });

  /// Parses the API's shape.
  factory SipTrunk.fromJson(Json json) => SipTrunk(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        host: readString(json, 'host'),
        port: readInt(json, 'port'),
        transport: SipTransport.parse(readStringOrNull(json, 'transport')),
        username: readStringOrNull(json, 'username'),
        sendPlus: readBool(json, 'send_plus'),
        platformIp: readStringOrNull(json, 'platform_ip'),
        originationUri: readStringOrNull(json, 'origination_uri'),
        providerName: readStringOrNull(json, 'provider_name'),
        status: readString(json, 'status'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The trunk's id.
  final String id;

  /// A label, e.g. `Twilio`.
  final String name;

  /// The carrier's SIP host.
  final String host;

  /// The carrier's SIP port.
  final int port;

  /// How the trunk talks to the carrier.
  final SipTransport transport;

  /// The account username, when the carrier uses one.
  final String? username;

  /// Whether the leading `+` is kept when dialling.
  final bool sendPlus;

  /// The address calls are placed from. Allowlist it with your carrier, or
  /// the trunk looks configured while no call completes.
  final String? platformIp;

  /// Where your carrier must send INBOUND calls. Without it a number is
  /// bought, pointed at an agent, and simply never rings.
  final String? originationUri;

  /// Free text, e.g. `twilio`.
  final String? providerName;

  /// The trunk's state.
  final String status;

  /// When it was created. UTC.
  final DateTime createdAt;
}

/// The body of `sipTrunks.create`.
class CreateSipTrunk {
  /// Builds a create request.
  const CreateSipTrunk({
    required this.name,
    required this.host,
    this.port,
    this.transport,
    this.username,
    this.password,
    this.authRealm,
    this.defaultCallerId,
    this.dialPrefix,
    this.sendPlus,
    this.providerName,
  });

  /// A label, e.g. `My carrier`.
  final String name;

  /// The carrier's SIP host.
  final String host;

  /// The carrier's SIP port. Defaults to 5060, or 5061 for TLS.
  final int? port;

  /// How to talk to the carrier.
  final SipTransport? transport;

  /// The account username.
  final String? username;

  /// The account password. Stored encrypted and never returned.
  final String? password;

  /// The authentication realm, when the carrier needs one.
  final String? authRealm;

  /// Caller id to present when no phone number is chosen.
  final String? defaultCallerId;

  /// Digits prepended to every dialled number.
  final String? dialPrefix;

  /// Keep the leading `+` when dialling. Most carriers want true.
  final bool? sendPlus;

  /// Free text, e.g. `twilio`.
  final String? providerName;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'host': host,
        'port': port,
        'transport': transport?.value,
        'username': username,
        'password': password,
        'auth_realm': authRealm,
        'default_caller_id': defaultCallerId,
        'dial_prefix': dialPrefix,
        'send_plus': sendPlus,
        'provider_name': providerName,
      });
}

/// The body of `sipTrunks.update`. Only the fields you set are changed.
class UpdateSipTrunk {
  /// Builds a partial update.
  const UpdateSipTrunk({
    this.name,
    this.host,
    this.port,
    this.transport,
    this.username,
    this.password,
    this.authRealm,
    this.defaultCallerId,
    this.dialPrefix,
    this.sendPlus,
    this.providerName,
  });

  /// A label.
  final String? name;

  /// The carrier's SIP host.
  final String? host;

  /// The carrier's SIP port.
  final int? port;

  /// How to talk to the carrier.
  final SipTransport? transport;

  /// The account username.
  final String? username;

  /// The account password. Stored encrypted and never returned.
  final String? password;

  /// The authentication realm.
  final String? authRealm;

  /// Caller id to present when no phone number is chosen.
  final String? defaultCallerId;

  /// Digits prepended to every dialled number.
  final String? dialPrefix;

  /// Keep the leading `+` when dialling.
  final bool? sendPlus;

  /// Free text, e.g. `twilio`.
  final String? providerName;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'host': host,
        'port': port,
        'transport': transport?.value,
        'username': username,
        'password': password,
        'auth_realm': authRealm,
        'default_caller_id': defaultCallerId,
        'dial_prefix': dialPrefix,
        'send_plus': sendPlus,
        'provider_name': providerName,
      });
}

/// What Asterisk itself thinks of a trunk.
class SipTrunkAsteriskStatus {
  /// Builds the Asterisk half of a status report.
  const SipTrunkAsteriskStatus({
    required this.connected,
    required this.endpointKnown,
    required this.detail,
    this.endpointState,
    this.reachable,
    this.roundTripMs,
  });

  /// Parses the API's shape.
  factory SipTrunkAsteriskStatus.fromJson(Json json) => SipTrunkAsteriskStatus(
        connected: readBool(json, 'connected'),
        endpointKnown: readBool(json, 'endpoint_known'),
        endpointState: readStringOrNull(json, 'endpoint_state'),
        reachable: readBoolOrNull(json, 'reachable'),
        roundTripMs: readDoubleOrNull(json, 'round_trip_ms'),
        detail: readString(json, 'detail'),
      );

  /// Whether the server currently holds an ARI connection.
  final bool connected;

  /// False until the trunk has synced into Asterisk's configuration.
  final bool endpointKnown;

  /// Asterisk's own word for the endpoint's state.
  final String? endpointState;

  /// Asterisk's qualify result.
  final bool? reachable;

  /// The qualify round trip.
  final double? roundTripMs;

  /// What the numbers mean, in prose.
  final String detail;
}

/// A live network probe of the carrier, from the platform.
class SipTrunkProbe {
  /// Builds the probe half of a status report.
  const SipTrunkProbe(
      {required this.reachable, required this.method, required this.detail});

  /// Parses the API's shape.
  factory SipTrunkProbe.fromJson(Json json) => SipTrunkProbe(
        reachable: readBool(json, 'reachable'),
        method: readString(json, 'method'),
        detail: readString(json, 'detail'),
      );

  /// Whether the carrier answered. Many carriers drop unauthenticated
  /// probes, so false is not proof the trunk is broken.
  final bool reachable;

  /// How it was probed, e.g. a TCP connect or a SIP OPTIONS.
  final String method;

  /// What happened, in prose.
  final String detail;
}

/// A call that recently failed on this trunk.
class SipTrunkRecentFailure {
  /// Builds a recent failure.
  const SipTrunkRecentFailure({
    required this.callId,
    this.failureCode,
    this.failureReason,
    this.at,
  });

  /// Parses the API's shape.
  factory SipTrunkRecentFailure.fromJson(Json json) => SipTrunkRecentFailure(
        callId: readString(json, 'call_id'),
        failureCode: readIntOrNull(json, 'failure_code'),
        failureReason: readStringOrNull(json, 'failure_reason'),
        at: readDateTime(json, 'at'),
      );

  /// Which call.
  final String callId;

  /// The Q.850 hangup cause.
  final int? failureCode;

  /// What to do about it, in plain language.
  final String? failureReason;

  /// When it failed. UTC.
  final DateTime? at;
}

/// Asterisk's view and a live probe, side by side.
///
/// Where the two disagree IS the diagnosis: a carrier that ignores
/// unauthenticated probes shows `probe.reachable` false while Asterisk
/// reports it healthy, and that is normal.
class SipTrunkStatus {
  /// Builds a status report.
  const SipTrunkStatus({
    required this.sipTrunkId,
    required this.asterisk,
    required this.probe,
    required this.recentFailures,
    this.name,
    this.host,
    this.port,
    this.transport,
    this.originationUri,
  });

  /// Parses the API's shape.
  factory SipTrunkStatus.fromJson(Json json) => SipTrunkStatus(
        sipTrunkId: readString(json, 'sip_trunk_id'),
        name: readStringOrNull(json, 'name'),
        host: readStringOrNull(json, 'host'),
        port: readIntOrNull(json, 'port'),
        transport: readStringOrNull(json, 'transport'),
        originationUri: readStringOrNull(json, 'origination_uri'),
        asterisk:
            readObject(json, 'asterisk', SipTrunkAsteriskStatus.fromJson) ??
                const SipTrunkAsteriskStatus(
                    connected: false, endpointKnown: false, detail: ''),
        probe: readObject(json, 'probe', SipTrunkProbe.fromJson) ??
            const SipTrunkProbe(reachable: false, method: '', detail: ''),
        recentFailures:
            readList(json, 'recent_failures', SipTrunkRecentFailure.fromJson),
      );

  /// Which trunk.
  final String sipTrunkId;

  /// The trunk's label.
  final String? name;

  /// The carrier's SIP host.
  final String? host;

  /// The carrier's SIP port.
  final int? port;

  /// How the trunk talks to the carrier.
  final String? transport;

  /// Where the carrier must send inbound calls. Repeated here because a
  /// number that never rings is usually this.
  final String? originationUri;

  /// What Asterisk thinks.
  final SipTrunkAsteriskStatus asterisk;

  /// What a live probe found.
  final SipTrunkProbe probe;

  /// Calls that recently failed on this trunk.
  final List<SipTrunkRecentFailure> recentFailures;
}

/// The result of poking the carrier.
class SipTrunkTest {
  /// Builds a test result.
  const SipTrunkTest({
    required this.sipTrunkId,
    required this.reachable,
    required this.method,
    required this.detail,
    required this.testedAt,
  });

  /// Parses the API's shape.
  factory SipTrunkTest.fromJson(Json json) => SipTrunkTest(
        sipTrunkId: readString(json, 'sip_trunk_id'),
        reachable: readBool(json, 'reachable'),
        method: readString(json, 'method'),
        detail: readString(json, 'detail'),
        testedAt: readDateTimeRequired(json, 'tested_at'),
      );

  /// Which trunk.
  final String sipTrunkId;

  /// Whether the carrier answered.
  final bool reachable;

  /// How it was probed.
  final String method;

  /// What happened, in prose.
  final String detail;

  /// When. UTC.
  final DateTime testedAt;
}

/// One line from the SIP engine's recent events.
class SipLogEntry {
  /// Builds a log entry.
  const SipLogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.callId,
    this.at,
  });

  /// Parses the API's shape.
  factory SipLogEntry.fromJson(Json json) => SipLogEntry(
        id: readInt(json, 'id'),
        level: readString(json, 'level'),
        message: readString(json, 'message'),
        callId: readStringOrNull(json, 'call_id'),
        at: readDateTime(json, 'at'),
      );

  /// Monotonic within the buffer. Pass the highest you have seen as
  /// `sinceId` on the next poll.
  final int id;

  /// How severe.
  final String level;

  /// What happened.
  final String message;

  /// Which call, when the line belongs to one.
  final String? callId;

  /// When. UTC.
  final DateTime? at;
}

/// A window onto the SIP engine's in-memory ring buffer.
///
/// A live diagnostic rather than an audit trail: it does not survive a
/// restart and old entries fall off.
class SipLogList {
  /// Builds a log window.
  const SipLogList({required this.data, required this.lastId});

  /// Parses the API's shape.
  factory SipLogList.fromJson(Json json) => SipLogList(
        data: readList(json, 'data', SipLogEntry.fromJson),
        lastId: readInt(json, 'last_id'),
      );

  /// The entries.
  final List<SipLogEntry> data;

  /// Pass as `sinceId` on the next poll to receive only new entries.
  final int lastId;
}
