/// API endpoint paths aligned with OpenAPI spec (base path /api/v1/).
/// Base URL is set via EnvService.apiBaseUrl in DioClient.
class Endpoint {
  Endpoint._();

  static const String root = '/api/v1/';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String authRegister = '${root}auth/register';
  static const String authLogin = '${root}auth/login';
  static const String authLogout = '${root}auth/logout';
  static const String authUser = '${root}auth/user';
  static const String authForgotPassword = '${root}auth/forgot-password';
  static const String authResetPassword = '${root}auth/reset-password';
  static const String authChangePassword = '${root}auth/change-password';

  // ─── Profile (shared) ─────────────────────────────────────────────────────
  static const String profile = '${root}shared/profile';
  static const String profileChangePassword = '${root}shared/profile/change-password';

  // ─── Cleaner - Assessment ──────────────────────────────────────────────────
  static const String cleanerAssessmentCategories = '${root}staff/assessment/categories';
  static const String cleanerAssessmentForms = '${root}staff/assessment/questions';
  static const String cleanerAssessmentGovCode = '${root}staff/assessment/gov-code';
  static const String saveCleanerAssessment = '${root}staff/assessment/submit';

  // ─── Cleaner - Dashboard ───────────────────────────────────────────────────
  static const String cleanerProfileCompletion = '${root}staff/profile-completion';
  static const String cleanerActionNeeded = '${root}staff/action-needed';
  static const String cleanerDashboard = '${root}staff/dashboard';

  // ─── Cleaner - Jobs ───────────────────────────────────────────────────────
  static String cleanerJobDecline(int id) => '${root}staff/jobs/$id/decline';
  static const String cleanerJob = '${root}staff/jobs';

  // Check-in/check-out: not in current OpenAPI spec; paths kept for app until backend adds them.
  static const String cleanerJobCheckIn = '${root}staff/jobs/check-in';
  static const String cleanerJobCheckOut = '${root}staff/jobs/check-out';

  // ---- Cleaner - Profile ---------
  static const String cleaningServices = '${root}staff/cleaning-services';
  static const String immigrations = '${root}staff/immigrations';
  static const String staffProfile = '${root}staff/profile';

  // ─── Client - Jobs ────────────────────────────────────────────────────────
  static String clientJobCancel(int id) => '${root}client/jobs/$id/cancel';
  static String clientJobSchedule(int id) => '${root}client/jobs/$id/schedule';
  static String clientJobReview(int id) => '${root}client/jobs/$id/review';
  static const String clientJob = '${root}client/jobs';

  // ─── Client - Properties ───────────────────────────────────────────────────
  static const String clientProperties = '${root}client/properties';

  static String clientProperty(int id) => '${root}client/properties/$id';
  static String getPropertyType = '${root}client/properties/types';

  static String getPropertySubType(int id) => '${root}client/properties/types/$id/subtypes';

  // ─── Common - Chat ────────────────────────────────────────────────────────
  static const String chatThreads = '${root}shared/chat/threads';

  static String chatThreadMessages(int userId) => '${root}shared/chat/threads/$userId/messages';
  static const String chatMessages = '${root}shared/chat/messages';

  static String chatMessage(int id) => '${root}shared/chat/messages/$id';

  // ─── Common - Device ──────────────────────────────────────────────────────
  static const String device = '${root}shared/device';

  // ─── Common - Support ─────────────────────────────────────────────────────
  static const String supportContact = '${root}shared/support/contact';
  static const String helpFaq = '${root}shared/help/faq';
  static const String notifications = '${root}shared/notifications';
  static const String trainingResources = '${root}shared/training-resources';
  static const String newsletters = '${root}shared/newsletters';
  static const String cleaningTypes = '${root}shared/cleaning-types';
  static const String mediaUpload = '${root}shared/media/upload';
}
