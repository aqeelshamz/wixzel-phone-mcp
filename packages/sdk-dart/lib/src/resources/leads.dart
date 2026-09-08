import '../models/lead.dart';
import '../page.dart';
import '../transport.dart';

/// Leads: the contacts agents call.
class Leads {
  /// Binds the resource to a transport.
  const Leads(this._transport);

  final Transport _transport;

  /// Lists leads. Filter by tag or free-text search.
  Future<Page<Lead>> list({
    int? limit,
    String? startingAfter,
    String? endingBefore,
    String? tag,
    String? search,
  }) =>
      _transport.list('/v1/leads', Lead.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
        'tag': tag,
        'search': search,
      });

  /// Creates one lead.
  Future<Lead> create(CreateLead body) => _transport
      .request('POST', '/v1/leads', Lead.fromJson, body: body.toJson());

  /// Creates up to 1,000 leads at once. Rows are validated individually;
  /// check `failedCount` and `errors`.
  Future<BulkLeadResult> bulkCreate(BulkCreateLeads body) =>
      _transport.request('POST', '/v1/leads/bulk', BulkLeadResult.fromJson,
          body: body.toJson());

  /// Fetches one lead.
  Future<Lead> retrieve(String id) => _transport.request(
      'GET', '/v1/leads/${Uri.encodeComponent(id)}', Lead.fromJson);

  /// Changes a lead. Only the fields you set are changed.
  Future<Lead> update(String id, UpdateLead body) => _transport.request(
      'PATCH', '/v1/leads/${Uri.encodeComponent(id)}', Lead.fromJson,
      body: body.toJson());

  /// Deletes a lead.
  Future<void> delete(String id) =>
      _transport.requestVoid('DELETE', '/v1/leads/${Uri.encodeComponent(id)}');
}
