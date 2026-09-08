import '../json.dart';

/// Which part of a call a charge came from.
enum UsageComponent {
  /// Speech-to-text.
  stt('stt'),

  /// The language model.
  llm('llm'),

  /// Text-to-speech.
  tts('tts'),

  /// A monolithic realtime model.
  realtime('realtime'),

  /// Carriage of the call itself.
  telephony('telephony'),

  /// The flat per-call platform fee.
  platformFee('platform_fee'),

  /// Platform API usage.
  platformApi('platform_api'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const UsageComponent(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [UsageComponent.unknown].
  static UsageComponent parse(String? raw) => UsageComponent.values
      .firstWhere((v) => v.value == raw, orElse: () => UsageComponent.unknown);
}

/// What moved the balance.
enum LedgerKind {
  /// Credit added.
  topup('topup'),

  /// Credit spent.
  usage('usage'),

  /// Credit returned.
  refund('refund'),

  /// A manual correction.
  adjustment('adjustment'),

  /// Promotional credit.
  promo('promo'),

  /// Spending past the balance.
  overage('overage'),

  /// A payment reversed by the card issuer.
  chargeback('chargeback'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const LedgerKind(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [LedgerKind.unknown].
  static LedgerKind parse(String? raw) => LedgerKind.values
      .firstWhere((v) => v.value == raw, orElse: () => LedgerKind.unknown);
}

/// Where a top-up stands.
enum TopupStatus {
  /// Waiting for payment.
  pending('pending'),

  /// Paid and credited.
  completed('completed'),

  /// Payment failed.
  failed('failed'),

  /// Refunded.
  refunded('refunded'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const TopupStatus(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [TopupStatus.unknown].
  static TopupStatus parse(String? raw) => TopupStatus.values
      .firstWhere((v) => v.value == raw, orElse: () => TopupStatus.unknown);
}

/// One billable line. The sum of a call's events is what it cost.
class UsageEvent {
  /// Builds a usage event.
  const UsageEvent({
    required this.component,
    required this.provider,
    required this.model,
    required this.unit,
    required this.quantity,
    required this.unitPriceMicros,
    required this.priceMicros,
    required this.occurredAt,
    this.sessionId,
  });

  /// Parses the API's shape.
  factory UsageEvent.fromJson(Json json) => UsageEvent(
        sessionId: readStringOrNull(json, 'session_id'),
        component: UsageComponent.parse(readStringOrNull(json, 'component')),
        provider: readString(json, 'provider'),
        model: readString(json, 'model'),
        unit: readString(json, 'unit'),
        quantity: readDouble(json, 'quantity'),
        unitPriceMicros: readDouble(json, 'unit_price_micros'),
        priceMicros: readInt(json, 'price_micros'),
        occurredAt: readDateTimeRequired(json, 'occurred_at'),
      );

  /// Which call, when the line belongs to one.
  final String? sessionId;

  /// Which part of the call.
  final UsageComponent component;

  /// Whose model.
  final String provider;

  /// Which model.
  final String model;

  /// What is being counted: seconds, tokens, characters.
  final String unit;

  /// How much of it.
  final double quantity;

  /// The rate applied. Fractional; sub-micro rates are normal.
  final double unitPriceMicros;

  /// What this line cost, in micro-USD. 1,000,000 = $1.00.
  final int priceMicros;

  /// When. UTC.
  final DateTime occurredAt;
}

/// One row of a usage summary.
class UsageComponentTotal {
  /// Builds a component total.
  const UsageComponentTotal({
    required this.component,
    required this.provider,
    required this.model,
    required this.quantity,
    required this.priceMicros,
  });

  /// Parses the API's shape.
  factory UsageComponentTotal.fromJson(Json json) => UsageComponentTotal(
        component: UsageComponent.parse(readStringOrNull(json, 'component')),
        provider: readString(json, 'provider'),
        model: readString(json, 'model'),
        quantity: readDouble(json, 'quantity'),
        priceMicros: readInt(json, 'price_micros'),
      );

  /// Which part of the call.
  final UsageComponent component;

  /// Whose model.
  final String provider;

  /// Which model.
  final String model;

  /// How much was used.
  final double quantity;

  /// What it cost, in micro-USD.
  final int priceMicros;
}

/// Spend over a period, by component.
class UsageSummary {
  /// Builds a usage summary.
  const UsageSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.totalMicros,
    required this.totalDisplay,
    required this.byComponent,
  });

  /// Parses the API's shape.
  factory UsageSummary.fromJson(Json json) => UsageSummary(
        periodStart: readDateTimeRequired(json, 'period_start'),
        periodEnd: readDateTimeRequired(json, 'period_end'),
        totalMicros: readInt(json, 'total_micros'),
        totalDisplay: readString(json, 'total_display'),
        byComponent:
            readList(json, 'by_component', UsageComponentTotal.fromJson),
      );

  /// Start of the window. UTC.
  final DateTime periodStart;

  /// End of the window. UTC.
  final DateTime periodEnd;

  /// The total, in micro-USD. 1,000,000 = $1.00.
  final int totalMicros;

  /// The total, formatted for people.
  final String totalDisplay;

  /// The breakdown.
  final List<UsageComponentTotal> byComponent;
}

/// The prepaid balance.
class Balance {
  /// Builds a balance.
  const Balance({
    required this.balanceMicros,
    required this.balanceDisplay,
    required this.heldMicros,
    required this.availableMicros,
    required this.currency,
    required this.lowBalanceThresholdMicros,
  });

  /// Parses the API's shape.
  factory Balance.fromJson(Json json) => Balance(
        balanceMicros: readInt(json, 'balance_micros'),
        balanceDisplay: readString(json, 'balance_display'),
        heldMicros: readInt(json, 'held_micros'),
        availableMicros: readInt(json, 'available_micros'),
        currency: readString(json, 'currency'),
        lowBalanceThresholdMicros:
            readInt(json, 'low_balance_threshold_micros'),
      );

  /// What the account holds, in micro-USD. 1,000,000 = $1.00.
  final int balanceMicros;

  /// The balance, formatted for people.
  final String balanceDisplay;

  /// What live calls have reserved.
  final int heldMicros;

  /// What is left to spend: balance minus holds.
  final int availableMicros;

  /// Always `USD` today.
  final String currency;

  /// Where the low-balance warning starts.
  final int lowBalanceThresholdMicros;
}

/// One movement on the account.
class LedgerEntry {
  /// Builds a ledger entry.
  const LedgerEntry({
    required this.kind,
    required this.amountMicros,
    required this.balanceAfterMicros,
    required this.createdAt,
    this.refType,
    this.refId,
  });

  /// Parses the API's shape.
  factory LedgerEntry.fromJson(Json json) => LedgerEntry(
        kind: LedgerKind.parse(readStringOrNull(json, 'kind')),
        amountMicros: readInt(json, 'amount_micros'),
        balanceAfterMicros: readInt(json, 'balance_after_micros'),
        refType: readStringOrNull(json, 'ref_type'),
        refId: readStringOrNull(json, 'ref_id'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// What moved the balance.
  final LedgerKind kind;

  /// Signed, in micro-USD. Negative is a debit.
  final int amountMicros;

  /// The balance after this entry.
  final int balanceAfterMicros;

  /// What it refers to, e.g. a call.
  final String? refType;

  /// Which one.
  final String? refId;

  /// When. UTC.
  final DateTime createdAt;
}

/// A request to add credit. Credit lands once payment settles.
class Topup {
  /// Builds a top-up record.
  const Topup({
    required this.id,
    required this.status,
    required this.amountUsd,
    required this.createdAt,
    this.creditedMicros,
    this.checkoutUrl,
  });

  /// Parses the API's shape.
  factory Topup.fromJson(Json json) => Topup(
        id: readString(json, 'id'),
        status: TopupStatus.parse(readStringOrNull(json, 'status')),
        amountUsd: readDouble(json, 'amount_usd'),
        creditedMicros: readIntOrNull(json, 'credited_micros'),
        checkoutUrl: readStringOrNull(json, 'checkout_url'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The top-up's id.
  final String id;

  /// Where it stands.
  final TopupStatus status;

  /// How much was asked for, in US dollars.
  final double amountUsd;

  /// What was actually credited, once it settles.
  final int? creditedMicros;

  /// Send the customer here to pay. A person must open it.
  final String? checkoutUrl;

  /// When it was started. UTC.
  final DateTime createdAt;
}

/// The body of `billing.createTopup`.
class CreateTopup {
  /// Builds a top-up request.
  const CreateTopup({required this.amountUsd, this.returnUrl});

  /// Amount to add, in US dollars.
  final double amountUsd;

  /// Where to send the customer after checkout.
  final String? returnUrl;

  /// The API's shape, without the nulls.
  Json toJson() =>
      omitNulls({'amount_usd': amountUsd, 'return_url': returnUrl});
}
