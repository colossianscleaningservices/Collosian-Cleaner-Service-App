import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

/// Repository for client-only APIs: properties, jobs (cancel, schedule, review).
class ClientRepository extends BaseRepository {
  // ─── Properties ────────────────────────────────────────────────────────────

  /// GET list of client properties (optional [perPage], [search]).
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

  /// POST create property. Required: name, address, city, postal_code, property_type.
  /// Optional: type, animal_property, staff_preference (Male|Female|No Preference).
  Future<NetworkResult<BaseResponse>> createProperty({
    required String name,
    required String address,
    required String city,
    required String postalCode,
    required String propertyType,
    String? type,
    bool? animalProperty,
    String? staffPreference,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'property_type': propertyType,
    };
    if (type != null) payload['type'] = type;
    if (animalProperty != null) payload['animal_property'] = animalProperty;
    if (staffPreference != null) payload['staff_preference'] = staffPreference;
    return post<BaseResponse>(
      endpoint: Endpoint.clientProperties,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
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
}
