import 'package:ccs_app/app/modules/client/preferred_staff/preferred_staff_controller.dart';
import 'package:ccs_app/app/network/response/get_staff_detail_response.dart';
import 'package:ccs_app/app/widget/job/job_detail_shared.dart';
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

  static String? _locationAddressText(Staff staff) {
    final parts = <String>[];
    if (staff.address?.trim().isNotEmpty ?? false) parts.add(staff.address!.trim());
    final cityPost = <String>[];
    if (staff.city?.trim().isNotEmpty ?? false) cityPost.add(staff.city!.trim());
    if (staff.postalCode?.trim().isNotEmpty ?? false) cityPost.add(staff.postalCode!.trim());
    if (cityPost.isNotEmpty) parts.add(cityPost.join(', '));
    if (staff.country != null && staff.country.toString().trim().isNotEmpty) {
      parts.add(staff.country.toString().trim());
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(() {
      final staff = controller.staffDetail.value;
      final name = _fullName(staff);

      return AppScaffold(
        appBar: Header(
          title: name.isNotEmpty ? name : 'Staff details',
          hasBackIcon: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Profile',
                  container: true,
                  child: _ProfileCard(staff: staff, scheme: scheme),
                ),
                const SizedBox(height: 20),

                JobDetailSection(
                  semanticLabel: 'Contact',
                  emoji: '📞',
                  title: 'Contact',
                  scheme: scheme,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledPair(
                          label: 'Email',
                          value: staff?.email ?? '—',
                          scheme: scheme,
                        ),
                        Divider(height: 24, color: scheme.outline.withValues(alpha: 0.12)),
                        _LabeledPair(
                          label: 'Phone',
                          value: staff?.phoneNumber ?? '—',
                          scheme: scheme,
                        ),
                      ],
                    ).paddingAll(UiConstants.defaultPadding),
                  ),
                ),

                if (_hasRates(staff)) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'Rates',
                    emoji: '💷',
                    title: 'Hourly rates',
                    scheme: scheme,
                    child: AppCard(
                      child: _RatesBlock(staff: staff!, scheme: scheme)
                          .paddingAll(UiConstants.defaultPadding),
                    ),
                  ),
                ],

                if (_hasLocation(staff)) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'Location',
                    emoji: '📍',
                    title: 'Location',
                    scheme: scheme,
                    child: AppCard(
                      child: JobPropertyBlock(
                        propertyName: null,
                        addressText: _locationAddressText(staff!),
                        scheme: scheme,
                      ).paddingAll(UiConstants.defaultPadding),
                    ),
                  ),
                ],

                if (_hasCleaningServices(staff)) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'Cleaning services',
                    emoji: '🧹',
                    title: 'Cleaning services',
                    scheme: scheme,
                    child: AppCard(
                      child: _CleaningServicesChips(staff: staff!, scheme: scheme)
                          .paddingAll(UiConstants.defaultPadding),
                    ),
                  ),
                ],

                if (staff?.availableSlots != null && staff!.availableSlots!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'Work shifts',
                    emoji: '📅',
                    title: 'Work shifts',
                    scheme: scheme,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildWorkShifts(staff.availableSlots ?? [], scheme),
                      ).paddingSymmetric(horizontal: UiConstants.defaultPadding, vertical: 12),
                    ),
                  ),
                ],

                if (_hasAvailability(staff)) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'Availability',
                    emoji: '🕐',
                    title: 'Availability',
                    scheme: scheme,
                    child: AppCard(
                      child: _AvailabilityBlock(staff: staff!, scheme: scheme)
                          .paddingAll(UiConstants.defaultPadding),
                    ),
                  ),
                ],

                if (_hasAbout(staff)) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'About',
                    emoji: '👤',
                    title: 'About',
                    scheme: scheme,
                    child: AppCard(
                      child: _AboutBlock(staff: staff!, scheme: scheme).paddingAll(UiConstants.defaultPadding),
                    ),
                  ),
                ],

                if (_hasNextOfKin(staff)) ...[
                  const SizedBox(height: 20),
                  JobDetailSection(
                    semanticLabel: 'Emergency contact',
                    emoji: '📋',
                    title: 'Emergency contact',
                    scheme: scheme,
                    child: AppCard(
                      child: _NextOfKinBlock(staff: staff!, scheme: scheme)
                          .paddingAll(UiConstants.defaultPadding),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: staff != null
            ? SingleActionBottomBar(
                label: '${staff.preferred == true ? 'Unmark' : 'Mark'} preferred',
                onPressed: () {
                  if (staff.preferred == true) {
                    controller.unmarkStaffPreferred(staff.id?.toInt());
                  } else {
                    controller.markStaffPreferred(staff.id?.toInt());
                  }
                },
              )
            : null,
      );
    });
  }

  bool _hasLocation(Staff? staff) {
    if (staff == null) return false;
    return _locationAddressText(staff) != null;
  }

  bool _hasRates(Staff? staff) {
    if (staff == null) return false;
    return staff.hourlyRate != null ||
        staff.residentialHourlyRate != null ||
        staff.commercialHourlyRate != null;
  }

  static String formatRate(num? rate) {
    if (rate == null) return '—';
    final value = rate is int ? rate.toDouble() : rate.toDouble();
    return '£${value.toStringAsFixed(2)}/hr';
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
          dayShifts.map((s) => '${CcsDateTimeX.convertTime(s.startTime ?? '')}–${CcsDateTimeX.convertTime(s.endTime ?? "")}').toSet().join(', ');
      if (i > 0) {
        list.add(Divider(height: 20, color: scheme.outline.withValues(alpha: 0.1)));
      }
      list.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
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
      );
    }
    return list;
  }
}

class _LabeledPair extends StatelessWidget {
  const _LabeledPair({
    required this.label,
    required this.value,
    required this.scheme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText.regular(label, size: 12, color: scheme.onSurfaceVariant),
        const SizedBox(height: 4),
        CommonText.regular(value, size: 15, color: scheme.onSurface),
      ],
    );
  }
}

class _RatesBlock extends StatelessWidget {
  const _RatesBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addPair(String label, num? rate) {
      if (rate == null) return;
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 20, color: scheme.outline.withValues(alpha: 0.12)));
      }
      rows.add(
        _LabeledPair(
          label: label,
          value: StaffDetailsView.formatRate(rate),
          scheme: scheme,
        ),
      );
    }

    addPair('Hourly rate', staff.hourlyRate);
    addPair('Residential', staff.residentialHourlyRate);
    addPair('Commercial', staff.commercialHourlyRate);

    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _CleaningServicesChips extends StatelessWidget {
  const _CleaningServicesChips({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final names = staff.cleaningServicesData
            ?.map((e) => e.name?.trim())
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final count = names.isNotEmpty ? names.length : (staff.cleaningServices?.length ?? 0);

    if (names.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: names
            .map(
              (name) => InfoChip(
                label: name,
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
              ),
            )
            .toList(),
      );
    }
    return CommonText.regular(
      '$count service${count == 1 ? '' : 's'} on file',
      size: 14,
      color: scheme.onSurfaceVariant,
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
    final badges = <Widget>[];

    if (staff?.preferred == true) {
      badges.add(
        InfoChip(
          label: 'Preferred',
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.primary,
          leftPadding: 10,
        ),
      );
    }
    if (staff?.isVerified == true) {
      if (badges.isNotEmpty) badges.add(const SizedBox(width: 8));
      badges.add(
        InfoChip(
          label: 'Verified',
          backgroundColor: scheme.tertiaryContainer,
          foregroundColor: scheme.onTertiaryContainer,
          leftPadding: 10,
        ),
      );
    }
    if (staff?.isActive == true) {
      if (badges.isNotEmpty) badges.add(const SizedBox(width: 8));
      badges.add(
        InfoChip(
          label: 'Active',
          backgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: scheme.onSurfaceVariant,
          leftPadding: 10,
        ),
      );
    }
    if (staff?.hourlyRate != null) {
      if (badges.isNotEmpty) badges.add(const SizedBox(width: 8));
      badges.add(
        InfoChip(
          label: StaffDetailsView.formatRate(staff!.hourlyRate),
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          leftPadding: 10,
        ),
      );
    }

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      borderWidth: 1,
      borderColor: scheme.outlineVariant.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(16),
      enableShadows: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _LargeAvatar(
            imageUrl: staff?.imageUrl,
            name: staff?.firstName,
            scheme: scheme,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(
                  fullName.isNotEmpty ? fullName : 'Staff',
                  size: 20,
                  color: scheme.onSurface,
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 0, runSpacing: 8, children: badges),
                ],
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
    const double size = 80;
    final letter = name != null && name!.isNotEmpty ? name!.trim()[0].toUpperCase() : '?';
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
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

class _AvailabilityBlock extends StatelessWidget {
  const _AvailabilityBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addPair(String label, String value) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 20, color: scheme.outline.withValues(alpha: 0.12)));
      }
      rows.add(_LabeledPair(label: label, value: value, scheme: scheme));
    }

    if (staff.preferredStartDate?.trim().isNotEmpty ?? false) {
      final dateStr = staff.preferredStartDate!.trim();
      var displayDate = dateStr;
      try {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) displayDate = CcsDateUtils.shortDate(parsed);
      } catch (_) {}
      addPair('Preferred start', displayDate);
    }
    if (staff.localAreas?.trim().isNotEmpty ?? false) {
      addPair('Local areas', staff.localAreas!.trim());
    }
    if (staff.hourBlocks != null && staff.hourBlocks!.isNotEmpty) {
      final blocks = staff.hourBlocks!.map((e) => e is String ? e : e.toString()).where((s) => s.trim().isNotEmpty).toList();
      if (blocks.isNotEmpty) {
        addPair('Hour blocks', blocks.join(', '));
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addPair(String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 20, color: scheme.outline.withValues(alpha: 0.12)));
      }
      rows.add(_LabeledPair(label: label, value: value.trim(), scheme: scheme));
    }

    if (staff.dob?.trim().isNotEmpty ?? false) {
      var displayDob = staff.dob!.trim();
      try {
        final parsed = DateTime.tryParse(displayDob);
        if (parsed != null) displayDob = CcsDateUtils.shortDate(parsed);
      } catch (_) {}
      addPair('Date of birth', displayDob);
    }
    addPair('Gender', staff.gender);
    addPair('Hobbies', staff.hobbies);
    if (staff.interests != null && staff.interests.toString().trim().isNotEmpty) {
      addPair('Interests', staff.interests.toString().trim());
    }
    addPair('Drives', staff.drives);
    addPair('Has children', staff.hasChildren);

    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _NextOfKinBlock extends StatelessWidget {
  const _NextOfKinBlock({required this.staff, required this.scheme});

  final Staff staff;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addPair(String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 20, color: scheme.outline.withValues(alpha: 0.12)));
      }
      rows.add(_LabeledPair(label: label, value: value.trim(), scheme: scheme));
    }

    addPair('Name', staff.nextOfKinName);
    addPair('Relationship', staff.nextOfKinRelationship);
    addPair('Contact', staff.nextOfKinContact);
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}
