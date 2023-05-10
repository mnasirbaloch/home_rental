import 'dart:convert';

import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/core/size_config.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/models/notif_model.dart';
import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/trans_model.dart';
import 'package:homerental/models/user_model.dart';
import 'package:homerental/pages/detail_rental.dart';
import 'package:homerental/screens/favorite_screen.dart';
import 'package:homerental/screens/history_screen.dart';
import 'package:homerental/screens/home_screen.dart';
import 'package:homerental/screens/profile_screen.dart';
import 'package:homerental/screens/search_screen.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/funky_notification.dart';
import 'package:intl/intl.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MyHome extends StatelessWidget {
  final XController x = XController.to;
  MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return WillPopScope(
      onWillPop: () => onBackPress(),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          //padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                mainBackgroundcolor,
                mainBackgroundcolor2,
                mainBackgroundcolor3,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Obx(() => switchWidget(x.indexBar.value)),
            extendBody: true,
            bottomNavigationBar: Obx(
              () => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DotNavigationBar(
                  boxShadow: const [
                    BoxShadow(
                      color: colorBoxShadow,
                      blurRadius: 1.0,
                      offset: Offset(1, 1),
                    )
                  ],
                  backgroundColor: Get.theme.primaryColor,
                  marginR:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                  paddingR: const EdgeInsets.only(bottom: 8, top: 5),
                  margin: const EdgeInsets.only(left: 10, right: 10, bottom: 0),
                  currentIndex: x.indexBar.value,
                  dotIndicatorColor: Get.theme.disabledColor,
                  selectedItemColor: Get.theme.canvasColor,
                  unselectedItemColor: Get.theme.colorScheme.background,
                  duration: const Duration(milliseconds: 300),
                  //enableFloatingNavBar: false,
                  onTap: (int index) {
                    x.setIndexBar(index);
                  },
                  items: [
                    /// Home
                    DotNavigationBarItem(
                      icon: const Icon(Icons.home),
                      //selectedColor: Color(0xff73544C),
                    ),

                    /// History
                    DotNavigationBarItem(
                      icon: const Icon(Icons.history),
                      //selectedColor: Color(0xff73544C),
                    ),

                    /// Likes
                    DotNavigationBarItem(
                      icon: const Icon(Icons.favorite),
                      //selectedColor: Color(0xff73544C),
                    ),

                    /// Search
                    DotNavigationBarItem(
                      icon: const Icon(Icons.search),
                      //selectedColor: Color(0xff73544C),
                    ),

                    /// Profile
                    DotNavigationBarItem(
                      icon: const Icon(Icons.person),
                      //selectedColor: Color(0xff73544C),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  switchWidget(final int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return HistoryScreen();
      case 2:
        return FavoriteScreen();
      case 3:
        return SearchScreen();
      case 4:
        return ProfileScreen();
      default:
        return HomeScreen();
    }
  }

  final _channel =
      const MethodChannel('com.erhacorpdotcom.homerental/app_retain');
  Future<bool> onBackPress() {
    debugPrint("onBackPress MyHome...");
    if (GetPlatform.isAndroid) {
      if (Navigator.of(Get.context!).canPop()) {
        return Future.value(true);
      } else {
        _channel.invokeMethod('sendToBackground');
        return Future.value(false);
      }
    } else {
      return Future.value(true);
    }
  }

  //static function
  static pushLikeOrDislike(
      final XController x, final RentalModel rental, final bool isLiked) {
    if (isLiked) {
      Future.microtask(() => x.likeOrDislike(rental.id, 'like'));
    } else {
      Future.microtask(() => x.likeOrDislike(rental.id, 'dislike'));
    }

    const int duration = 2000;
    final overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return FunkyNotification(
          text: isLiked ? "Liked It!" : "Dislike!",
          backgroundColor:
              isLiked ? Get.theme.primaryColor : Get.theme.disabledColor,
          duration: duration - 400,
        );
      },
    );
    final overlayState = Navigator.of(Get.context!).overlay;
    overlayState!.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: duration), () {
      overlayEntry.remove();
    });
  }

  //static dialog re-usabled
  static final TextEditingController _noteReview = TextEditingController();
  static final ratingReview = 2.5.obs;
  static showDialogInputReview(
      final XController x, final RentalModel rental, final UserModel user) {
    _noteReview.text = '';

    return showModalBottomSheet(
      barrierColor: Get.theme.disabledColor.withOpacity(.4),
      context: Get.context!,
      builder: (context) => Container(
        width: Get.width,
        height: Get.height / 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            topLeft: Radius.circular(15.0),
          ),
          gradient: LinearGradient(
            colors: [
              mainBackgroundcolor,
              mainBackgroundcolor2,
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.only(top: 15),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        margin: const EdgeInsets.only(top: 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(MyTheme.conerRadius),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "review".tr,
                                style:
                                    Get.theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RatingBar.builder(
                              initialRating: 2.5,
                              allowHalfRating: true,
                              minRating: 1,
                              direction: Axis.horizontal,
                              unratedColor: Colors.orange.withAlpha(50),
                              itemCount: 5,
                              itemSize: 30.0,
                              itemPadding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.orange,
                              ),
                              onRatingUpdate: (rating) {
                                ratingReview.value = rating;
                              },
                            ),
                          ],
                        ),
                      ),
                      spaceHeight20,
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              Get.theme.canvasColor,
                              Get.theme.canvasColor.withOpacity(.98)
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Get.theme.colorScheme.background,
                              blurRadius: 1.0,
                              offset: const Offset(1, 2),
                            )
                          ],
                        ),
                        child: SizedBox(
                          width: Get.width,
                          child: TextField(
                            controller: _noteReview,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 6,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "a_review".tr,
                            ),
                          ),
                        ),
                      ),
                      spaceHeight20,
                      spaceHeight10,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "close".tr,
                                  )
                                ],
                              ),
                            ),
                          ),
                          spaceWidth10,
                          InkWell(
                            onTap: () async {
                              String note = _noteReview.text.trim();
                              if (note.isEmpty) {
                                MyTheme.showToast('Note review invalid!');
                                return;
                              }

                              Get.back();
                              EasyLoading.show(status: 'Loading...');
                              x.postReview(
                                  rental.id!, note, ratingReview.value);
                              await Future.delayed(
                                  const Duration(milliseconds: 1800), () {
                                x.getRentReviewById(
                                    rental.id!, x.thisUser.value.id!);
                                x.asyncHome();
                              });

                              Future.delayed(const Duration(milliseconds: 800),
                                  () {
                                EasyLoading.showSuccess('Review successful...');
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Submit",
                                    style: textBold.copyWith(
                                      color: Get.theme.canvasColor,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceHeight20,
                      spaceHeight20,
                      spaceHeight50,
                      spaceHeight50,
                      spaceHeight50,
                      spaceHeight50,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Feather.chevron_down, size: 30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static showDialogNotif(final XController x, final NotifModel e) {
    return showModalBottomSheet(
      barrierColor: Get.theme.disabledColor.withOpacity(.4),
      context: Get.context!,
      builder: (context) => Container(
        width: Get.width,
        height: Get.height / 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            topLeft: Radius.circular(15.0),
          ),
          gradient: LinearGradient(
            colors: [
              mainBackgroundcolor,
              mainBackgroundcolor2,
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.only(top: 15),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        margin: const EdgeInsets.only(top: 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(MyTheme.conerRadius),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "information".tr,
                                style:
                                    Get.theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${e.title}",
                                style: textBold.copyWith(fontSize: 14)),
                            Text(
                              DateFormat.yMEd().add_jms().format(
                                  MyTheme.convertDatetime(e.dateCreated!)),
                              style: textSmallGrey,
                            ),
                            spaceHeight15,
                            Text(
                              "${e.description}",
                              textAlign: TextAlign.center,
                              style: textSmall.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      spaceHeight20,
                      spaceHeight10,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "close".tr,
                                  )
                                ],
                              ),
                            ),
                          ),
                          spaceWidth10,
                          InkWell(
                            onTap: () async {
                              EasyLoading.show(status: 'Loading...');
                              Future.delayed(const Duration(milliseconds: 1200),
                                  () async {
                                final jsonBody = jsonEncode({
                                  "id": "${e.id}",
                                  "iu": "${x.thisUser.value.id}",
                                  "status": "0",
                                  "lat": x.latitude,
                                });
                                debugPrint(jsonBody);

                                await x.provider
                                    .pushResponse('notif/update', jsonBody);

                                x.asyncHome();
                                Get.back(result: {"success": "delete"});
                                EasyLoading.showSuccess('Delete successful...');
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Delete",
                                    style: textBold.copyWith(
                                      color: Get.theme.canvasColor,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceHeight20,
                      spaceHeight20,
                      spaceHeight50,
                      spaceHeight50,
                      spaceHeight50,
                      spaceHeight50,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Feather.chevron_down, size: 30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static showDialogTrans(final XController x, final TransModel e) {
    String unitPrice = "${e.unitPrice}".tr;

    String descPay = e.descPayment!;
    try {
      if (e.payment! == 'Credit Card') {
        final jsonPay = jsonDecode(e.descPayment!);
        descPay =
            "CC: ${jsonPay['no'].toString().substring(0, 4)} xxxx xxxx xxxx";
      }
    } catch (e) {
      debugPrint("");
    }

    return showModalBottomSheet(
      barrierColor: Get.theme.disabledColor.withOpacity(.4),
      context: Get.context!,
      builder: (context) => Container(
        width: Get.width,
        height: Get.height / 1.2,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            topLeft: Radius.circular(15.0),
          ),
          gradient: LinearGradient(
            colors: [
              mainBackgroundcolor,
              mainBackgroundcolor2,
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.only(top: 15),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        margin: const EdgeInsets.only(top: 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(MyTheme.conerRadius),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "information".tr,
                                style:
                                    Get.theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("#${e.no} - ${e.payment}",
                                style: textBold.copyWith(fontSize: 16)),
                            Text(
                              DateFormat.yMEd().add_jms().format(
                                  MyTheme.convertDatetime(e.dateCreated!)),
                              style: textSmallGrey,
                            ),
                            spaceHeight15,
                            Text(
                              "Duration: ${e.duration}\nPayment Desc: $descPay",
                              textAlign: TextAlign.center,
                              style: textSmall.copyWith(fontSize: 14),
                            ),
                            spaceHeight10,
                            Text(
                              "Total: ${e.currency}. ${MyTheme.numberFormat(e.total!)} /$unitPrice",
                              style: textBold.copyWith(
                                color: Get.theme.primaryColor,
                              ),
                            ),
                            spaceHeight20,
                            Text(
                              e.rent!.title!,
                              textAlign: TextAlign.center,
                              style: textSmall.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            spaceHeight10,
                            Text(
                              "Address: ${e.rent!.address!}",
                              textAlign: TextAlign.center,
                              style: textSmall.copyWith(fontSize: 14),
                            ),
                            Text(
                              e.rent!.description!,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: textSmall.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      spaceHeight20,
                      spaceHeight10,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "close".tr,
                                  )
                                ],
                              ),
                            ),
                          ),
                          spaceWidth10,
                          InkWell(
                            onTap: () async {
                              Get.back();
                              Future.microtask(
                                  () => Get.to(DetailRental(rental: e.rent!)));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Details",
                                    style: textBold.copyWith(
                                      color: Get.theme.canvasColor,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceHeight20,
                      spaceHeight20,
                      spaceHeight50,
                      spaceHeight50,
                      spaceHeight50,
                      spaceHeight50,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Feather.chevron_down, size: 30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //static dialog re-usabled
}
