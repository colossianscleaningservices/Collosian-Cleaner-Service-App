import 'package:ccs_app/app/modules/client/dashboard/client_dashboard_controller.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:ccs_app/export.dart';
import 'package:ccs_app/app/model/calendar_event.dart';

class ClientCalendarView extends GetView<ClientDashboardController> {
  const ClientCalendarView({super.key});

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
          ).marginOnly(bottom: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(IconsaxPlusLinear.arrow_left_1, color: scheme.secondary,),
                onPressed: controller.onCalendarPrev,
              ),
              Obx(() => CommonText.bold(controller.periodLabel, size: 16, color: scheme.onSurface)),
              IconButton(
                icon: Icon(IconsaxPlusLinear.arrow_right_2, color: scheme.secondary,),
                onPressed: controller.onCalendarNext,
              ),
            ],
          ),
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
      ).paddingSymmetric(horizontal: 24, vertical: 16),
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
  final ClientDashboardController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                selectedDecoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle, border: Border.all(color: scheme.secondary, width: 2)),
                selectedTextStyle: context.textTheme.bodyLarge!.copyWith(color: scheme.secondary)
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              weekendStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ).marginSymmetric(vertical: 16),
        ).marginOnly(top: 16, left: 4, right: 4),
        SizedBox(height: UiConstants.gap),
        CommonText.semiBold('Upcoming', size: 16, color: scheme.onSurface),
        const SizedBox(height: 8),
        _EmptyStateCard(scheme: scheme, ctrl: ctrl),
      ],
    );
  }
}

class _ListContentView extends StatelessWidget {
  const _ListContentView({required this.scheme, required this.ctrl, this.eventsMap});

  final ColorScheme scheme;
  final ClientDashboardController ctrl;
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText.semiBold('Upcoming', size: 16, color: scheme.onSurface),
        const SizedBox(height: 8),
        if (list.isEmpty)
          _EmptyStateCard(scheme: scheme, ctrl: ctrl)
        else
          for (var i = 0; i < list.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ListJobCard(
                date: DateFormat('EEE d MMM').format(list[i].$1),
                time: list[i].$2.timeRange,
                property: list[i].$2.title,
                status: list[i].$2.status,
                scheme: scheme,
              ),
            ),
      ],
    );
  }
}

class _ListJobCard extends StatelessWidget {
  const _ListJobCard({required this.date, required this.time, required this.property, required this.status, required this.scheme});

  final String date;
  final String time;
  final String property;
  final String status;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'Approved';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Notifier.info('Job details (coming soon)'),
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Card(
          color: context.colorScheme.onPrimary,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(color: isApproved ? scheme.primary : scheme.outline, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold(property, size: 14),
                      const SizedBox(height: 2),
                      CommonText.regular('$date · $time', size: 12, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isApproved ? scheme.primaryContainer : scheme.surfaceContainerHighest).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: CommonText.medium(status, size: 11, color: isApproved ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
                Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.scheme, this.ctrl});

  final ColorScheme scheme;
  final ClientDashboardController? ctrl;

  @override
  Widget build(BuildContext context) {
    final c = ctrl ?? Get.find<ClientDashboardController>();

    return Card(
      color: context.colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(IconsaxPlusLinear.calendar, color: scheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText.regular('No jobs this month.', size: 13, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 2),
                  CommonText.regular('Your assigned jobs will appear here.', size: 12, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
            AppButton(
              label: 'My Jobs',
              type: ButtonType.outline,
              onPressed: () => c.setTab(2),
              btnVerticalPadding: 8,
              btnHorizontalPadding: 12,
              textSize: 12,
            ),
          ],
        ),
      ),
    );
  }
}
