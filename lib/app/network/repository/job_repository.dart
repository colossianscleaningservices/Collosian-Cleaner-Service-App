import '../../core/base/base_repository.dart';
import '../response/base_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

class JobRepository extends BaseRepository {
  /// Check-in (start job): submit photos; backend stores them and sets job to in progress.
  Future<NetworkResult<BaseResponse>> checkIn({
    required int jobId,
    required String checkInDate,
    required String checkInTime,
    required List<String> photos,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerJobCheckIn(jobId),
      data: <String, dynamic>{'check_in_date': checkInDate, 'check_in_time': checkInTime, 'before_photos': photos},
      fromJson: (j) => BaseResponse.fromJson(j),
    );
  }

  /// Check-out (stop job): submit photos; backend stores them and sets job to completed.
  Future<NetworkResult<BaseResponse>> checkOut({
    required int jobId,
    required String checkOutDate,
    required String checkOutTime,
    required List<String> photos,
  }) async {
    return post<BaseResponse>(
      endpoint: Endpoint.cleanerJobCheckOut(jobId),
      data: <String, dynamic>{'check_out_date': checkOutDate, 'check_out_time': checkOutTime, 'after_photos': photos},
      fromJson: (j) => BaseResponse.fromJson(j),
    );
  }
}
