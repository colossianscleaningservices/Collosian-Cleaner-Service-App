import 'package:ccs_app/app/modules/client/preferred_staff/preferred_staff_controller.dart';
import 'package:ccs_app/app/network/response/get_staff_detail_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
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

  static String _dayLabel(String? day, String? dayName) {
    if (dayName != null && dayName.trim().isNotEmpty) return dayName.trim();
    if (day == null || day.isEmpty) return '—';
    final i = int.tryParse(day);
    if (i == null || i < 1 || i > 7) return 'Day $day';
    return _dayNames[i - 1];
  }

  static String _fullName(Staff? staff) {
    if (staff == null) return '';
    final first = staff.firstName?.trim() ?? '';
    final last = staff.lastName?.trim() ?? '';
    if (first.isEmpty && last.isEmpty) return 'Staff';
    return [first, last].where((s) => s.isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(() {
      final staff = controller.staffDetail.value;
      return AppScaffold(
        appBar: Header(
          title: _fullName(staff).isNotEmpty ? _fullName(staff) : 'Staff details',
          hasBackIcon: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile hero card
                _ProfileCard(staff: staff, scheme: scheme),
                const SizedBox(height: 28),

                // Contact
                _SectionHeader(icon: IconsaxPlusLinear.call, title: 'Contact', scheme: scheme),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: IconsaxPlusLinear.sms,
                        label: 'Email',
                        value: staff?.email ?? '—',
                        scheme: scheme,
                      ),
                      Divider(height: 28, color: scheme.outlineVariant.withValues(alpha: 0.6)),
                      _DetailRow(
                        icon: IconsaxPlusLinear.call,
                        label: 'Phone',
                        value: staff?.phoneNumber ?? '—',
                        scheme: scheme,
                      ),
                    ],
                  ).paddingAll(20),
                ),
                const SizedBox(height: 28),

                // Location
                if (_hasLocation(staff)) ...[
                  _SectionHeader(icon: IconsaxPlusLinear.location, title: 'Location', scheme: scheme),
                  const SizedBox(height: 12),
                  AppCard(
                    child: _LocationBlock(staff: staff!, scheme: scheme).paddingAll(20),
                  ),
                  const SizedBox(height: 28),
                ],

                // Cleaning services
                if (_hasCleaningServices(staff)) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.home_2,
                    title: 'Cleaning services',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: _CleaningServicesBlock(staff: staff!, scheme: scheme).paddingAll(20),
                  ),
                  const SizedBox(height: 28),
                ],

                // Work shifts
                if (staff?.availableSlots != null && staff!.availableSlots!.isNotEmpty) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.calendar_1,
                    title: 'Work shifts',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: _buildWorkShifts(staff.availableSlots ?? [], scheme),
                    ).paddingAll(12),
                  ),
                  const SizedBox(height: 28),
                ],

                // Availability (preferred start, local areas, hour blocks)
                if (_hasAvailability(staff)) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.calendar_tick,
                    title: 'Availability',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: _AvailabilityBlock(staff: staff!, scheme: scheme).paddingAll(20),
                  ),
                  const SizedBox(height: 28),
                ],

                // About (dob, gender, hobbies, interests, drives, hasChildren)
                if (_hasAbout(staff)) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.user,
                    title: 'About',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: _AboutBlock(staff: staff!, scheme: scheme).paddingAll(20),
                  ),
                  const SizedBox(height: 28),
                ],

                // Emergency contact (next of kin)
                if (_hasNextOfKin(staff)) ...[
                  _SectionHeader(
                    icon: IconsaxPlusLinear.people,
                    title: 'Emergency contact',
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: _NextOfKinBlock(staff: staff!, scheme: scheme).paddingAll(20),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: SingleActionBottomBar(
            label: '${staff?.preferred == true ? "Unmark" : "Mark"} Preferred',
            onPressed: () {
              if (staff?.preferred == true) {
                controller.unmarkStaffPreferred(staff?.id?.toInt());
              } else {
                controller.markStaffPreferred(staff?.id?.toInt());
              }
            }),
      );
    });
  }

  bool _hasLocation(Staff? staff) {
    if (staff == null) return false;
    return (staff.address?.isNotEmpty ?? false) ||
        (staff.city?.isNotEmpty ?? false) ||
        (staff.postalCode?.isNotEmpty ?? false) ||
        (staff.country != null && staff.country.toString().trim().isNotEmpty);
  }

  bool _hasCleaningServices(Staff? staff) {
    if (staff == null) return false;
    final hasData = staff.cleaningServicesData != null && staff.cleaningServicesData!.isNotEmpty;
    final hasIds = staff.cleaningServices != null && staff.cleaningServices!.isNotEmpty;
    return hasData || hasIds;
  }

  bool _hasAvailability(Staff? staff) {
    if (staff == null) return false;
    return (staff.preferredStartDate?.trim().isNotEmpty ?? false) ||
        (staff.localAreas?.trim().isNotEmpty ?? false) ||
        (staff.hourBlocks != null && staff.hourBlocks!.isNotEmpty);
  }

  bool _hasAbout(Staff? staff) {
    if (staff == null) return false;
    return (staff.dob?.trim().isNotEmpty ?? false) ||
        (staff.gender?.trim().isNotEmpty ?? false) ||
        (staff.hobbies?.trim().isNotEmpty ?? false) ||
        (staff.interests != null && staff.interests.toString().trim().isNotEmpty) ||
        (staff.drives?.trim().isNotEmpty ?? false) ||
        (staff.hasChildren?.trim().isNotEmpty ?? false);
  }

  bool _hasNextOfKin(Staff? staff) {
    if (staff == null) return false;
    return (staff.nextOfKinName?.trim().isNotEmpty ?? false) ||
        (staff.nextOfKinRelationship?.trim().isNotEmpty ?? false) ||
        (staff.nextOfKinContact?.trim().isNotEmpty ?? false);
  }

  List<Widget> _buildWorkShifts(List<AvailableSlots> shifts, ColorScheme scheme) {
    final byDay = <String, List<AvailableSlots>>{};
    for (final s in shifts) {
      final d = s.day ?? '';
      byDay.putIfAbsent(d, () => []).add(s);
    }
    final orderedDays = byDay.keys.toList()..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    final list = <Widget>[];
    for (var i = 0; i < orderedDays.length; i++) {
      final dayKey = orderedDays[i];
      final dayShifts = byDay[dayKey]!;
      final timeRanges =
          dayShifts.map((s) => '${CcsDateTimeX.convertTime(s.startTime ?? "")} – ${CcsDateTimeX.convertTime(s.endTime ?? "")}').toSet().join(', ');
      final isAlternate = i.isOdd;
      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: isAlternate ? scheme.surfaceContainerHighest.withValues(alpha: 0.5) : scheme.surfaceContainerLow.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: scheme.primary.withValues(alpha: 0.6), width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(IconsaxPlusLinear.clock, size: 18, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: CommonText.semiBold(
                  _dayLabel(dayKey, dayShifts.first.dayName),
                  size: 14,
                  color: scheme.onSurface,
                ),
              ),
              Expanded(
                child: CommonText.regular(
                  timeRanges,
                  size: 14,
                  color: scheme.onSurfaceVariant,
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        CommonText.semiBold(title, size: 17, color: scheme.onSurface),
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
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.medium(label, size: 12, color: scheme.onSurfaceVariant),
              const SizedBox(height: 4),
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
    final fullName = StaffDetailsView._fullName(staff);
    final badges = <Widget>[
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
    ];
    if (staff?.isVerified == true) {
      badges.add(const SizedBox(width: 8));
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.tertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.shield_tick, size: 14, color: scheme.tertiary),
              const SizedBox(width: 4),
              CommonText.medium('Verified', size: 12, color: scheme.tertiary),
            ],
          ),
        ),
      );
    }
    if (staff?.isActive == true) {
      badges.add(const SizedBox(width: 8));
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
          ),
          child: CommonText.medium('Active', size: 12, color: scheme.primary),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.7),
            scheme.surfaceContainerHigh.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _LargeAvatar(
            imageUrl: staff?.imageUrl,
            name: staff?.firstName,
            scheme: scheme,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(
                  fullName.isNotEmpty ? fullName : 'Staff',
                  size: 22,
                  color: scheme.onSurface,
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: badges,
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
    const double size = 88;
    final letter = name != null && name!.isNotEmpty ? name!.trim()[0].toUpperCase() : '?';
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
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
      child: CommonText.semiBold(letter, size: 32, color: scheme.primary),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    if (staff.address?.trim().isNotEmpty ?? false) lines.add(staff.address!.trim());
    final cityLine = <String>[];
    if (staff.city?.trim().isNotEmpty ?? false) cityLine.add(staff.city!.trim());
    if (staff.postalCode?.trim().isNotEmpty ?? false) cityLine.add(staff.postalCode!.trim());
    if (cityLine.isNotEmpty) lines.add(cityLine.join(', '));
    if (staff.country != null && staff.country.toString().trim().isNotEmpty) {
      lines.add(staff.country.toString().trim());
    }
    if (lines.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(IconsaxPlusLinear.location, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: CommonText.regular(
            lines.join('\n'),
            size: 15,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CleaningServicesBlock extends StatelessWidget {
  const _CleaningServicesBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final names = staff.cleaningServicesData?.map((e) => e.name?.trim()).whereType<String>().where((s) => s.isNotEmpty).toList() ?? [];
    final count = names.isNotEmpty ? names.length : (staff.cleaningServices?.length ?? 0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            IconsaxPlusLinear.home_2,
            size: 24,
            color: scheme.tertiary,
          ),
        ),
        Expanded(
          child: names.isNotEmpty
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: names
                      .map(
                        (name) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CommonText.medium(name, size: 14, color: scheme.onSurface),
                        ),
                      )
                      .toList(),
                )
              : CommonText.regular(
                  '$count service${count == 1 ? '' : 's'} selected',
                  size: 16,
                  color: scheme.onSurface,
                ),
        ),
      ],
    );
  }
}

class _AvailabilityBlock extends StatelessWidget {
  const _AvailabilityBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (staff.preferredStartDate?.trim().isNotEmpty ?? false) {
      final dateStr = staff.preferredStartDate!.trim();
      String displayDate = dateStr;
      try {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) displayDate = CcsDateUtils.shortDate(parsed);
      } catch (_) {}
      rows.add(_DetailRow(
        icon: IconsaxPlusLinear.calendar_tick,
        label: 'Preferred start date',
        value: displayDate,
        scheme: scheme,
      ));
    }
    if (staff.localAreas?.trim().isNotEmpty ?? false) {
      if (rows.isNotEmpty) rows.add(Divider(height: 24, color: scheme.outlineVariant));
      rows.add(_DetailRow(
        icon: IconsaxPlusLinear.location,
        label: 'Local areas',
        value: staff.localAreas!.trim(),
        scheme: scheme,
      ));
    }
    if (staff.hourBlocks != null && staff.hourBlocks!.isNotEmpty) {
      if (rows.isNotEmpty) rows.add(Divider(height: 24, color: scheme.outlineVariant));
      final blocks = staff.hourBlocks!.map((e) => e is String ? e : e.toString()).where((s) => s.trim().isNotEmpty).toList();
      if (blocks.isNotEmpty) {
        rows.add(_DetailRow(
          icon: IconsaxPlusLinear.clock,
          label: 'Hour blocks',
          value: blocks.join(', '),
          scheme: scheme,
        ));
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addRow(IconData icon, String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      if (rows.isNotEmpty) rows.add(Divider(height: 24, color: scheme.outlineVariant));
      rows.add(_DetailRow(icon: icon, label: label, value: value.trim(), scheme: scheme));
    }

    if (staff.dob?.trim().isNotEmpty ?? false) {
      String displayDob = staff.dob!.trim();
      try {
        final parsed = DateTime.tryParse(displayDob);
        if (parsed != null) displayDob = CcsDateUtils.shortDate(parsed);
      } catch (_) {}
      addRow(IconsaxPlusLinear.calendar, 'Date of birth', displayDob);
    }
    addRow(IconsaxPlusLinear.user, 'Gender', staff.gender);
    addRow(IconsaxPlusLinear.heart, 'Hobbies', staff.hobbies);
    if (staff.interests != null && staff.interests.toString().trim().isNotEmpty) {
      addRow(IconsaxPlusLinear.like_1, 'Interests', staff.interests.toString().trim());
    }
    addRow(IconsaxPlusLinear.car, 'Drives', staff.drives);
    addRow(IconsaxPlusLinear.people, 'Has children', staff.hasChildren);

    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _NextOfKinBlock extends StatelessWidget {
  const _NextOfKinBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addRow(IconData icon, String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      if (rows.isNotEmpty) rows.add(Divider(height: 24, color: scheme.outlineVariant));
      rows.add(_DetailRow(icon: icon, label: label, value: value.trim(), scheme: scheme));
    }

    addRow(IconsaxPlusLinear.user, 'Name', staff.nextOfKinName);
    addRow(IconsaxPlusLinear.people, 'Relationship', staff.nextOfKinRelationship);
    addRow(IconsaxPlusLinear.call, 'Contact', staff.nextOfKinContact);
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
