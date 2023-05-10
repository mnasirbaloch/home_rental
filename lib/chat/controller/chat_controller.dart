// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:homerental/chat/models/ext_chat_message.dart';
import 'package:homerental/chat/models/ext_message.dart';
import 'package:homerental/chat/models/message.dart';
import 'package:homerental/chat/models/userchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/models/user_model.dart';
import 'package:homerental/theme.dart';

class ChatController {
  ChatController._internal() {
    logPrint("ChatController._internal...");
    //init();
  }

  static final ChatController _instance = ChatController._internal();
  static ChatController get instance => _instance;

  static const tAGUSERCHAT = "userschat";
  static const tAGMESSAGECHAT = "messageschat";
  static const lASTCHATS = "_pref_last";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  final FirebaseStorage _fireStorage = FirebaseStorage.instance;
  FirebaseStorage get fireStorage => _fireStorage;

  checkUserExistOrNot(final XController x, final User? firebaseUser,
      final UserModel userModel) async {
    try {
      _thisUser = firebaseUser;

      //logPrint("_thisUser: $thisUser");
      //logPrint("uid firebase : ${firebaseUser!.uid}");
      //logPrint("userModel: ${userModel.toJson()}");

      // Check is already sign up
      final QuerySnapshot result = await firestore
          .collection(tAGUSERCHAT)
          .where('id', isEqualTo: firebaseUser!.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;

      String phone = userModel.phone ?? "";
      if (phone != '' && phone.length > 2 && phone.substring(0, 1) == "0") {
        phone = "+62${phone.substring(1)}";
      }
      String nickname = userModel.fullname ?? "";

      if (documents.isEmpty) {
        var jsonUser = {
          'nickname': nickname,
          'photoUrl': userModel.image ?? firebaseUser.photoURL,
          'id': userModel.uidFcm,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'aboutMe': null,
          'location': x.latitude,
          'tipe': "1",
          'token': x.myPref.pTokenFCM.val,
          'phoneNumber': phone,
          'email': firebaseUser.email
        };

        //logPrint(jsonUser);
        // Update data to server if new user
        firestore.collection(tAGUSERCHAT).doc(firebaseUser.uid).set(jsonUser);
      } else {
        updateUserFirebaseByToken(x, userModel);
      }
    } catch (e) {
      logPrint("Error checkUserExistOrNot $e");
    }

    getAllUserChatFirebase(x, x.thisUser.value);
  }

  bool isProcessUpdateUser = false;
  User? _thisUser;
  User get thisUser => _thisUser!;

  updateUserFirebaseByToken(final XController x, final UserModel userModel) {
    if (isProcessUpdateUser) return;

    isProcessUpdateUser = true;
    Future.delayed(const Duration(seconds: 30), () {
      isProcessUpdateUser = false;
    });

    try {
      if (_thisUser == null || _thisUser!.uid.isEmpty || userModel.id == null) {
        return;
      }

      String phone = userModel.phone ?? "";
      if (phone != '' && phone.length > 2 && phone.substring(0, 1) == "0") {
        phone = "+62${phone.substring(1)}";
      }

      String imageUser = userModel.image!;

      var jsonUser = {
        'nickname': userModel.fullname,
        'photoUrl': imageUser,
        'location': x.latitude,
        'tipe': "1",
        'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'phoneNumber': phone,
        'token': x.myPref.pTokenFCM.val
      };

      logPrint(jsonUser);
      logPrint("UID USER Firebase: ${_thisUser!.uid}");
      firestore.collection(tAGUSERCHAT).doc(_thisUser!.uid).update(jsonUser);
    } catch (e) {
      logPrint("Error updateUserFirebaseByToken: $e");
    }
  }

  // functions
  bool isProcessGetUser = false;
  getAllUserChatFirebase(final XController x, final UserModel userModel) async {
    logPrint(
        "getAllUserChatFirebase is ${isProcessGetUser ? 'waiting' : 'running'}...");

    if (isProcessGetUser) return;
    Future.delayed(const Duration(seconds: 10), () {
      isProcessGetUser = false;
    });

    isProcessGetUser = true;

    if (userModel.uidFcm!.isEmpty) {
      return;
    }

    //_userChats = [];
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection(tAGUSERCHAT)
        .orderBy('updatedAt', descending: true)
        .limit(200)
        .get();
    List<UserChat> datauserChats = [];

    querySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>>? doc) {
      if (doc != null) {
        String uidUserLogin = x.thisUser.value.uidFcm!;
        if (uidUserLogin != doc["id"].toString()) {
          datauserChats.add(UserChat.fromData(doc.data()));
        }
      }
    });

    try {
      x.userLogin.update((val) {
        val!.userChats = datauserChats;
      });
    } catch (e) {
      logPrint("Error EXP2: $e");
    }

    //get for lastMessage
    if (datauserChats.isNotEmpty) {
      List<ExtChatMessage> dtmessageChats = [];
      List<ExtChatMessage> dttempMessageChats = [];

      datauserChats.forEach((userChat) async {
        String id = x.userLogin.value.user!.uid;
        String peerId = userChat.id!;
        String groupChatId = generateGroupChatId(id, peerId);

        final ExtChatMessage? lastMessag =
            await getLastChatMessageFromId(groupChatId);

        if (lastMessag != null && lastMessag.lastMessage != null) {
          dtmessageChats.add(lastMessag);
        }
      });

      await Future.delayed(const Duration(milliseconds: 5000));

      datauserChats.forEach((userChat) {
        String id = x.userLogin.value.user!.uid;
        String peerId = userChat.id!;
        String groupChatId = generateGroupChatId(id, peerId);

        dtmessageChats.forEach((msg) {
          if (msg.groupChatId == groupChatId) {
            dttempMessageChats.add(msg);
          }
        });
      });

      if (dttempMessageChats.isEmpty) {
        dttempMessageChats = dtmessageChats;
      }

      logPrint("_tempMessageChats length: ${dttempMessageChats.length}");

      if (dttempMessageChats.length > 1) {
        dttempMessageChats.sort((a, b) {
          DateTime dateUpdate = a.lastMessage!.createdAt;
          var adate = dateUpdate;

          DateTime nextDate = DateTime.now();
          if (b.lastMessage != null) {
            nextDate = b.lastMessage!.createdAt;
          }

          var bdate = nextDate;
          return -adate.compareTo(bdate);
        });
      }

      try {
        x.userLogin.update((val) {
          val!.userChats = datauserChats;
          val.userChatMessages = dttempMessageChats;
        });
      } catch (e) {
        logPrint("Error EXP4: $e");
      }

      if (dttempMessageChats.isNotEmpty) {
        List<dynamic> lastChats = [];

        dttempMessageChats.forEach((extMessage) {
          dynamic map = extMessage.toJson();
          lastChats.add(map);
        });
      }
    }

    logPrint("get all userchat length : ${datauserChats.length} ");
    logPrint(
        "userChatMessages.length ${x.userLogin.value.userChatMessages!.length}");
  }

  UserChat? getUserChatById(final XController x, String uid) {
    logPrint("uid $uid");
    try {
      List<UserChat>? userChats = x.userLogin.value.userChats!;
      UserChat? userChat;

      if (userChats.isNotEmpty) {
        userChat = userChats.firstWhere((user) => user.id == uid);
      }

      return userChat;
    } catch (e) {
      debugPrint("");
    }

    return null;
  }

  String generateGroupChatId(id, peerId) {
    String groupChatId = '$peerId-$id';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    }
    return groupChatId;
  }

  Future<ExtChatMessage>? getLastChatMessageFromId(String groupChatId) async {
    ExtChatMessage extMessage;
    ChatMessage? message;
    ChatMessage? firstMessage;
    int unRead = 0;

    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection(tAGMESSAGECHAT)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('createdAt', descending: true)
        .limit(11)
        .get();
    unRead = 0;
    int counter = 0;

    querySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>>? doc) {
      if (doc != null) {
        message = ChatMessage.fromJson(doc.data());
        if (counter == 0 && message != null) {
          firstMessage = message;
        }

        counter++;
        if (message != null && !message!.customProperties!['isRead']) {
          unRead++;
        }
      }
    });

    extMessage = ExtChatMessage(
        lastMessage: firstMessage, unRead: unRead, groupChatId: groupChatId);

    return extMessage;
  }

  Future<ExtMessage> getLastMessageFromId(String groupChatId) async {
    ExtMessage? extMessage;
    Message? message;
    Message? firstMessage;
    int unRead = 0;

    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection(tAGMESSAGECHAT)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(11)
        .get();
    unRead = 0;
    int counter = 0;

    querySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>>? doc) {
      if (doc != null) {
        message = Message.fromJson(doc.data());
        if (counter == 0 && message != null) {
          firstMessage = message;
        }

        counter++;
        if (message != null && !message!.isRead!) {
          unRead++;
        }
      }
    });

    extMessage = ExtMessage(
        lastMessage: firstMessage!, unRead: unRead, groupChatId: groupChatId);

    return extMessage;
  }

  Future<UserChat?> setUserLoginFirebaseById(
      final XController x, String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? userData =
          await firestore.collection(tAGUSERCHAT).doc(uid).get();
      Map<String, dynamic> data = userData.data()!;

      UserChat dtuser = UserChat.fromData(data);

      x.userLogin.update((val) {
        val!.userChat = dtuser;
      });

      return dtuser;
    } catch (e) {
      logPrint("Error: setUserLoginFirebaseById $e");
    }
    return null;
  }

  UserChat? getUserChatByEmail(final XController x, String email) {
    try {
      List<UserChat> userChats = x.userLogin.value.userChats!;
      return userChats.firstWhere((user) => user.email == email);
    } catch (e) {
      debugPrint("");
    }
    return null;
  }

  // delete messages
  Future<void> deleteMessageByGroupIdChatIdMessage(
      String groupIdChat, String idMessage) {
    CollectionReference messages = firestore.collection(tAGMESSAGECHAT);

    return messages
        .doc(groupIdChat)
        .collection(groupIdChat)
        .doc(idMessage)
        .delete()
        .then((value) => logPrint(
            "Message Deleted groupIdChat: $groupIdChat, idMessage: $idMessage"))
        .catchError((error) => logPrint("Failed to delete message: $error"));
  }

  Future<void> deleteMessageByGroupIdChat(
      final XController x, String groupIdChat) {
    List<UserChat> userChats = x.userLogin.value.userChats!;
    if (userChats.length == 1) {
      x.userLogin.update((val) {
        val!.userChats = null;
      });
    } else {
      List<UserChat> tempChats = [];
      for (var t = 0; t < userChats.length; t++) {
        UserChat user = userChats[t];
        if (user.id!.contains(groupIdChat)) {
        } else {
          tempChats.add(user);
        }
      }

      x.userLogin.update((val) {
        val!.userChats = tempChats;
      });
    }

    CollectionReference messages = firestore.collection(tAGMESSAGECHAT);

    return messages
        .doc(groupIdChat)
        .collection(groupIdChat)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in documentSnapshot.docs) {
          doc.reference.delete();
        }
      }
    });
  }
}
