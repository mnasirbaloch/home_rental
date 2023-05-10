import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:homerental/chat/chat_app.dart';
import 'package:homerental/chat/controller/chat_controller.dart';
import 'package:homerental/chat/models/chat_user.dart';
import 'package:homerental/chat/models/ext_chat_message.dart';
import 'package:homerental/chat/models/ext_message.dart';
import 'package:homerental/chat/models/userchat.dart';
import 'package:homerental/core/firebase_auth_service.dart';
import 'package:homerental/core/get_location.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/core/notification_fcm_manager.dart';
import 'package:homerental/core/provider/all_provider.dart';
import 'package:homerental/models/category_model.dart';
import 'package:homerental/models/notif_model.dart';
import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/review_model.dart';
import 'package:homerental/models/trans_model.dart';
import 'package:homerental/models/user_model.dart';
import 'package:homerental/theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum AppState { loading, done, error }

class ItemResponse {
  ItemResponse({this.result, this.categories, this.appState = AppState.done});
  dynamic result;
  List<CategoryModel>? categories;
  List<RentalModel>? recommend;
  List<RentalModel>? rents;
  List<RentalModel>? nearbys;
  List<RentalModel>? latests;
  List<RentalModel>? mylikes;
  List<ReviewModel>? reviews;
  List<TransModel>? trans;
  List<NotifModel>? notifs;
  AppState appState;
}

//chat utility
enum ChatState { loading, done }

class ItemChatUser {
  ItemChatUser();
  User? user;
  UserChat? peer;
  String? groupChatId;
}

class UserLogin {
  UserLogin();
  UserChat? userChat;
  List<UserChat>? userChats = [];
  List<ExtMessage>? userMessages = [];
  List<ExtChatMessage>? userChatMessages = [];

  User? user;
  bool? isLogin;
  int status = 0;
}
//chat utility

class XController extends GetxController {
  static XController get to => Get.find<XController>();

  final AllProvider _provider = AllProvider();
  AllProvider get provider => _provider;

  final myPref = Get.find<MyPref>();

  @override
  void onInit() {
    final uuid = myPref.pUUID;
    if (uuid.val == '') {
      uuid.val = const Uuid().v1();
    }

    final realUuid = uuid.val;
    logPrint("UUID: $realUuid");

    loggedIn.value = isLogin();

    super.onInit();

    logPrint("XController initState...");
    asyncLatitude();
    asyncHome();
  }

  setDefaultLocale() {
    String lang = myPref.pLang.val;
    String locale = lang == 'id' ? 'id_ID' : 'en_US';
    initializeDateFormatting(locale, null);
    Intl.defaultLocale = locale;
  }

  final indexBar = 0.obs;
  setIndexBar(final int index) {
    if (index == 3) {
      getUserById();
    }

    indexBar.value = index;
    update();
  }

  final itemHome = ItemResponse().obs;
  asyncHome() async {
    //load local Database key value pair
    loadLocalPrefHome();
    //load local Database key value pair

    try {
      String iu = "";
      try {
        if (thisUser.value.id != null) {
          iu = thisUser.value.id!;
        }
      } catch (e) {
        debugPrint("");
      }

      final jsonBody = jsonEncode({
        "iu": iu,
        "lat": latitude,
        "loc": location,
        "cc": myPref.pCountry.val,
        "uuid": myPref.pUUID.val,
        "os": GetPlatform.isAndroid ? "Android" : "iOS",
        "tk": myPref.pTokenFCM.val,
        "ver": MyTheme.appVersion,
        "lt": MyTheme.pageLimit,
      });
      logPrint(jsonBody);

      _provider.pushResponse('api', jsonBody)!.then((Response? response) {
        if (response != null && response.statusCode == 200) {
          //logPrint(response.bodyString!);
          dynamic dataresult = jsonDecode(response.bodyString!);

          if (dataresult['result'] != null && dataresult['result'].length > 0) {
            dynamic getHome = dataresult['result'];

            final pHome = myPref.pHome;
            pHome.val = jsonEncode(getHome);

            List<dynamic>? categs = getHome['category'];
            List<CategoryModel> categModels = [];
            if (categs != null && categs.isNotEmpty) {
              for (var e in categs) {
                categModels.add(CategoryModel.fromMap(e));
              }
            }

            List<dynamic>? mytrans = getHome['my_trans'];
            List<TransModel> myTransModels = [];
            if (mytrans != null && mytrans.isNotEmpty) {
              for (var e in mytrans) {
                myTransModels.add(TransModel.fromMap(e));
              }
            }

            List<dynamic>? recomms = getHome['recommended'];
            List<RentalModel> rentRecommModels = [];
            if (recomms != null && recomms.isNotEmpty) {
              for (var e in recomms) {
                rentRecommModels.add(RentalModel.fromMap(e));
              }
            }

            List<dynamic>? latest = getHome['latest'];
            List<RentalModel> rentLatestModels = [];
            if (latest != null && latest.isNotEmpty) {
              for (var e in latest) {
                rentLatestModels.add(RentalModel.fromMap(e));
              }
            }

            List<dynamic>? rents = getHome['rent'];
            List<RentalModel> rentModels = [];
            if (rents != null && rents.isNotEmpty) {
              for (var e in rents) {
                rentModels.add(RentalModel.fromMap(e));
              }
            }

            List<dynamic>? nearbys = getHome['nearby'];
            List<RentalModel> rentNearbyModels = [];
            if (nearbys != null && nearbys.isNotEmpty) {
              for (var e in nearbys) {
                rentNearbyModels.add(RentalModel.fromMap(e));
              }
            }

            List<dynamic>? likes = getHome['my_liked'];
            List<RentalModel> rentLikedModels = [];
            if (likes != null && likes.isNotEmpty) {
              for (var e in likes) {
                rentLikedModels.add(RentalModel.fromMap(e));
              }
            }

            List<dynamic>? notifs = getHome['my_notif'];
            List<NotifModel> notifModels = [];
            if (notifs != null && notifs.isNotEmpty) {
              for (var e in notifs) {
                notifModels.add(NotifModel.fromMap(e));
              }
            }

            itemHome.update((val) {
              val!.result = getHome;
              val.categories = categModels;
              val.recommend = rentRecommModels;
              val.latests = rentLatestModels;
              val.rents = rentModels;
              val.trans = myTransModels;
              val.mylikes = rentLikedModels;
              val.nearbys = rentNearbyModels;
              val.notifs = notifModels;
            });

            allLiked.value = rentLikedModels;
            update();
          }
        }
      });
    } catch (e) {
      debugPrint("");
    }

    //getUserByid
    getUserById();
  }

  loadLocalPrefHome() {
    logPrint("loadLocalPrefHome is running..");
    try {
      final pHome = myPref.pHome;
      if (pHome.val != '') {
        dynamic getHome = jsonDecode(pHome.val);
        dynamic dataresult = getHome;

        if (dataresult['category'] != null) {
          List<dynamic>? categs = dataresult['category'];
          List<CategoryModel> categModels = [];
          if (categs != null && categs.isNotEmpty) {
            for (var e in categs) {
              categModels.add(CategoryModel.fromMap(e));
            }
          }

          List<dynamic>? mytrans = getHome['my_trans'];
          List<TransModel> myTransModels = [];
          if (mytrans != null && mytrans.isNotEmpty) {
            for (var e in mytrans) {
              myTransModels.add(TransModel.fromMap(e));
            }
          }

          List<dynamic>? latest = dataresult['latest'];
          List<RentalModel> rentLatestModels = [];
          if (latest != null && latest.isNotEmpty) {
            for (var e in latest) {
              rentLatestModels.add(RentalModel.fromMap(e));
            }
          }

          List<dynamic>? rents = dataresult['rent'];
          List<RentalModel> rentModels = [];
          if (rents != null && rents.isNotEmpty) {
            for (var e in rents) {
              rentModels.add(RentalModel.fromMap(e));
            }
          }

          List<dynamic>? nearbys = dataresult['nearby'];
          List<RentalModel> rentNearbyModels = [];
          if (nearbys != null && nearbys.isNotEmpty) {
            for (var e in nearbys) {
              rentNearbyModels.add(RentalModel.fromMap(e));
            }
          }

          List<dynamic>? recomms = getHome['recommended'];
          List<RentalModel> rentRecommModels = [];
          if (recomms != null && recomms.isNotEmpty) {
            for (var e in recomms) {
              rentRecommModels.add(RentalModel.fromMap(e));
            }
          }

          List<dynamic>? likes = getHome['my_liked'];
          List<RentalModel> rentLikedModels = [];
          if (likes != null && likes.isNotEmpty) {
            for (var e in likes) {
              rentLikedModels.add(RentalModel.fromMap(e));
            }
          }

          List<dynamic>? notifs = getHome['my_notif'];
          List<NotifModel> notifModels = [];
          if (notifs != null && notifs.isNotEmpty) {
            for (var e in notifs) {
              notifModels.add(NotifModel.fromMap(e));
            }
          }

          itemHome.update((val) {
            val!.result = getHome;
            val.categories = categModels;
            val.recommend = rentRecommModels;
            val.latests = rentLatestModels;
            val.rents = rentModels;
            val.trans = myTransModels;
            val.mylikes = rentLikedModels;
            val.nearbys = rentNearbyModels;
            val.notifs = notifModels;
          });

          allLiked.value = rentLikedModels;
        }
      }
    } catch (e) {
      debugPrint("");
    }
  }

  //other utilities
  final itemReview = ItemResponse().obs;
  getRentReviewById(final String ir, final String iu) {
    try {
      itemReview.update((val) {
        val!.result = null;
        val.rents = [];
      });

      if (iu == '') {
        return;
      }

      final jsonBody = jsonEncode({"iu": iu, "lat": latitude, "ir": ir});
      logPrint(jsonBody);

      _provider
          .pushResponse('rent/get_review', jsonBody)!
          .then((Response? response) {
        if (response != null && response.statusCode == 200) {
          //logPrint(response.bodyString!);
          dynamic dataresult = jsonDecode(response.bodyString!);

          if (dataresult['result'] != null && dataresult['result'].length > 0) {
            List<dynamic>? getResults = dataresult['result'];

            List<ReviewModel> commentModels = [];
            if (getResults != null && getResults.isNotEmpty) {
              for (var e in getResults) {
                commentModels.add(ReviewModel.fromMap(e));
              }
            }

            itemReview.update((val) {
              val!.result = dataresult;
              val.reviews = commentModels;
            });
          }
        }
      });
    } catch (e) {
      debugPrint("");
    }
  }

  postReview(final String ir, final String desc, final double rating) {
    try {
      String iu = "";
      try {
        if (thisUser.value.id != null) {
          iu = thisUser.value.id!;
        }
      } catch (e) {
        debugPrint("");
      }

      final jsonBody = jsonEncode(
          {"iu": iu, "lat": latitude, "ir": ir, "ds": desc, "rt": "$rating"});
      //logPrint(jsonBody);

      _provider
          .pushResponse('rent/comment', jsonBody)!
          .then((Response? response) {
        if (response != null && response.statusCode == 200) {
          //logPrint(response.bodyString!);
          dynamic dataresult = jsonDecode(response.bodyString!);

          if (dataresult['result'] != null && dataresult['result'].length > 0) {
            List<dynamic>? getResults = dataresult['result'];

            List<ReviewModel> commentModels = [];
            if (getResults != null && getResults.isNotEmpty) {
              for (var e in getResults) {
                commentModels.add(ReviewModel.fromMap(e));
              }
            }

            itemReview.update((val) {
              val!.result = dataresult;
              val.reviews = commentModels;
            });
          }
        }
      });
    } catch (e) {
      debugPrint("");
    }
  }

  final isProcessPass = false.obs;
  final itemPass = ItemResponse().obs;
  getRentByCategory(final String ic) {
    try {
      itemPass.update((val) {
        val!.result = null;
        val.rents = [];
      });

      String iu = "";
      try {
        if (thisUser.value.id != null) {
          iu = thisUser.value.id!;
        }
      } catch (e) {
        debugPrint("");
      }

      final jsonBody = jsonEncode({"iu": iu, "lat": latitude, "ic": ic});

      _provider
          .pushResponse('rent/get_byid', jsonBody)!
          .then((Response? response) {
        if (response != null && response.statusCode == 200) {
          //logPrint(response.bodyString!);
          dynamic dataresult = jsonDecode(response.bodyString!);

          if (dataresult['result'] != null && dataresult['result'].length > 0) {
            List<dynamic>? getResults = dataresult['result'];

            List<RentalModel> rentModels = [];
            if (getResults != null && getResults.isNotEmpty) {
              for (var e in getResults) {
                rentModels.add(RentalModel.fromMap(e));
              }
            }

            itemPass.update((val) {
              val!.result = dataresult;
              val.rents = rentModels;
            });
          }
        }
      });
    } catch (e) {
      debugPrint("");
    }
  }

  final itemPassReview = ItemResponse().obs;
  getReviewByRent(final RentalModel rental, final String idReview) {
    try {
      itemPassReview.update((val) {
        val!.result = null;
        val.rents = [];
      });

      String iu = "";
      try {
        if (thisUser.value.id != null) {
          iu = thisUser.value.id!;
        }
      } catch (e) {
        debugPrint("");
      }

      final jsonBody = jsonEncode(
          {"iu": iu, "lat": latitude, "ir": "${rental.id}", "idr": idReview});
      //logPrint(jsonBody);

      _provider
          .pushResponse('rent/get_review', jsonBody)!
          .then((Response? response) {
        if (response != null && response.statusCode == 200) {
          //logPrint(response.bodyString!);
          dynamic dataresult = jsonDecode(response.bodyString!);

          if (dataresult['result'] != null && dataresult['result'].length > 0) {
            List<dynamic>? getResults = dataresult['result'];

            List<RentalModel> rentModels = [];
            if (getResults != null && getResults.isNotEmpty) {
              for (var e in getResults) {
                rentModels.add(RentalModel.fromMap(e));
              }
            }

            itemPassReview.update((val) {
              val!.result = dataresult;
              val.rents = rentModels;
            });
          }
        }
      });
    } catch (e) {
      debugPrint("");
    }
  }

  likeOrDislike(idRent, action) async {
    RentalModel? rentModel;
    try {
      final jsonBody = jsonEncode({
        "lat": latitude,
        "ir": "$idRent",
        "iu": "${thisUser.value.id}",
        "act": action
      });
      logPrint(jsonBody);
      final response =
          await _provider.pushResponse('rent/like_dislike', jsonBody);
      //logPrint(response);

      if (response != null && response.statusCode == 200) {
        //logPrint(response.body);
        dynamic dataresult = jsonDecode(response.bodyString!);

        if (dataresult['code'] == '200') {
          List<dynamic>? updatedRent = dataresult['result'];
          //logPrint(updatedRent);
          if (updatedRent != null && updatedRent.isNotEmpty) {
            rentModel = RentalModel.fromMap(updatedRent[0]);
          }
        }
      }
    } catch (e) {
      debugPrint("");
    }

    asyncHome();

    return rentModel;
  }

  disLikeAll(final List<String> ids) async {
    RentalModel? rentModel;
    try {
      final jsonBody = jsonEncode({
        "lat": latitude,
        "ids": ids,
        "iu": "${thisUser.value.id}",
        "act": 'remove_all'
      });
      logPrint(jsonBody);
      final response =
          await _provider.pushResponse('rent/like_dislike', jsonBody);
      //logPrint(response);

      if (response != null && response.statusCode == 200) {
        //logPrint(response.body);
        dynamic dataresult = jsonDecode(response.bodyString!);

        if (dataresult['code'] == '200') {
          List<dynamic>? updatedRent = dataresult['result'];
          //logPrint(updatedRent);
          if (updatedRent != null && updatedRent.isNotEmpty) {
            rentModel = RentalModel.fromMap(updatedRent[0]);
          }
        }
      }
    } catch (e) {
      debugPrint("");
    }

    asyncHome();

    return rentModel;
  }

  //other utilities

  //member
  final member = <String, dynamic>{}.obs;
  final loggedIn = false.obs;
  updateLogin() {
    loggedIn.value = isLogin();
    update();
  }

  bool isLogin() {
    bool login = myPref.pLogin.val;

    String getMember = myPref.pMember.val;
    logPrint(getMember);
    try {
      if (getMember != '') {
        member.value = jsonDecode(getMember);
        update();
        //logPrint(member);

        _setUserLogin();
        update();
      }
    } catch (e) {
      logPrint("Error isLogin $e");
    }

    return login;
  }

  final thisUser = UserModel().obs;
  //photo this user util
  final photoUser = "".obs;
  updatePhotoUser() {
    String photoUrl = '';
    if (thisUser.value.image != null && thisUser.value.image != '') {
      photoUrl = thisUser.value.image!;
    }
    photoUser.value = photoUrl;
    update();
  }
  //photo this user util

  _setUserLogin() {
    if (member['id_user'] != null && member['id_user'] != '') {
      thisUser.value = UserModel.fromJson(member);
      try {
        photoUser.value = thisUser.value.image!;
      } catch (e) {
        debugPrint("");
      }

      // setUserFirebase
      setUserFirebase();
    }
  }

  doLogin(final dynamic member) {
    try {
      myPref.pMember.val = jsonEncode(member);
      myPref.pLogin.val = true;
      updateLogin();
      asyncHome();
    } catch (e) {
      debugPrint("");
    }
  }

  doLogout() async {
    try {
      myPref.pMember.val = '';
      myPref.pLogin.val = false;
      await notificationFCMManager.firebaseAuthService.signOut();
      updateLogin();
      asyncHome();
    } catch (e) {
      debugPrint("");
    }
  }

  getUserById() async {
    try {
      logPrint("check loggedIn ${loggedIn.value}");
      if (loggedIn.value) {
        final jsonBody = jsonEncode({
          "lat": latitude,
          "loc": location,
          "cc": myPref.pCountry.val,
          "rp": "${notificationFCMManager.firebaseAuthService.getPassword()}",
          "iu": thisUser.value.id ?? '',
          "uf": thisUser.value.uidFcm ?? '',
          "is": install['id_install'] ?? ""
        });

        logPrint(jsonBody);

        _provider
            .pushResponse('api/get_user?lt=${MyTheme.pageLimit}', jsonBody)!
            .then((Response? response) {
          if (response != null && response.statusCode == 200) {
            dynamic dataresult = jsonDecode(response.bodyString!);
            //logPrint(_result);
            if (dataresult['code'] == '200') {
              List<dynamic>? likes = dataresult['result']['my_liked'];
              List<RentalModel> rentLikedModels = [];
              if (likes != null && likes.isNotEmpty) {
                for (var e in likes) {
                  rentLikedModels.add(RentalModel.fromMap(e));
                }
              }

              itemHome.update((val) {
                val!.mylikes = rentLikedModels;
              });

              allLiked.value = rentLikedModels;

              dynamic getMember = dataresult['result']['user'];
              myPref.pMember.val = jsonEncode(getMember);
              member.value = getMember;
              //update();

              //update state
              _setUserLogin();
              update();
            }
          }
        });
      }
    } catch (e) {
      debugPrint("");
    }
  }

  updateUserById(
      final String action, final String about, final String fullname) async {
    try {
      String idUser = thisUser.value.id ?? '';

      var jsonBody = jsonEncode({
        "lat": latitude,
        "loc": location,
        "cc": myPref.pCountry.val,
        "rp": myPref.pPassword.val,
        "iu": idUser,
        "act": action,
        "ab": about,
        "fn": fullname,
      });

      if (action == 'change_password') {
        jsonBody = jsonEncode({
          "lat": latitude,
          "loc": location,
          "cc": myPref.pCountry.val,
          "rp": fullname,
          "iu": idUser,
          "act": action,
          "ps": about,
          "np": fullname, // is a new password
        });
      }
      logPrint(jsonBody);

      final response =
          await _provider.pushResponse('api/update_user_byid', jsonBody);
      if (response != null && response.statusCode == 200) {
        //logPrint(response.bodyString!);

        Future.microtask(() async {
          if (action == 'change_password') {
            await notificationFCMManager.firebaseAuthService
                .firebaseUpdatePassword(fullname);
          }
          getUserById();

          // update firebase password
        });
      }
    } catch (e) {
      debugPrint("");
    }
  }

  final NotificationFCMManager notificationFCMManager =
      NotificationFCMManager.instance;
  final GetLocation geoLocation = GetLocation.instance;
  final shortAddress = ''.obs;

  asyncLatitude() async {
    await geoLocation.init();

    _latitude = geoLocation.latitude;
    _location = (latitude != '') ? geoLocation.shortAddr : "";
    shortAddress.value = location;

    asyncUuidToken();
  }

  saveTokenFCM(String token) {
    myPref.pTokenFCM.val = token;
    asyncUuidToken();
  }

  String? _latitude;
  String get latitude => _latitude ?? "";
  setLatitude(String lat) => _latitude = lat;

  String? _location;
  String get location => _location ?? "";
  setLocation(String loc) => _location = loc;

  final install = <String, dynamic>{}.obs;
  bool isProcessAsync = false;
  asyncUuidToken() async {
    logPrint("asyncUuidToken is runnning $isProcessAsync");
    if (isProcessAsync) return;
    isProcessAsync = true;

    int duration = 0;
    String getInstall = myPref.pInstall.val;
    if (getInstall != '') {
      install.value = jsonDecode(getInstall);
      duration = 10;
    }

    Future.delayed(Duration(seconds: duration), () {
      isProcessAsync = false;
    });

    try {
      //logPrint(install);
      String idInstall = '';
      try {
        idInstall = getInstall != '' ? install['id_install'] ?? "" : "";
      } catch (e) {
        debugPrint("");
      }

      //logPrint("idInstall : $idInstall");

      final jsonBody = jsonEncode({
        "id": idInstall,
        "lat": latitude,
        "loc": location,
        "cc": myPref.pCountry.val,
        "uuid": myPref.pUUID.val,
        "os": GetPlatform.isAndroid ? "Android" : "iOS",
        "tk": myPref.pTokenFCM.val,
        "ver": MyTheme.appVersion
      });
      logPrint(jsonBody);

      _provider
          .pushResponse('install/saveUpdate', jsonBody)!
          .then((Response? response) {
        if (response != null && response.statusCode == 200) {
          //logPrint(response.bodyString!);
          dynamic dataresult = jsonDecode(response.bodyString!);

          if (dataresult['result'] != null && dataresult['result'].length > 0) {
            dynamic installRow = dataresult['result'][0];
            install.value = installRow;
            update();

            final pInstall = myPref.pInstall;
            pInstall.val = jsonEncode(installRow);
            //logPrint(pInstall.val);
          }
        }
      });
    } catch (e) {
      logPrint("error: asyncUuidToken $e");
    }
  }

  //add-on utilities
  final allLiked = <RentalModel>[].obs;
  List<RentalModel> getLikedByUserId(final String idUser) {
    return allLiked.where((element) => element.user!.id == idUser).toList();
  }

  List<RentalModel> getLikedByRentId(final String idRent) {
    return allLiked.where((element) => element.id == idRent).toList();
  }

  List<RentalModel> getLikedByFlag(final int flag) {
    return allLiked.where((element) => element.flag == flag).toList();
  }

  RentalModel getLikedByUserRentId(final String idUser, final String idRent) {
    return allLiked.firstWhere(
        (element) => element.user!.id == idUser && element.id == idRent);
  }

  RentalModel getLikedById(final String id) {
    return allLiked.firstWhere((element) => element.id == id);
  }

  //chat utility
  setUserFirebase() async {
    //logPrint("setUserFirebase...");
    try {
      FirebaseAuthService fauth = notificationFCMManager.firebaseAuthService;
      String? uid = await fauth.getFirebaseUserId();

      if (uid != null) {
        _thisUserFirebase = fauth.firebaseUser;

        logPrint("get setUserFirebase: ${thisUserFirebase.uid}");
        if (_thisUserFirebase != null && thisUserFirebase.uid != '') {
          initChatController();
        }
      }
    } catch (e) {
      logPrint("Error: setUserFirebase $e");
    }
  }

  final itemChatScreen = ItemChatUser().obs;

  gotoChatApp(UserChat peer) {
    logPrint("gotoChatApp... ");
    logPrint(userLogin.value.userChat);

    if (userLogin.value.userChat == null ||
        userLogin.value.userChat!.id!.isEmpty) {
      EasyLoading.showToast("User login offline");
      return;
    }

    itemChatScreen.update((val) {
      val!.user = userLogin.value.user;
      val.peer = peer;
      val.groupChatId =
          generateGroupChatId(userLogin.value.userChat!.id, peer.id);
    });

    Get.to(ChatApp(userChat: peer));
  }

  final ChatController _chatController = ChatController.instance;
  ChatController get chatController => _chatController;

  User? _thisUserFirebase;
  User get thisUserFirebase => _thisUserFirebase!;

  final textToSend = "".obs;

  bool getReadyToSend() {
    String text = textToSend.value.trim();
    if (text.isEmpty || text == '' || text.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  String generateGroupChatId(id, peerId) {
    String groupChatId = '$peerId-$id';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    }
    return groupChatId;
  }

  //startChatWith(String uid, String peerId) {}

  final userLogin = UserLogin().obs;
  getUserChatById(String id) {
    //logPrint("getUserChatById ID: $id");

    try {
      return userLogin.value.userChats!
          .firstWhere((userChat) => id == userChat.id);
    } catch (e) {
      logPrint("Error getUserChatById $e");
    }

    return null;
  }

  initChatController() async {
    //logPrint("initChatController: is runnning...");
    try {
      if (loggedIn.value) {
        userLogin.update((val) {
          val!.user = thisUserFirebase;
          val.isLogin = true;
          val.status = 1;
        });

        if (_thisUserFirebase != null && thisUserFirebase.uid != '') {
          await setUserFirebaseAsync();
          chatController.checkUserExistOrNot(
              this, thisUserFirebase, thisUser.value);
        }
      } else {
        userLogin.update((val) {
          val!.user = null;
          val.isLogin = false;
          val.status = 0;
        });
      }
    } catch (e) {
      logPrint("Error initChatController: $e");
    }
  }

  setUserFirebaseAsync() async {
    //logPrint("uid: ${thisUserFirebase.uid}");
    try {
      await chatController.setUserLoginFirebaseById(this, thisUserFirebase.uid);
    } catch (e) {
      logPrint("Error setUserfirebaseAsync");
    }
  }

  getAllUserFirebase() {
    chatController.getAllUserChatFirebase(this, thisUser.value);
  }

  bool onProcessAsyncChat = false;
  asyncUserChat() async {
    if (onProcessAsyncChat) return;

    onProcessAsyncChat = true;
    Future.delayed(const Duration(seconds: 5), () {
      onProcessAsyncChat = false;
    });

    await chatController.checkUserExistOrNot(
        this, thisUserFirebase, thisUser.value);
  }

  final itemChat = ChatUserModel().obs;
  final chatState = ChatState.done.obs;

  sendMessage(String content, int type) async {
    chatState.value = ChatState.loading;
    update();

    textToSend.value = '';
    update();
  }

  closeMessage() {
    myPref.pOnChatScreen.val = "";
  }

  updateChattingWith(String uid, String peerId) {
    UserModel member = thisUser.value;
    chatController.firestore
        .collection(ChatController.tAGUSERCHAT)
        .doc(uid)
        .update({
      'chattingWith': peerId,
      'nickname': member.fullname ?? "",
      'photoUrl': member.image ?? "",
      'aboutMe': member.about ?? "",
      'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  clearBufferChat() {
    logPrint("clearBufferChat .. running...");
    closeMessage();
  }

  sendNotifToRecipient(dynamic map) async {
    var dataPush = {"token": map['token'], "data": map};

    _provider.pushResponse('user/push_fcm', jsonEncode(dataPush));
  }
  //chat utility
}
