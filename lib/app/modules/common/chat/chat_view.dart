import 'dart:io';

import 'package:ccs_app/app/model/chat_message.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_controller.dart';

/// Chat screen: scrollable message list, bubbles, composer, typing indicator.
/// Uses app design system (CommonText, AppButton, UiConstants, colorScheme).
/// Backend: wire [ChatController.messages] to API/WebSocket; plug send/delete in controller.
class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final maxBubbleWidth = _maxBubbleWidth(context);

    return AppScaffold(
      appBar: _ChatAppBar(controller: controller, scheme: scheme),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final list = controller.messages;
                final isSelectionMode = controller.isSelectionMode.value;
                return ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: UiConstants.padding.left,
                    vertical: UiConstants.gap,
                  ),
                  reverse: true,
                  itemCount: list.length + (controller.isTyping.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.isTyping.value && index == 0) {
                      return _TypingIndicator(scheme: scheme);
                    }
                    final msg = list[controller.isTyping.value ? index - 1 : index];
                    return _MessageBubble(
                      message: msg,
                      maxWidth: maxBubbleWidth,
                      scheme: scheme,
                      isSelectionMode: isSelectionMode,
                      isSelected: controller.isSelected(msg),
                      onLongPress: () => _onMessageLongPress(context, msg),
                      onTap: () => _onMessageTap(msg),
                      onSwipeToReply: () => controller.setReplyTo(msg),
                      onImageTap: () => _showFullscreenImage(context, msg.imageUrl),
                    );
                  },
                );
              }),
            ),
            Obx(() => controller.isSelectionMode.value
                ? const SizedBox.shrink()
                : _ChatComposer(controller: controller, scheme: scheme)),
          ],
        ),
      ),
    );
  }

  double _maxBubbleWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 600) return w * 0.6;
    return w * 0.85;
  }

  void _onMessageLongPress(BuildContext context, ChatMessage msg) {
    if (controller.isSelectionMode.value) {
      controller.toggleMessageSelection(msg);
    } else {
      if (msg.isOutgoing) {
        controller.toggleMessageSelection(msg);
      }
    }
  }

  void _onMessageTap(ChatMessage msg) {
    if (controller.isSelectionMode.value && msg.isOutgoing) {
      controller.toggleMessageSelection(msg);
    }
  }

  void _showFullscreenImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    showDialog<void>(
      context: context,
      barrierColor: context.colorScheme.scrim,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(UiConstants.defaultPadding),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: _ImageFromSource(
                source: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: UiConstants.gap),
              child: AppButton(
                label: 'Close',
                type: ButtonType.tonal,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.maxWidth,
    required this.scheme,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onLongPress,
    required this.onTap,
    required this.onSwipeToReply,
    required this.onImageTap,
  });

  final ChatMessage message;
  final double maxWidth;
  final ColorScheme scheme;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback onSwipeToReply;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    final bubble = Align(
      alignment: message.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: GestureDetector(
          onLongPress: onLongPress,
          onTap: isSelectionMode ? onTap : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: _BubbleContent(
                  key: ValueKey(message.id),
                  message: message,
                  scheme: scheme,
                  onImageTap: onImageTap,
                ),
              ),
              if (isSelectionMode && message.isOutgoing)
                Positioned(
                  left: -4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 22,
                      color: isSelected ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (isSelectionMode) {
      return Padding(
        padding: const EdgeInsets.only(bottom: UiConstants.gap),
        child: bubble,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: UiConstants.gap),
      child: Dismissible(
        key: Key(message.id),
        direction: DismissDirection.endToStart,
        background: Container(
          width: double.infinity,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: UiConstants.defaultPadding),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CommonText.medium('Reply', size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Icon(Icons.reply_rounded, size: 20, color: scheme.primary),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          onSwipeToReply();
          return false;
        },
        child: bubble,
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    super.key,
    required this.message,
    required this.scheme,
    this.onImageTap,
  });

  final ChatMessage message;
  final ColorScheme scheme;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    final bg = message.isOutgoing ? scheme.primary : scheme.surfaceContainerHigh;
    final fg = message.isOutgoing ? scheme.onPrimary : scheme.onSurface;
    final radius = UiConstants.radiusLarge;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(message.isOutgoing ? radius : 4),
      bottomRight: Radius.circular(message.isOutgoing ? 4 : radius),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiConstants.defaultPadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.replyToPreview != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
              ),
              child: CommonText.regular(
                message.replyToPreview!,
                size: 12,
                color: fg.withValues(alpha: 0.8),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
            GestureDetector(
              onTap: () => onImageTap?.call(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                child: _ImageFromSource(
                  source: message.imageUrl!,
                  width: 200,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (message.text.isNotEmpty && message.text != '(Image)') const SizedBox(height: 6),
          ],
          if (message.text.isNotEmpty && message.text != '(Image)')
            CommonText.regular(
              message.text,
              size: 14,
              color: fg,
              maxLines: 20,
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonText.light(
                _formatTime(message.timestamp),
                size: 11,
                color: fg.withValues(alpha: 0.7),
              ),
              if (message.isOutgoing && message.isRead) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: fg.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(t.year, t.month, t.day);
    if (msgDay == today) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.day}/${t.month} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

/// Inline/fullscreen image: supports asset path or file path.
class _ImageFromSource extends StatelessWidget {
  const _ImageFromSource({
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    final file = File(source);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 120,
      color: context.colorScheme.surfaceContainerHighest,
      child: Icon(
        IconsaxPlusLinear.gallery,
        size: UiConstants.defaultIconSize,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}


class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.scheme,
  });

  final ChatController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //reply bar
          Obx(() {
            final reply = controller.replyTo.value;
            if (reply == null) return const SizedBox.shrink();
            return _ReplyPreviewBar(
              reply: reply,
              scheme: scheme,
              onCancel: controller.clearReplyTo,
            );
          }),
          //image preview
          Obx(() {
            final paths = controller.pendingImagePaths;
            if (paths.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: UiConstants.padding.left,
                right: UiConstants.padding.right,
                bottom: UiConstants.gap,
              ),
              child: Row(
                children: paths.map((path) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                        child: _ImageFromSource(
                          source: path,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.removePendingImage(path),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(right: 8)).toList(),
              ),
            );
          }),
          //chat box
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _pickImage(context),
                style: filledIconButtonStyle(context),
                icon: const Icon(IconsaxPlusLinear.gallery, size: 22),
              ),
              Expanded(
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                      if (!HardwareKeyboard.instance.isShiftPressed) {
                        controller.sendMessage();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: CommonTextField(
                    controller: controller.textController,
                    hint: 'Message',
                    maxLines: 4,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                    focus: controller.focusNode,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.sendMessage,
                style: filledIconButtonStyle(context),
                icon: const Icon(Icons.send_rounded, size: 22),
              ),
            ],
          ).paddingSymmetric(horizontal: 8, vertical: 8),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    showPicker(
      galleryPicker: () async {
        final picker = ImagePicker();
        final x = await picker.pickImage(source: ImageSource.gallery);
        if (x != null) controller.addPendingImage(x.path);
      },
      cameraPicker: () async {
        final picker = ImagePicker();
        final x = await picker.pickImage(source: ImageSource.camera);
        if (x != null) controller.addPendingImage(x.path);
      },
    );
  }
}

class _ReplyPreviewBar extends StatelessWidget {
  const _ReplyPreviewBar({
    required this.reply,
    required this.scheme,
    required this.onCancel,
  });

  final ChatMessage reply;
  final ColorScheme scheme;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        border: Border(
          bottom: BorderSide(
            color: scheme.secondary.withValues(alpha: 0.15),
          ),
        ),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText.medium('Replying', size: 12, color: scheme.primary),
                const SizedBox(height: 2),
                CommonText.regular(
                  reply.text,
                  size: 13,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: Icon(
              Icons.cancel,
              size: 22,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ).paddingOnly(left: 16, right: 0, top: 8, bottom: 8),
    ).marginSymmetric(horizontal: 8);
  }
}

/// Switches between normal header and selection action bar (PreferredSizeWidget for AppScaffold).
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.controller, required this.scheme});

  final ChatController controller;
  final ColorScheme scheme;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSelectionMode.value) {
        return _SelectionAppBar(controller: controller, scheme: scheme);
      }
      return Header(
        title: 'Chat',
        hasBackIcon: true,
        headerLogoIcon: false,
        titleCentered: false,
      );
    });
  }
}

/// WhatsApp-like action bar when multiselect is on. Delete removes only selected self messages.
class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SelectionAppBar({required this.controller, required this.scheme});

  final ChatController controller;
  final ColorScheme scheme;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.selectedMessageIds.length;
      final canDelete = count > 0;
      return AppBar(
        toolbarHeight: 68,
        backgroundColor: scheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: controller.exitSelectionMode,
          color: scheme.primary,
        ),
        title: CommonText.semiBold(
          count == 1 ? '1 selected' : '$count selected',
          size: 18,
          color: scheme.onSurface,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(IconsaxPlusLinear.trash, size: 22, color: canDelete ? scheme.error : scheme.onSurfaceVariant.withValues(alpha: 0.5)),
            tooltip: 'Delete',
            onPressed: canDelete
                ? () {
                    Notifier.openSheet(
                      context,
                      title: 'Delete messages?',
                      message: 'Delete $count message${count == 1 ? '' : 's'}? This cannot be undone.',
                      type: SheetType.warning,
                      primaryButtonLabel: 'Delete',
                      secondaryButtonLabel: 'Cancel',
                      showPrimaryButton: true,
                      showSecondaryButton: true,
                      onPrimaryPressed: () => controller.deleteSelectedMessages(),
                      onSecondaryPressed: () {},
                    );
                  }
                : null,
          ),
        ],
      );
    });
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiConstants.gap),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: UiConstants.defaultPadding, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(UiConstants.radiusLarge),
              topRight: const Radius.circular(UiConstants.radiusLarge),
              bottomLeft: const Radius.circular(4),
              bottomRight: Radius.circular(UiConstants.radiusLarge),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
