import '../models/billing.dart';
import '../page.dart';
import '../response.dart';
import '../transport.dart';

/// Billing: the prepaid balance, its history, and adding to it.
class Billing {
  /// Binds the resource to a transport.
  const Billing(this._transport);

  final Transport _transport;

  /// The balance, what live calls have reserved, and what is left.
  Future<Balance> balance() =>
      _transport.request('GET', '/v1/billing/balance', Balance.fromJson);

  /// Every movement on the account. Balances reconcile exactly.
  Future<Page<LedgerEntry>> ledger(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/billing/ledger', LedgerEntry.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Starts a top-up. Returns a `checkoutUrl` a person must open; credit
  /// lands once payment settles, not when this returns.
  Future<Topup> createTopup(CreateTopup body, {String? idempotencyKey}) =>
      _transport.request(
        'POST',
        '/v1/billing/topups',
        Topup.fromJson,
        body: body.toJson(),
        idempotent: true,
        idempotencyKey: idempotencyKey,
      );

  /// As [createTopup], but keeps the request id and whether the server
  /// replayed an earlier request.
  Future<WixzelResponse<Topup>> createTopupWithResponse(CreateTopup body,
          {String? idempotencyKey}) =>
      _transport.requestWithResponse(
        'POST',
        '/v1/billing/topups',
        Topup.fromJson,
        body: body.toJson(),
        idempotent: true,
        idempotencyKey: idempotencyKey,
      );
}
