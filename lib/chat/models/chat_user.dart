//class extention
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/chat/models/message.dart';
import 'package:homerental/chat/models/userchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUserModel {
  ChatUserModel(
      {this.chatState = ChatState.done, this.chatStateLoad = ChatState.done});
  UserChat? user;
  UserChat? member;
  String? groupChatId;
  String? id;
  String? peerId;
  String? peerAvatar;
  List<QueryDocumentSnapshot> documents = [];
  String? peerName;
  String? peerEmail;
  Message? message;
  ChatState chatState;
  ChatState chatStateLoad;
}
