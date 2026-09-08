import '../models/billing.dart';
import '../page.dart';
import '../transport.dart';

/// Usage: every billable line, and the totals.
class Usage {
  /// Binds the resource to a transport.
  const Usage(this._transport);

  final Transport _transport;

  /// Itemised events. Filter by [sessionId] to see exactly what one call
  /// cost; the sum equals what was debited.
  Future<Page<UsageEvent>> events({
    int? limit,
    String? startingAfter,
    String? endingBefore,
    String? sessionId,
    UsageComponent? component,
    DateTime? start,
    DateTime? end,
  }) =>
      _transport.list('/v1/usage/events', UsageEvent.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
        'session_id': sessionId,
        'component': component?.value,
        'start': start,
        'end': end,
      });

  /// Spend over a period, by component, provider and model.
  Future<UsageSummary> summary({DateTime? start, DateTime? end}) =>
      _transport.request(
        'GET',
        '/v1/usage/summary',
        UsageSummary.fromJson,
        query: {'start': start, 'end': end},
      );
}
