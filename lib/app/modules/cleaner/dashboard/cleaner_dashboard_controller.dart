import 'dart:io' show Platform;

import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../model/availability.dart';
import '../../../model/calendar_event.dart';
import '../../../model/common_model.dart';
import '../../../model/menu_model.dart';
import '../../../network/repository/cleaner_repository.dart';
import 'view/cleaner_availability_view.dart';
import 'view/cleaner_calendar_view.dart';
import 'view/cleaner_dashboard_content.dart';
import 'view/cleaner_jobs_view.dart';
import 'view/cleaner_profile_view.dart';

class CleanerDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final tabIndex = 0.obs;

  late final TabController tabController;
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>();

  static const modes = [CalendarViewMode.week, CalendarViewMode.month, CalendarViewMode.list];
  final mode = CalendarViewMode.month.obs;

  /// Schedule validity: from / to (date-only) for this weekly pattern.
  final scheduleValidFrom = Rx<DateTime>(DateTime.now());
  final scheduleValidTo = Rx<DateTime>(DateTime.now().add(const Duration(days: 365)));

  /// Weekly: index 0 = Monday .. 6 = Sunday. Toggle + multiple slots per day.
  final weeklySchedule = <DayAvailability>[].obs;

  /// Specific dates when the cleaner is not available (date-only).
  final blockedDays = <DateTime>[].obs;

  List<Widget> get pages => const [
        CleanerDashboardContent(),
        CleanerCalendarView(),
        CleanerJobsView(),
        CleanerAvailabilityView(),
        CleanerProfileView(),
      ];

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

  /// Flattened, sorted (date asc) for dashboard. Replace with API-backed source.
  List<(DateTime date, CalendarEvent event)> get upcomingJobsForDashboard {
    final list = <(DateTime, CalendarEvent)>[];
    for (final e in eventsMap.entries) {
      for (final ev in e.value) {
        list.add((e.key, ev));
      }
    }
    list.sort((a, b) => a.$1.compareTo(b.$1));
    return list;
  }

  /// Placeholder. Replace with API/session.
  String get earningsTotal => '£0.00';

  /// From API (profile-completion, action-needed). Updated when dashboard loads.
  final actionNeededCount = 0.obs;
  final isProfileComplete = false.obs;
  final profileCompletionPercentage = 0.obs;

  String get periodLabel {
    if (mode.value == CalendarViewMode.week) {
      final d = focusedDay.value;
      final start = d.subtract(Duration(days: d.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return CcsDateUtils.dateRange(start, end);
    }
    return CcsDateUtils.fullMonthYear(focusedDay.value);
  }

  List<MenuModel> profileItems = [
    MenuModel(icon: IconsaxPlusLinear.lock_1, title: 'Change password', subtitle: "Change password to protect your account"),
    MenuModel(icon: IconsaxPlusLinear.home_hashtag, title: 'Properties', subtitle: "Manage your properties"),
    MenuModel(icon: IconsaxPlusLinear.people, title: 'Preferred Staff', subtitle: "Manage your preferred staff members"),
    MenuModel(icon: IconsaxPlusLinear.notification, title: 'Notifications', subtitle: "View and manage notifications"),
    MenuModel(icon: IconsaxPlusLinear.trade, title: 'Training & Resources', subtitle: "View Training Resources & FAQs"),
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'Help & support', subtitle: "Get help and support"),
  ];

  List<MenuModel> cleanerProfileItems = [
    MenuModel(icon: IconsaxPlusLinear.lock_1, title: 'Change password', subtitle: "Change password to protect your account"),
    MenuModel(icon: IconsaxPlusLinear.home_hashtag, title: 'References', subtitle: "Manage your references"),
    MenuModel(icon: IconsaxPlusLinear.people, title: 'Supporting Documents', subtitle: "Manage your supporting documents"),
    MenuModel(icon: IconsaxPlusLinear.people, title: 'My Reviews', subtitle: "Manage your reviews"),
    MenuModel(icon: IconsaxPlusLinear.alarm, title: 'Work Hours & Pay', subtitle: "Manage your work hour & pay"),
    MenuModel(icon: IconsaxPlusLinear.notification, title: 'Notifications', subtitle: "View and manage notifications"),
    MenuModel(icon: IconsaxPlusLinear.trade, title: 'Training & Resources', subtitle: "View Training Resources & FAQs"),
    MenuModel(icon: IconsaxPlusLinear.message_text, title: 'Support chat', subtitle: "Message admin for help"),
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'Help & support', subtitle: "Get help and support"),
  ];

  List<String> propertyNameOptions = ['British Citizen / Right of Adobe', 'Settled Status', 'Other'];
  List<String> statusOptions = ['All', 'Finished', 'Approved'];
  final selectedPropertyName = Rxn<String>();
  final selectedStatus = Rxn<String>();
  RxList<CommonModel> filter = <CommonModel>[].obs;

  var appVersion = "".obs;

  // Controllers and focus node
  final TextEditingController propertyController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // This will hold the suggestions that will be used in the typeahead field
  final SuggestionsController<String> suggestionsController = SuggestionsController<String>();
  final jobs = <ClientJob>[].obs;

  @override
  void onInit() {
    super.onInit();
    /*if (!Get.find<SessionService>().isLoggedIn) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }*/
    selectedDay.value = DateTime.now();
    if (weeklySchedule.isEmpty) {
      weeklySchedule.assignAll(List.generate(7, DayAvailability.getDefault));
    }
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      tabIndex.value = (args['tab'] as int).clamp(0, pages.length - 1);
    }
    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    tabController.addListener(_syncModeFromTab);

    filter.clear();
    filter.add(CommonModel(type: "All Jobs", isSelected: true));
    filter.add(CommonModel(type: "Pending"));
    filter.add(CommonModel(type: "Approved"));

    getAppVersion();
    _registerDevice();
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

  @override
  void onReady() {
    super.onReady();
    jobs.assignAll(ClientJob.demoJobs);
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final compResult = await _cleanerRepository.getProfileCompletion();
      switch (compResult) {
        case NetworkSuccess(data: final res):
          final data = res.data;
          if (data is Map) {
            final pc = data['profile_completion'];
            if (pc is Map) {
              final pct = pc['percentage'];
              if (pct is int) profileCompletionPercentage.value = pct;
              isProfileComplete.value = pct == 100;
            }
          }
        case NetworkError():
          break;
      }
      final actionResult = await _cleanerRepository.getActionNeeded();
      switch (actionResult) {
        case NetworkSuccess(data: final res):
          final data = res.data;
          if (data is Map && data['action_needed_count'] is int) {
            actionNeededCount.value = data['action_needed_count'] as int;
          }
        case NetworkError():
          break;
      }
    } catch (_) {}
  }

  void openDetail(ClientJob job) {
    final path = Routes.CLEANER_JOB_DETAIL.replaceFirst(':id', job.id);
    Get.toNamed(path, arguments: job);
  }

  // Fetches the app version from the platform and updates the appVersion observable
  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
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

  // --- Availability (weekly: Mon–Sun, toggle + slots; + blocked dates) ---

  void setScheduleValidFrom(DateTime d) {
    scheduleValidFrom.value = DateTime(d.year, d.month, d.day);
  }

  void setScheduleValidTo(DateTime d) {
    scheduleValidTo.value = DateTime(d.year, d.month, d.day);
  }

  void updateDay(int i, {bool? enabled, List<TimeSlot>? slots}) {
    if (i < 0 || i >= weeklySchedule.length) return;
    final c = List<DayAvailability>.from(weeklySchedule);
    c[i] = c[i].copyWith(enabled: enabled, slots: slots);
    weeklySchedule.assignAll(c);
  }

  void addSlot(int i) {
    if (i < 0 || i >= weeklySchedule.length) return;
    final c = List<DayAvailability>.from(weeklySchedule);
    c[i] = c[i].copyWith(slots: [...c[i].slots, TimeSlot()]);
    weeklySchedule.assignAll(c);
  }

  void removeSlot(int i, int slotIndex) {
    if (i < 0 || i >= weeklySchedule.length) return;
    final day = weeklySchedule[i];
    if (slotIndex < 0 || slotIndex >= day.slots.length) return;
    final newSlots = List<TimeSlot>.from(day.slots)..removeAt(slotIndex);
    updateDay(i, slots: newSlots);
  }

  void updateSlot(int i, int slotIndex, {TimeOfDay? start, TimeOfDay? end}) {
    if (i < 0 || i >= weeklySchedule.length) return;
    final day = weeklySchedule[i];
    if (slotIndex < 0 || slotIndex >= day.slots.length) return;
    final newSlots = List<TimeSlot>.from(day.slots);
    newSlots[slotIndex] = newSlots[slotIndex].copyWith(start: start, end: end);
    updateDay(i, slots: newSlots);
  }

  void addBlockedDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (blockedDays.any((x) => x.year == d.year && x.month == d.month && x.day == d.day)) return;
    blockedDays.add(d);
  }

  void removeBlockedDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    blockedDays.removeWhere((x) => x.year == d.year && x.month == d.month && x.day == d.day);
  }

  List<String> getSuggestions(String pattern) {
    return propertyNameOptions.where((item) => item.toLowerCase().contains(pattern.toLowerCase())).toList();
  }

  void onSelected(String selectedItem) {
    propertyController.text = selectedItem;
  }

  void openFilter(BuildContext context) {
    Notifier.openSheet(context, body: filterJob(context), showIcon: false, showPrimaryButton: false, showSecondaryButton: false);
  }

  Widget filterJob(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      children: [
        AppCard(
          color: Colors.transparent,
          enableShadows: false,
          child: Row(
            children: [
              AppCard(
                radius: UiConstants.radiusDefault,
                color: scheme.secondaryContainer.withValues(alpha: 0.7),
                child: Icon(
                  IconsaxPlusLinear.filter_search,
                  size: 20,
                  color: scheme.secondary,
                ).paddingAll(10),
              ).marginOnly(right: UiConstants.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.bold('Filter Jobs', size: 18, color: scheme.onSurface),
                    const SizedBox(height: 2),
                    CommonText.regular(
                      'By property and status',
                      size: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).marginOnly(bottom: 12),

        // Filter card
        Obx(() {
          return AppCard(
            radius: UiConstants.radiusLarge,
            enableShadows: true,
            borderWidth: 1,
            borderColor: scheme.outline.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonTypeAheadField<String>(
                  controller: propertyController,
                  focusNode: focusNode,
                  suggestionsController: suggestionsController,
                  suggestionsCallback: getSuggestions,
                  itemBuilder: (context, item) {
                    return ListTile(
                      title: CommonText.regular(item),
                    );
                  },
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 1,
                        height: 24,
                        color: context.colorScheme.outline,
                      ).marginOnly(right: 8),
                      Icon(
                        IconsaxPlusLinear.arrow_down,
                        color: scheme.onSurfaceVariant,
                      )
                    ],
                  ),
                  onSelected: onSelected,
                  hint: 'Select Property Name',
                ),
                SizedBox(height: UiConstants.gap),
                CommonDropDownField(
                  itemLabel: (value) => value.toString(),
                  hint: 'Select Status',
                  label: 'Status',
                  onChanged: (value) {
                    selectedStatus.value = value;
                  },
                  items: statusOptions,
                  value: selectedStatus.value,
                  borderRadius: UiConstants.radiusDefault,
                ),
              ],
            ).paddingAll(UiConstants.defaultPadding),
          );
        }).marginOnly(bottom: 18),

        Row(
          children: [
            Expanded(
              child: AppButton(
                type: ButtonType.tonal,
                label: 'Cancel',
                onPressed: () => Get.back(),
              ).marginOnly(right: 4),
            ),
            Expanded(
              child: AppButton(
                type: ButtonType.primary,
                label: 'Apply Filter',
                onPressed: () => Get.back(),
              ).marginOnly(left: 4),
            ),
          ],
        ),
      ],
    );
  }
}
