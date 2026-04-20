import 'dart:io' show Platform;

import 'package:ccs_app/app/model/menu_model.dart';
import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/network/repository/common_repository.dart';
import 'package:ccs_app/app/network/response/property_list_response.dart';
import 'package:ccs_app/app/services/onesignal_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:step_progress/step_progress.dart';

import '../../../model/calendar_event.dart';
import '../../../network/repository/client_repository.dart';
import '../../../network/response/get_client_dash_response.dart';
import '../../../network/response/jobs.dart';
import '../../../services/session_service.dart';
import 'view/client_calendar_view.dart';
import 'view/client_dashboard_home.dart';
import 'view/client_jobs_view.dart';
import 'view/client_profile_view.dart';

class ClientDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final CommonRepository _commonRepository = CommonRepository();
  final ClientRepository _clientRepository = ClientRepository();

  late StepProgressController stepProgressController;
  final nodeIcons = [
    Icon(IconsaxPlusBold.user),
    Icon(IconsaxPlusBold.home),
    Icon(IconsaxPlusBold.briefcase),
  ];
  final tabIndex = 0.obs;
  final hasUnreadNotifications = false.obs;
  var appVersion = "".obs;

  List<Widget> get pages => const [
        ClientDashboardContent(), ClientCalendarView(), ClientJobsView(),
        // ClientNotificationsView(),
        ClientProfileView()
      ];

  List<MenuModel> alertItems = [
    MenuModel(icon: IconsaxPlusLinear.user, title: 'Complete Profile', subtitle: "Add your personal and work details"),
    MenuModel(icon: IconsaxPlusLinear.home_2, title: 'Create Property', subtitle: "Add a property to start creating jobs"),
    MenuModel(icon: IconsaxPlusLinear.briefcase, title: 'Create Jobs', subtitle: "Set up a job for your property"),
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

  /// Calendar events from getClientCalender() API, keyed by date (date-only).
  final calendarEventsMap = Rx<Map<DateTime, List<CalendarEvent>>>({});

  /// Properties for dashboard home listing (fetched via listProperties).
  final RxList<PropertyModel> dashboardProperties = <PropertyModel>[].obs;
  final Rxn<ClientDashModel> clientDash = Rxn<ClientDashModel>();

  var registrationProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();

    stepProgressController = StepProgressController(initialStep: 0, totalSteps: 3);

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

  /// Calendar events (from getClientCalender()). Reactive so view updates when API returns.
  Map<DateTime, List<CalendarEvent>> get eventsMap => calendarEventsMap.value;

  void _syncModeFromTab() {
    mode.value = modes[tabController.index];
  }

  void onCalendarDaySelected(DateTime? selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    final day = selected ?? focused;
    if (mode.value == CalendarViewMode.month || mode.value == CalendarViewMode.week) return;
    getClientCalender(forDate: day, singleDay: true);
  }

  void onCalendarPageChanged(DateTime focused) {
    focusedDay.value = focused;
    getClientCalender(forDate: focused, forWeek: mode.value == CalendarViewMode.week);
  }

  void onCalendarPrev() {
    if (mode.value == CalendarViewMode.week) {
      focusedDay.value = focusedDay.value.subtract(const Duration(days: 7));
    } else {
      focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month - 1, focusedDay.value.day);
    }
    if (focusedDay.value.isBefore(kCalendarFirstDay)) focusedDay.value = kCalendarFirstDay;
    getClientCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
  }

  void onCalendarNext() {
    if (mode.value == CalendarViewMode.week) {
      focusedDay.value = focusedDay.value.add(const Duration(days: 7));
    } else {
      focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month + 1, focusedDay.value.day);
    }
    if (focusedDay.value.isAfter(kCalendarLastDay)) focusedDay.value = kCalendarLastDay;
    getClientCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
  }

  void setTab(int index) {
    tabIndex.value = index.clamp(0, pages.length - 1);

    if (tabIndex.value == 2) {
      if (jobs.isEmpty) {
        fetchJobs();
      }
    } else if (tabIndex.value == 1) {
      getClientCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
    }
  }

  void openDetail(Jobs job) {
    Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: job.id)?.then((value) {
      if (value != null) {
        if (value.containsKey('action') && value['action'] == 'delete') {
          jobs.removeWhere((p) => p.id == job.id);
          jobs.refresh();
        }
      }
    });
  }

  /// Navigate to job detail from calendar (by id only). Refreshes calendar on delete.
  void openCalendarJobDetail(num jobId) {
    Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: jobId)?.then((value) {
      if (value != null && value is Map && value['action'] == 'delete') {
        getClientCalender(forDate: focusedDay.value, forWeek: mode.value == CalendarViewMode.week);
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
          isJobMoreLoading.value = false;
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

  /// Fetches calendar jobs. [singleDay] = that day only; [forWeek] = that week (Mon–Sun); else that month.
  Future<void> getClientCalender({DateTime? forDate, bool singleDay = false, bool forWeek = false}) async {
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
      final result = await _clientRepository.getClientCalender(dateFrom: dateFrom, dateTo: dateTo, date: date);
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
            );
            map.putIfAbsent(dateKey, () => []).add(event);
          }
          calendarEventsMap.value = map;
        },
        contextTag: 'get-client-calender',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-client-calender');
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

  Future<void> getClientDash({bool isLoaderShown = true, bool showAlert = false}) async {
    if (isLoaderShown) Loader.show();
    try {
      final result = await _clientRepository.getClientDash();
      result.handle(
        success: (response) {
          final raw = response.data;
          clientDash.value = raw;

          registrationProgress.value = clientDash.value?.registrationProgress?.toInt() ?? 0;

          final profileCreated = true;
          final propertyAdded = clientDash.value?.propertyAdded ?? false;
          final jobAdded = clientDash.value?.jobAdded ?? false;

          if (profileCreated && propertyAdded && jobAdded) {
            stepProgressController.setCurrentStep(2);
          } else if (profileCreated && propertyAdded) {
            stepProgressController.setCurrentStep(1);
          } else if (profileCreated) {
            stepProgressController.setCurrentStep(0);
          }

          if (raw != null && raw.properties?.isNotEmpty == true) {
            dashboardProperties.assignAll(raw.properties as Iterable<PropertyModel>);
          } else {
            dashboardProperties.clear();
          }

          hasUnreadNotifications.value = (raw?.unreadNotifications ?? 0) > 0;

          if (showAlert && !jobAdded) {
            Loader.hide();
            // Defer sheet to next frame so Loader.hide() from finally can close the loader first
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.context == null) return;
              showAlertSheet(Get.context!);
            });
          }
        },
        onError: (e) {
          log(runtimeType.toString(), "ERROR ${e}");
        },
        contextTag: 'get-client-dash',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-client-dash');
    } finally {
      if (isLoaderShown) Loader.hide();
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
        children: [
          // Container(
          //   padding: const EdgeInsets.all(14),
          //   decoration: BoxDecoration(
          //     color: scheme.primaryContainer.withValues(alpha: 0.22),
          //     borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
          //     border: Border.all(
          //       color: scheme.primary.withValues(alpha: 0.12),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       AppCard(
          //         color: scheme.primaryContainer.withValues(alpha: 0.45),
          //         enableShadows: false,
          //         padding: const EdgeInsets.all(10),
          //         child: Icon(IconsaxPlusLinear.notification, size: 20, color: scheme.primary),
          //       ),
          //       const SizedBox(width: 10),
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             CommonText.semiBold('Action needed', size: 16, color: scheme.onSurface),
          //             const SizedBox(height: 2),
          //             CommonText.regular(
          //               'Completed steps are marked below.',
          //               size: 12,
          //               color: scheme.onSurfaceVariant,
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ).marginOnly(bottom: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alertItems.length,
            itemBuilder: (context, index) {
              final item = alertItems[index];
              return AppCard(
                color: context.colorScheme.onPrimary,
                borderWidth: 0,
                onTap: () {
                  Get.back();
                  if (index == 0) {
                    Get.toNamed(Routes.CLIENT_EDIT_PROFILE);
                  } else if (index == 1) {
                    Get.toNamed(Routes.ADD_PROPERTY);
                  } else {
                    goToCreateJob();
                  }
                },
                child:  Row(
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
          CommonText.regular('Follow these quick steps to get started', size: 16, color: scheme.onSecondary.withValues(alpha: 0.5),).marginOnly(bottom: 16),
        ],
      ),
    );
  }

  @override
  void onReady() {
    getClientDash(showAlert: true);
    getProfile();
    super.onReady();
  }
}
