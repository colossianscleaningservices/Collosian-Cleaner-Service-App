import 'package:ccs_app/app/utils/extension.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

class JobRepository extends BaseRepository {
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
      endpoint: Endpoint.cleanerJobCheckIn(jobId.toInt()),
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
