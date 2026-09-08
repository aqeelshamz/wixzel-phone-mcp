import '../json.dart';

/// A contact an agent can call.
class Lead {
  /// Builds a lead record.
  const Lead({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.tags,
    required this.createdAt,
    this.fields,
  });

  /// Parses the API's shape.
  factory Lead.fromJson(Json json) => Lead(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        phoneNumber: readString(json, 'phone_number'),
        fields: readMap(json, 'fields'),
        tags: readStringList(json, 'tags'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The lead's id.
  final String id;

  /// The person's name.
  final String name;

  /// E.164, e.g. `+14155551234`.
  final String phoneNumber;

  /// Arbitrary data, usable as `{{merge}}` fields in prompts.
  final Map<String, dynamic>? fields;

  /// Tags for filtering.
  final List<String> tags;

  /// When the lead was created. UTC.
  final DateTime createdAt;
}

/// The body of `leads.create`.
class CreateLead {
  /// Builds a create-lead request.
  const CreateLead({
    required this.name,
    required this.phoneNumber,
    this.fields,
    this.tags,
  });

  /// The person's name.
  final String name;

  /// E.164, e.g. `+14155551234`.
  final String phoneNumber;

  /// Arbitrary data, usable as `{{merge}}` fields in prompts.
  final Map<String, dynamic>? fields;

  /// Tags for filtering.
  final List<String>? tags;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'phone_number': phoneNumber,
        'fields': fields,
        'tags': tags,
      });
}

/// The body of `leads.update`. Only the fields you set are changed.
class UpdateLead {
  /// Builds a partial update.
  const UpdateLead({this.name, this.phoneNumber, this.fields, this.tags});

  /// The person's name.
  final String? name;

  /// E.164, e.g. `+14155551234`.
  final String? phoneNumber;

  /// Arbitrary data, usable as `{{merge}}` fields in prompts.
  final Map<String, dynamic>? fields;

  /// Tags for filtering.
  final List<String>? tags;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'phone_number': phoneNumber,
        'fields': fields,
        'tags': tags,
      });
}

/// The body of `leads.bulkCreate`. Up to 1,000 rows.
class BulkCreateLeads {
  /// Builds a bulk import.
  const BulkCreateLeads(this.leads);

  /// The rows to create. Validated individually.
  final List<CreateLead> leads;

  /// The API's shape.
  Json toJson() => {'leads': leads.map((l) => l.toJson()).toList()};
}

/// A row the bulk import refused, with its position in the submitted array.
class BulkLeadError {
  /// Builds a rejected row.
  const BulkLeadError(
      {required this.index, required this.phoneNumber, required this.error});

  /// Parses the API's shape.
  factory BulkLeadError.fromJson(Json json) => BulkLeadError(
        index: readInt(json, 'index'),
        phoneNumber: readString(json, 'phone_number'),
        error: readString(json, 'error'),
      );

  /// Position in the array you sent.
  final int index;

  /// The number on that row.
  final String phoneNumber;

  /// Why it was refused.
  final String error;
}

/// What a bulk import created, and what it refused.
///
/// Partial success is the contract: check [failedCount] and [errors].
class BulkLeadResult {
  /// Builds a bulk result.
  const BulkLeadResult({
    required this.createdCount,
    required this.failedCount,
    required this.data,
    required this.errors,
  });

  /// Parses the API's shape.
  factory BulkLeadResult.fromJson(Json json) => BulkLeadResult(
        createdCount: readInt(json, 'created_count'),
        failedCount: readInt(json, 'failed_count'),
        data: readList(json, 'data', Lead.fromJson),
        errors: readList(json, 'errors', BulkLeadError.fromJson),
      );

  /// How many rows were created.
  final int createdCount;

  /// How many were refused.
  final int failedCount;

  /// The leads that were created.
  final List<Lead> data;

  /// The rows that were refused, with their positions.
  final List<BulkLeadError> errors;
}
