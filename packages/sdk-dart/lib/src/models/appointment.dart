import '../json.dart';

/// Where an appointment stands.
enum AppointmentStatus {
  /// Booked and upcoming.
  scheduled('scheduled'),

  /// It happened.
  completed('completed'),

  /// It will not happen.
  canceled('canceled'),

  /// A value this version of the SDK does not know.
  unknown('unknown');

  const AppointmentStatus(this.value);

  /// The wire value.
  final String value;

  /// Maps a wire value, falling back to [AppointmentStatus.unknown].
  static AppointmentStatus parse(String? raw) =>
      AppointmentStatus.values.firstWhere((v) => v.value == raw,
          orElse: () => AppointmentStatus.unknown);
}

/// A booking made by an agent or created directly.
class Appointment {
  /// Builds an appointment record.
  const Appointment({
    required this.id,
    required this.phoneNumber,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    required this.createdAt,
    this.clientName,
    this.notes,
    this.agentId,
    this.leadId,
  });

  /// Parses the API's shape.
  factory Appointment.fromJson(Json json) => Appointment(
        id: readString(json, 'id'),
        clientName: readStringOrNull(json, 'client_name'),
        phoneNumber: readString(json, 'phone_number'),
        dateTime: readDateTimeRequired(json, 'date_time'),
        durationMinutes: readInt(json, 'duration_minutes'),
        status: AppointmentStatus.parse(readStringOrNull(json, 'status')),
        notes: readStringOrNull(json, 'notes'),
        agentId: readStringOrNull(json, 'agent_id'),
        leadId: readStringOrNull(json, 'lead_id'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The appointment's id.
  final String id;

  /// Who it is with.
  final String? clientName;

  /// Their number, E.164.
  final String phoneNumber;

  /// When it starts. UTC.
  final DateTime dateTime;

  /// How long it runs.
  final int durationMinutes;

  /// Where it stands.
  final AppointmentStatus status;

  /// Anything worth remembering.
  final String? notes;

  /// The agent that booked it.
  final String? agentId;

  /// The lead it belongs to.
  final String? leadId;

  /// When it was created. UTC.
  final DateTime createdAt;
}

/// The body of `appointments.create`.
class CreateAppointment {
  /// Builds a booking request.
  const CreateAppointment({
    required this.phoneNumber,
    required this.dateTime,
    required this.agentId,
    required this.leadId,
    this.clientName,
    this.durationMinutes,
    this.notes,
  });

  /// The client's number, E.164.
  final String phoneNumber;

  /// When it starts. UTC.
  final DateTime dateTime;

  /// The agent it belongs to.
  final String agentId;

  /// The lead it belongs to.
  final String leadId;

  /// Who it is with.
  final String? clientName;

  /// How long it runs.
  final int? durationMinutes;

  /// Anything worth remembering.
  final String? notes;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'phone_number': phoneNumber,
        'date_time': isoUtc(dateTime),
        'agent_id': agentId,
        'lead_id': leadId,
        'client_name': clientName,
        'duration_minutes': durationMinutes,
        'notes': notes,
      });
}

/// The body of `appointments.update`. Only the fields you set are changed.
class UpdateAppointment {
  /// Builds a partial update.
  const UpdateAppointment({
    this.phoneNumber,
    this.dateTime,
    this.agentId,
    this.leadId,
    this.clientName,
    this.durationMinutes,
    this.notes,
  });

  /// The client's number, E.164.
  final String? phoneNumber;

  /// When it starts. UTC.
  final DateTime? dateTime;

  /// The agent it belongs to.
  final String? agentId;

  /// The lead it belongs to.
  final String? leadId;

  /// Who it is with.
  final String? clientName;

  /// How long it runs.
  final int? durationMinutes;

  /// Anything worth remembering.
  final String? notes;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'phone_number': phoneNumber,
        'date_time': dateTime == null ? null : isoUtc(dateTime!),
        'agent_id': agentId,
        'lead_id': leadId,
        'client_name': clientName,
        'duration_minutes': durationMinutes,
        'notes': notes,
      });
}
