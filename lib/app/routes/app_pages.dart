import 'package:ccs_app/app/modules/cleaner/notification/notification_binding.dart';
import 'package:ccs_app/app/modules/cleaner/notification/notification_view.dart';
import 'package:ccs_app/app/modules/cleaner/support_document/support_document_binding.dart';
import 'package:ccs_app/app/modules/cleaner/support_document/support_document_view.dart';
import 'package:ccs_app/app/modules/cleaner/support_document/views/add_document_view.dart';
import 'package:get/get.dart';

import '../modules/auth/auth_binding.dart';
import '../modules/auth/auth_view.dart';
import '../modules/auth/forgot_password_view.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/reset_password_view.dart';
import '../modules/auth/role_selection_view.dart';
import '../modules/auth/signup_view.dart';
import '../modules/cleaner/cleaner_edit_profile/cleaner_edit_profile_binding.dart';
import '../modules/cleaner/cleaner_edit_profile/cleaner_edit_profile_view.dart';
import '../modules/cleaner/cleaner_payout_computation/cleaner_payout_computation_binding.dart';
import '../modules/cleaner/cleaner_payout_computation/cleaner_payout_computation_view.dart';
import '../modules/cleaner/cleaner_references/cleaner_references_binding.dart';
import '../modules/cleaner/cleaner_references/cleaner_references_view.dart';
import '../modules/cleaner/cleaner_references/views/add_reference_view.dart';
import '../modules/cleaner/cleaner_review/cleaner_review_binding.dart';
import '../modules/cleaner/cleaner_review/cleaner_review_view.dart';
import '../modules/cleaner/dashboard/cleaner_dashboard_binding.dart';
import '../modules/cleaner/dashboard/cleaner_dashboard_view.dart';
import '../modules/cleaner/job/cleaner_job_detail_binding.dart';
import '../modules/cleaner/job/cleaner_job_detail_view.dart';
import '../modules/cleaner/training_and_resources/training_and_resources_binding.dart';
import '../modules/cleaner/training_and_resources/training_and_resources_view.dart';
import '../modules/client/create_job/create_job_binding.dart';
import '../modules/client/create_job/create_job_view.dart';
import '../modules/client/dashboard/client_dashboard_binding.dart';
import '../modules/client/dashboard/client_dashboard_view.dart';
import '../modules/client/edit_profile/client_edit_profile_binding.dart';
import '../modules/client/edit_profile/client_edit_profile_view.dart';
import '../modules/client/job/client_job_detail_binding.dart';
import '../modules/client/job/client_job_detail_view.dart';
import '../modules/client/property/add_property_view.dart';
import '../modules/client/property/property_binding.dart';
import '../modules/client/property/property_view.dart';
import '../modules/common/change_password/change_password_binding.dart';
import '../modules/common/change_password/change_password_view.dart';
import '../modules/common/help_support/help_support_binding.dart';
import '../modules/common/help_support/help_support_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = <GetPage>[
    GetPage(name: _Paths.SPLASH, page: () => const SplashView(), binding: SplashBinding()),

    // Auth module (single binding/controller shared across auth screens)
    GetPage(name: _Paths.AUTH, page: () => const AuthView(), binding: AuthBinding()),
    GetPage(name: _Paths.LOGIN, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(name: _Paths.ROLE_SELECTION, page: () => const RoleSelectionView(), binding: AuthBinding()),
    GetPage(name: _Paths.SIGN_UP, page: () => const SignupView(), binding: AuthBinding()),
    GetPage(name: _Paths.FORGOT_PASSWORD, page: () => const ForgotPasswordView(), binding: AuthBinding()),
    GetPage(name: _Paths.RESET_PASSWORD, page: () => const ResetPasswordView(), binding: AuthBinding()),

    // Client module — register CREATE before DETAIL so /client/job/create opens CreateJobView, not JobDetail
    GetPage(name: _Paths.CLIENT_DASHBOARD, page: () => const ClientDashboardView(), binding: ClientDashboardBinding()),
    GetPage(name: _Paths.CLIENT_CREATE_JOB, page: () => const CreateJobView(), binding: CreateJobBinding()),
    GetPage(
      name: _Paths.CLIENT_JOB_DETAIL,
      page: () => const ClientJobDetailView(),
      binding: ClientJobDetailBinding(),
    ),
    GetPage(
      name: _Paths.CLIENT_EDIT_PROFILE,
      page: () => const ClientEditProfileView(),
      binding: ClientEditProfileBinding(),
    ),

    // Cleaner module
    GetPage(name: _Paths.CLEANER_DASHBOARD, page: () => const CleanerDashboardView(), binding: CleanerDashboardBinding()),
    GetPage(
      name: _Paths.CLEANER_JOB_DETAIL,
      page: () => const CleanerJobDetailView(),
      binding: CleanerJobDetailBinding(),
    ),
    GetPage(
      name: _Paths.PROPERTY,
      page: () => const PropertyView(),
      binding: PropertyBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PROPERTY,
      page: () => const AddPropertyView(),
      binding: PropertyBinding(),
    ),
    GetPage(
      name: _Paths.CLEANER_EDIT_PROFILE,
      page: () => const CleanerEditProfileView(),
      binding: CleanerEditProfileBinding(),
    ),
    GetPage(
      name: _Paths.TRAINING_AND_RESOURCES,
      page: () => const TrainingAndResourcesView(),
      binding: TrainingAndResourcesBinding(),
    ),
    GetPage(
      name: _Paths.CLEANER_REFERENCES,
      page: () => const CleanerReferencesView(),
      binding: CleanerRefrencesBinding(),
    ),
    GetPage(
      name: _Paths.ADD_REFERENCES,
      page: () => const AddReferenceView(),
      binding: CleanerRefrencesBinding(),
    ),
    GetPage(
      name: _Paths.SUPPORT_DOCUMENT,
      page: () => const SupportDocumentView(),
      binding: SupportDocumentBinding(),
    ),
    GetPage(
      name: _Paths.ADD_DOCUMENT,
      page: () => const AddDocumentView(),
      binding: SupportDocumentBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.CLEANER_PAYOUT_COMPUTATION,
      page: () => const CleanerPayoutComputationView(),
      binding: CleanerPayoutComputationBinding(),
    ),
    GetPage(
      name: _Paths.HELP_SUPPORT,
      page: () => const HelpSupportView(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.CLEANER_REVIEW,
      page: () => const CleanerReviewView(),
      binding: CleanerReviewBinding(),
    ),
  ];
}
