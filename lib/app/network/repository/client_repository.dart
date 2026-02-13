import 'package:ccs_app/app/network/response/property_sub_type_response.dart';

import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
import '../response/property_type_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

/// Repository for client-only APIs: properties, jobs (cancel, schedule, review).
class ClientRepository extends BaseRepository {
  // ─── Properties ────────────────────────────────────────────────────────────

  /// GET list of client properties (optional [perPage], [search]).
  /// POST create property. Required: name, address, city, postal_code, property_type.
  /// Optional: type, animal_property, staff_preference (Male|Female|No Preference).
  Future<NetworkResult<BaseResponse>> createProperty({
    required String name,
    required String businessType,
    required String address,
    required String city,
    required String postalCode,
    required String propertyType,
    String? propertySubType,
    int? noOfBedrooms,
    int? noOfBathrooms,
    int? noOfGuestToilet,
    int? livingRoom,
    int? office,
    int? conservatory,
    int? diningRoom,
    String? haveHoover,
    bool? provideCleaningProduct,
    bool? haveWashingMachine,
    String? staffPreference,
    bool? haveDryer,
    String? accessProperty,
    bool? animalProperty,
  }) async {
    final payload = <String, dynamic>{
      'property_name': name,
      'bussiness_type': businessType,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'property_type': propertyType,
    };
    if (propertySubType != null) payload['sub_type'] = propertySubType;
    if (noOfBedrooms != null) payload['bedrooms'] = noOfBedrooms;
    if (noOfBathrooms != null) payload['bathrooms'] = noOfBathrooms;
    if (noOfGuestToilet != null) payload['separate_guest_toilet'] = noOfGuestToilet;
    if (livingRoom != null) payload['living_rooms'] = livingRoom;
    if (office != null) payload['office'] = office;
    if (conservatory != null) payload['conservatory'] = conservatory;
    if (diningRoom != null) payload['dining_room'] = diningRoom;
    if (haveHoover != null) payload['type'] = haveHoover;
    if (provideCleaningProduct != null) payload['type'] = provideCleaningProduct;
    if (haveWashingMachine != null) payload['type'] = haveWashingMachine;
    if (staffPreference != null) payload['staff_preference'] = staffPreference;
    if (haveDryer != null) payload['type'] = haveDryer;
    if (accessProperty != null) payload['type'] = accessProperty;
    if (animalProperty != null) payload['animal_property'] = animalProperty;
    return post<BaseResponse>(
      endpoint: Endpoint.clientProperties,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }

  Future<NetworkResult<DataResponse>> listProperties({
    int? perPage,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (perPage != null) query['per_page'] = perPage;
    if (search != null && search.isNotEmpty) query['search'] = search;
    return get<DataResponse>(
      endpoint: Endpoint.clientProperties,
      fromJson: (json) => DataResponse.fromJson(json),
      queryParameters: query.isEmpty ? null : query,
    );
  }

  /// GET single property by [id].
  Future<NetworkResult<DataResponse>> getProperty(int id) async {
    return get<DataResponse>(
      endpoint: Endpoint.clientProperty(id),
      fromJson: (json) => DataResponse.fromJson(json),
    );
  }

  /// PUT update property (partial: name, address, city, etc.).
  Future<NetworkResult<BaseResponse>> updateProperty({
    required int id,
    String? name,
    String? address,
    String? city,
    String? postalCode,
    String? propertyType,
    String? type,
    bool? animalProperty,
    String? staffPreference,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (address != null) payload['address'] = address;
    if (city != null) payload['city'] = city;
    if (postalCode != null) payload['postal_code'] = postalCode;
    if (propertyType != null) payload['property_type'] = propertyType;
    if (type != null) payload['type'] = type;
    if (animalProperty != null) payload['animal_property'] = animalProperty;
    if (staffPreference != null) payload['staff_preference'] = staffPreference;
    return put<BaseResponse>(
      endpoint: Endpoint.clientProperty(id),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload.isEmpty ? null : payload,
    );
  }

  /// DELETE property by [id].
  Future<NetworkResult<BaseResponse>> deleteProperty(int id) async {
    return delete<BaseResponse>(
      endpoint: Endpoint.clientProperty(id),
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  // ─── Jobs ─────────────────────────────────────────────────────────────────

  /// POST cancel job (optional [reason]).
  Future<NetworkResult<BaseResponse>> cancelJob({
    required int jobId,
    String? reason,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.clientJobCancel(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: reason != null ? <String, dynamic>{'reason': reason} : null,
    );
  }

  /// PUT schedule job with recurrence. [frequency]: daily|weekly|monthly.
  /// Optional: start_date, end_date, occurrence, copy_cleaners.
  Future<NetworkResult<BaseResponse>> scheduleJob({
    required int jobId,
    required String frequency,
    String? startDate,
    String? endDate,
    int? occurrence,
    bool? copyCleaners,
  }) async {
    final payload = <String, dynamic>{'frequency': frequency};
    if (startDate != null) payload['start_date'] = startDate;
    if (endDate != null) payload['end_date'] = endDate;
    if (occurrence != null) payload['occurrence'] = occurrence;
    if (copyCleaners != null) payload['copy_cleaners'] = copyCleaners;
    return put<BaseResponse>(
      endpoint: Endpoint.clientJobSchedule(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }

  /// POST submit job review. [rating] 1–5, optional [feedback], [message].
  Future<NetworkResult<BaseResponse>> submitJobReview({
    required int jobId,
    required int rating,
    String? feedback,
    String? message,
  }) async {
    final payload = <String, dynamic>{'rating': rating};
    if (feedback != null) payload['feedback'] = feedback;
    if (message != null) payload['message'] = message;
    return post<BaseResponse>(
      endpoint: Endpoint.clientJobReview(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }

  Future<NetworkResult<PropertyTypeResponse>> getPropertyType() async {
    return get<PropertyTypeResponse>(
      endpoint: Endpoint.getPropertyType,
      fromJson: (json) => PropertyTypeResponse.fromJson(json),
    );
  }

  Future<NetworkResult<PropertySubTypeResponse>> getPropertySubTypes({
    required int propertyId,
  }) async {
    return get<PropertySubTypeResponse>(
      endpoint: Endpoint.getPropertySubType(propertyId),
      fromJson: (json) => PropertySubTypeResponse.fromJson(json),
    );
  }
}
