import 'package:ccs_app/export.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../model/calendar_event.dart';
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
                icon: Icon(
                  IconsaxPlusLinear.arrow_left_1,
                  color: scheme.secondary,
                ),
                onPressed: controller.onCalendarPrev,
              ),
              Obx(() => CommonText.bold(controller.periodLabel, size: 16, color: scheme.onSurface)),
              IconButton(
                icon: Icon(
                  IconsaxPlusLinear.arrow_right_3,
                  color: scheme.secondary,
                ),
                onPressed: controller.onCalendarNext,
              ),
            ],
          ).marginSymmetric(horizontal: 24),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                SingleChildScrollView(
                  child: Obx(() => _CalendarSection(
                        scheme: scheme,
                        mode: CalendarViewMode.week,
                        focusedDay: controller.focusedDay.value,
                        selectedDay: controller.selectedDay.value,
                        eventsMap: controller.eventsMap,
                        onDaySelected: controller.onCalendarDaySelected,
                        onPageChanged: controller.onCalendarPageChanged,
                        ctrl: controller,
                      )),
                ),
                SingleChildScrollView(
                  child: Obx(() => _CalendarSection(
                        scheme: scheme,
                        mode: CalendarViewMode.month,
                        focusedDay: controller.focusedDay.value,
                        selectedDay: controller.selectedDay.value,
                        eventsMap: controller.eventsMap,
                        onDaySelected: controller.onCalendarDaySelected,
                        onPageChanged: controller.onCalendarPageChanged,
                        ctrl: controller,
                      )),
                ),
                SingleChildScrollView(
                  child: _ListContentView(scheme: scheme, ctrl: controller, eventsMap: controller.eventsMap),
                ),
              ],
            ),
          ),
        ],
      ).paddingSymmetric(vertical: 16),
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
    required this.onDaySelected,
    required this.onPageChanged,
    required this.ctrl,
  });

  final ColorScheme scheme;
  final CalendarViewMode mode;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<CalendarEvent>>? eventsMap;
  final dynamic onDaySelected;
  final dynamic onPageChanged;
  final CleanerDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
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
        CommonText.semiBold('Upcoming', size: 16, color: scheme.onSurface).marginSymmetric(horizontal: 24),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CalendarEmptyCard(scheme: scheme, onMyJobsPressed: () => ctrl.setTab(2)),
        ),
      ],
    );
  }
}

class _ListContentView extends StatelessWidget {
  const _ListContentView({required this.scheme, required this.ctrl, this.eventsMap});

  final ColorScheme scheme;
  final CleanerDashboardController ctrl;
  final Map<DateTime, List<CalendarEvent>>? eventsMap;

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
        CommonText.semiBold('Upcoming', size: 16, color: scheme.onSurface),
        const SizedBox(height: 8),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CalendarEmptyCard(scheme: scheme, onMyJobsPressed: () => ctrl.setTab(2)),
          )
        else
          AppGrid(
            maxExtent: 140,
            axisSpacing: 8,
            phoneCount: 1,
            tabletCount: 2,
            landscapeCount: 3,
            child: List.generate(
              list.length,
              (i) => JobCard(
                title: list[i].$2.title,
                dateTime: '${CcsDateUtils.shortDateNoYear(list[i].$1)} · ${list[i].$2.timeRange}',
                status: list[i].$2.status,
                onTap: () => Notifier.info('Job details (coming soon)'),
              ),
            ),
          ),
      ],
    ).marginSymmetric(horizontal: 14);
  }
}
