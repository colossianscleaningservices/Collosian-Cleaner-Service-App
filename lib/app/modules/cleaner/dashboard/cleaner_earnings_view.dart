import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

import 'cleaner_dashboard_controller.dart';

/// Earnings detail: Total, History, Payout. Opened from dashboard earnings block.
class CleanerEarningsView extends GetView<CleanerDashboardController> {
  const CleanerEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UiConstants.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(label: 'Total', scheme: scheme),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText.regular('Current total', size: 14, color: scheme.onSurfaceVariant),
                      CommonText.semiBold(controller.earningsTotal, size: 20, color: scheme.onSurface),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(label: 'History', scheme: scheme),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.regular('Transaction history (coming soon)', size: 13, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      _HistoryRow(date: 'Today', desc: 'Residential clean', amount: '£0.00', scheme: scheme),
                      _HistoryRow(
                          date: DateFormat('d MMM').format(DateTime.now().subtract(const Duration(days: 2))),
                          desc: 'Office – Clerkenwell Road',
                          amount: '£0.00',
                          scheme: scheme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(label: 'Payout', scheme: scheme),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.regular('Next payout (coming soon)', size: 13, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      CommonText.semiBold('—', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 4),
                      CommonText.regular('Bank details and payout schedule will appear here.', size: 12, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UiConstants.gap),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return CommonText.semiBold(label, size: 16, color: scheme.onSurface);
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.date, required this.desc, required this.amount, required this.scheme});

  final String date;
  final String desc;
  final String amount;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.medium(desc, size: 14, color: scheme.onSurface),
              CommonText.regular(date, size: 12, color: scheme.onSurfaceVariant),
            ],
          ),
          CommonText.semiBold(amount, size: 14, color: scheme.onSurface),
        ],
      ),
    );
  }
}
