import 'dart:async';

import 'package:ccs_app/export.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;

import '../../../model/chat_message.dart';
import '../../../network/repository/common_repository.dart';
import '../../../services/pref.dart';
import '../../../utils/fire_ref.dart';

class ChatController extends GetxController {
  ChatController();

  final CommonRepository _commonRepository = CommonRepository();

  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final replyTo = Rxn<ChatMessage>();
  final pendingImagePaths = <String>[].obs;
  final isSelectionMode = false.obs;
  final selectedMessageIds = <String>[].obs;
  final isEmojiPickerVisible = false.obs;
  final isLoading = false.obs;
  final canSend = false.obs;
  var isNetworkConnected = true.obs;
  RxList<String> imageUrl = <String>[].obs;

  late final ChatMode chatMode;
  late final String chatKey;

  ChatJob? chatJob;
  Map<String, ChatParticipant> participants = {};
  final headerTitle = 'Chat'.obs;
  final headerSubtitle = ''.obs;

  Timer? _typingTimer;
  StreamSubscription? _newMessageSub;
  static const int _pageSize = 50;
  bool _initialLoadDone = false;
  String _effectiveUserId = '';
  String _effectiveUserName = '';
  String type = '';

  @override
  Future<void> onInit() async {
    super.onInit();

    Connectivity().onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });

    _checkConnectivity();

    final prefsId = Prefs().userId;
    final prefsName = Prefs().userFullName;
    _effectiveUserId = prefsId.isNotEmpty ? prefsId : 'user_${DateTime.now().millisecondsSinceEpoch}';
    _effectiveUserName = prefsName.isNotEmpty ? prefsName : 'Me';

    final args = Get.arguments as Map<String, dynamic>? ?? {};

    type = args['type'];

    if (type == ChatConstants.typeSupport) {
      chatMode = ChatMode.support;
      chatKey = _effectiveUserId;
      headerTitle.value = 'Support';
      headerSubtitle.value = 'Message admin';
      _initSupportChat();
    } else if (type == ChatConstants.typeNotification) {
      chatMode = ChatMode.job;
      chatKey = (args['jobId'] ?? '').toString();
      initChatFromFirebase();
      headerTitle.value = chatJob?.jobType ?? 'Job Chat';
      headerSubtitle.value = chatJob?.propertyOneLine ?? '';
      _initJobChat();
    } else {
      chatMode = ChatMode.job;
      chatKey = (args['jobId'] ?? '').toString();

      if (args['job'] is ChatJob) {
        chatJob = args['job'] as ChatJob;
      }
      if (args['participants'] is Map<String, ChatParticipant>) {
        participants = Map<String, ChatParticipant>.from(args['participants'] as Map);
      }

      headerTitle.value = chatJob?.jobType ?? 'Job Chat';
      headerSubtitle.value = chatJob?.propertyOneLine ?? '';
      _initJobChat();
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) hideEmojiPicker();
    });
    textController.addListener(_updateCanSend);
    scrollController.addListener(_onScroll);
  }

  void _updateCanSend() {
    canSend.value = textController.text.trim().isNotEmpty || pendingImagePaths.isNotEmpty;
  }

  void initChatFromFirebase() {
    FireRef.jobChats.child(chatKey).once().then((value) {
      if (value.snapshot.hasChild('job')) {
        chatJob = ChatJob.fromSnapshot(value.snapshot.child('job'));
      }
      if (value.snapshot.hasChild('participants')) {
        value.snapshot.child('participants').children.forEach((item) {
          var member = ChatParticipant.fromSnapshot(item);
          participants[member.id] = member;
        });
      }
    });
  }

  @override
  void onClose() {
    updateStatus(false);
    _newMessageSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }

  DatabaseReference get _chatRef => chatMode == ChatMode.job ? FireRef.jobChats.child(chatKey) : FireRef.supportChats.child(chatKey);

  DatabaseReference get _messagesRef => _chatRef.child(MESSAGE_NODE);

  DatabaseReference get _chatListRef => chatMode == ChatMode.job ? FireRef.jobChatList : FireRef.supportChatList;

  Future _initJobChat() async {
    _ensureJobThread();
    _loadInitialMessages();
  }

  void _initSupportChat() {
    _ensureSupportThread();
    _loadInitialMessages();
  }

  Future _ensureJobThread() async {
    if (chatJob != null) {
      _chatRef.child(JOB_NODE).update(chatJob!.toJson()).catchError((_) {});
    }
    _ensureCurrentUserInParticipants();
    final validParticipants = participants.entries.where((e) => e.key.isNotEmpty);
    if (validParticipants.isNotEmpty) {
      final map = Map.fromEntries(validParticipants.map((e) => MapEntry(e.key, e.value.toJson())));

      final ref = _chatRef.child(PARTICIPANTS_NODE);

      final snapshot = await ref.get();
      final existing = snapshot.value as Map? ?? {};

      final hasChange = map.entries.any(
        (e) => existing[e.key] != e.value,
      );

      if (hasChange) {
        await ref.update(map);
        updateStatus(true);
      }

      /* final map = Map.fromEntries(validParticipants.map((e) => MapEntry(e.key, e.value.toJson())));
      _chatRef.child(PARTICIPANTS_NODE).update(map).then((onValue){
        updateStatus(true);
      }).catchError((_) {});*/
    }

  }

  void _ensureCurrentUserInParticipants() {
    if (!participants.containsKey(_effectiveUserId)) {
      participants[_effectiveUserId] = ChatParticipant(
        id: _effectiveUserId,
        name: _effectiveUserName,
        role: Prefs().userRoleString,
      );
    }
  }

  Future<void> _ensureSupportThread() async {
    final userRole = Prefs().userRoleString;

    final supportParticipants = <String, ChatParticipant>{
      _effectiveUserId: ChatParticipant(id: _effectiveUserId, name: _effectiveUserName, role: userRole),
      supportAdminUserId: ChatParticipant(
        id: supportAdminUserId,
        name: supportAdminDisplayName,
        role: RoleConstants.roleKeyAdmin,
      ),
    };

    participants = supportParticipants;
    final map = supportParticipants.map((k, v) => MapEntry(k, v.toJson()));

    await _chatRef.child(PARTICIPANTS_NODE).update(map).catchError((_) {});

    updateStatus(true);

  }

  void _loadInitialMessages() {
    _messagesRef.orderByKey().limitToLast(_pageSize).once().then((event) {
      final List<ChatMessage> fetched = [];
      for (final child in event.snapshot.children) {
        fetched.add(ChatMessage.fromSnapshot(child));
      }
      messages.assignAll(fetched.reversed.toList());
      _initialLoadDone = true;
      _listenForNewMessages();
    }).catchError((e) {
      _initialLoadDone = true;
      _listenForNewMessages();
    });
  }

  void _listenForNewMessages() {
    _newMessageSub?.cancel();

    Query query = _messagesRef.orderByKey();
    if (messages.isNotEmpty) {
      query = query.startAfter(messages.first.id);
    }

    _newMessageSub = query.onChildAdded.listen((event) {
      final msg = ChatMessage.fromSnapshot(event.snapshot);
      if (!messages.any((m) => m.id == msg.id)) {
        messages.insert(0, msg);
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && messages.isNotEmpty && !isLoading.value && _initialLoadDone) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    if (isLoading.value || messages.isEmpty) return;
    isLoading.value = true;
    final oldestKey = messages.last.id;

    _messagesRef.orderByKey().endBefore(oldestKey).limitToLast(_pageSize).once().then((event) {
      if (event.snapshot.children.isNotEmpty) {
        final older = <ChatMessage>[];
        for (final child in event.snapshot.children) {
          older.add(ChatMessage.fromSnapshot(child));
        }
        messages.addAll(older.reversed);
      }
    }).whenComplete(() {
      isLoading.value = false;
    });
  }

  Future<void> uploadImages() async {
    Get.context!.hideKeyboard();

    if (pendingImagePaths.isNotEmpty) {
      Loader.show();

      List<dio.MultipartFile> files = [];

      for (var path in pendingImagePaths) {
        var value = await dio.MultipartFile.fromFile(
          path,
          filename: "image_${DateTime.now()}.jpg",
        );

        files.add(value);
      }

      final data = <String, dynamic>{};
      data["files[]"] = files;
      data["mediaable_type"] = 'App\\Models\\chat';
      data["mediaable_id"] = '1';
      data["media_type"] = 'chat';

      log(runtimeType.toString(), 'Media Upload Data => $data');

      var result = await _commonRepository.mediaUpload(data);
      result.handle(
        success: (value) {
          Loader.hide();

          final data = value.data;

          imageUrl.assignAll(data?.fileUrl as Iterable<String>);
        },
        onError: (_) {
          Loader.hide();
        },
        contextTag: 'media-upload',
      );
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty && pendingImagePaths.isEmpty) return;

    var userId = Prefs().userId;
    var userName = Prefs().userFullName;
    if (userId.isEmpty) userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    if (userName.isEmpty) userName = 'Me';

    final userRole = Prefs().userRoleString;
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final reply = replyTo.value;

    final isImageMsg = pendingImagePaths.isNotEmpty && text.isEmpty;

    List<String> urls = [];

    if (type != ChatConstants.typeSupport) {
      final inactiveUsers = await fetchInactiveUserList();

      inactiveUsers.removeWhere((element) => element == _effectiveUserId.toInt());

      if (inactiveUsers.isNotEmpty) sendNotification(inactiveUsers, isImageMsg, text);
    } else {
      final adminsIds = Prefs().getAdminsIds();

      sendNotification(adminsIds, isImageMsg, text);
    }

    // ✅ Upload images if needed
    if (isImageMsg) {
      try {
        await uploadImages();
        urls = imageUrl; // assuming this is List<String>
        if (urls.isEmpty) {
          _showSendError();
          return;
        }
      } catch (_) {
        _showSendError();
        return;
      }
    }

    // ✅ Insert date message once (not inside loop)
    Future<void> insertDateIfNeeded() async {
      if (_shouldInsertDateMessage()) {
        final dateKey = _messagesRef.push().key;
        if (dateKey != null) {
          final dateMsg = ChatMessage(
            id: '',
            text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            type: ChatConstants.messageTypeDate,
            timeStamp: time,
            senderId: '',
            senderName: '',
            senderRole: '',
          );
          await _messagesRef.child(dateKey).set(dateMsg.toJson());
        }
      }
    }

    await insertDateIfNeeded();

    // ✅ Helper to send one message
    Future<void> sendSingleMessage(String? url) async {
      final message = ChatMessage(
        id: '',
        text: text.isEmpty ? '(Image)' : text,
        type: isImageMsg ? ChatConstants.messageTypeImage : ChatConstants.messageTypeText,
        timeStamp: time,
        senderId: userId,
        senderName: userName,
        senderRole: userRole,
        imageUrl: url,
        replyToId: reply?.id,
        replyToPreview: reply?.text,
      );

      final key = _messagesRef.push().key;
      if (key == null) {
        _showSendError();
        return;
      }

      try {
        await _messagesRef.child(key).set(message.toJson());
        _updateChatList(message);
      } catch (_) {
        _showSendError();
      }
    }

    // ✅ Send messages
    if (isImageMsg) {
      for (final url in urls) {
        await sendSingleMessage(url);
      }
    } else {
      await sendSingleMessage(
        imageUrl.isNotEmpty ? imageUrl.first : null,
      );
    }

    // ✅ Clear UI ONCE (not inside loop)
    textController.clear();
    pendingImagePaths.clear();
    imageUrl.clear();
    clearReplyTo();
    _updateCanSend();
    _scrollToBottom();
  }

  Future<void> sendNotification(List<int> inactiveUsers, bool msgTypeImage, String msg) async {
    final data = <String, dynamic>{};
    data["receiver_ids[]"] = inactiveUsers;
    data["sender_id"] = Prefs().userId;
    data["title"] = Prefs().userFullName.isEmpty ? "New Message Received" : Prefs().userFullName;
    data["message"] = msgTypeImage ? '📷 Image received' : msg;
    data["flag"] = 'chat';
    data["message_type"] = msgTypeImage ? 'chat_image' : 'chat_text';
    data["related_id"] = chatJob?.id;

    log(runtimeType.toString(), 'Media Upload Data => $data');

    _commonRepository.sendNotification(data);
  }

  bool _shouldInsertDateMessage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (messages.isEmpty) return true;
    final lastMsgDate = messages.first.timestamp;
    final lastDay = DateTime(lastMsgDate.year, lastMsgDate.month, lastMsgDate.day);
    return today != lastDay;
  }

  void _showSendError() {
    Get.snackbar('Send failed', 'Could not send message. Check connection and try again.');
  }

  void _updateChatList(ChatMessage lastMessage) {
    final validParticipants = participants.entries.where((e) => e.key.isNotEmpty);
    final participantsJson = Map.fromEntries(validParticipants.map((e) => MapEntry(e.key, e.value.toJson())));
    final chatListData = <String, dynamic>{
      'type': chatMode.asType,
      'lastMessage': lastMessage.toJson(),
      'participants': participantsJson,
    };

    if (chatMode == ChatMode.job && chatJob != null) {
      chatListData['job'] = chatJob!.toJson();
    }

    for (final participantId in participants.keys) {
      if (participantId.isEmpty) continue;
      _chatListRef.child(participantId).child(chatKey).update(chatListData).catchError((_) {});
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  void deleteMessage(ChatMessage msg) {
    _messagesRef.child(msg.id).remove().catchError((_) {});
    messages.removeWhere((m) => m.id == msg.id);
    selectedMessageIds.remove(msg.id);
  }

  void deleteSelectedMessages() {
    final ids = selectedMessageIds.toSet();
    for (final id in ids) {
      _messagesRef.child(id).remove().catchError((_) {});
    }
    messages.removeWhere((m) => isOutgoingMessage(m) && ids.contains(m.id));
    selectedMessageIds.clear();
    isSelectionMode.value = false;
  }

  bool isSelected(ChatMessage msg) => selectedMessageIds.contains(msg.id);

  bool isOutgoingMessage(ChatMessage msg) => msg.senderId == _effectiveUserId;

  void toggleMessageSelection(ChatMessage msg) {
    if (!isOutgoingMessage(msg)) return;
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

  void setReplyTo(ChatMessage? msg) => replyTo.value = msg;

  void clearReplyTo() => replyTo.value = null;

  void addPendingImage(String path) {
    if (pendingImagePaths.length < 5) pendingImagePaths.add(path);
    _updateCanSend();
  }

  void removePendingImage(String path) {
    pendingImagePaths.remove(path);
    _updateCanSend();
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

  void toggleEmojiPicker() {
    isEmojiPickerVisible.value = !isEmojiPickerVisible.value;
    if (isEmojiPickerVisible.value) focusNode.unfocus();
  }

  void hideEmojiPicker() => isEmojiPickerVisible.value = false;

  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void updateStatus(bool isActive) {
    try {
      _chatRef.child(PARTICIPANTS_NODE).child(_effectiveUserId).update({'isActive': isActive});
      log(runtimeType.toString(), 'Update Updated:');
    } catch (e) {
      log(runtimeType.toString(), 'Update failed: $e');
    }
  }

  /*void addAndUpdateUser(bool isActive) {
    var userId = Prefs().userId;
    var userName = Prefs().userFullName;
    if (userId.isEmpty) userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    if (userName.isEmpty) userName = 'Me';

    final userRole = Prefs().userRoleString;
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final userData = <String, dynamic>{'userId': userId, 'userName': userName, 'userRole': userRole, 'isActive': isActive, 'time': time};

    _userListRef.child(userId).update(userData).catchError((_) {});

    print('USER DATA UPDATED');
  }*/

  Future<List<int>> fetchInactiveUserList() async {
    final snapshot = await _chatRef.child(PARTICIPANTS_NODE).get();

    if (!snapshot.exists || snapshot.value == null) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final userList = data.values
        .whereType<Map>() // ensures safe casting
        .map((e) => Map<String, dynamic>.from(e))
        .where((user) => user['isActive'] != true)
        .map((user) => int.tryParse(user['id']?.toString() ?? ''))
        .whereType<int>() // removes nulls
        .toList();

    return userList;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    isNetworkConnected.value = results.any(
      (result) => result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet,
    );
  }
}
