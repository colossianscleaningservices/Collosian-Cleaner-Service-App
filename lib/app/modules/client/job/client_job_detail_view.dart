import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

import 'client_job_detail_controller.dart';

/// Client job detail: status, schedule, property, preferences, cleaners.
class ClientJobDetailView extends GetView<ClientJobDetailController> {
  const ClientJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final j = c.job;
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(
        title: j.jobType,
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
        actions: [
          IconButton(
            icon: Icon(IconsaxPlusLinear.edit_2, size: 22, color: scheme.primary),
            tooltip: 'Edit job',
            onPressed: c.onEdit,
          ),
          IconButton(
            icon: Icon(IconsaxPlusLinear.trash, size: 22, color: scheme.error),
            tooltip: 'Delete job',
            onPressed: () => c.confirmDeleteJob(context),
          ),
        ],
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UiConstants.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status & schedule
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold('Status & schedule', size: 16, color: scheme.onSurface),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(j.status, scheme.primaryContainer, scheme.primary),
                        if (j.recurrence != null) _chip(j.recurrence!, scheme.secondaryContainer, scheme.secondary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _row('Date', DateFormat('EEE d MMM yyyy').format(j.date), scheme),
                    _row('Time', '${j.startTime} – ${j.endTime}', scheme),
                    if (j.jobEndDate != null) _row('End date', DateFormat('EEE d MMM yyyy').format(j.jobEndDate!), scheme),
                    if (j.status == 'Scheduled') ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: c.onCancelJob,
                        child: CommonText.regular('Cancel job', size: 14, color: scheme.error),
                      ),
                    ],
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: 16),

              // Property & client
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold('Property & client', size: 16, color: scheme.onSurface),
                    const SizedBox(height: 12),
                    _row('Client', j.clientName, scheme),
                    _row('Property', j.propertyOneLine, scheme),
                    if (j.propertyLabel != null) _row('Label', j.propertyLabel!, scheme),
                    if (j.accessToProperty != null) _row('Access', j.accessToProperty!, scheme),
                    if (j.address != null || j.city != null || j.postalCode != null)
                      _row(
                        'Address',
                        [j.address, j.city, j.postalCode].whereType<String>().join(', '),
                        scheme,
                      ),
                    if (j.propertyType != null) _row('Property type', j.propertyType!, scheme),
                    if (j.propertySubtype != null) _row('Subtype', j.propertySubtype!, scheme),
                    if (j.animals != null) _row('Animals', j.animals!, scheme),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: 16),

              // Preferences & equipment
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold('Preferences & equipment', size: 16, color: scheme.onSurface),
                    const SizedBox(height: 12),
                    if (j.staffPreference != null) _row('Staff preference', j.staffPreference!, scheme),
                    if (j.hoover != null) _row('Hoover', j.hoover!, scheme),
                    _row('Cleaning products', j.provideCleaningProducts ? 'Yes' : 'No', scheme),
                    _row('Washing machine', j.provideWashingMachine ? 'Yes' : 'No', scheme),
                    _row('Dryer', j.provideDryer ? 'Yes' : 'No', scheme),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: 16),

              // Payment & staff
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold('Payment & staff', size: 16, color: scheme.onSurface),
                    const SizedBox(height: 12),
                    if (j.invoicePaymentSource != null) _row('Payment source', j.invoicePaymentSource!, scheme),
                    _row('Cleaners needed', '${j.cleanersNeeded}', scheme),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),

              if (j.additionalNotes != null && j.additionalNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Additional notes', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 8),
                      CommonText.regular(j.additionalNotes!, size: 14, color: scheme.onSurfaceVariant),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
              ],

              if (j.cleaners.isNotEmpty) ...[
                const SizedBox(height: 16),
                CommonText.semiBold('Cleaners', size: 16, color: scheme.onSurface),
                const SizedBox(height: 8),
                ...j.cleaners.map(
                  (cl) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CleanerCard(
                      cleaner: cl,
                      onShare: () => c.onShareCleanerProfile(cl),
                      scheme: scheme,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: CommonText.regular('$label', size: 14, color: scheme.onSurfaceVariant),
          ),
          Expanded(
            child: CommonText.regular(value, size: 14, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.medium(label, size: 13, color: fg),
    );
  }
}

class _CleanerCard extends StatelessWidget {
  const _CleanerCard({
    required this.cleaner,
    required this.onShare,
    required this.scheme,
  });

  final ClientJobCleaner cleaner;
  final VoidCallback onShare;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: cleaner.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                    child: Image.network(cleaner.avatarUrl!, fit: BoxFit.cover),
                  )
                : Center(
                    child: CommonText.semiBold(
                      cleaner.name.isNotEmpty ? cleaner.name[0].toUpperCase() : '?',
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(cleaner.name, size: 15, color: scheme.onSurface),
                const SizedBox(height: 2),
                CommonText.regular(cleaner.status, size: 13, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
          TextButton(
            onPressed: onShare,
            child: CommonText.regular('Share', size: 14, color: scheme.primary),
          ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}
