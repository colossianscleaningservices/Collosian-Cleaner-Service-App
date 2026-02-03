import 'dart:async';

import 'package:ccs_app/export.dart';
import 'package:flutter/material.dart';

import '../../../model/chat_message.dart';

/// Chat screen controller. Uses GetX (existing state management).
/// Backend plug-in: replace [messages] with API/WebSocket stream; call [addMessage]
/// when new messages arrive. Real-time: subscribe to channel in [onInit], dispose in [onClose].
class ChatController extends GetxController {
  ChatController();

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final replyTo = Rxn<ChatMessage>();
  final pendingImagePaths = <String>[].obs;

  /// WhatsApp-like multiselect: only self (outgoing) messages can be selected for delete.
  final isSelectionMode = false.obs;
  final selectedMessageIds = <String>[].obs;

  Timer? _typingTimer;

  @override
  void onInit() {
    super.onInit();
    _loadMockMessages();
    // Backend/real-time: e.g. Firebase/WebSocket listener that calls addMessage() on new message.
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }

  void _loadMockMessages() {
    messages.assignAll(_mockMessages());
  }

  /// Local mock data. Replace with API fetch or real-time stream.
  static List<ChatMessage> _mockMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        text: 'Hi! When is the cleaning scheduled?',
        isOutgoing: false,
        timestamp: now.subtract(const Duration(minutes: 12)),
        isRead: true,
        imageUrl: 'assets/images/dummy.jpg',
      ),
      ChatMessage(
        id: '2',
        text: 'Tomorrow at 10 AM. I\'ll bring supplies.',
        isOutgoing: true,
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        text: 'Perfect, thanks 👍',
        isOutgoing: false,
        timestamp: now.subtract(const Duration(minutes: 8)),
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        text: 'See you then!',
        isOutgoing: true,
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty && pendingImagePaths.isEmpty) return;

    final reply = replyTo.value;
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.isEmpty ? '(Image)' : text,
      isOutgoing: true,
      timestamp: DateTime.now(),
      imageUrl: pendingImagePaths.isNotEmpty ? pendingImagePaths.first : null,
      replyToId: reply?.id,
      replyToPreview: reply?.text,
    );
    addMessage(msg);
    textController.clear();
    pendingImagePaths.clear();
    clearReplyTo();
    _scrollToBottom();
    // Backend: POST message to API or send via WebSocket.
  }

  void addMessage(ChatMessage msg) {
    messages.insert(0, msg);
  }

  void deleteMessage(ChatMessage msg) {
    messages.removeWhere((m) => m.id == msg.id);
    selectedMessageIds.remove(msg.id);
    // Backend: DELETE message API or emit via WebSocket.
  }

  void deleteSelectedMessages() {
    final ids = selectedMessageIds.toSet();
    messages.removeWhere((m) => m.isOutgoing && ids.contains(m.id));
    selectedMessageIds.clear();
    isSelectionMode.value = false;
    // Backend: DELETE messages API or emit via WebSocket.
  }

  bool isSelected(ChatMessage msg) => selectedMessageIds.contains(msg.id);

  void toggleMessageSelection(ChatMessage msg) {
    if (!msg.isOutgoing) return;
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
      selectedMessageIds.add(msg.id);
    } else {
      if (selectedMessageIds.contains(msg.id)) {
        selectedMessageIds.remove(msg.id);
        if (selectedMessageIds.isEmpty) isSelectionMode.value = false;
      } else {
        selectedMessageIds.add(msg.id);
      }
    }
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedMessageIds.clear();
  }

  void setReplyTo(ChatMessage? msg) {
    replyTo.value = msg;
  }

  void clearReplyTo() {
    replyTo.value = null;
  }

  void addPendingImage(String path) {
    if (pendingImagePaths.length < 5) pendingImagePaths.add(path);
  }

  void removePendingImage(String path) {
    pendingImagePaths.remove(path);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showTypingIndicator() {
    isTyping.value = true;
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      isTyping.value = false;
    });
  }

  void hideTypingIndicator() {
    isTyping.value = false;
    _typingTimer?.cancel();
  }
}
