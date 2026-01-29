import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/model/menu_model.dart';
import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

import '../../../model/calendar_event.dart';
import 'view/client_calendar_view.dart';
import 'view/client_dashboard_home.dart';
import 'view/client_jobs_view.dart';
import 'view/client_profile_view.dart';

class ClientDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  final tabIndex = 0.obs;
  final jobs = <ClientJob>[].obs;

  List<Widget> get pages => const [
        ClientDashboardContent(), ClientCalendarView(), ClientJobsView(),
        // ClientNotificationsView(),
        ClientProfileView()
      ];

  List<MenuModel> profileItems = [
    MenuModel(icon: IconsaxPlusLinear.lock_1, title: 'Change password', subtitle: "Change password to protect your account"),
    MenuModel(icon: IconsaxPlusLinear.home_hashtag, title: 'Properties', subtitle: "Manage your properties"),
    MenuModel(icon: IconsaxPlusLinear.people, title: 'Preferred Staff', subtitle: "Manage your preferred staff members"),
    MenuModel(icon: IconsaxPlusLinear.notification, title: 'Notifications', subtitle: "View and manage notifications"),
    MenuModel(icon: IconsaxPlusLinear.trade, title: 'Training & Resources', subtitle: "View Training Resources & FAQs"),
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'Help & support', subtitle: "Get help and support"),
  ];

  late final TabController tabController;
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>();

  static const modes = [CalendarViewMode.week, CalendarViewMode.month, CalendarViewMode.list];
  final mode = CalendarViewMode.month.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      tabIndex.value = (args['tab'] as int).clamp(0, pages.length - 1);
    }
    jobs.assignAll(ClientJob.demoJobs);
    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    tabController.addListener(_syncModeFromTab);
  }

  @override
  void onClose() {
    tabController.removeListener(_syncModeFromTab);
    tabController.dispose();
    super.onClose();
  }

  String get periodLabel {
    if (mode.value == CalendarViewMode.week) {
      final d = focusedDay.value;
      final start = d.subtract(Duration(days: d.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.day}–${end.day} ${DateFormat('MMM yyyy').format(start)}';
    }
    return DateFormat('MMMM yyyy').format(focusedDay.value);
  }

  /// Placeholder events. Replace with API-backed source.
  Map<DateTime, List<CalendarEvent>> get eventsMap {
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    return {
      t: [CalendarEvent(title: 'Residential clean')],
      t.add(const Duration(days: 2)): [CalendarEvent(title: 'Office – Clerkenwell Road', status: 'Pending')],
      t.add(const Duration(days: 5)): [CalendarEvent(title: 'Nellie – 8 The Grove')],
    };
  }

  void _syncModeFromTab() {
    mode.value = modes[tabController.index];
  }

  void onCalendarDaySelected(DateTime? selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  void onCalendarPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  void onCalendarPrev() {
    if (mode.value == CalendarViewMode.week) {
      focusedDay.value = focusedDay.value.subtract(const Duration(days: 7));
    } else {
      focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month - 1, focusedDay.value.day);
    }
    if (focusedDay.value.isBefore(kCalendarFirstDay)) focusedDay.value = kCalendarFirstDay;
  }

  void onCalendarNext() {
    if (mode.value == CalendarViewMode.week) {
      focusedDay.value = focusedDay.value.add(const Duration(days: 7));
    } else {
      focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month + 1, focusedDay.value.day);
    }
    if (focusedDay.value.isAfter(kCalendarLastDay)) focusedDay.value = kCalendarLastDay;
  }

  void setTab(int index) {
    tabIndex.value = index.clamp(0, pages.length - 1);
  }

  void openDetail(ClientJob job) {
    Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: job);
  }
}
