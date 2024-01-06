import 'package:badges/badges.dart' as badges;
import 'package:homerental/chat/models/ext_chat_message.dart';
import 'package:homerental/chat/models/userchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/chat/controller/chat_controller.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/chat/widgets/photo_hero.dart';
import 'package:homerental/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageRow extends StatefulWidget {
  final ExtChatMessage extChat;
  const MessageRow({Key? key, required this.extChat}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MessageRow();
  }
}

class ItemExtMessage {
  ItemExtMessage();
  ExtChatMessage? item;
}

class _MessageRow extends State<MessageRow> {
  final XController x = XController.to;
  FirebaseFirestore get firestore => x.chatController.firestore;

  ExtChatMessage? item;
  //_MessageRow({this.item});

  bool isRefresh = false;
  static const tAG = "MessageRow";
  int unRead = 0;

  @override
  void initState() {
    super.initState();

    item = widget.extChat;

    String groupChatId = item!.groupChatId!;
    logPrint("$tAG groupChatID: $groupChatId");

    Future.delayed(const Duration(milliseconds: 100), () {
      setListenerMessageGroupChatId();
    });
  }

  setListenerMessageGroupChatId() {
    String groupChatId = item!.groupChatId!;
    ChatMessage firstMessage;

    firestore
        .collection(ChatController.tAGMESSAGECHAT)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      //logPrint("length: ${snapshot.docs.length}");
      //logPrint("first doc: ${snapshot.docs.first.data()}");
      if (snapshot.docs.isNotEmpty && snapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
        if (doc.id.isNotEmpty) {
          firstMessage = ChatMessage.fromJson(doc.data());
          if (!firstMessage.customProperties!['isRead']) {
            var isOnChatScreen = x.myPref.pOnChatScreen.val;
            //logPrint("isOnChatScreen: $isOnChatScreen");
            if (isOnChatScreen == 'onChatScreen') {
            } else {
              unRead = unRead + 1;
            }
          }

          try {
            if (mounted) {
              setState(() {
                item = ExtChatMessage(
                    lastMessage: firstMessage,
                    unRead: unRead,
                    groupChatId: groupChatId);
              });
            }
          } catch (e) {
            debugPrint("");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupSplit = item!.groupChatId!.split("-");
    final ChatMessage chat = item!.lastMessage!;
    final bool isImage = chat.image != null;
    final String thisUserId = x.userLogin.value.user!.uid;
    bool isMe = chat.user.uid == thisUserId;
    final UserChat? userChat = x.getUserChatById(
        groupSplit[0] == thisUserId ? groupSplit[1] : groupSplit[0]);

    //logPrint(userChat!.toJson());

    bool isRead = false;
    if (chat.customProperties != null &&
        chat.customProperties!['isRead'] != null) {
      isRead = chat.customProperties!['isRead'];
    }

    String photoUrl = "";
    if (userChat != null) {
      if (userChat.photoUrl != null && userChat.photoUrl != '') {
        photoUrl = userChat.photoUrl!;
      }
    }

    String timeagoo = "";
    int diff = 10000;
    try {
      //logPrint(chat.customProperties);
      DateTime dateUpdate = DateTime.fromMillisecondsSinceEpoch(
        chat.customProperties!['updatedAt'],
      ).toLocal();
      timeagoo = timeago.format(dateUpdate);

      DateTime dateUpdateUser = DateTime.fromMillisecondsSinceEpoch(
        int.parse(userChat!.updatedAt!),
      ).toLocal();
      diff = DateTime.now().difference(dateUpdateUser).inMinutes;
    } catch (e) {
      logPrint("errr $e");
    }

    final thisStyle = TextStyle(
        fontWeight:
            (unRead > 0 && !isMe) ? FontWeight.bold : FontWeight.normal);

    return InkWell(
      onTap: () {
        setState(() {
          unRead = 0;
        });

        x.gotoChatApp(userChat!);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 6, bottom: 15),
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 5,
          left: 12,
          right: 8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(22),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Stack(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            if (photoUrl.isNotEmpty && photoUrl != '') {
                              Get.to(
                                MyTheme.photoView(photoUrl),
                                transition: Transition.zoom,
                              );
                            }
                          },
                          child: (photoUrl.isEmpty || photoUrl == '')
                              ? const CircleAvatar(
                                  radius: 25,
                                  backgroundImage: AssetImage(
                                    "assets/avatar_red.jpg",
                                  ),
                                )
                              : SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: PhotoHero(
                                      photo: photoUrl,
                                      //isHero: true,
                                      onTap: () {
                                        Get.to(
                                          MyTheme.photoView(photoUrl),
                                          transition: Transition.zoom,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (diff < 10)
                        Positioned(
                          right: 10,
                          bottom: 5,
                          child: badges.Badge(
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: Colors.lightGreen,
                            ),
                            position:
                                badges.BadgePosition.topEnd(top: 10, end: 10),
                            badgeContent: null,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      spaceHeight10,
                      Text(userChat!.nickname!, style: textBold),
                      isImage
                          ? Row(
                              children: [
                                Icon(Feather.image,
                                    size: 16,
                                    color: (unRead > 0 && !isMe)
                                        ? Colors.black
                                        : Colors.black54),
                                Container(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Image",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: thisStyle.copyWith(
                                        color: (unRead > 0 && !isMe)
                                            ? Colors.black
                                            : Colors.black54),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: Get.width / 2.0,
                              child: Text(
                                "${chat.text}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textNormal.copyWith(
                                    fontWeight: (unRead > 0 && !isMe)
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            ),
                      spaceHeight20,
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(timeagoo,
                        style: textSmall.copyWith(
                            fontSize: 11, color: colorGrey2)),
                    Row(
                      children: [
                        if (isMe)
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: Icon(
                              isRead ? Icons.done_all : Icons.done,
                              color: isRead ? Colors.green[600] : Colors.red,
                              size: 14,
                            ),
                          ),
                        Text(
                            DateFormat('HH:mm').format(
                              chat.createdAt.toLocal(),
                            ),
                            style: textNormal.copyWith(
                                color: Get.theme.colorScheme.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (unRead > 0 && !isMe)
                Positioned(
                  right: 0,
                  top: 5,
                  child: badges.Badge(
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.redAccent,
                    ),
                    position: badges.BadgePosition.topEnd(top: 10, end: 10),
                    badgeContent: Text("${unRead > 10 ? '10+' : unRead}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
