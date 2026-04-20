import 'dart:io' show Platform;

import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/request/availability_request.dart';
import 'package:ccs_app/app/network/response/get_transaction_history_response.dart';
import 'package:ccs_app/app/network/response/payout_earning_response.dart';
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
import '../../../network/repository/common_repository.dart';
import '../../../network/response/get_availability_response.dart' as avail_resp;
import '../../../network/response/jobs.dart';
import '../../../network/response/staff_dashboard_response.dart';
import '../../../services/session_service.dart';
import 'view/cleaner_availability_view.dart';
import 'view/cleaner_calendar_view.dart';
import 'view/cleaner_dashboard_content.dart';
import 'view/cleaner_jobs_view.dart';
import 'view/cleaner_profile_view.dart';

class CleanerDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final CommonRepository _commonRepository = CommonRepository();
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final tabIndex = 0.obs;

  List<MenuModel> alertItems = [
    MenuModel(icon: IconsaxPlusLinear.user, title: 'Complete Profile', subtitle: 'Add your personal and work details'),
    MenuModel(icon: IconsaxPlusLinear.document, title: 'Upload Documents', subtitle: 'Submit ID and required verification files'),
    MenuModel(icon: IconsaxPlusLinear.calendar, title: 'View Calendar', subtitle: 'Check assigned jobs and upcoming schedule'),
  ];

  late final TabController tabController;
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>();
  final hasUnreadNotifications = false.obs;

  static const modes = [CalendarViewMode.week, CalendarViewMode.month, CalendarViewMode.list];
  final mode = CalendarViewMode.month.obs;

  /// Schedule validity: from / to (date-only) for this weekly pattern.
  final scheduleValidFrom = Rx<DateTime>(DateTime.now());
  final scheduleValidTo = Rx<DateTime>(DateTime.now().add(const Duration(days: 365)));

  /// Weekly: index 0 = Monday .. 6 = Sunday. Toggle + multiple slots per day.
  final weeklySchedule = <DayAvailability>[].obs;

  /// Calendar events from getClientCalender() API, keyed by date (date-only).
  final calendarEventsMap = Rx<Map<DateTime, List<CalendarEvent>>>({});

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
  Map<DateTime, List<CalendarEvent>> get eventsMap => calendarEventsMap.value;

  /// Placeholder. Replace with API/session.
  RxString earningsTotal = '£0.00'.obs;

  var userDisplayName = ''.obs;
  var userDisplayImage = ''.obs;

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

  RxList<String> propertyNameOptions = <String>[].obs;
  List<String> statusOptions = ['All', 'Finished', 'Approved', 'Pending', 'Created', 'Cancelled'];
  final selectedStatus = Rxn<String>();
  RxList<CommonModel> filter = <CommonModel>[].obs;

  var appVersion = "".obs;

  // Controllers and focus node
  final TextEditingController propertyController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // This will hold the suggestions that will be used in the typeahead field
  final SuggestionsController<String> suggestionsController = SuggestionsController<String>();

  final jobs = <Jobs>[].obs;

  final Rxn<StaffDashModel> staffDash = Rxn<StaffDashModel>(null);

  //JOBS
  var jobCurrentPage = 1;
  var jobTotalPage = 1;
  RxBool isJobMoreLoading = false.obs;
  ScrollController jobScrollController = ScrollController();

  //EARNING
  final Rxn<PayoutEarningModel> payoutEarning = Rxn<PayoutEarningModel>(null);
  final RxList<Payouts> transactionHistory = <Payouts>[].obs;
  ScrollController scrollController = ScrollController();
  var totalPage = 1;
  var currentPage = 1;
  bool _isLoading = false;

  @override
  void onInit() {
    super.onInit();
    if (!Get.find<SessionService>().isLoggedIn) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    selectedDay.value = DateTime.now();
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

    userDisplayName.value = Get.find<SessionService>().userDisplayName;
    userDisplayImage.value = Get.find<SessionService>().userDisplayImage;

    jobScrollController.addListener(() {
      if (_isScrollBottom) {
        if (jobCurrentPage <= jobTotalPage && !isJobMoreLoading.value) {
          isJobMoreLoading.value = true;
          fetchJobs();
        }
      }
    });

    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage && !_isLoading) {
          getTransactionHistory();
        }
      }
    });

    getAppVersion();
    _registerDevice();
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

  @override
  void onReady() {
    super.onReady();
    fetchDashboardData(showAlert: true);
    getProfile();
  }

  Future<void> fetchDashboardData({bool showAlert = false, showLoader}) async {
    Loader.show();
    try {
      final compResult = await _cleanerRepository.getCleanerDashboard();
      compResult.handle(
        success: (res) {
          staffDash.value = res.data;
          profileCompletionPercentage.value = staffDash.value?.profileCompletion?.percentage?.toInt() ?? 0;
          isProfileComplete.value = profileCompletionPercentage.value == 100;
          earningsTotal.value = "£${staffDash.value?.totalEarnings?.toString()}";

          hasUnreadNotifications.value = ((staffDash.value?.unreadNotifications ?? 0) > 0);

          final documentAdded = staffDash.value?.isDocumentAdded ?? false;

          if (showAlert && !documentAdded) {
            Loader.hide();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.context == null) return;
              showAlertSheet(Get.context!);
            });
          }
        },
      );
    } catch (_) {
    } finally {
      Loader.hide();
    }
  }

  void openDetail(num? job) {
    Get.toNamed(Routes.CLEANER_JOB_DETAIL, arguments: {'jobId': job});
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
    final day = selected ?? focused;
    if (mode.value == CalendarViewMode.month || mode.value == CalendarViewMode.week) return;
    getCleanerCalender(forDate: day, singleDay: true);
  }

  void onCalendarPageChanged(DateTime focused) {
    focusedDay.value = focused;
    getCleanerCalender(forDate: focused, forWeek: mode.value == CalendarViewMode.week);
  }

  void onCalendarPrev() {
    if (mode.value == CalendarViewMode.week) {
      focusedDay.value = focusedDay.value.subtract(const Duration(days: 7));
    } else {
      focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month - 1, focusedDay.value.day);
    }
    if (focusedDay.value.isBefore(kCalendarFirstDay)) focusedDay.value = kCalendarFirstDay;
    getCleanerCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
  }

  void onCalendarNext() {
    if (mode.value == CalendarViewMode.week) {
      focusedDay.value = focusedDay.value.add(const Duration(days: 7));
    } else {
      focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month + 1, focusedDay.value.day);
    }
    if (focusedDay.value.isAfter(kCalendarLastDay)) focusedDay.value = kCalendarLastDay;
    getCleanerCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
  }

  Future<void> setTab(int index) async {
    tabIndex.value = index.clamp(0, pages.length - 1);

    if (index == 2) {
      var item = filter.firstWhereOrNull((item) => item.isSelected);

      String type = '';

      if (item != null && item.type != 'All Jobs') {
        type = item.type;
      }

      jobCurrentPage = 1;
      fetchJobs(filter: type);
    } else if (tabIndex.value == 1) {
      await getCleanerCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
      if (propertyNameOptions.isEmpty) await geCleanerProperties();
    } else if (tabIndex.value == 3 && weeklySchedule.isEmpty) {
      weeklySchedule.assignAll(List.generate(7, DayAvailability.getDefault));
      getCleanerAvailability();
    }
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
                enableShadows: false,
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
            radius: 0,
            enableShadows: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonTypeAheadField<String>(
                  controller: propertyController,
                  focusNode: focusNode,
                  label: 'Property Name',
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
            ).paddingSymmetric(vertical: 0),
          );
        }).marginOnly(bottom: 18),

        Row(
          children: [
            Expanded(
              child: AppButton(
                type: ButtonType.tonal,
                label: 'Reset Filter',
                onPressed: () {
                  Get.back();
                  if (propertyController.text.isNotEmpty || selectedStatus.value != null) {
                    propertyController.clear();
                    selectedStatus.value = null;
                    getCleanerCalender();
                  }
                },
              ).marginOnly(right: 4),
            ),
            Expanded(
              child: AppButton(
                type: ButtonType.primary,
                label: 'Apply Filter',
                onPressed: () {
                  if (propertyController.text.isEmpty && selectedStatus.value == null) {
                    Notifier.error('Please select option to apply filter.');
                  } else {
                    Get.back();
                    getCleanerCalender();
                  }
                },
              ).marginOnly(left: 4),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> fetchJobs({bool isLoaderShown = true, String filter = ''}) async {
    if (!isJobMoreLoading.value && isLoaderShown) Loader.show();
    try {
      final result = await _cleanerRepository.getCleanerJob(page: jobCurrentPage, status: filter);
      result.handle(
        success: (response) {
          final raw = response.data;
          if (jobCurrentPage == 1) jobs.clear();
          if (raw != null && raw.jobs?.isNotEmpty == true) {
            jobs.addAll(raw.jobs as Iterable<Jobs>);
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

  /// Fetches calendar jobs. [singleDay] = that day only; [forWeek] = that week (Mon–Sun); else that month.
  Future<void> getCleanerCalender({DateTime? forDate, bool singleDay = false, bool forWeek = false}) async {
    Loader.show();
    try {
      String? dateFrom;
      String? dateTo;
      String? date;
      if (forDate != null) {
        if (singleDay) {
          final d = DateTime(forDate.year, forDate.month, forDate.day);
          date = _formatDateForApi(d);
        } else if (forWeek) {
          final weekStart = forDate.subtract(Duration(days: forDate.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          dateFrom = _formatDateForApi(DateTime(weekStart.year, weekStart.month, weekStart.day));
          dateTo = _formatDateForApi(DateTime(weekEnd.year, weekEnd.month, weekEnd.day));
        } else {
          final start = DateTime(forDate.year, forDate.month, 1);
          final end = DateTime(forDate.year, forDate.month + 1, 0);
          dateFrom = _formatDateForApi(start);
          dateTo = _formatDateForApi(end);
        }
      }
      final result = await _cleanerRepository.getCleanerCalender(
        dateFrom: dateFrom,
        dateTo: dateTo,
        date: date,
        status: selectedStatus.value == "All" ? null : selectedStatus.value,
        propertyName: propertyController.text.isEmpty ? null : propertyController.text,
      );
      result.handle(
        success: (value) {
          final list = value.data?.jobs;
          if (list == null || list.isEmpty) {
            calendarEventsMap.value = {};
            return;
          }
          final map = <DateTime, List<CalendarEvent>>{};
          for (final item in list) {
            final dateKey = _parseCalendarDate(item.date);
            String? timeRange;
            if (item.startTime != null && item.endTime != null) {
              timeRange = '${CcsDateTimeX.convertTime(item.startTime ?? '')} – ${CcsDateTimeX.convertTime(item.endTime ?? '')}';
            }
            if (dateKey == null) continue;
            final event = CalendarEvent(
                title: item.cleaningType?.name ?? "",
                timeRange: timeRange,
                status: item.status ?? 'Pending',
                jobId: item.id,
                propertyName: item.property?.propertyName ?? "",
                address: item.property?.address ?? "",
                subtitle: item.property?.additionalDetails ?? "",
                cleanerInfo: item.cleaners?.map((cl) => cl.name ?? "").toList().join(', '),
                cleanerJobStatus: item.cleanerJobStatus);
            map.putIfAbsent(dateKey, () => []).add(event);
          }
          calendarEventsMap.value = map;
        },
        contextTag: 'get-cleaner-calender',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-cleaner-calender');
    } finally {
      Loader.hide();
    }
  }

  /// Parses API date string to date-only [DateTime] for calendar key.
  DateTime? _parseCalendarDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String _formatDateForApi(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> setCleanerAvailability() async {
    // Validate time slots: start < end and no overlaps per enabled day.
    for (final day in weeklySchedule) {
      if (!day.enabled) continue;
      if (day.slots.isEmpty) {
        Notifier.info('Please add at least one time slot for ${kDayNames[day.dayIndex]}.');
        return;
      }

      // Convert to minutes since midnight for easier comparison.
      final slotsWithMinutes = day.slots
          .map((slot) => (
                slot: slot,
                startM: slot.start.hour * 60 + slot.start.minute,
                endM: slot.end.hour * 60 + slot.end.minute,
              ))
          .toList();

      for (final s in slotsWithMinutes) {
        if (s.endM <= s.startM) {
          Notifier.info('End time must be after start time for ${kDayNames[day.dayIndex]}.');
          return;
        }
      }

      // Check for overlapping slots within the same day.
      slotsWithMinutes.sort((a, b) => a.startM.compareTo(b.startM));
      for (var i = 1; i < slotsWithMinutes.length; i++) {
        final prev = slotsWithMinutes[i - 1];
        final curr = slotsWithMinutes[i];
        if (curr.startM < prev.endM) {
          Notifier.info('Time slots for ${kDayNames[day.dayIndex]} must not overlap.');
          return;
        }
      }
    }

    // Build request payload from weeklySchedule + blockedDays.
    final weekly = <WeeklySchedule>[];
    for (final day in weeklySchedule) {
      weekly.add(
        WeeklySchedule(
          day: kDayNames[day.dayIndex],
          enabled: day.enabled,
          slots: day.slots
              .map(
                (slot) => Slots(
                  startTime: '${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}',
                  endTime: '${slot.end.hour.toString().padLeft(2, '0')}:${slot.end.minute.toString().padLeft(2, '0')}',
                ),
              )
              .toList(),
        ),
      );
    }

    final blocked = blockedDays.map(_formatDateForApi).toList();

    Loader.show();
    try {
      final request = AvailabilityRequest(
        weeklySchedule: weekly,
        blockedDays: blocked,
      );

      log(runtimeType.toString(), "${request.toJson()}");

      final result = await _cleanerRepository.setCleanerAvailability(request);
      result.handle(
        success: (response) {
          Notifier.success(response.message ?? 'Schedule updated');
          getCleanerAvailability();
        },
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> getCleanerAvailability() async {
    Loader.show();
    try {
      final result = await _cleanerRepository.getCleanerAvailability();
      result.handle(
        success: (response) {
          _applyAvailabilityFromResponse(response);
        },
      );
    } finally {
      Loader.hide();
    }
  }

  /// Applies API availability data to [weeklySchedule] and [blockedDays].
  void _applyAvailabilityFromResponse(avail_resp.GetAvailabilityResponse response) {
    final data = response.data;
    if (data == null) {
      _ensureWeeklyScheduleDefaults();
      blockedDays.clear();
      return;
    }

    // Build 7 days (Mon–Sun). Match API entries by day name.
    final List<DayAvailability> newSchedule = [];
    for (var i = 0; i < 7; i++) {
      final dayName = kDayNames[i];
      final apiDay = data.weeklySchedule?.where((avail_resp.WeeklySchedule w) => w.day == dayName).firstOrNull;
      if (apiDay != null) {
        final slots = apiDay.slots ?? [];
        final timeSlots = slots.map((s) {
          final slot = s as avail_resp.Slots;
          return TimeSlot(
            start: CcsDateUtils.parseTimeOfDay(slot.startTime ?? '09:00'),
            end: CcsDateUtils.parseTimeOfDay(slot.endTime ?? '18:00'),
          );
        }).toList();
        newSchedule.add(DayAvailability(
          dayIndex: i,
          enabled: apiDay.enabled ?? false,
          slots: timeSlots,
        ));
      } else {
        newSchedule.add(DayAvailability.getDefault(i));
      }
    }
    weeklySchedule.assignAll(newSchedule);

    // Blocked days: parse "yyyy-MM-dd" strings to date-only DateTime.
    final blocked = data.blockedDays ?? [];
    blockedDays.assignAll(
      blocked.map((d) => DateTime.tryParse(d)).whereType<DateTime>().map((d) => DateTime(d.year, d.month, d.day)).toList(),
    );
  }

  /// Ensures [weeklySchedule] has exactly 7 default days when API returns nothing.
  void _ensureWeeklyScheduleDefaults() {
    if (weeklySchedule.length != 7) {
      weeklySchedule.assignAll(List.generate(7, DayAvailability.getDefault));
    }
  }

  Future<void> geCleanerProperties() async {
    Loader.show();
    try {
      final result = await _cleanerRepository.geCleanerProperties();
      result.handle(
        success: (response) {
          propertyNameOptions.clear();
          response.data?.forEach((item) {
            propertyNameOptions.add(item.propertyName ?? "");
          });
        },
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> getPayoutDash({bool isLoaderShown = true}) async {
    if (!isJobMoreLoading.value && isLoaderShown) Loader.show();
    Loader.show();
    try {
      final result = await _cleanerRepository.getPayoutDash();
      result.handle(
        success: (response) {
          payoutEarning.value = response.data;
        },
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> getTransactionHistory() async {
    if (_isLoading) return;
    _isLoading = true;
    Loader.show();
    try {
      final result = await _cleanerRepository.getTransactionHistory(
        page: currentPage,
      );
      result.handle(
        success: (response) {
          if (currentPage == 1) transactionHistory.clear();
          transactionHistory.addAll(response.data?.payouts as Iterable<Payouts>);
          transactionHistory.refresh();

          totalPage = (response.data?.pagination?.totalPages ?? 1).toInt();
          if (currentPage <= totalPage) {
            currentPage++;
          }
        },
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> getProfile() async {
    Loader.show();

    try {
      final result = await _commonRepository.getProfile();
      result.handle(
        success: (value) {
          Loader.hide();
          final prefs = Prefs();

          final admins = value.data?.admins;

          final appSetting = value.data?.appSettings;

          if (admins?.isNotEmpty == true) {
            for (final admin in admins!) {
              prefs.addAdminId(admin.id?.toInt() ?? 0);
            }
          }

          if (appSetting != null) {
            prefs.putData(Prefs.supportMail, appSetting.appEmail ?? 'support@collosian.com');
            prefs.putData(Prefs.supportPhone, appSetting.appPhone ?? '+44 (0) 123 456 7890');
          }
        },
        contextTag: 'get-profile',
      );
    } catch (e) {
      Notifier.info('Failed to get profile: $e');
    } finally {
      Loader.hide();
    }
  }

  Future showAlertSheet(BuildContext context) async {
    final scheme = context.colorScheme;

    Notifier.openSheet(
      context,
      top: true,
      showPrimaryButton: false,
      showSecondaryButton: false,
      showIcon: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                AppCard(
                  color: scheme.primaryContainer.withValues(alpha: 0.45),
                  enableShadows: false,
                  padding: const EdgeInsets.all(10),
                  child: Icon(IconsaxPlusLinear.notification, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Action needed', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 2),
                      CommonText.regular(
                        'Completed steps are marked below.',
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).marginOnly(bottom: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alertItems.length,
            itemBuilder: (context, index) {
              final item = alertItems[index];
              return AppCard(
                color: scheme.onPrimary,
                enableShadows: false,
                onTap: () {
                  Get.back();
                  if (index == 0) {
                    Get.toNamed(Routes.CLEANER_EDIT_PROFILE);
                  } else if (index == 1) {
                    Get.toNamed(Routes.SUPPORT_DOCUMENT, arguments: {'from': ' dash'});
                  } else {
                    setTab(1);
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppCard.iconContainer(
                      context: context,
                      padding: const EdgeInsets.all(10),
                      child: Icon(item.icon, size: 20, color: scheme.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.semiBold(item.title ?? '', size: 14, color: scheme.onSurface),
                          if ((item.subtitle ?? '').isNotEmpty) ...[
                            const SizedBox(height: 3),
                            CommonText.regular(
                              item.subtitle ?? '',
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.onSurfaceVariant),
                  ],
                ).paddingAll(14),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
          ),
        ],
      ),
    );
  }
}
