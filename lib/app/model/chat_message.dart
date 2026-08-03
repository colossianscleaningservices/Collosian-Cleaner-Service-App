import 'package:firebase_database/firebase_database.dart';

import '../constants/chat_constants.dart';
import '../services/pref.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.timeStamp,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.imageUrl,
    this.replyToId,
    this.replyToPreview,
    this.isRead = false,
  });

  final String id;
  final String text;
  final String type;
  final String timeStamp;
  final String senderId;
  final String senderName;
  final String senderRole;
  String? imageUrl;
  final String? replyToId;
  final String? replyToPreview;
  final bool isRead;

  bool get isOutgoing => senderId == Prefs().getData(Prefs.id);

  DateTime get timestamp {
    final ms = int.tryParse(timeStamp) ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Map<String, dynamic> toJson() => {
        'msg': text,
        'type': type,
        'timeStamp': timeStamp,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (replyToId != null) 'replyToId': replyToId,
        if (replyToPreview != null) 'replyToPreview': replyToPreview,
        'isRead': isRead,
      };

  factory ChatMessage.fromJson(dynamic json, String id) {
    return ChatMessage(
      id: id,
      text: (json['msg'] ?? '').toString(),
      type: (json['type'] ?? ChatConstants.messageTypeText).toString(),
      timeStamp: (json['timeStamp'] ?? '0').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      replyToId: json['replyToId']?.toString(),
      replyToPreview: json['replyToPreview']?.toString(),
      isRead: json['isRead'] == true,
    );
  }

  factory ChatMessage.fromSnapshot(DataSnapshot snapshot) {
    return ChatMessage.fromJson(snapshot.value, snapshot.key ?? '');
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    String? type,
    String? timeStamp,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? imageUrl,
    String? replyToId,
    String? replyToPreview,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      timeStamp: timeStamp ?? this.timeStamp,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      imageUrl: imageUrl ?? this.imageUrl,
      replyToId: replyToId ?? this.replyToId,
      replyToPreview: replyToPreview ?? this.replyToPreview,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ChatParticipant {
  ChatParticipant({
    required this.id,
    required this.name,
    required this.role,
    this.isActive ,
    this.image,
  });

  final String id;
  final String name;
  final String role;
  final bool? isActive;
  final String? image;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'isActive': isActive,
        if (image != null) 'image': image,
      };

  factory ChatParticipant.fromJson(dynamic json, String id) {
    return ChatParticipant(
      id: id,
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      isActive: (json['isActive'] ?? false),
      image: json['image']?.toString(),
    );
  }

  factory ChatParticipant.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>?;

    return ChatParticipant(
      id: snapshot.key ?? '',
      name: (json?['name'] ?? '').toString(),
      role: (json?['role'] ?? '').toString(),
      isActive: json?['isActive']?? false ,
      image: json?['image']?.toString(),
    );
  }
}

class ChatJob {
  ChatJob({
    required this.id,
    this.jobType,
    this.propertyOneLine,
    this.date,
    this.clientName,
  });

  final String id;
  final String? jobType;
  final String? propertyOneLine;
  final String? date;
  final String? clientName;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (jobType != null) 'jobType': jobType,
        if (propertyOneLine != null) 'propertyOneLine': propertyOneLine,
        if (date != null) 'date': date,
        if (clientName != null) 'clientName': clientName,
      };

  factory ChatJob.fromJson(dynamic json) {
    return ChatJob(
      id: (json['id'] ?? '').toString(),
      jobType: json['jobType']?.toString(),
      propertyOneLine: json['propertyOneLine']?.toString(),
      date: json['date']?.toString(),
      clientName: json['clientName']?.toString(),
    );
  }

  factory ChatJob.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>? ?? {};
    return ChatJob(
      id: (json['id']??'').toString(),
      jobType: json['jobType']?.toString(),
      propertyOneLine: json['propertyOneLine']?.toString(),
      date: json['date']?.toString(),
      clientName: json['clientName']?.toString(),
    );
  }
}

class ChatThread {
  ChatThread({
    required this.threadKey,
    required this.type,
    this.participants = const {},
    this.job,
    this.lastMessage,
    this.unReadCount = 0,
  });

  final String threadKey;
  final String type;
  final Map<String, ChatParticipant> participants;
  final ChatJob? job;
  final ChatMessage? lastMessage;
  final int unReadCount;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'participants': participants.map((k, v) => MapEntry(k, v.toJson())),
      if (job != null) 'job': job!.toJson(),
      if (lastMessage != null) 'lastMessage': lastMessage!.toJson(),
      'unReadCount': unReadCount,
    };
  }

  factory ChatThread.fromJson(dynamic json, String threadKey) {
    final participantsMap = <String, ChatParticipant>{};
    if (json['participants'] is Map) {
      (json['participants'] as Map).forEach((key, value) {
        participantsMap[key.toString()] = ChatParticipant.fromJson(value, key.toString());
      });
    }

    return ChatThread(
      threadKey: threadKey,
      type: (json['type'] ?? ChatConstants.typeJob).toString(),
      participants: participantsMap,
      job: json['job'] != null ? ChatJob.fromJson(json['job']) : null,
      lastMessage: json['lastMessage'] != null ? ChatMessage.fromJson(json['lastMessage'], '') : null,
      unReadCount: int.tryParse((json['unReadCount'] ?? '0').toString()) ?? 0,
    );
  }
}
