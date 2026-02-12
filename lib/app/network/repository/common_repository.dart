import 'package:ccs_app/app/network/repository/training_resource_response.dart';

import '../../core/base/base_repository.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';
import 'notification_response.dart';

class CommonRepository extends BaseRepository {
  Future<NetworkResult<NotificationResponse>> getNotifications({int perPage = 15, int page = 1}) async {
    return get<NotificationResponse>(
      endpoint: Endpoint.notifications,
      queryParameters: {'per_page': perPage, 'page': page},
      fromJson: (json) => NotificationResponse.fromJson(json),
    );
  }

  Future<NetworkResult<TrainingResourceResponse>> getTrainingResources({int perPage = 15, int page = 1}) async {
    return get<TrainingResourceResponse>(
      endpoint: Endpoint.trainingResources,
      queryParameters: {'per_page': perPage, 'page': page},
      fromJson: (json) => TrainingResourceResponse.fromJson(json),
    );
  }
}
