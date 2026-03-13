import 'package:ccs_app/app/modules/client/preferred_staff/preferred_staff_controller.dart';
import 'package:ccs_app/app/network/response/get_preferred_staff_response.dart';
import 'package:ccs_app/app/network/response/get_staff_detail_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

class StaffDetailsView extends GetView<PreferredStaffController> {
  const StaffDetailsView({super.key});

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String _dayLabel(String? day) {
    if (day == null || day.isEmpty) return '—';
    final i = int.tryParse(day);
    if (i == null || i < 1 || i > 7) return 'Day $day';
    return _dayNames[i - 1];
  }

  // static bool _isRedacted(String? value) {
  //   return value == null || value.isEmpty || value.contains('REDACTED') || value.contains('***');
  // }

  @override
  Widget build(BuildContext context) {
    // final staff = Get.arguments as PreferredStaff?;
    final scheme = context.colorScheme;

/*    if (staff == null) {
      return AppScaffold(
        appBar: Header(title: 'Staff details', hasBackIcon: true),
        body: Center(
          child: CommonText.regular(
            'No staff selected',
            size: 16,
            color: scheme.onSurface,
          ),
        ),
      );
    }*/

    return Obx(() {
      return AppScaffold(
        appBar: Header(
          title: controller.staffDetail.value?.firstName ?? 'Staff details',
          hasBackIcon: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile hero card
                _ProfileCard(staff: controller.staffDetail.value, scheme: scheme),
                const SizedBox(height: 24),

                // Contact
                _SectionHeader(icon: IconsaxPlusLinear.call, title: 'Contact', scheme: scheme),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: IconsaxPlusLinear.sms,
                        label: 'Email',
                        value: controller.staffDetail.value?.email ?? '',
                        scheme: scheme,
                      ),
                      Divider(height: 24, color: scheme.outlineVariant),
                      _DetailRow(
                        icon: IconsaxPlusLinear.call,
                        label: 'Phone',
                        value: controller.staffDetail.value?.phoneNumber ?? '',
                        scheme: scheme,
                      ),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
                const SizedBox(height: 24),

                // Location
                if ((controller.staffDetail.value?.address?.isNotEmpty ?? false) ||
                    (controller.staffDetail.value?.city?.isNotEmpty ?? false) ||
                    (controller.staffDetail.value?.country != null && controller.staffDetail.value!
                        .country
                        .toString()
                        .isNotEmpty)) ...[
                  _SectionHeader(icon: IconsaxPlusLinear.location, title: 'Location', scheme: scheme),
                  const SizedBox(height: 8),
                  AppCard(
                    child: _LocationBlock(staff: controller.staffDetail.value!, scheme: scheme).paddingAll(UiConstants.defaultPadding),
                  ),
                  const SizedBox(height: 24),
                ],

                // Cleaning services
                if (controller.staffDetail.value?.cleaningServices != null && controller.staffDetail.value!.cleaningServices!.isNotEmpty) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.home_2,
                    title: 'Cleaning services',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
                          ),
                          child: Icon(
                            IconsaxPlusLinear.home_2,
                            size: 22,
                            color: scheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CommonText.regular(
                            '${controller.staffDetail.value?.cleaningServices!.length} service${controller.staffDetail.value?.cleaningServices!.length == 1
                                ? ''
                                : 's'} selected',
                            size: 15,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ).paddingAll(UiConstants.defaultPadding),
                  ),
                  const SizedBox(height: 24),
                ],

                // Work shifts
                if (controller.staffDetail.value?.availableSlots != null && controller.staffDetail.value!.availableSlots!.isNotEmpty) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.calendar_1,
                    title: 'Work shifts',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: _buildWorkShifts(controller.staffDetail.value!.availableSlots ?? [], scheme),
                    ).paddingAll(4),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildWorkShifts(List<AvailableSlots> shifts, ColorScheme scheme) {
    final byDay = <String, List<AvailableSlots>>{};
    for (final s in shifts) {
      final d = s.day ?? '';
      byDay.putIfAbsent(d, () => []).add(s);
    }
    final orderedDays = byDay.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    final list = <Widget>[];
    for (var i = 0; i < orderedDays.length; i++) {
      final dayKey = orderedDays[i];
      final dayShifts = byDay[dayKey]!;
      final timeRanges = dayShifts.map((s) => '${s.startTime ?? "—"} – ${s.endTime ?? "—"}').toSet().join(', ');
      final isAlternate = i.isOdd;
      list.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isAlternate ? scheme.surfaceContainerHighest.withValues(alpha: 0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.clock,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CommonText.medium(
                        _dayLabel(dayKey),
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CommonText.regular(
                  timeRanges,
                  size: 14,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.scheme,
  });

  final IconData icon;
  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        CommonText.semiBold(title, size: 16, color: scheme.onSurface),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.regular(label, size: 12, color: scheme.onSurfaceVariant),
              const SizedBox(height: 2),
              CommonText.regular(value, size: 15, color: scheme.onSurface),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.staff, required this.scheme});

  final Staff? staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.6),
            scheme.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _LargeAvatar(imageUrl: staff?.imageUrl, name: staff?.firstName, scheme: scheme),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(
                  staff?.firstName ?? '',
                  size: 20,
                  color: scheme.onSurface,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconsaxPlusLinear.star_1, size: 14, color: scheme.primary),
                      const SizedBox(width: 6),
                      CommonText.medium('Preferred', size: 13, color: scheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  const _LargeAvatar({
    required this.imageUrl,
    required this.name,
    required this.scheme,
  });

  final String? imageUrl;
  final String? name;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    const double size = 72;
    final letter = name != null && name!.isNotEmpty ? name!.trim()[0].toUpperCase() : '?';
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialChild(letter),
      )
          : _initialChild(letter),
    );
  }

  Widget _initialChild(String letter) {
    return Center(
      child: CommonText.semiBold(letter, size: 28, color: scheme.primary),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (staff.address?.isNotEmpty ?? false) parts.add(staff.address!);
    if (staff.city?.isNotEmpty ?? false) parts.add(staff.city!);
    if (staff.country != null && staff.country
        .toString()
        .isNotEmpty) {
      parts.add(staff.country.toString());
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(IconsaxPlusLinear.location, size: 20, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: CommonText.regular(
            parts.join(', '),
            size: 15,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
