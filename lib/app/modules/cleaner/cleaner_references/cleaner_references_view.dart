import 'package:ccs_app/app/network/response/get_references_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';

import '../../../../export.dart';
import 'cleaner_references_controller.dart';

class CleanerReferencesView extends GetView<CleanerReferencesController> {
  const CleanerReferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(title: "References"),
      body: Obx(() {
        if (controller.references.isEmpty) {
          return NoDataView(
            icon: IconsaxPlusLinear.profile_2user,
            title: 'No references yet',
            subtitle: 'Add professional or personal references to strengthen your profile. They\'ll appear here once added.',
            actionLabel: 'Add Reference',
            onAction: () => Get.toNamed(Routes.ADD_REFERENCES),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Icon(IconsaxPlusLinear.profile_2user, size: 20, color: scheme.primary),
                    const SizedBox(width: 8),
                    CommonText.semiBold(
                      '${controller.references.length} ${controller.references.length == 1 ? 'reference' : 'references'}',
                      size: 16,
                      color: scheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ref = controller.references[index];
                    return _ReferenceCard(reference: ref, scheme: scheme).marginOnly(bottom: 12);
                  },
                  childCount: controller.references.length,
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_REFERENCES),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reference'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({required this.reference, required this.scheme});

  final References reference;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final fullName = '${reference.firstName} ${reference.lastName}'.trim();
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return AppCard(
      margin: EdgeInsets.zero,
      enableShadows: true,
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: CommonText.semiBold(
                  initial,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ).marginOnly(right: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold(
                      fullName.capitalize ?? '',
                      size: 17,
                      color: scheme.onSurface,
                    ),
                    if (reference.relationship != null && reference.relationship!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                        ),
                        child: CommonText.medium(
                          reference.relationship!,
                          size: 12,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (reference.companyName != null && reference.companyName!.isNotEmpty) ...[
            _InfoRow(
              scheme: scheme,
              icon: IconsaxPlusLinear.building_4,
              label: reference.companyName!,
            ),
            const SizedBox(height: 10),
          ],
          if (reference.email != null && reference.email!.isNotEmpty) ...[
            _InfoRow(
              scheme: scheme,
              icon: IconsaxPlusLinear.sms,
              label: reference.email!,
            ),
            const SizedBox(height: 10),
          ],
          if (reference.phoneNumber != null && reference.phoneNumber!.isNotEmpty)
            _InfoRow(
              scheme: scheme,
              icon: IconsaxPlusLinear.call,
              label: reference.phoneNumber!,
            ),
        ],
      ).paddingAll(18),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.scheme,
    required this.icon,
    required this.label,
  });

  final ColorScheme scheme;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary.withValues(alpha: 0.9)).marginOnly(right: 10),
        Expanded(
          child: CommonText.regular(
            label,
            size: 14,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
