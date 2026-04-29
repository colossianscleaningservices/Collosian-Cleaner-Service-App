import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:chewie/chewie.dart';

import '../../../network/response/training_resource_response.dart';
import 'training_and_resources_controller.dart';

class TrainingAndResourcesView extends GetView<TrainingAndResourcesController> {
  const TrainingAndResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      appBar: Header(title: 'Training & Resources'),
      body: SwipeRefresh(
        onRefresh: () => controller.refreshTraining(),
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsRow(controller: controller, scheme: scheme).marginOnly(bottom: 20),
              _SearchSection(controller: controller, scheme: scheme).marginOnly(bottom: 20),
              CommonText.semiBold('Media type filter', color: scheme.onSurface).marginOnly(bottom: 10),
              _FilterChips(controller: controller, scheme: scheme).marginOnly(bottom: 20),
              CommonText.semiBold('Resources', color: scheme.onSurface).marginOnly(bottom: 12),
              Obx(() {
                final list = controller.trainingList.value;
                final selected = controller.filter.where((c) => c.isSelected).toList();
                final selectedType = selected.isNotEmpty ? selected.first.type : 'All';
                if (list.isEmpty) {
                  return NoDataView(
                    title: 'No resources yet',
                    subtitle: 'Training materials will appear here when available.',
                    icon: IconsaxPlusLinear.document,
                  );
                }

                final itemCount = list.length;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    if (index < 0 || index >= itemCount) return const SizedBox.shrink();
                    final item = list[index];
                    return _TrainingCard(
                      item: item,
                      mediaTypeLabel: selectedType,
                      scheme: scheme,
                      ctrl: controller,
                    );
                  },
                );
              }).marginOnly(bottom: 24),
              Obx(() => controller.isMoreLoading.value ? PageLoader() : SizedBox.shrink())
            ],
          ).paddingAll(UiConstants.defaultPadding),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller, required this.scheme});

  final TrainingAndResourcesController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unseen = controller.counts.value?.unseen ?? 0;
      final seen = controller.counts.value?.seen ?? 0;
      final total = controller.counts.value?.total ?? 0;

      return Row(
        children: [
          Expanded(
            child: _StatChip(
              label: 'Unseen',
              value: unseen,
              scheme: scheme,
              accentColor: scheme.error,
            ).marginOnly(right: 10),
          ),
          Expanded(
            child: _StatChip(
              label: 'Seen',
              value: seen,
              scheme: scheme,
              accentColor: scheme.tertiary,
            ).marginOnly(right: 10),
          ),
          Expanded(
            child: _StatChip(
              label: 'Total',
              value: total,
              scheme: scheme,
              accentColor: scheme.primary,
            ),
          ),
        ],
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.scheme,
    required this.accentColor,
  });

  final String label;
  final num value;
  final ColorScheme scheme;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: accentColor.withValues(alpha: 0.08),
      radius: UiConstants.radiusDefault,
      borderWidth: 1,
      enableShadows: false,
      borderColor: accentColor.withValues(alpha: 0.25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText.medium(
            label,
            size: 12,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          CommonText.semiBold(
            '$value',
            size: 20,
            color: accentColor,
          ),
        ],
      ).paddingSymmetric(vertical: 14, horizontal: 12),
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
        controller: controller.searchController,
        borderColor: scheme.outline.withValues(alpha: 0.2),
        focus: controller.searchFocus,
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
                  controller.searchController.clear();
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
                controller.currentPage = 1;
                controller.getTrainingResources();
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

class _VideoPlaceholder extends StatefulWidget {
  const _VideoPlaceholder({
    required this.chewieController,
    required this.scheme,
  });

  final ChewieController? chewieController;
  final ColorScheme scheme;

  static const double _minHeight = 160;

  static Widget _videoFallback({
    required ColorScheme scheme,
    required IconData icon,
    String? label,
  }) {
    return Container(
      height: _minHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            scheme.surfaceContainerHigh.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.onSurfaceVariant),
            if (label != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommonText.regular(
                  label,
                  size: 12,
                  color: scheme.onSurfaceVariant,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  State<_VideoPlaceholder> createState() => _VideoPlaceholderState();
}

class _VideoPlaceholderState extends State<_VideoPlaceholder> {
  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    if (widget.chewieController == null) {
      return _VideoPlaceholder._videoFallback(
        scheme: scheme,
        icon: IconsaxPlusLinear.video_play,
      );
    }
    final chewieCtrl = widget.chewieController!;
    final videoCtrl = chewieCtrl.videoPlayerController;

    return ListenableBuilder(
      listenable: videoCtrl,
      builder: (_, __) {
        if (videoCtrl.value.hasError) {
          return _VideoPlaceholder._videoFallback(
            scheme: scheme,
            icon: IconsaxPlusLinear.video_slash,
            label: 'Video unavailable on this device',
          );
        }
        if (!videoCtrl.value.isInitialized) {
          return SizedBox(
            height: _VideoPlaceholder._minHeight,
            width: double.infinity,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: videoCtrl.value.aspectRatio,
              child: Chewie(
                controller: chewieCtrl,
              ),
            )
          ],
        );
      },
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.item,
    required this.mediaTypeLabel,
    required this.scheme,
    required this.ctrl,
  });

  final Trainings item;
  final String mediaTypeLabel;
  final ColorScheme scheme;
  final TrainingAndResourcesController ctrl;

  @override
  Widget build(BuildContext context) {
    final isSeen = item.isSeen ?? false;

    return AppCard(
      onTap: () {
        if (isSeen == false && item.id != null) {
          ctrl.seenTrainingResources(item.id!.toInt(), ctrl.trainingList.indexOf(item));
        }
      },
      radius: UiConstants.radiusLarge,
      enableShadows: true,
      shadowOpacity: 0.06,
      borderWidth: 1.5,
      borderColor: isSeen == true ? scheme.outline.withValues(alpha: 0.08) : scheme.error,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(UiConstants.radiusLarge),
              topRight: Radius.circular(UiConstants.radiusLarge),
            ),
            child: item.fileCategory?.toLowerCase() == 'video'
                ? _VideoPlaceholder(
                    chewieController: item.chewieController,
                    scheme: scheme,
                  )
                : item.fileCategory?.toLowerCase() == 'image'
                    ? Container(
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
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              item.fileUrl!,
                              fit: BoxFit.fitWidth,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return _loadingPlaceholder(context);
                              },
                            ),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          if (item.fileUrl != null) {
                            ctrl.onViewFile(item.fileUrl!);
                          }
                        },
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
                                _iconForMediaType(item.fileCategory ?? ""),
                                size: 40,
                                color: scheme.primary,
                              ),
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
                        item.contentType ?? "",
                        size: 12,
                        color: scheme.onSecondaryContainer,
                      ),
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

  Widget _loadingPlaceholder(BuildContext context) {
    return Container(
      height:  120,
      color: context.colorScheme.surfaceContainerHighest,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colorScheme.primary)),
    );
  }


  IconData _iconForMediaType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return IconsaxPlusLinear.video_play;
      case 'document':
        return IconsaxPlusLinear.document;
      default:
        return IconsaxPlusLinear.book_1;
    }
  }
}
