import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/model/menu_model.dart';
import 'package:ccs_app/export.dart';

import 'view/client_calendar_view.dart';
import 'view/client_dashboard_home.dart';
import 'view/client_jobs_view.dart';
import 'view/client_notifications_view.dart';
import 'view/client_profile_view.dart';

class ClientDashboardController extends GetxController {
  final tabIndex = 0.obs;
  final jobs = <ClientJob>[].obs;

  List<Widget> get pages => const [ClientDashboardContent(), ClientCalendarView(), ClientJobsView(), ClientNotificationsView(), ClientProfileView()];

  List<MenuModel> profileItems = [
    MenuModel(icon: IconsaxPlusLinear.lock_1, title: 'Change password', subtitle: "Change password to protect your account"),
    MenuModel(icon: IconsaxPlusLinear.home_hashtag, title: 'Properties', subtitle: "Manage your properties"),
    MenuModel(icon: IconsaxPlusLinear.people, title: 'Preferred Staff', subtitle: "Manage your preferred staff members"),
    MenuModel(icon: IconsaxPlusLinear.notification, title: 'Notifications', subtitle: "View and manage notifications"),
    MenuModel(icon: IconsaxPlusLinear.trade, title: 'Training & Resources', subtitle: "View Training Resources & FAQs"),
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'Help & support', subtitle: "Get help and support"),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      tabIndex.value = (args['tab'] as int).clamp(0, pages.length - 1);
    }
    jobs.assignAll(ClientJob.demoJobs);
  }

  void openDetail(ClientJob job) {
    Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: job);
  }

  void setTab(int index) {
    tabIndex.value = index.clamp(0, pages.length - 1);
  }
}
