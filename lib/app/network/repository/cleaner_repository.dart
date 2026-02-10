import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
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

  /// GET action-needed count and items.
  Future<NetworkResult<DataResponse>> getActionNeeded() async {
    return get<DataResponse>(
      endpoint: Endpoint.cleanerActionNeeded,
      fromJson: (json) => DataResponse.fromJson(json),
    );
  }

  // ─── Jobs ─────────────────────────────────────────────────────────────────

  /// POST decline job (optional [reason]).
  Future<NetworkResult<BaseResponse>> declineJob({
    required int jobId,
    String? reason,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerJobDecline(jobId),
      fromJson: (json) => BaseResponse.fromJson(json),
      data: reason != null ? <String, dynamic>{'reason': reason} : null,
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
}
