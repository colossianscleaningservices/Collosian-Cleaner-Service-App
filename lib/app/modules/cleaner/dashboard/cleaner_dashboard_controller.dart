import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../model/availability.dart';
import '../../../model/calendar_event.dart';
import '../../../model/menu_model.dart';
import 'cleaner_availability_view.dart';
import 'cleaner_calendar_view.dart';
import 'cleaner_dashboard_content.dart';
import 'cleaner_jobs_view.dart';
import 'cleaner_profile_view.dart';

class CleanerDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
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

  /// Placeholder. Replace with API (documents, confirmations, messages).
  int get actionNeededCount => 0;

  /// Placeholder. Replace with session/profile check.
  bool get isProfileComplete => false;

  String get periodLabel {
    if (mode.value == CalendarViewMode.week) {
      final d = focusedDay.value;
      final start = d.subtract(Duration(days: d.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.day}–${end.day} ${DateFormat('MMM yyyy').format(start)}';
    }
    return DateFormat('MMMM yyyy').format(focusedDay.value);
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
    MenuModel(icon: IconsaxPlusLinear.message_question, title: 'Help & support', subtitle: "Get help and support"),
  ];

  var appVersion = "".obs;

  @override
  void onInit() {
    super.onInit();
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

    getAppVersion();
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
}
