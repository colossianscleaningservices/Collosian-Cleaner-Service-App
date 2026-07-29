import 'package:ccs_app/export.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../model/calendar_event.dart';
import '../../../../widget/common/month_year_picker.dart';
import '../cleaner_dashboard_controller.dart';

class CleanerCalendarView extends GetView<CleanerDashboardController> {
  const CleanerCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Assigned / Available toggle ───────────────────────────────────

          Row(
            children: [
              Expanded(child: Obx(() {
                final current = controller.calendarJobMode.value;
                return AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeChip(
                          label: 'Assigned',
                          icon: IconsaxPlusLinear.calendar_tick,
                          selected: current == CalendarJobMode.assigned,
                          scheme: scheme,
                          onTap: () => controller.toggleCalendarJobMode(CalendarJobMode.assigned),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeChip(
                          label: 'Unassigned',
                          icon: IconsaxPlusLinear.briefcase,
                          selected: current == CalendarJobMode.available,
                          scheme: scheme,
                          onTap: () => controller.toggleCalendarJobMode(CalendarJobMode.available),
                        ),
                      ),
                    ],
                  ).paddingAll(8),
                ).marginOnly(left: 24);
              })),
              AppCard(
                onTap: controller.openAllJobs,
                color: Colors.transparent,
                enableShadows: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText.semiBold('View all', size: 13, color: scheme.primary),
                    Icon(
                      IconsaxPlusLinear.arrow_right_3,
                      color: context.colorScheme.secondary,size: 18,
                    )
                  ],
                ).paddingSymmetric(horizontal: 12, vertical: 16),
              ).marginOnly(left: 12, right: 8),
            ],
          ),

          const SizedBox(height: 12),
          AppCard(
            child: TabBar(
              unselectedLabelStyle: context.textTheme.bodyLarge,
              labelStyle: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
              labelColor: scheme.secondary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              indicatorColor: scheme.secondary,
              controller: controller.tabController,
              tabs: const [
                Tab(text: 'Week'),
                Tab(text: 'Month'),
                Tab(text: 'List'),
              ],
            ),
          ).marginOnly(bottom: 16, left: 24, right: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(IconsaxPlusLinear.arrow_left_1, color: scheme.secondary),
                onPressed: controller.onCalendarPrev,
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showMonthYearPicker(context, controller.focusedDay.value);
                  if (picked != null) controller.onCalendarPageChanged(picked);
                },
                child: Obx(() => CommonText.bold(controller.periodLabel, size: 16, color: scheme.onSurface)),
              ),
              IconButton(
                icon: Icon(IconsaxPlusLinear.arrow_right_3, color: scheme.secondary),
                onPressed: controller.onCalendarNext,
              ),
            ],
          ).marginSymmetric(horizontal: 24),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    controller.onCalendarContentScrolled(n.metrics);
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Obx(() => _CalendarSection(
                          scheme: scheme,
                          mode: CalendarViewMode.week,
                          focusedDay: controller.focusedDay.value,
                          selectedDay: controller.selectedDay.value,
                          eventsMap: controller.activeEventsMap,
                          isAvailableMode: controller.calendarJobMode.value == CalendarJobMode.available,
                          onDaySelected: controller.onCalendarDaySelected,
                          onPageChanged: controller.onCalendarPageChanged,
                          ctrl: controller,
                        )),
                  ),
                ),
                NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    controller.onCalendarContentScrolled(n.metrics);
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Obx(() => _CalendarSection(
                          scheme: scheme,
                          mode: CalendarViewMode.month,
                          focusedDay: controller.focusedDay.value,
                          selectedDay: controller.selectedDay.value,
                          eventsMap: controller.activeEventsMap,
                          isAvailableMode: controller.calendarJobMode.value == CalendarJobMode.available,
                          onDaySelected: controller.onCalendarDaySelected,
                          onPageChanged: controller.onCalendarPageChanged,
                          ctrl: controller,
                        )),
                  ),
                ),
                SingleChildScrollView(
                  controller: controller.calendarListScrollController,
                  child: Obx(() => _ListContentView(
                        scheme: scheme,
                        ctrl: controller,
                        eventsMap: controller.activeEventsMap,
                        isAvailableMode: controller.calendarJobMode.value == CalendarJobMode.available,
                      ).marginSymmetric(horizontal: 8).marginOnly(bottom: 16)),
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(top: 16),
    );
  }
}

// ─── Segmented mode chip ──────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? scheme.primary : scheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: CommonText.semiBold(
                label,
                size: 13,
                color: fg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.scheme,
    required this.mode,
    required this.focusedDay,
    required this.selectedDay,
    this.eventsMap,
    this.isAvailableMode = false,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.ctrl,
  });

  final ColorScheme scheme;
  final CalendarViewMode mode;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<CalendarEvent>>? eventsMap;
  final bool isAvailableMode;
  final dynamic onDaySelected;
  final dynamic onPageChanged;
  final CleanerDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
    final sectionTitle = isAvailableMode ? 'Open jobs' : 'Upcoming';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: TableCalendar<CalendarEvent>(
            firstDay: kCalendarFirstDay,
            lastDay: kCalendarLastDay,
            focusedDay: focusedDay,
            currentDay: DateTime.now(),
            selectedDayPredicate: (d) => selectedDay != null && isSameDay(d, selectedDay!),
            calendarFormat: mode == CalendarViewMode.week ? CalendarFormat.week : CalendarFormat.month,
            eventLoader: (day) => eventsMap?[DateTime(day.year, day.month, day.day)] ?? [],
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarBuilders: CalendarBuilders<CalendarEvent>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final n = events.length > 3 ? 3 : events.length;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    n,
                    (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                selectedDecoration:
                    BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle, border: Border.all(color: scheme.secondary, width: 2)),
                selectedTextStyle: context.textTheme.bodyLarge!.copyWith(color: scheme.secondary)),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              weekendStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ).marginSymmetric(vertical: 16),
        ).marginOnly(top: 16, left: 4, right: 4).marginSymmetric(horizontal: 24),
        SizedBox(height: UiConstants.gap),
        CommonText.semiBold(sectionTitle, size: 16, color: scheme.onSurface).marginSymmetric(horizontal: 24),
        const SizedBox(height: 8),
        _UpcomingEvents(
          scheme: scheme,
          eventsMap: eventsMap,
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          isAvailableMode: isAvailableMode,
          onMyJobsPressed: () => ctrl.openAllJobs(),
          onJobTap: (event) => ctrl.openDetail(event.jobId),
        ).marginSymmetric(horizontal: 24).marginOnly(bottom: 8),
        Obx(() {
          if (!ctrl.isCalendarMoreLoading.value) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(color: scheme.primary)),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Shows events for the selected (or focused) day, or empty state.
class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents({
    required this.scheme,
    this.eventsMap,
    this.selectedDay,
    required this.focusedDay,
    this.isAvailableMode = false,
    required this.onMyJobsPressed,
    required this.onJobTap,
  });

  final ColorScheme scheme;
  final Map<DateTime, List<CalendarEvent>>? eventsMap;
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final bool isAvailableMode;
  final VoidCallback onMyJobsPressed;
  final void Function(CalendarEvent) onJobTap;

  @override
  Widget build(BuildContext context) {
    final day = selectedDay ?? focusedDay;
    final dateKey = DateTime(day.year, day.month, day.day);
    final events = eventsMap?[dateKey] ?? [];
    final dateLabel = CcsDateUtils.shortDate(day);

    if (events.isEmpty) {
      return CalendarEmptyCard(
        scheme: scheme,
        onMyJobsPressed: onMyJobsPressed,
        title: isAvailableMode ? 'No available jobs on $dateLabel.' : 'No jobs on $dateLabel.',
        subtitle: isAvailableMode ? 'Open jobs you can apply for will appear here.' : 'Your assigned jobs will appear here.',
      );
    }

    return AppGrid(
      maxExtent: 130,
      axisSpacing: 8,
      phoneCount: 1,
      tabletCount: 2,
      landscapeCount: 3,
      physics: NeverScrollableScrollPhysics(),
      child: List.generate(
        events.length,
        (i) {
          var status = events[i].cleanerJobStatus ?? (events[i].status ?? "N/A");
          if (events[i].status == Constants.jobFinished) {
            status = events[i].status ?? status;
          }

          return JobCard(
            title: events[i].title,
            dateTime: '${CcsDateUtils.shortDateNoYear(dateKey)} · ${events[i].timeRange}',
            status: status,
            propertyName: events[i].propertyName,
            address: events[i].address,
            onTap: () => onJobTap(events[i]),
          );
        },
      ),
    );
  }
}

class _ListContentView extends StatelessWidget {
  const _ListContentView({
    required this.scheme,
    required this.ctrl,
    this.eventsMap,
    this.isAvailableMode = false,
  });

  final ColorScheme scheme;
  final CleanerDashboardController ctrl;
  final Map<DateTime, List<CalendarEvent>>? eventsMap;
  final bool isAvailableMode;

  @override
  Widget build(BuildContext context) {
    final list = <(DateTime, CalendarEvent)>[];
    if (eventsMap != null) {
      for (final e in eventsMap!.entries) {
        for (final ev in e.value) {
          list.add((e.key, ev));
        }
      }
      list.sort((a, b) => a.$1.compareTo(b.$1));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText.semiBold(isAvailableMode ? 'Open jobs' : 'Upcoming', size: 16, color: scheme.onSurface),
        const SizedBox(height: 8),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CalendarEmptyCard(
              scheme: scheme,
              onMyJobsPressed: () => ctrl.openAllJobs(),
              title: isAvailableMode ? 'No available jobs this period.' : 'No jobs this period.',
              subtitle: isAvailableMode ? 'Open jobs you can apply for will appear here.' : 'Your assigned jobs will appear here.',
            ),
          )
        else
          Column(
            children: [
              AppGrid(
                maxExtent: 140,
                axisSpacing: 8,
                phoneCount: 1,
                tabletCount: 2,
                landscapeCount: 3,
                physics: NeverScrollableScrollPhysics(),
                child: List.generate(
                  list.length,
                  (i) {
                    var status = list[i].$2.cleanerJobStatus ?? (list[i].$2.status ?? "N/A");
                    if (list[i].$2.status == Constants.jobFinished) {
                      status = list[i].$2.status ?? status;
                    }

                    return JobCard(
                      title: list[i].$2.title,
                      dateTime: '${CcsDateUtils.shortDateNoYear(list[i].$1)} · ${list[i].$2.timeRange}',
                      status: status,
                      propertyName: list[i].$2.propertyName,
                      address: list[i].$2.address,
                      onTap: () => ctrl.openDetail(list[i].$2.jobId),
                    );
                  },
                ),
              ),
              Obx(() {
                if (!ctrl.isCalendarMoreLoading.value) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: scheme.primary)),
                );
              }),
            ],
          ),
      ],
    ).marginSymmetric(horizontal: 14);
  }
}
