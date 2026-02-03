import 'package:ccs_app/app/model/common_model.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'training_and_resources_controller.dart';

class TrainingAndResourcesView extends GetView<TrainingAndResourcesController> {
  const TrainingAndResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(title: 'Training & Resources'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(scheme: scheme).marginOnly(bottom: 20),
            _SearchSection(controller: controller, scheme: scheme).marginOnly(bottom: 20),
            CommonText.semiBold('Media type filter', color: scheme.onSurface).marginOnly(bottom: 10),
            _FilterChips(controller: controller, scheme: scheme).marginOnly(bottom: 20),
            CommonText.semiBold('Resources', color: scheme.onSurface).marginOnly(bottom: 12),
            Obx(() {
              final list = controller.training;
              final selected = controller.filter.where((c) => c.isSelected).toList();
              final selectedType = selected.isNotEmpty ? selected.first.type : 'All';
              if (list.isEmpty) {
                return _EmptyState(scheme: scheme);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _TrainingCard(
                    item: item,
                    mediaTypeLabel: selectedType,
                    scheme: scheme,
                  );
                },
              );
            }).marginOnly(bottom: 24),
          ],
        ).paddingAll(UiConstants.defaultPadding),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppCard(
              radius: UiConstants.radiusDefault,
              enableShadows: false,
              color: scheme.primary.withValues(alpha: 0.05),
              child: Icon(IconsaxPlusLinear.book_1, size: 24, color: scheme.primary).paddingAll(12),
            ).marginOnly(right: 14),
            CommonText.regular(
              'Videos, guides and materials',
              size: 14,
              color: scheme.onSurfaceVariant,
            )
          ],
        ),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.controller, required this.scheme});

  final TrainingAndResourcesController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonTextField(
        hint: 'Search by title or description',
        label: 'Search',
        controller: controller.groupSearchController,
        borderColor: scheme.outline.withValues(alpha: 0.2),
        focus: controller.groupSearchFocus,
        onChanged: (value) => controller.searchTerm.value = value,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        suffixIcon: controller.searchTerm.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
                onPressed: () {
                  controller.groupSearchController.clear();
                  controller.searchTerm.value = '';
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller, required this.scheme});

  final TrainingAndResourcesController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: controller.filter.map((category) {
          final isSelected = category.isSelected;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                for (var element in controller.filter) {
                  element.isSelected = false;
                }
                category.isSelected = true;
                controller.filter.refresh();
              },
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? scheme.primaryContainer.withValues(alpha: 0.5) : scheme.onPrimary,
                  borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                  boxShadow: context.effectiveShadows(),
                  border: Border.all(
                    color: isSelected ? scheme.primary.withValues(alpha: 0.4) : scheme.outline.withValues(alpha: 0.15),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForType(category.type),
                      size: 18,
                      color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ).marginOnly(right: 8),
                    CommonText.medium(
                      category.type,
                      size: 14,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ],
                ).paddingSymmetric(horizontal: 14, vertical: 10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return IconsaxPlusLinear.video_play;
      case 'flyer':
        return IconsaxPlusLinear.document;
      default:
        return IconsaxPlusLinear.menu;
    }
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.item,
    required this.mediaTypeLabel,
    required this.scheme,
  });

  final CommonModel item;
  final String mediaTypeLabel;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isSeen = item.isSeen;

    return AppCard(
      radius: UiConstants.radiusLarge,
      enableShadows: true,
      shadowOpacity: 0.06,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(UiConstants.radiusLarge),
              topRight: Radius.circular(UiConstants.radiusLarge),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.35),
                    scheme.secondaryContainer.withValues(alpha: 0.25),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForMediaType(mediaTypeLabel),
                    size: 40,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: scheme.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                      ),
                      child: CommonText.medium(
                        mediaTypeLabel,
                        size: 12,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconsaxPlusLinear.profile_2user,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        CommonText.regular(
                          'All',
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CommonText.semiBold(
                        'Training resource',
                        size: 15,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (!isSeen)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                        ),
                        child: CommonText.medium(
                          'New',
                          size: 11,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForMediaType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return IconsaxPlusLinear.video_play;
      case 'flyer':
        return IconsaxPlusLinear.document;
      default:
        return IconsaxPlusLinear.book_1;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            IconsaxPlusLinear.document,
            size: 48,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          CommonText.medium(
            'No resources yet',
            size: 16,
            color: scheme.onSurface,
          ),
          const SizedBox(height: 8),
          CommonText.regular(
            'Training materials will appear here when available.',
            size: 14,
            color: scheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
