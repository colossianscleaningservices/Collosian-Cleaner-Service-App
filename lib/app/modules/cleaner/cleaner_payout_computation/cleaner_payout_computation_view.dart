import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'cleaner_payout_computation_controller.dart';

class CleanerPayoutComputationView
    extends GetView<CleanerPayoutComputationController> {
  const CleanerPayoutComputationView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(title: 'Payout computation'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).marginOnly(right: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.bold('Work hour & payout calculation',
                                size: 20, color: scheme.onSurface)
                            .marginOnly(bottom: 4),
                        CommonText.regular(
                          'Select a date range to view work entries and earnings.',
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ).marginOnly(bottom: 20),

              // Summary cards – 2×1 grid
              Obx(() {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Residential Earnings',
                            value: controller.totalResidentialEarning.value ??
                                '0.0',
                            scheme: scheme,
                            accentColor: scheme.tertiary,
                            icon: IconsaxPlusLinear.home_2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Commercial Earnings',
                            value: controller.totalCommercialEarning.value ??
                                '0.0',
                            scheme: scheme,
                            accentColor: scheme.primary,
                            icon: IconsaxPlusLinear.building_4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SummaryCard(
                      label: 'Total Payout',
                      value: controller.totalPayout.value ?? '0.0',
                      scheme: scheme,
                      accentColor: scheme.secondary,
                      icon: IconsaxPlusLinear.wallet_money,
                      isHighlight: true,
                    ),
                  ],
                );
              }).marginOnly(bottom: 24),

              // Date range
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'From',
                        value: controller.scheduleValidFrom.value,
                        onTap: () =>
                            _pickDate(context, controller, isFrom: true),
                        onClear: () => controller.setStartDate(null),
                        validator: (_) =>
                            controller.scheduleValidFrom.value == null
                                ? 'Select start date'
                                : null,
                        scheme: scheme,
                        ctrl: controller,
                      ).marginOnly(right: 8),
                    ),
                    Expanded(
                      child: _DateField(
                        label: 'To',
                        value: controller.scheduleValidTo.value,
                        onTap: () =>
                            _pickDate(context, controller, isFrom: false),
                        onClear: () => controller.setEndDate(null),
                        validator: (_) =>
                            controller.scheduleValidTo.value == null
                                ? 'Select end date'
                                : null,
                        scheme: scheme,
                        ctrl: controller,
                      ).marginOnly(left: 8),
                    ),
                  ],
                ).marginOnly(bottom: 24),
              ),

              // Work entries section title
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: scheme.tertiary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).marginOnly(right: 12),
                  CommonText.semiBold('Work entries detail',
                      size: 18, color: scheme.onSurface),
                ],
              ).marginOnly(bottom: 14),

              // Table or empty state when no date range selected / no entries
              Obx(() {
                if (controller.entries.isEmpty) {
                  return _EmptyWorkEntries(scheme: scheme);
                }
                return _WorkEntriesTable(
                    scheme: scheme, controller: controller);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, CleanerPayoutComputationController ctrl,
      {required bool isFrom}) async {
    final d = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2030, 12, 31));
    if (d == null || !context.mounted) return;
    if (isFrom) {
      ctrl.setScheduleValidFrom(d);
    } else {
      ctrl.setScheduleValidTo(d);
    }

    if (ctrl.scheduleValidFrom.value != null &&
        ctrl.scheduleValidTo.value != null) {
      ctrl.getPayoutComputation();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.scheme,
    required this.accentColor,
    required this.icon,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final Color accentColor;
  final IconData icon;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      borderWidth: 1,
      borderColor: isHighlight
          ? accentColor.withValues(alpha: 0.35)
          : scheme.outline.withValues(alpha: 0.15),
      enableShadows: isHighlight ? false : true,
      color: isHighlight
          ? accentColor.withValues(alpha: 0.08)
          : scheme.surfaceContainerHighest,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(icon, size: 24, color: accentColor),
          ).marginOnly(right: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.medium(label,
                        size: 14, color: scheme.onSurfaceVariant)
                    .marginOnly(bottom: 4),
                CommonText.bold('£$value', size: 18, color: accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWorkEntries extends StatelessWidget {
  const _EmptyWorkEntries({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: scheme.surfaceContainerLow.withValues(alpha: 0.5),
      borderColor: scheme.outline.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      enableShadows: true,
      child: Column(
        children: [
          Icon(IconsaxPlusLinear.document_text,
                  size: 44,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6))
              .marginOnly(bottom: 16),
          CommonText.semiBold('No work entries',
                  size: 16, color: scheme.onSurface)
              .marginOnly(bottom: 6),
          CommonText.regular(
            'Select a date range to load work entries. If none appear, there are no records for this period.',
            size: 14,
            color: scheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WorkEntriesTable extends StatelessWidget {
  const _WorkEntriesTable({required this.scheme, required this.controller});

  final ColorScheme scheme;
  final CleanerPayoutComputationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(scheme.surfaceContainerHigh),
          headingTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Paid For')),
            DataColumn(label: Text('Hours Worked')),
            DataColumn(label: Text('Residential Rate')),
            DataColumn(label: Text('Commercial Rate')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Residential Earnings')),
            DataColumn(label: Text('Commercial Earnings')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Paid Date')),
          ],
          rows: controller.entries.map((entry) {
            return DataRow(
              cells: [
                DataCell(CommonText.regular(entry.clientName?.toString() ?? '',
                    size: 12)),
                DataCell(CommonText.regular(
                    entry.workedHours?.toString() ?? '0',
                    size: 12)),
                DataCell(CommonText.regular("${controller.residentialRate}",
                    size: 12)),
                DataCell(CommonText.regular("${controller.commercialRate}",
                    size: 12)),
                DataCell(CommonText.semiBold(
                    entry.totalPayout?.toString() ?? '0',
                    size: 12,
                    color: scheme.primary)),
                DataCell(CommonText.regular(
                    entry.residentialEarnings?.toString() ?? 'N/A',
                    size: 12)),
                DataCell(CommonText.regular(
                    entry.commercialEarnings?.toString() ?? 'N/A',
                    size: 12)),
                DataCell(_StatusChip(
                    label: entry.status?.toString().capitalizeFirst ?? '',
                    scheme: scheme)),
                DataCell(CommonText.regular(
                    entry.paidOn != null
                        ? formatDate(entry.paidOn ?? "",
                            inputFormat: 'yyyy-MM-dd',
                            outputFormat: 'dd/MM/yyyy')
                        : 'N/A',
                    size: 12)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.tertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: CommonText.medium(label, size: 12, color: scheme.tertiary),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
    required this.validator,
    required this.scheme,
    required this.ctrl,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final FormFieldValidator<String>? validator;
  final ColorScheme scheme;
  final CleanerPayoutComputationController ctrl;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: value != null ? CcsDateUtils.forInput(value!) : null,
      builder: (ff) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.semiBold(label, size: 14, color: scheme.onSurface)
                .marginOnly(bottom: 6),
            Material(
              color: context.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                child: InputDecorator(
                  decoration: buildCommonDecoration(
                    context: context,
                    hint: '-- / -- / ----',
                    contentPadding: EdgeInsets.only(left: 8),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (value != null && onClear != null)
                          IconButton(
                            icon: Icon(IconsaxPlusLinear.close_circle,
                                size: 18, color: scheme.onSurfaceVariant),
                            onPressed: onClear,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        Icon(IconsaxPlusLinear.calendar_1,
                            size: 18, color: scheme.primary),
                      ],
                    ).marginOnly(right: 8),
                  ),
                  isEmpty: value == null,
                  child: CommonText.regular(
                      value != null ? CcsDateUtils.forInput(value!) : '',
                      color: scheme.onSurface),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
