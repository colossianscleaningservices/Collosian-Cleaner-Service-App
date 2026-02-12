import 'package:ccs_app/app/network/repository/training_resource_response.dart';
import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:ccs_app/app/network/response/faq_response.dart';

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

  Future<NetworkResult<BaseResponse>> contactUs({
    required String name,
    required String email,
    required String message,
  }) async {
    final payload = <String, String>{'name': name.trim(), 'email': email.trim(), 'message': message.trim()};
    return post<BaseResponse>(
      endpoint: Endpoint.supportContact,
      fromJson: (json) => BaseResponse.fromJson(json),
      data: payload,
    );
  }

  Future<NetworkResult<FaqResponse>> getFaqs() async {
    return get<FaqResponse>(
      endpoint: Endpoint.helpFaq,
      fromJson: (json) => FaqResponse.fromJson(json),
    );
  }


}
