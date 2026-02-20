import 'dart:io' show Platform;

import 'package:ccs_app/app/model/menu_model.dart';
import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/response/get_client_job_response.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../model/calendar_event.dart';
import '../../../network/repository/client_repository.dart';
import '../../../services/session_service.dart';
import 'view/client_calendar_view.dart';
import 'view/client_dashboard_home.dart';
import 'view/client_jobs_view.dart';
import 'view/client_profile_view.dart';

class ClientDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final ClientRepository _clientRepository = ClientRepository();

  final tabIndex = 0.obs;
  var appVersion = "".obs;

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
    MenuModel(icon: IconsaxPlusLinear.message_text, title: 'Newsletters', subtitle: "Get your news"),
    MenuModel(icon: IconsaxPlusLinear.message_text, title: 'Support chat', subtitle: "Message admin for help"),
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'Help & support', subtitle: "Get help and support"),
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'FAQs', subtitle: "Frequently asked questions"),
  ];

  late final TabController tabController;
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>();

  static const modes = [CalendarViewMode.week, CalendarViewMode.month, CalendarViewMode.list];
  final mode = CalendarViewMode.month.obs;

  var userDisplayName = ''.obs;
  var userDisplayImage = ''.obs;

  //JOBS
  RxList<Jobs> jobs = <Jobs>[].obs;
  var jobCurrentPage = 1;
  var jobTotalPage = 1;
  RxBool isJobMoreLoading = false.obs;
  ScrollController jobScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    if (!Get.find<SessionService>().isLoggedIn) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      tabIndex.value = (args['tab'] as int).clamp(0, pages.length - 1);
    }
    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    tabController.addListener(_syncModeFromTab);
    getAppVersion();
    _registerDevice();

    userDisplayName.value =  Get.find<SessionService>().userDisplayName;
    userDisplayImage.value =  Get.find<SessionService>().userDisplayImage;

    jobScrollController.addListener(() {
      if (_isScrollBottom) {
        if (jobCurrentPage <= jobTotalPage && !isJobMoreLoading.value) {
          isJobMoreLoading.value = true;
          fetchJobs();
        }
      }
    });
  }

  bool get _isScrollBottom {
    if (!jobScrollController.hasClients) return false;
    final maxScroll = jobScrollController.position.maxScrollExtent;
    final currentScroll = jobScrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// Call device registration API so latest app/device data is saved when dashboard opens.
  Future<void> _registerDevice() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final platform = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');
      final timezone = Prefs().getTimeZoneData(Prefs.timezone);
      final ip = Prefs().getData(Prefs.ipAddress);
      await _authRepository.saveDeviceDetails(
        platform: platform,
        appVersion: info.version,
        debug: kDebugMode,
        timezone: timezone.isNotEmpty ? timezone : null,
        ip: ip.isNotEmpty ? ip : null,
        onesignalPlayerId: OneSignalService.pushSubscriptionId,
      );
    } catch (_) {
      // Best-effort; do not block dashboard
    }
  }

  @override
  void onClose() {
    tabController.removeListener(_syncModeFromTab);
    tabController.dispose();
    super.onClose();
  }

  // Fetches the app version from the platform and updates the appVersion observable
  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  String get periodLabel {
    if (mode.value == CalendarViewMode.week) {
      final d = focusedDay.value;
      final start = d.subtract(Duration(days: d.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return CcsDateUtils.dateRange(start, end);
    }
    return CcsDateUtils.fullMonthYear(focusedDay.value);
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

    if (tabIndex.value == 2) {
      if (jobs.isEmpty) {
        fetchJobs();
      }
    }
  }

  void openDetail(Jobs job) {
    Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: job.id)?.then((value) {
      if (value != null) {
        log(runtimeType.toString(), "VLUE ${value}");
        if (value.containsKey('action') && value['action'] == 'delete') {
          jobs.removeWhere((p) => p.id == job.id);
          jobs.refresh();
        }
      }
    });
  }

  Future<void> fetchJobs({bool isLoaderShown = true}) async {
    if (!isJobMoreLoading.value && isLoaderShown) Loader.show();
    try {
      final result = await _clientRepository.getJob(page: jobCurrentPage);
      result.handle(
        success: (response) {
          final raw = response.data;
          if (jobCurrentPage == 1) jobs.clear();
          if (raw != null && raw.jobs?.isNotEmpty == true) {
            jobs.assignAll(raw.jobs as Iterable<Jobs>);
          }
          jobTotalPage = (response.data?.pagination?.totalPages ?? 1).toInt();

          if (jobCurrentPage <= jobTotalPage) {
            jobCurrentPage++;
          }
        },
      );
    } finally {
      if (!isJobMoreLoading.value && isLoaderShown) Loader.hide();
      isJobMoreLoading.value = false;
    }
  }

  void goToCreateJob() {
    Get.toNamed(Routes.CLIENT_CREATE_JOB)?.then((value) {
      if (value != null) {
        if (value['isUpdate'] != null) {
          if (value['isUpdate']) {
            jobCurrentPage = 1;
            fetchJobs();
          }
        }
      }
    });
  }
}
