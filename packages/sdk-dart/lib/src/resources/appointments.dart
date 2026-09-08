import '../models/appointment.dart';
import '../page.dart';
import '../transport.dart';

/// Appointments booked by agents or created directly.
class Appointments {
  /// Binds the resource to a transport.
  const Appointments(this._transport);

  final Transport _transport;

  /// Lists appointments.
  Future<Page<Appointment>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/appointments', Appointment.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Creates one.
  Future<Appointment> create(CreateAppointment body) =>
      _transport.request('POST', '/v1/appointments', Appointment.fromJson,
          body: body.toJson());

  /// Fetches one.
  Future<Appointment> retrieve(String id) => _transport.request('GET',
      '/v1/appointments/${Uri.encodeComponent(id)}', Appointment.fromJson);

  /// Changes one. Only the fields you set are changed.
  Future<Appointment> update(String id, UpdateAppointment body) =>
      _transport.request('PATCH', '/v1/appointments/${Uri.encodeComponent(id)}',
          Appointment.fromJson,
          body: body.toJson());

  /// Deletes one.
  Future<void> delete(String id) => _transport.requestVoid(
      'DELETE', '/v1/appointments/${Uri.encodeComponent(id)}');
}
