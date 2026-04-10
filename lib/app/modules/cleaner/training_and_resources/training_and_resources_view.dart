import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:video_player/video_player.dart';

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
    required this.controller,
    required this.scheme,
  });

  final VideoPlayerController? controller;
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
  bool _initFailed = false;
  bool _initStarted = false;

  Future<void> _tryInitialize(VideoPlayerController ctrl) async {
    if (_initStarted) return;
    _initStarted = true;
    try {
      await ctrl.initialize();
      if (mounted) setState(() {});
    } on PlatformException catch (_) {
      if (mounted) setState(() => _initFailed = true);
    } catch (_) {
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    if (widget.controller == null) {
      return _VideoPlaceholder._videoFallback(
        scheme: scheme,
        icon: IconsaxPlusLinear.video_play,
      );
    }
    final ctrl = widget.controller!;

    if (!ctrl.value.isInitialized && !_initFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryInitialize(ctrl));
    }

    if (_initFailed) {
      return _VideoPlaceholder._videoFallback(
        scheme: scheme,
        icon: IconsaxPlusLinear.video_slash,
        label: 'Video unavailable on this device',
      );
    }

    return ListenableBuilder(
      listenable: ctrl,
      builder: (_, __) {
        if (ctrl.value.hasError) {
          return _VideoPlaceholder._videoFallback(
            scheme: scheme,
            icon: IconsaxPlusLinear.video_slash,
            label: 'Video unavailable on this device',
          );
        }
        if (!ctrl.value.isInitialized) {
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
              aspectRatio: ctrl.value.aspectRatio,
              child: VideoPlayer(ctrl),
            ),
            _VideoControlsBar(controller: ctrl, scheme: scheme),
          ],
        );
      },
    );
  }
}

String _formatVideoDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class _VideoControlsBar extends StatefulWidget {
  const _VideoControlsBar({
    required this.controller,
    required this.scheme,
  });

  final VideoPlayerController controller;
  final ColorScheme scheme;

  @override
  State<_VideoControlsBar> createState() => _VideoControlsBarState();
}

class _VideoControlsBarState extends State<_VideoControlsBar> {
  bool _isDragging = false;
  double _dragPositionSeconds = 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final scheme = widget.scheme;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (_, __) {
        final position = ctrl.value.position;
        final duration = ctrl.value.duration;
        final totalSeconds = duration.inMilliseconds / 1000.0;
        final currentSeconds = _isDragging ? _dragPositionSeconds : position.inMilliseconds / 1000.0;
        final safeTotal = totalSeconds > 0 ? totalSeconds : 1.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.95),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    if (ctrl.value.isPlaying) {
                      ctrl.pause();
                    } else {
                      ctrl.play();
                    }
                  },
                  icon: Icon(
                    ctrl.value.isPlaying ? IconsaxPlusLinear.pause : IconsaxPlusLinear.play,
                    color: scheme.primary,
                    size: 28,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: scheme.outline.withValues(alpha: 0.3),
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: currentSeconds.clamp(0.0, safeTotal),
                    max: safeTotal,
                    onChanged: totalSeconds <= 0
                        ? null
                        : (v) {
                            setState(() {
                              _isDragging = true;
                              _dragPositionSeconds = v;
                            });
                          },
                    onChangeEnd: (v) {
                      ctrl.seekTo(Duration(milliseconds: (v * 1000).round()));
                      setState(() => _isDragging = false);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatVideoDuration(Duration(milliseconds: (currentSeconds * 1000).round()))} / ${_formatVideoDuration(duration)}',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
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
                    controller: item.videoPlayerController,
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
                    /*Row(
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
                    ),*/
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
      case 'document':
        return IconsaxPlusLinear.document;
      default:
        return IconsaxPlusLinear.book_1;
    }
  }
}
