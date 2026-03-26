// ignore_for_file: constant_identifier_names

class ChatConstants {
  ChatConstants._();

  static const String typeJob = 'job';
  static const String typeNotification = 'notification';
  static const String typeSupport = 'support';

  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeSystem = 'system';
  static const String messageTypeDate = 'date';
}

enum ChatMode {
  job,
  support,
}

extension ChatModeX on ChatMode {
  String get asType => this == ChatMode.job ? ChatConstants.typeJob : ChatConstants.typeSupport;
}

ChatMode chatModeFromType(String? type) {
  if (type == ChatConstants.typeSupport) return ChatMode.support;
  return ChatMode.job;
}

const String supportAdminUserId = 'admin';
const String supportAdminDisplayName = 'Support';
