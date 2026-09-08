import '../models/campaign.dart';
import '../page.dart';
import '../transport.dart';

/// Campaigns: one agent calling a list of leads.
class Campaigns {
  /// Binds the resource to a transport.
  const Campaigns(this._transport);

  final Transport _transport;

  /// Lists campaigns.
  Future<Page<Campaign>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/campaigns', Campaign.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Creates a campaign. Creating does not dial anyone; call [start].
  Future<Campaign> create(CreateCampaign body) => _transport
      .request('POST', '/v1/campaigns', Campaign.fromJson, body: body.toJson());

  /// Fetches one campaign.
  Future<Campaign> retrieve(String id) => _transport.request(
      'GET', '/v1/campaigns/${Uri.encodeComponent(id)}', Campaign.fromJson);

  /// Deletes a campaign. Pause it first if it is running.
  Future<void> delete(String id) => _transport.requestVoid(
      'DELETE', '/v1/campaigns/${Uri.encodeComponent(id)}');

  /// Begins calling every lead. Spends credit; refused with
  /// `insufficient_credits` when the balance cannot cover the run.
  Future<Campaign> start(String id) => _transport.request('POST',
      '/v1/campaigns/${Uri.encodeComponent(id)}/start', Campaign.fromJson);

  /// Stops placing new calls and hangs up any in flight.
  Future<Campaign> pause(String id) => _transport.request('POST',
      '/v1/campaigns/${Uri.encodeComponent(id)}/pause', Campaign.fromJson);
}
