import 'dart:ffi';

import 'package:ccs_app/app/network/request/schedule_job_request.dart';
import 'package:ccs_app/app/network/response/get_client_calender_response.dart';
import 'package:ccs_app/app/network/response/get_client_dash_response.dart';
import 'package:ccs_app/app/network/response/get_client_job_details_response.dart';
import 'package:ccs_app/app/network/response/get_client_job_response.dart';
import 'package:ccs_app/app/network/response/get_preferred_staff_response.dart';
import 'package:ccs_app/app/network/response/get_staff_detail_response.dart';
import 'package:ccs_app/app/network/response/property_sub_type_response.dart';

import '../../core/base/base_repository.dart';
import '../request/create_job_request.dart';
import '../response/base_response.dart';
import '../response/property_list_response.dart';
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
    payload['sub_type'] = propertySubType;
    payload['bedrooms'] = noOfBedrooms;
    payload['bathrooms'] = noOfBathrooms;
    payload['separate_guest_toilet'] = noOfGuestToilet;
    payload['living_rooms'] = livingRoom;
    payload['office'] = office;
    payload['conservatory'] = conservatory;
    payload['dining_room'] = diningRoom;
    payload['hoover'] = haveHoover;
    payload['provide_cleaning_products'] = provideCleaningProduct;
    payload['provide_washing_machine'] = haveWashingMachine;
    payload['staff_preference'] = staffPreference;
    payload['provide_dryer'] = haveDryer;
    payload['access_to_property'] = accessProperty;
    payload['animal_property'] = animalProperty;
    return post<BaseResponse>(
      endpoint: Endpoint.clientProperties,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }

  Future<NetworkResult<PropertyListResponse>> listProperties({
    int? perPage,
    String? search,
    bool? withPagination = true,
    int page = 1,
  }) async {
    final query = <String, dynamic>{};
    if (perPage != null) query['per_page'] = perPage;
    if (search != null && search.isNotEmpty) query['search'] = search;
    query['with_pagination'] = withPagination;
    query['page'] = page;
    return get<PropertyListResponse>(
      endpoint: Endpoint.clientProperties,
      fromJson: (json) => PropertyListResponse.fromJson(json),
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
    payload['sub_type'] = propertySubType;
    payload['bedrooms'] = noOfBedrooms;
    payload['bathrooms'] = noOfBathrooms;
    payload['separate_guest_toilet'] = noOfGuestToilet;
    payload['living_rooms'] = livingRoom;
    payload['office'] = office;
    payload['conservatory'] = conservatory;
    payload['dining_room'] = diningRoom;
    payload['hoover'] = haveHoover;
    payload['provide_cleaning_products'] = provideCleaningProduct;
    payload['provide_washing_machine'] = haveWashingMachine;
    payload['staff_preference'] = staffPreference;
    payload['provide_dryer'] = haveDryer;
    payload['access_to_property'] = accessProperty;
    payload['animal_property'] = animalProperty;
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

  Future<NetworkResult<BaseResponse>> createJob(CreateJobRequest request) async {
    return post<BaseResponse>(
      endpoint: Endpoint.clientJob,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: request,
    );
  }

  Future<NetworkResult<BaseResponse>> updateJob(CreateJobRequest request, int? jobId) async {
    return put<BaseResponse>(
      endpoint: "${Endpoint.clientJob}/$jobId",
      fromJson: (json) => BaseResponse.fromJson(json),
      data: request,
    );
  }

  Future<NetworkResult<GetClientJobResponse>> getJob({int page = 1, bool? upcoming}) async {
    return get<GetClientJobResponse>(
      queryParameters: {'page': page, 'upcoming': upcoming},
      endpoint: Endpoint.clientJob,
      fromJson: (json) => GetClientJobResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetClientJobDetailsResponse>> getJobDetails(num jobId) async {
    return get<GetClientJobDetailsResponse>(
      endpoint: "${Endpoint.clientJob}/$jobId",
      fromJson: (json) => GetClientJobDetailsResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> deleteJob(num jobId) async {
    return delete<BaseResponse>(
      endpoint: "${Endpoint.clientJob}/$jobId",
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  /// PUT schedule job with recurrence. [frequency]: daily|weekly|monthly.
  /// Optional: start_date, end_date, occurrence, copy_cleaners.
  Future<NetworkResult<BaseResponse>> scheduleJob({required int jobId, required ScheduleJobRequest request}) async {
    return put<BaseResponse>(
      endpoint: Endpoint.clientJobSchedule(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: request,
    );
  }

  /// POST submit job review. [rating] 1–5, optional [feedback], [message].
  Future<NetworkResult<BaseResponse>> submitJobReview({
    required int jobId,
    required int cleanerId,
    required bool arrivedOnTime,
    required bool woreUniform,
    required bool completedOnTime,
    required bool wouldRehire,
    required int satisfactionRating,
    String? message,
  }) async {
    final payload = <String, dynamic>{'cleaner_id': cleanerId};
    payload['arrived_on_time'] = arrivedOnTime;
    payload['wore_uniform'] = woreUniform;
    payload['completed_on_time'] = completedOnTime;
    payload['would_rehire'] = wouldRehire;
    payload['satisfaction_rating'] = satisfactionRating;
    if (message != null) payload['comments'] = message;
    return post<BaseResponse>(
      endpoint: Endpoint.clientJobReview(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }

  Future<NetworkResult<PropertyTypeResponse>> getPropertyType({
    required String businessType,
  }) async {
    final payload = <String, dynamic>{'business_type': businessType};
    return get<PropertyTypeResponse>(endpoint: Endpoint.getPropertyType, fromJson: (json) => PropertyTypeResponse.fromJson(json), queryParameters: payload);
  }

  Future<NetworkResult<PropertySubTypeResponse>> getPropertySubTypes({
    required int propertyId,
  }) async {
    return get<PropertySubTypeResponse>(
      endpoint: Endpoint.getPropertySubType(propertyId),
      fromJson: (json) => PropertySubTypeResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetClientCalenderResponse>> getClientCalender({
    String? date,
    String? dateFrom,
    String? dateTo,
  }) async {
    return get<GetClientCalenderResponse>(
      endpoint: Endpoint.clientCalender,
      queryParameters: {'date': date, 'date_from': dateFrom, 'date_to': dateTo},
      fromJson: (json) => GetClientCalenderResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetClientDashResponse>> getClientDash() async {
    return get<GetClientDashResponse>(
      endpoint: Endpoint.clientDashboard,
      fromJson: (json) => GetClientDashResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetPreferredStaffResponse>> getPreferredStaff() async {
    return get<GetPreferredStaffResponse>(
      endpoint: Endpoint.getPreferredStaff,
      fromJson: (json) => GetPreferredStaffResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetStaffDetailResponse>> getStaffDetail({
    required int staffId,
  }) async {
    return get<GetStaffDetailResponse>(
      endpoint: Endpoint.getStaffDetail(staffId),
      fromJson: (json) => GetStaffDetailResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> markStaffPreferred({
    required int staffId,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.markStaffPreferred(staffId),
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> unmarkStaffPreferred({
    required int staffId,
  }) async {
    return delete<BaseResponse>(
      endpoint: Endpoint.markStaffPreferred(staffId),
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }
}
