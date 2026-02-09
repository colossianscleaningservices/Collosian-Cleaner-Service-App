import 'dart:io';

import 'package:ccs_app/app/model/chat_message.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'chat_controller.dart';

String _formatMessageTime(DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(t.year, t.month, t.day);
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  if (msgDay == today) return '$hh:$mm';
  return '${t.day}/${t.month} $hh:$mm';
}

String _formatDateLabel(DateTime date) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final msgDate = DateTime(date.year, date.month, date.day);
  final days = todayDate.difference(msgDate).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return DateFormat('d MMM yyyy').format(date);
}

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isGroupChat = controller.chatMode == ChatMode.job;

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
                final isTyping = controller.isTyping.value;
                return ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: UiConstants.padding.left,
                    vertical: UiConstants.gap,
                  ),
                  reverse: true,
                  itemCount: list.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == 0) {
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
                              children: List.generate(
                                  3,
                                  (_) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(color: scheme.onSurfaceVariant.withValues(alpha: 0.6), shape: BoxShape.circle),
                                      )),
                            ),
                          ),
                        ),
                      );
                    }
                    final msg = list[index - (isTyping ? 1 : 0)];
                    if (msg.type == ChatConstants.messageTypeDate) {
                      return _DateRow(date: msg.timestamp, scheme: scheme);
                    }
                    return _MessageBubble(
                      message: msg,
                      scheme: scheme,
                      isOutgoing: controller.isOutgoingMessage(msg),
                      isSelectionMode: isSelectionMode,
                      isSelected: controller.isSelected(msg),
                      isGroupChat: isGroupChat,
                      onLongPress: () => _onMessageLongPress(context, msg),
                      onTap: () => _onMessageTap(msg),
                      onSwipeToReply: () => controller.setReplyTo(msg),
                      onImageTap: () => _showFullscreenImage(context, msg.imageUrl),
                    );
                  },
                );
              }),
            ),
            Obx(() => controller.isSelectionMode.value ? const SizedBox.shrink() : _ChatComposer(controller: controller, scheme: scheme)),
            Obx(() => _buildEmojiPicker(controller, scheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker(ChatController ctrl, ColorScheme scheme) {
    if (!ctrl.isEmojiPickerVisible.value) return const SizedBox.shrink();
    return SizedBox(
      height: 256,
      child: EmojiPicker(
        textEditingController: ctrl.textController,
        onEmojiSelected: (category, config) {},
        onBackspacePressed: () {
          final t = ctrl.textController;
          if (t.text.isNotEmpty && t.selection.baseOffset > 0) {
            t.text = t.text.replaceRange(
              t.selection.baseOffset - 1,
              t.selection.baseOffset,
              '',
            );
            t.selection = TextSelection.collapsed(offset: t.selection.baseOffset - 1);
          }
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 * (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS ? 1.20 : 1.0),
            backgroundColor: scheme.surfaceContainerHigh,
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: scheme.surfaceContainerHighest,
            indicatorColor: scheme.secondary,
            dividerColor: Colors.transparent,
            iconColor: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            iconColorSelected: scheme.secondary,
            backspaceColor: scheme.secondary,
            extraTab: CategoryExtraTab.BACKSPACE,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: scheme.surfaceContainerHighest,
            buttonIconColor: scheme.onSurface,
            showSearchViewButton: false,
            showBackspaceButton: false,
          ),
          viewOrderConfig: ViewOrderConfig(
            top: EmojiPickerItem.searchBar,
            middle: EmojiPickerItem.categoryBar,
            bottom: EmojiPickerItem.emojiView,
          ),
        ),
      ),
    );
  }

  void _onMessageLongPress(BuildContext context, ChatMessage msg) {
    if (controller.isSelectionMode.value) {
      controller.toggleMessageSelection(msg);
    } else if (controller.isOutgoingMessage(msg)) {
      controller.toggleMessageSelection(msg);
    }
  }

  void _onMessageTap(ChatMessage msg) {
    if (controller.isSelectionMode.value && controller.isOutgoingMessage(msg)) {
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
              child: _ChatImage(source: imageUrl, fit: BoxFit.contain),
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

// ---------------------------------------------------------------------------
// Date row
// ---------------------------------------------------------------------------

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date, required this.scheme});

  final DateTime date;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiConstants.gap),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: scheme.outline.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: CommonText.semiBold(_formatDateLabel(date), size: 12, color: scheme.onSurface),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.scheme,
    required this.isOutgoing,
    required this.isSelectionMode,
    required this.isSelected,
    required this.isGroupChat,
    required this.onLongPress,
    required this.onTap,
    required this.onSwipeToReply,
    required this.onImageTap,
  });

  final ChatMessage message;
  final ColorScheme scheme;
  final bool isOutgoing;
  final bool isSelectionMode;
  final bool isSelected;
  final bool isGroupChat;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback onSwipeToReply;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    final isOut = isOutgoing;
    final bg = isOut ? scheme.primary : scheme.surfaceContainerHigh;
    final fg = isOut ? scheme.onPrimary : scheme.onSurface;
    final radius = UiConstants.radiusLarge;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(isOut ? radius : 4),
      bottomRight: Radius.circular(isOut ? 4 : radius),
    );

    final maxWidth = MediaQuery.sizeOf(context).width;
    final bubbleMaxWidth = maxWidth >= 600 ? maxWidth * 0.6 : maxWidth * 0.85;

    final bubble = Align(
      alignment: isOut ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
        child: GestureDetector(
          onLongPress: onLongPress,
          onTap: isSelectionMode ? onTap : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AppCard(
                color: bg,
                borderRadius: borderRadius,
                borderColor: scheme.outline.withValues(alpha: 0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isGroupChat && !isOut) ...[
                      _buildSenderLabel(scheme),
                      const SizedBox(height: 4),
                    ],
                    if (message.replyToPreview != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                        ),
                        child: CommonText.regular(message.replyToPreview!,
                            size: 12, color: fg.withValues(alpha: 0.8), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => onImageTap?.call(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                          child: _ChatImage(source: message.imageUrl!, width: 200, height: 160, fit: BoxFit.cover),
                        ),
                      ),
                      if (_hasVisibleText) const SizedBox(height: 6),
                    ],
                    if (_hasVisibleText) CommonText.regular(message.text, size: 14, color: fg, maxLines: 20),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText.light(_formatMessageTime(message.timestamp), size: 11, color: fg.withValues(alpha: 0.7)),
                        if (isOutgoing && message.isRead) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.check_circle, size: 14, color: fg.withValues(alpha: 0.7)),
                        ],
                      ],
                    ),
                  ],
                ).paddingSymmetric(horizontal: UiConstants.defaultPadding, vertical: 10),
              ),
              if (isSelectionMode && isOut)
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

    return Padding(
      padding: const EdgeInsets.only(bottom: UiConstants.gap),
      child: isSelectionMode
          ? bubble
          : Dismissible(
              key: Key(message.id),
              direction: DismissDirection.endToStart,
              background: const SizedBox.shrink(),
              secondaryBackground: _swipeBackground,
              confirmDismiss: (_) async {
                onSwipeToReply();
                return false;
              },
              child: bubble,
            ),
    );
  }

  bool get _hasVisibleText => message.text.isNotEmpty && message.text != '(Image)';

  Widget _buildSenderLabel(ColorScheme scheme) {
    final roleColor = switch (message.senderRole) {
      RoleConstants.roleKeyAdmin => scheme.error,
      RoleConstants.roleKeyCleaner => scheme.tertiary,
      _ => scheme.secondary,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonText.semiBold(message.senderName, size: 12, color: roleColor),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
          child: CommonText.medium(message.senderRole.toUpperCase(), size: 9, color: roleColor),
        ),
      ],
    );
  }

  Widget get _swipeBackground => Container(
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
      );
}

// ---------------------------------------------------------------------------
// Image
// ---------------------------------------------------------------------------

class _ChatImage extends StatelessWidget {
  const _ChatImage({
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
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _loadingPlaceholder(context);
        },
        errorBuilder: (_, __, ___) => _errorPlaceholder(context),
      );
    }

    if (source.startsWith('assets/')) {
      return Image.asset(source, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => _errorPlaceholder(context));
    }

    return Image.file(
      File(source),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _errorPlaceholder(context),
    );
  }

  Widget _loadingPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 120,
      color: context.colorScheme.surfaceContainerHighest,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colorScheme.primary)),
    );
  }

  Widget _errorPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 120,
      color: context.colorScheme.surfaceContainerHighest,
      child: Icon(IconsaxPlusLinear.gallery, size: UiConstants.defaultIconSize, color: context.colorScheme.onSurfaceVariant),
    );
  }
}

// ---------------------------------------------------------------------------
// Composer
// ---------------------------------------------------------------------------

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({required this.controller, required this.scheme});

  final ChatController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final reply = controller.replyTo.value;
            if (reply == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                border: Border(bottom: BorderSide(color: scheme.secondary.withValues(alpha: 0.15))),
                borderRadius: BorderRadius.circular(8),
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
                        CommonText.regular(reply.text, size: 13, color: scheme.onSurfaceVariant, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(onPressed: controller.clearReplyTo, icon: Icon(Icons.cancel, size: 22, color: scheme.onSurfaceVariant)),
                ],
              ).paddingOnly(left: 16, right: 0, top: 8, bottom: 8),
            );
          }),
          Obx(() {
            final paths = controller.pendingImagePaths;
            if (paths.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: UiConstants.padding.left, right: UiConstants.padding.right, bottom: UiConstants.gap),
              child: Row(
                children: [
                  for (final path in paths)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                            child: _ChatImage(source: path, width: 64, height: 64, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => controller.removePendingImage(path),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _pickImage(context),
                style: filledIconButtonStyle(context),
                icon: const Icon(IconsaxPlusLinear.gallery, size: 22),
              ),
              Obx(
                () => IconButton(
                  onPressed: controller.toggleEmojiPicker,
                  style: filledIconButtonStyle(context),
                  icon: Icon(
                    controller.isEmojiPickerVisible.value ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
                    size: 22,
                    color: scheme.secondary,
                  ),
                ),
              ),
              Expanded(
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter && !HardwareKeyboard.instance.isShiftPressed) {
                      if (controller.canSend.value) {
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
              Obx(
                () => IconButton(
                  onPressed: controller.canSend.value ? controller.sendMessage : null,
                  style: filledIconButtonStyle(context),
                  icon: Icon(Icons.send_rounded, size: 22, color: controller.canSend.value ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                ),
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

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

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
        final count = controller.selectedMessageIds.length;
        final canDelete = count > 0;
        return AppBar(
          toolbarHeight: 68,
          backgroundColor: scheme.surface,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: controller.exitSelectionMode, color: scheme.primary),
          title: CommonText.semiBold(count == 1 ? '1 selected' : '$count selected', size: 18, color: scheme.onSurface),
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
      }
      return Header(
        title: controller.headerTitle.value,
        hasBackIcon: true,
        headerLogoIcon: false,
        titleCentered: false,
      );
    });
  }
}
