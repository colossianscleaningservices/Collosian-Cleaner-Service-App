import 'package:ccs_app/app/modules/cleaner/dashboard/view/transaction_history_view.dart';
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
      body: SwipeRefresh(
        onRefresh: () async {
          controller.jobCurrentPage = 1;
          await controller.getPayoutDash(isLoaderShown: false);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: UiConstants.padding,
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        CommonText.semiBold('£${controller.payoutEarning.value?.nextPayout ?? "0"}', size: 18, color: scheme.onSurface),
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
                  const SizedBox(height: 24),

                  // Transaction history
                  Row(
                    children: [
                      Icon(IconsaxPlusLinear.receipt_2, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: CommonText.semiBold('Transaction history', size: 16, color: scheme.onSurface)),
                      CommonText.semiBold(
                        'View All',
                        size: 14,
                        color: scheme.secondary,
                        onTap: () {
                          Get.to(() => const TransactionHistoryView());
                          controller.currentPage = 1;
                          controller.getTransactionHistory();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.regular('Recent payments and job earnings', size: 13, color: scheme.onSurfaceVariant).marginOnly(bottom: 14),
                        controller.payoutEarning.value?.latestPayouts?.isNotEmpty == true
                            ? ListView.builder(
                                itemCount: controller.payoutEarning.value?.latestPayouts?.length ?? 0,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var item = controller.payoutEarning.value?.latestPayouts?[index];
                                  var date = '';
                                  if (item?.paidOn != null) {
                                    date = CcsDateUtils.fullDate(DateTime.parse(item?.paidOn ?? ""));
                                  }

                                  return Column(
                                    children: [
                                      _HistoryRow(
                                        date: date,
                                        desc: item?.job?.cleaningService ?? "N/A",
                                        amount: "£${item?.totalPayout}",
                                        status: item?.status,
                                        scheme: scheme,
                                      ),
                                      Divider(height: 1, color: scheme.outline.withValues(alpha: 0.12)),
                                    ],
                                  );
                                })
                            : NoDataView(
                                title: 'No recent payments',
                              ),
                      ],
                    ).paddingAll(UiConstants.defaultPadding),
                  ),
                  const SizedBox(height: 24),

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
                              CommonText.extraBold("£${c.payoutEarning.value?.totalEarnings??0}", size: 26, color: scheme.onSurface),
                              const SizedBox(height: 4),
                              CommonText.regular('Paid amounts only', size: 12, color: scheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ],
                    ).paddingAll(UiConstants.defaultPadding),
                  ),
                  const SizedBox(height: UiConstants.gap),
                ],
              );
            }),
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
    this.status,
  });

  final String date;
  final String desc;
  final String amount;
  final ColorScheme scheme;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final statusLabel = status?.trim();
    final hasStatus = statusLabel != null && statusLabel.isNotEmpty;

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
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(IconsaxPlusLinear.calendar_1, size: 12, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      CommonText.regular(date, size: 12, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommonText.semiBold(amount, size: 15, color: scheme.primary),
              if (hasStatus) ...[
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: getBgColor(statusLabel, scheme),
                    borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                  ),
                  child: CommonText.semiBold(
                    statusLabel.capitalizeFirst ?? statusLabel,
                    size: 11,
                    color: getFgColor(statusLabel, scheme),
                  ).paddingSymmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
