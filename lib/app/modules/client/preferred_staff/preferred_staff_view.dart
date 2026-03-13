import '../../../../export.dart';
import '../../../widget/layout/app_scaffold.dart';
import 'preferred_staff_controller.dart';

class PreferredStaffView extends GetView<PreferredStaffController> {
  const PreferredStaffView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Header(title: 'Preferred Staff'),
      body: Obx(() {
        return SwipeRefresh(
          onRefresh: () async => controller.preferredStaff(),
          child: SafeArea(
            child: controller.preferredStaff.isEmpty
                ? NoDataView(
                    title: 'No preferred staff found',
                    subtitle: "We'll share preferred staff here when they're available.",
                    icon: IconsaxPlusLinear.sms_edit,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    itemCount: controller.preferredStaff.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var preferredStaff = controller.preferredStaff[index];

                      return AppCard(
                        onTap: () => controller.goToPreferredStaffDetail(preferredStaff.id?.toInt() ?? 0),
                        child: Row(
                          children: [
                            AppAvatar(
                              imageUrl: preferredStaff.imageUrl,
                              name: preferredStaff.name,
                              radius: 8,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText.semiBold(preferredStaff.name ?? '', size: 15, color: context.colorScheme.onSurface),
                                  const SizedBox(height: 2),
                                  CommonText.regular(preferredStaff.email ?? '', size: 15, color: context.colorScheme.onSurface),
                                ],
                              ),
                            ),
                          ],
                        ).paddingAll(UiConstants.defaultPadding),
                      );
                    },
                  ),
          ),
        );
      }),
    );
  }
}
