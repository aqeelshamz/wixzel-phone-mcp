import '../models/telephony.dart';
import '../page.dart';
import '../transport.dart';

/// Phone numbers you own at your carrier, registered on a SIP trunk.
class PhoneNumbers {
  /// Binds the resource to a transport.
  const PhoneNumbers(this._transport);

  final Transport _transport;

  /// Lists phone numbers.
  Future<Page<PhoneNumber>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/phone-numbers', PhoneNumber.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Creates one.
  Future<PhoneNumber> create(CreatePhoneNumber body) =>
      _transport.request('POST', '/v1/phone-numbers', PhoneNumber.fromJson,
          body: body.toJson());

  /// Fetches one.
  Future<PhoneNumber> retrieve(String id) => _transport.request('GET',
      '/v1/phone-numbers/${Uri.encodeComponent(id)}', PhoneNumber.fromJson);

  /// Changes one. Only the fields you set are changed.
  Future<PhoneNumber> update(String id, UpdatePhoneNumber body) =>
      _transport.request('PATCH',
          '/v1/phone-numbers/${Uri.encodeComponent(id)}', PhoneNumber.fromJson,
          body: body.toJson());

  /// Deletes one.
  Future<void> delete(String id) => _transport.requestVoid(
      'DELETE', '/v1/phone-numbers/${Uri.encodeComponent(id)}');
}
