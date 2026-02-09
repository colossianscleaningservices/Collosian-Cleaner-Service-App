// ignore_for_file: constant_identifier_names

import 'package:firebase_database/firebase_database.dart';

class FireRef {
  static final dbRef = FirebaseDatabase.instance.ref();

  static final jobChats = dbRef.child(JOB_CHATS);
  static final jobChatList = dbRef.child(JOB_CHAT_LIST);

  static final supportChats = dbRef.child(SUPPORT_CHATS);
  static final supportChatList = dbRef.child(SUPPORT_CHAT_LIST);

  static final users = dbRef.child(USERS_NODE);
}

const JOB_CHATS = 'job_chats';
const JOB_CHAT_LIST = 'job_chat_list';

const SUPPORT_CHATS = 'support_chats';
const SUPPORT_CHAT_LIST = 'support_chat_list';

const USERS_NODE = 'users';
const MESSAGE_NODE = 'messages';
const PARTICIPANTS_NODE = 'participants';
const JOB_NODE = 'job';
