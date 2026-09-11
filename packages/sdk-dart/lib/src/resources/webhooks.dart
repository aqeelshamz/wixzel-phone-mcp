import '../models/webhook.dart';
import '../page.dart';
import '../transport.dart';

/// Webhooks: where events are sent, and what happened when they got there.
///
/// A singleton, not a collection — one endpoint per account — so there is a
/// [retrieve] and no `list`. [deliveries] is the list, and it lists attempts.
class Webhooks {
  /// Binds the resource to a transport.
  const Webhooks(this._transport);

  final Transport _transport;

  /// The configured endpoint. The signing secret is never returned; only
  /// whether one is set.
  Future<Webhook> retrieve() =>
      _transport.request('GET', '/v1/webhook', Webhook.fromJson);

  /// Changes the endpoint. Only the fields you set change — except `events`,
  /// which replaces the subscription entirely.
  Future<Webhook> update(UpdateWebhook body) => _transport
      .request('PATCH', '/v1/webhook', Webhook.fromJson, body: body.toJson());

  /// Mints a new signing secret and returns it once.
  ///
  /// The old secret stops verifying immediately, so a receiver that checks
  /// signatures rejects events until it has the new one.
  Future<WebhookSecret> rotateSecret() => _transport.request(
      'POST', '/v1/webhook/rotate-secret', WebhookSecret.fromJson);

  /// POSTs one sample event now and returns what the endpoint answered.
  ///
  /// Ignores `enabled` and the event subscription on purpose: this is how you
  /// check an endpoint works before turning delivery on.
  Future<WebhookDelivery> test(WebhookEvent event) => _transport.request(
        'POST',
        '/v1/webhook/test',
        WebhookDelivery.fromJson,
        body: {'event': event.value},
      );

  /// Every POST that was made, newest first.
  ///
  /// One record per attempt, so an event delivered on its third try is three
  /// records. A null `responseStatus` means nothing answered at all.
  Future<Page<WebhookDelivery>> deliveries({
    WebhookEvent? event,
    String? status,
    DateTime? start,
    DateTime? end,
    int? limit,
    String? startingAfter,
    String? endingBefore,
  }) =>
      _transport.list('/v1/webhook/deliveries', WebhookDelivery.fromJson,
          query: {
            'event': event?.value,
            'status': status,
            'start': start?.toUtc().toIso8601String(),
            'end': end?.toUtc().toIso8601String(),
            'limit': limit,
            'starting_after': startingAfter,
            'ending_before': endingBefore,
          });
}
