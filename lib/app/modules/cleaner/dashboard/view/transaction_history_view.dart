import 'package:ccs_app/app/modules/cleaner/dashboard/cleaner_dashboard_controller.dart';
import '../../../../../export.dart';
import '../../../../widget/layout/app_scaffold.dart';

class TransactionHistoryView extends GetView<CleanerDashboardController> {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(
        title: "Transaction History",
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  controller.transactionHistory.isNotEmpty == true
                      ? ListView.builder(
                          itemCount: controller.transactionHistory.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var item = controller.transactionHistory[index];
                            var date = '';
                            if (item.paidOn != null) {
                              date = CcsDateUtils.fullDate(DateTime.parse(item.paidOn ?? ""));
                            }
                            final status = (item.status != null && item.status!.trim().isNotEmpty)
                                ? item.status
                                : (date.isNotEmpty ? 'Paid' : null);

                            return AppCard(
                              onTap: null,
                              child: Column(
                                children: [
                                  _HistoryRow(
                                    date: date,
                                    desc: item.job?.cleaningService ?? "N/A",
                                    amount: "£${item.totalPayout}",
                                    status: status,
                                    scheme: scheme,
                                  ),
                                ],
                              ).paddingSymmetric(horizontal: 16, vertical: 4),
                            ).marginSymmetric(vertical: 4);
                          })
                      : NoDataView(
                          title: 'No recent payments',
                        ),
                ],
              ),
            ],
          ).marginSymmetric(horizontal: 16);
        }),
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
