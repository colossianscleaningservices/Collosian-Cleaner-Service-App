import 'package:ccs_app/app/network/response/cleaner_job_response.dart';
import 'package:ccs_app/app/network/response/staff_dashboard_response.dart';
import 'package:ccs_app/app/network/response/update_profile_response.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/base/base_repository.dart';
import '../request/staff_edit_profile_request.dart';
import '../response/base_response.dart';
import '../response/get_cleaning_service_response.dart';
import '../response/get_client_calender_response.dart';
import '../response/get_immigrations_response.dart';
import '../response/get_staff_job_details_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

/// Repository for cleaner-only APIs: dashboard, jobs (decline, check-in, check-out).
/// Cleaner assessment APIs live in [AuthRepository].
class CleanerRepository extends BaseRepository {
  // ─── Dashboard ─────────────────────────────────────────────────────────────

  /// GET profile completion status (percentage, missing_fields).
  Future<NetworkResult<DataResponse>> getProfileCompletion() async {
    return get<DataResponse>(
      endpoint: Endpoint.cleanerProfileCompletion,
      fromJson: (json) => DataResponse.fromJson(json),
    );
  }

  Future<NetworkResult<StaffDashboardResponse>> getCleanerDashboard() async {
    return get<StaffDashboardResponse>(
      endpoint: Endpoint.cleanerDashboard,
      fromJson: (json) => StaffDashboardResponse.fromJson(json),
    );
  }

  /// GET action-needed count and items.
  Future<NetworkResult<DataResponse>> getActionNeeded() async {
    return get<DataResponse>(
      endpoint: Endpoint.cleanerActionNeeded,
      fromJson: (json) => DataResponse.fromJson(json),
    );
  }

  // ─── Jobs ─────────────────────────────────────────────────────────────────

 /* /// POST decline job (optional [reason]).
  Future<NetworkResult<BaseResponse>> declineJob({
    required int jobId,
    String? reason,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerJobAcceptDecline(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: reason != null ? <String, dynamic>{'reason': reason} : null,
    );
  }*/

  Future<NetworkResult<BaseResponse>> acceptOrDeclineJob({
    required int jobId,
    required String status,
    String? reason,
  })
  async {
    final payload = <String , dynamic>{};
    payload['status'] = status;
    if(reason != null)payload['reason'] = reason;
    return put<BaseResponse>(
      endpoint: Endpoint.cleanerJobAcceptDecline(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload
    );
  }

  Future<NetworkResult<CleanerJobResponse>> getCleanerJob() async {
    return get<CleanerJobResponse>(
      endpoint: Endpoint.cleanerJob,
      fromJson: (json) => CleanerJobResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetStaffJobDetailsResponse>> getCleanerJobDetails(int jobId) async {
    return get<GetStaffJobDetailsResponse>(
      endpoint: "${Endpoint.cleanerJob}/$jobId",
      fromJson: (json) => GetStaffJobDetailsResponse.fromJson(json),
    );
  }

  /// Check-in (start job): submit photos; backend stores them and sets job to in progress.
  Future<NetworkResult<BaseResponse>> checkIn({
    required String jobId,
    required List<XFile> photos,
  }) async {
    final formData = FormData.fromMap({'job_id': jobId});
    for (final x in photos) {
      final bytes = await x.readAsBytes();
      final name = x.name.isNotEmpty ? x.name : 'photo.jpg';
      formData.files.add(MapEntry('photos', MultipartFile.fromBytes(bytes, filename: name)));
    }
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerJobCheckIn,
      data: formData,
      fromJson: (j) => BaseResponse.fromJson(j),
    );
  }

  /// Check-out (stop job): submit photos; backend stores them and sets job to completed.
  Future<NetworkResult<BaseResponse>> checkOut({
    required String jobId,
    required List<XFile> photos,
  }) async {
    final formData = FormData.fromMap({'job_id': jobId});
    for (final x in photos) {
      final bytes = await x.readAsBytes();
      final name = x.name.isNotEmpty ? x.name : 'photo.jpg';
      formData.files.add(MapEntry('photos', MultipartFile.fromBytes(bytes, filename: name)));
    }
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerJobCheckOut,
      data: formData,
      fromJson: (j) => BaseResponse.fromJson(j),
    );
  }

  Future<NetworkResult<UpdateProfileResponse>> updateProfile(StaffEditProfileRequest request) async {
    return put<UpdateProfileResponse>(
      endpoint: Endpoint.staffProfile,
      data: request,
      fromJson: (json) => UpdateProfileResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetCleaningServiceResponse>> getCleaningServices() async {
    return get<GetCleaningServiceResponse>(
      endpoint: Endpoint.cleaningServices,
      fromJson: (json) => GetCleaningServiceResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetImmigrationsResponse>> getImmigrations() async {
    return get<GetImmigrationsResponse>(
      endpoint: Endpoint.immigrations,
      fromJson: (json) => GetImmigrationsResponse.fromJson(json),
    );
  }

  Future<NetworkResult<GetClientCalenderResponse>> getCleanerCalender({
    String? date,
    String? dateFrom,
    String? dateTo,
  }) async {
    return get<GetClientCalenderResponse>(
      endpoint: Endpoint.cleanerCalender,
      queryParameters: {'date': date, 'date_from': dateFrom, 'date_to': dateTo},
      fromJson: (json) => GetClientCalenderResponse.fromJson(json),
    );
  }

}
