import 'package:ccs_app/app/network/request/edit_profile_request.dart';
import 'package:ccs_app/app/network/response/base_response.dart';
import 'package:ccs_app/app/network/response/cleaning_type_response.dart';
import 'package:ccs_app/app/network/response/faq_response.dart';
import 'package:ccs_app/app/network/response/media_upload_response.dart';
import 'package:ccs_app/app/network/response/profile_response.dart';
import 'package:ccs_app/app/network/response/training_resource_response.dart';
import 'package:dio/dio.dart';

import '../../core/base/base_repository.dart';
import '../response/newsletter_response.dart';
import '../response/notification_response.dart';
import '../utils/network_result.dart';
import 'endpoint.dart';

class CommonRepository extends BaseRepository {
  Future<NetworkResult<NotificationResponse>> getNotifications({int perPage = 15, int page = 1}) async {
    return get<NotificationResponse>(
      endpoint: Endpoint.notifications,
      queryParameters: {'per_page': perPage, 'page': page},
      fromJson: (json) => NotificationResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> readNotifications(int id) async {
    return put<BaseResponse>(
      endpoint: "${Endpoint.notifications}/$id/read",
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> deleteNotifications(int id) async {
    return delete<BaseResponse>(
      endpoint: "${Endpoint.notifications}/$id",
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> deleteAllNotifications() async {
    return delete<BaseResponse>(
      endpoint: Endpoint.notifications,
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> readAllNotifications() async {
    return put<BaseResponse>(
      endpoint: Endpoint.readAllNotifications,
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<TrainingResourceResponse>> getTrainingResources({int perPage = 15, int page = 1, String? filter, String? search}) async {
    return get<TrainingResourceResponse>(
      endpoint: Endpoint.trainingResources,
      queryParameters: {'per_page': perPage, 'page': page, 'content_type': filter, 'search': search},
      fromJson: (json) => TrainingResourceResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> seenTrainingResources(int id) async {
    return put<BaseResponse>(
      endpoint: Endpoint.seenTrainingResources(id),
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<NewsletterResponse>> getNewsletters({int perPage = 20, int page = 1}) async {
    return get<NewsletterResponse>(
      endpoint: Endpoint.newsletters,
      queryParameters: {'per_page': perPage, 'page': page},
      fromJson: (json) => NewsletterResponse.fromJson(json),
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

  Future<NetworkResult<CleaningTypeResponse>> getCleaningTypes({String? search}) async {
    return get<CleaningTypeResponse>(
      endpoint: Endpoint.cleaningTypes,
      queryParameters: {'is_active': true, 'search': search},
      fromJson: (json) => CleaningTypeResponse.fromJson(json),
    );
  }

  Future<NetworkResult<ProfileResponse>> updateProfile(EditProfileRequest request) async {
    return put<ProfileResponse>(
      endpoint: Endpoint.profile,
      data: request,
      fromJson: (json) => ProfileResponse.fromJson(json),
    );
  }

  Future<NetworkResult<ProfileResponse>> getProfile() async {
    return get<ProfileResponse>(
      endpoint: Endpoint.profile,
      fromJson: (json) => ProfileResponse.fromJson(json),
    );
  }

  Future<NetworkResult<BaseResponse>> deleteProfile() async {
    return delete<BaseResponse>(
      endpoint: Endpoint.profile,
      data: {'confirm': true},
      fromJson: (json) => BaseResponse.fromJson(json),
    );
  }

  Future<NetworkResult<MediaUploadResponse>> mediaUpload(Map<String, dynamic> data) async {
    return post<MediaUploadResponse>(
      endpoint: Endpoint.mediaUpload,
      data: FormData.fromMap(data),
      fromJson: (json) => MediaUploadResponse.fromJson(json),
    );
  }
}
