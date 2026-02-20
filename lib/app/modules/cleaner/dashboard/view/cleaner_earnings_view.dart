import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../cleaner_dashboard_controller.dart';

/// Earnings detail: Total, History, Payout. Opened from dashboard earnings block.
class CleanerEarningsView extends GetView<CleanerDashboardController> {
  const CleanerEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final c = controller;

    return AppScaffold(
      appBar: Header(
        title: 'Earnings',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UiConstants.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total earnings hero card
              AppCard(
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    AppCard(
                      enableShadows: false,
                      radius: UiConstants.radiusDefault,
                      color: scheme.primaryContainer,
                      child: Icon(
                        IconsaxPlusLinear.wallet_3,
                        size: 28,
                        color: scheme.primary,
                      ).paddingAll(16),
                    ).marginOnly(right: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.regular('Total earnings', size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(height: 6),
                          CommonText.extraBold(c.earningsTotal.value, size: 26, color: scheme.onSurface),
                          const SizedBox(height: 4),
                          CommonText.regular('Current balance', size: 12, color: scheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: 24),

              // Transaction history
              Row(
                children: [
                  Icon(IconsaxPlusLinear.receipt_2, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  CommonText.semiBold('Transaction history', size: 16, color: scheme.onSurface),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.regular('Recent payments and job earnings', size: 13, color: scheme.onSurfaceVariant).marginOnly(bottom: 14),
                    _HistoryRow(
                      date: 'Today',
                      desc: 'Residential clean',
                      amount: '£0.00',
                      scheme: scheme,
                    ),
                    Divider(height: 1, color: scheme.outline.withValues(alpha: 0.12)),
                    _HistoryRow(
                      date: CcsDateUtils.dayMonth(DateTime.now().subtract(const Duration(days: 2))),
                      desc: 'Office – Clerkenwell Road',
                      amount: '£0.00',
                      scheme: scheme,
                    ),
                    Divider(height: 1, color: scheme.outline.withValues(alpha: 0.12)),
                    _HistoryRow(
                      date: CcsDateUtils.dayMonth(DateTime.now().subtract(const Duration(days: 5))),
                      desc: 'Nellie – 8 The Grove',
                      amount: '£0.00',
                      scheme: scheme,
                    ),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: 24),

              // Payout
              Row(
                children: [
                  Icon(IconsaxPlusLinear.bank, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  CommonText.semiBold('Payout', size: 16, color: scheme.onSurface),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.regular('Next payout', size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    CommonText.semiBold('—', size: 18, color: scheme.onSurface),
                    const SizedBox(height: 10),
                    CommonText.regular(
                      'Bank details and payout schedule will appear here when configured.',
                      size: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      btnCornerRadius: 32,
                      borderClr: scheme.primary.withValues(alpha: 0.6),
                      txtClr: scheme.primary,
                      textSize: 14,
                      btnVerticalPadding: 8,
                      label: 'View payout computation',
                      onPressed: () => Get.toNamed(Routes.CLEANER_PAYOUT_COMPUTATION),
                      type: ButtonType.outline,
                      icon: IconsaxPlusLinear.calculator,
                    ),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),
              const SizedBox(height: UiConstants.gap),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.date,
    required this.desc,
    required this.amount,
    required this.scheme,
  });

  final String date;
  final String desc;
  final String amount;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.medium(desc, size: 14, color: scheme.onSurface),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(IconsaxPlusLinear.calendar_1, size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    CommonText.regular(date, size: 12, color: scheme.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
          CommonText.semiBold(amount, size: 15, color: scheme.primary),
        ],
      ),
    );
  }
}
