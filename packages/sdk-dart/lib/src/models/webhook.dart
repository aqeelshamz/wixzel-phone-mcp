import '../json.dart';

/// An event the platform can POST to your webhook URL.
///
/// The wire values are camelCase, which is unusual for this API and
/// deliberate: they are the literal `event` field of the JSON delivered to
/// your endpoint, not API field names, and they predate `/v1`.
enum WebhookEvent {
  /// A call arrived on one of your numbers.
  inboundCall('inboundCall'),

  /// A call was placed.
  outboundCall('outboundCall'),

  /// A call finished, with its duration and outcome.
  callCompleted('callCompleted'),

  /// A lead was created.
  leadCreated('leadCreated'),

  /// A lead was marked qualified.
  leadQualified('leadQualified'),

  /// A campaign finished its list.
  campaignCompleted('campaignCompleted'),

  /// An appointment was booked, including by an agent mid-call.
  appointmentBooked('appointmentBooked'),

  /// An appointment was cancelled.
  appointmentCanceled('appointmentCanceled'),

  /// A call was handed to a human. SIP calls only.
  callTransferred('callTransferred'),

  /// A transfer to a human did not connect.
  transferFailed('transferFailed'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const WebhookEvent(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [WebhookEvent.unknown].
  static WebhookEvent parse(String? raw) => WebhookEvent.values
      .firstWhere((v) => v.value == raw, orElse: () => WebhookEvent.unknown);
}

/// The account's webhook endpoint. There is exactly one.
class Webhook {
  /// Builds a webhook configuration.
  const Webhook({
    required this.enabled,
    required this.events,
    required this.secretSet,
    this.url,
  });

  /// Parses the API's shape.
  factory Webhook.fromJson(Json json) => Webhook(
        url: readStringOrNull(json, 'url'),
        enabled: readBool(json, 'enabled'),
        events: readStringList(json, 'events')
            .map(WebhookEvent.parse)
            .toList(growable: false),
        secretSet: readBool(json, 'secret_set'),
      );

  /// Where events are POSTed. Null until you set one.
  final String? url;

  /// The master switch. False sends nothing, whatever [events] says.
  final bool enabled;

  /// The events you are subscribed to.
  final List<WebhookEvent> events;

  /// Whether a signing secret exists. The secret itself is never returned.
  final bool secretSet;
}

/// The body of `webhooks.update`.
///
/// Only the fields you set are changed — except [events], which replaces the
/// subscription entirely.
class UpdateWebhook {
  /// Builds a webhook update.
  const UpdateWebhook({this.url, this.enabled, this.events});

  /// The HTTPS endpoint to POST events to. Must resolve publicly.
  final String? url;

  /// Turn delivery on or off.
  final bool? enabled;

  /// The complete set of events to receive, not a delta.
  final List<WebhookEvent>? events;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'url': url,
        'enabled': enabled,
        'events': events?.map((e) => e.value).toList(),
      });
}

/// A freshly minted signing secret. Returned once, by `webhooks.rotateSecret`.
class WebhookSecret {
  /// Builds a secret result.
  const WebhookSecret({required this.secret});

  /// Parses the API's shape.
  factory WebhookSecret.fromJson(Json json) =>
      WebhookSecret(secret: readString(json, 'secret'));

  /// The secret. Shown once and never again: store it now.
  final String secret;
}

/// One attempt to POST one event to your endpoint.
class WebhookDelivery {
  /// Builds a delivery record.
  const WebhookDelivery({
    required this.event,
    required this.url,
    required this.attempt,
    required this.status,
    required this.durationMs,
    required this.willRetry,
    required this.occurredAt,
    this.responseStatus,
    this.error,
  });

  /// Parses the API's shape.
  factory WebhookDelivery.fromJson(Json json) => WebhookDelivery(
        event: WebhookEvent.parse(readStringOrNull(json, 'event')),
        url: readString(json, 'url'),
        attempt: readInt(json, 'attempt'),
        status: readString(json, 'status'),
        responseStatus: readIntOrNull(json, 'response_status'),
        error: readStringOrNull(json, 'error'),
        durationMs: readInt(json, 'duration_ms'),
        willRetry: readBool(json, 'will_retry'),
        occurredAt: readDateTimeRequired(json, 'occurred_at'),
      );

  /// Which event was sent.
  final WebhookEvent event;

  /// Where it was sent — the URL configured at the time, not the current one.
  final String url;

  /// 1 for the first POST of this event.
  final int attempt;

  /// `delivered` (a 2xx) or `failed`.
  final String status;

  /// Your endpoint's HTTP status, or null when nothing answered at all.
  final int? responseStatus;

  /// Why it failed, at the transport level. Never a response body.
  final String? error;

  /// How long the request took.
  final int durationMs;

  /// Whether another attempt was scheduled.
  final bool willRetry;

  /// When the attempt was made. UTC.
  final DateTime occurredAt;
}
