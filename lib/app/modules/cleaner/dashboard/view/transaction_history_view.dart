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

                            return AppCard(
                              onTap: null,
                              child: Column(
                                children: [
                                  _HistoryRow(date: date, desc: item.job?.cleaningService ?? "", amount: "£${item.totalPayout}", scheme: scheme),
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
