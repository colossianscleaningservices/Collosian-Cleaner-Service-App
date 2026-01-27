import 'package:intl/intl.dart';

import 'package:ccs_app/export.dart';
import 'package:ccs_app/app/model/client_job.dart';
import 'client_job_detail_controller.dart';

/// Client job detail: all fields from website specs (status, dates, client, property, access, address, preferences, equipment, cleaners).
class ClientJobDetailView extends GetView<ClientJobDetailController> {
  const ClientJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final j = c.job;
    final scheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Job'),
        actions: [
          TextButton(onPressed: c.onEdit, child: const Text('Edit')),
          TextButton(onPressed: c.deleteJob, child: const Text('Delete')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UiConstants.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Status', scheme),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(j.status, scheme.primaryContainer, scheme.primary),
                  if (j.recurrence != null) _chip(j.recurrence!, scheme.secondaryContainer, scheme.secondary),
                  if (j.status == 'Scheduled')
                    TextButton(
                      onPressed: c.onCancelJob,
                      child: Text('Cancel Job', style: TextStyle(color: scheme.error)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _section('Job Start & End', scheme),
              _row('Start', '${DateFormat('MM/dd/yyyy').format(j.date)} ${j.startTime}', scheme),
              _row('End', j.jobEndDate != null ? '${DateFormat('MM/dd/yyyy').format(j.jobEndDate!)} ${j.endTime}' : j.endTime, scheme),
              const SizedBox(height: 16),
              _section('Client & Property', scheme),
              _row('Client', j.clientName, scheme),
              if (j.propertyLabel != null) _row('Property', j.propertyLabel!, scheme),
              if (j.accessToProperty != null) _row('Access to Property', j.accessToProperty!, scheme),
              if (j.address != null || j.city != null || j.postalCode != null) ...[
                const SizedBox(height: 8),
                CommonText.regular(
                  [j.address, j.city, j.postalCode].whereType<String>().join(', '),
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ],
              if (j.propertyType != null) _row('Property Type', j.propertyType!, scheme),
              if (j.propertySubtype != null) _row('Property Subtype', j.propertySubtype!, scheme),
              if (j.animals != null) _row('Animals', j.animals!, scheme),
              const SizedBox(height: 16),
              _section('Preferences & equipment', scheme),
              if (j.staffPreference != null) _row('Staff Preference', j.staffPreference!, scheme),
              if (j.hoover != null) _row('Do you have a hoover?', j.hoover!, scheme),
              _row('Provide cleaning products', j.provideCleaningProducts ? 'Yes' : 'No', scheme),
              _row('Washing machine', j.provideWashingMachine ? 'Yes' : 'No', scheme),
              _row('Dryer', j.provideDryer ? 'Yes' : 'No', scheme),
              const SizedBox(height: 16),
              _section('Payment & staff', scheme),
              if (j.invoicePaymentSource != null) _row('Payment source', j.invoicePaymentSource!, scheme),
              _row('Cleaner(s) needed', '${j.cleanersNeeded}', scheme),
              if (j.additionalNotes != null && j.additionalNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _section('Additional notes', scheme),
                CommonText.regular(j.additionalNotes!, size: 14, color: scheme.onSurface),
              ],
              if (j.cleaners.isNotEmpty) ...[
                const SizedBox(height: 20),
                _section('Cleaners', scheme),
                ...j.cleaners.map((cl) => _CleanerCard(
                      cleaner: cl,
                      onShare: () => c.onShareCleanerProfile(cl),
                      scheme: scheme,
                    )),
              ],
              const SizedBox(height: UiConstants.gap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CommonText.semiBold(title, size: 16, color: scheme.onSurface),
    );
  }

  Widget _row(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: CommonText.regular('$label:', size: 14, color: scheme.onSurfaceVariant),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primaryContainer,
              backgroundImage: cleaner.avatarUrl != null ? NetworkImage(cleaner.avatarUrl!) : null,
              child: cleaner.avatarUrl == null
                  ? CommonText.semiBold(cleaner.name.isNotEmpty ? cleaner.name[0].toUpperCase() : '?', size: 18, color: scheme.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText.semiBold(cleaner.name, size: 15, color: scheme.onSurface),
                  CommonText.regular(cleaner.status, size: 13, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
            TextButton(
              onPressed: onShare,
              child: const Text('Share Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
