import 'dart:convert';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/app/my_home.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/core/size_config.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/review_model.dart';
import 'package:homerental/models/user_model.dart';
import 'package:homerental/pages/gallery_photo.dart';
import 'package:homerental/pages/review_rental.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/button_container.dart';
import 'package:homerental/widgets/icon_back.dart';
import 'package:homerental/widgets/info_square.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DetailRental extends StatelessWidget {
  final RentalModel rental;
  DetailRental({Key? key, required this.rental}) : super(key: key) {
    isLiked.value = x.getLikedByRentId(rental.id!).isNotEmpty;

    //load data review by id rental
    Future.microtask(() {
      x.getRentReviewById(rental.id!, x.thisUser.value.id!);
    });
  }

  final XController x = XController.to;
  final myPref = MyPref.to;
  final dataReviews = <ReviewModel>[].obs;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
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
      child: SizedBox(
        width: Get.width,
        height: Get.height,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: mainBackgroundcolor,
              title: topIcon(),
              elevation: 0.1,
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            floatingActionButton: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    debugPrint("float clicked..");
                    showDialogBooking(x.thisUser.value, rental);
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(right: 10, left: 10, bottom: 10),
                    child: ButtonContainer(
                      text: "rent_now".tr,
                      boxShadow: BoxShadow(
                        color: Get.theme.primaryColor.withOpacity(.5),
                        blurRadius: 10.0,
                        offset: const Offset(1, 3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: createBody(),
          ),
        ),
      ),
    );
  }

  Widget createBody() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(top: 5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(15)),
            InkWell(
              onTap: () {
                debugPrint("clicked image");
                Get.dialog(MyTheme.photoView(rental.image));
              },
              child: createImage(rental),
            ),
            SizedBox(height: getProportionateScreenHeight(15)),
            Container(
              margin: const EdgeInsets.only(left: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                "description".tr,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15),
              padding:
                  const EdgeInsets.only(left: 20, right: 25, top: 5, bottom: 5),
              child: Text(
                "${rental.description}",
                style: const TextStyle(
                  color: colorTrans1,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(15)),
            if (rental.image2 != null && rental.image2 != '')
              Container(
                margin: const EdgeInsets.only(left: 15),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  "gallery".tr,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700),
                ),
              ),
            if (rental.image2 != null && rental.image2 != '')
              SizedBox(height: getProportionateScreenHeight(10)),
            if (rental.image2 != null && rental.image2 != '') listGalleries(),
            SizedBox(height: getProportionateScreenHeight(30)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  x.getReviewByRent(rental, "");
                  Get.to(
                      ReviewRental(
                        rentalModel: rental,
                        title: "Review ${rental.title}",
                        reviews: x.itemReview.value.reviews!,
                      ),
                      transition: Transition.size);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "review".tr,
                        style: Get.theme.textTheme.titleLarge!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "more".tr,
                        style: Get.theme.textTheme.titleLarge!.copyWith(
                          fontSize: 12,
                          color: colorGrey,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(5)),
            newReview(),
            SizedBox(height: getProportionateScreenHeight(15)),
            Obx(
              () => x.itemReview.value.result != null &&
                      x.itemReview.value.reviews!.isNotEmpty
                  ? listReview(x.itemReview.value.reviews!)
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: getProportionateScreenHeight(155)),
          ],
        ),
      ),
    );
  }

  Widget newReview() {
    return InkWell(
      onTap: () {
        MyHome.showDialogInputReview(x, rental, x.thisUser.value);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Colors.white60,
              Colors.white70,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.background,
              blurRadius: 0.0,
              offset: const Offset(1, 1),
            )
          ],
        ),
        child: SizedBox(
          width: Get.width,
          child: TextField(
            enabled: false,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(
                FontAwesome.star,
                size: 20,
                color: Get.theme.primaryColor,
              ),
              border: InputBorder.none,
              hintText: "write_review".tr,
              suffixIcon: Icon(
                FontAwesome.send,
                size: 16,
                color: Get.theme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  final exampleReview = {
    "description": "Popular place, quite, happy to stay",
    "user": {
      "fullname": "Megan Morgan",
      "image":
          "http://test4.servernet.rs/assets/pages/media/users/avatar80_2.jpg",
    },
    "timestamp": DateTime.now().millisecondsSinceEpoch,
    "rating": 4.7,
  };

  Widget listReview(final List<ReviewModel> reviews) {
    final double thisWidth = Get.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      width: Get.width,
      child: ListView(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: reviews.map((e) {
            return Container(child: createSingleReview(thisWidth, e));
          }).toList()),
    );
  }

  static createSingleReview(final double thisWidth, final ReviewModel e) {
    return InkWell(
      onTap: () {
        //Get.to(DetailRental(rental: e));
      },
      child: Container(
        width: thisWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: colorBoxShadow,
              blurRadius: 1.0,
              offset: Offset(1, 1),
            )
          ],
        ),
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        child: Stack(
          children: [
            Container(
              width: thisWidth / 1.1,
              padding:
                  const EdgeInsets.only(top: 5, left: 22, right: 10, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ExtendedImage.network(
                            e.user!.image!,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            cache: true,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.user!.fullname!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.1,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              DateFormat.yMEd().add_jms().format(
                                  MyTheme.convertDatetime(e.dateCreated!)),
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            "${e.rating}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        RatingBar.builder(
                          ignoreGestures: true,
                          initialRating: e.rating!,
                          minRating: 1,
                          direction: Axis.horizontal,
                          unratedColor: Colors.amber.withAlpha(50),
                          itemCount: 5,
                          itemSize: 14.0,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {},
                          updateOnDrag: false,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    margin: const EdgeInsets.only(
                      bottom: 10,
                      top: 10,
                    ),
                    child: Text(
                      "${e.review}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  InkWell(
                      onTap: () {
                        debugPrint("clicked thumb up");
                        MyTheme.showToast('Dummy action...');
                      },
                      child: const Icon(Feather.thumbs_up, size: 18)),
                  const SizedBox(height: 20),
                  InkWell(
                      onTap: () {
                        debugPrint("clicked thumb down");
                        MyTheme.showToast('Dummy action...');
                      },
                      child: const Icon(Feather.thumbs_down,
                          size: 18, color: colorGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listGalleries() {
    List<dynamic> temps = [];
    try {
      if (rental.image2 != null) {
        temps.add({"image": "${rental.image2}"});
      }

      if (rental.image3 != null) {
        temps.add({"image": "${rental.image3}"});
      }

      if (rental.image4 != null) {
        temps.add({"image": "${rental.image4}"});
      }

      if (rental.image5 != null) {
        temps.add({"image": "${rental.image5}"});
      }

      if (rental.image6 != null) {
        temps.add({"image": "${rental.image6}"});
      }
    } catch (e) {
      debugPrint("");
    }

    List<dynamic> galleries = [];
    if (temps.isNotEmpty) {
      galleries = temps.toList()..shuffle();
    }

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: galleries.map((e) {
          final int idx = galleries.indexOf(e);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialogPhoto(galleries, idx);
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: idx == 0 ? 16 : 0,
                  right: idx >= galleries.length - 1 ? 50 : 0,
                ),
                padding: EdgeInsets.only(
                  left: idx == 0 ? 15 : 0,
                  right: idx >= galleries.length - 1 ? 30 : 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ExtendedImage.network(
                    "${e['image']}",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    cache: true,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  showDialogPhoto(final List<dynamic> photos, final int index) {
    return Get.dialog(
      Container(
        width: Get.width,
        height: Get.height,
        color: Colors.black87,
        padding: const EdgeInsets.only(bottom: 0),
        child: Stack(
          children: [
            GalleryPhoto(images: photos, initialIndex: index),
            Positioned(
              top: 10,
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: mainBackgroundcolor,
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        FontAwesome.chevron_left,
                        size: 16,
                        color: MyTheme.iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createImage(final RentalModel e) {
    final double thisWidth = Get.width; //  / 1.2;
    String unitPrice = "${e.unitPrice}".tr;
    return Container(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
        width: thisWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
        ),
        margin: const EdgeInsets.only(
          bottom: 3,
          right: 12,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ExtendedImage.network(
                      "${e.image}",
                      width: thisWidth - 1,
                      height: Get.height / 3.9,
                      fit: BoxFit.cover,
                      cache: true,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 18, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              width: Get.width / 2.1,
                              child: Text(
                                "${e.title}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.1,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              "${myPref.pCurrency.val} ${e.price!} /$unitPrice",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          debugPrint("clicked location here");
                          String? latitude = e.latitude;

                          if (latitude != null) {
                            var split = latitude.split(",");
                            String googleUrl =
                                'https://www.google.com/maps/search/?api=1&query=${split[0]},${split[1]}';
                            MyTheme.launchUrlGeo(googleUrl);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(MaterialIcons.location_pin,
                                      color: Colors.black45, size: 18),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${e.address}",
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black45),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesome.heart,
                                        size: 15,
                                        color: Get.theme.primaryColor),
                                    spaceWidth5,
                                    Text(
                                        MyTheme.formatCounterNumber(
                                            e.totalLike!),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: InfoSquare(
                          rental: e,
                          iconSize: 17,
                          spaceWidth: 6,
                        ),
                      ),
                      if (e.distance != null)
                        InkWell(
                          onTap: () {
                            debugPrint("clicked location here");
                            String? latitude = e.latitude;

                            if (latitude != null) {
                              var split = latitude.split(",");
                              String googleUrl =
                                  'https://www.google.com/maps/search/?api=1&query=${split[0]},${split[1]}';
                              MyTheme.launchUrlGeo(googleUrl);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Feather.navigation,
                                  size: 16,
                                  color: Get.theme.colorScheme.background,
                                ),
                                spaceWidth5,
                                Text(
                                  "${MyTheme.numberFormatDec(e.distance!, 2)} km",
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.background,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: colorTrans2.withOpacity(.8),
                ),
                child: Row(
                  children: [
                    const Icon(MaterialIcons.star,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      "${e.rating} (${e.totalRating} ${'review'.tr})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  final isLiked = false.obs;
  Widget topIcon() {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 0),
            child: const IconBack(),
          ),
          Container(
            padding: const EdgeInsets.only(top: 0),
            child: const Text(
              "Details",
              style: TextStyle(
                fontSize: 18,
                color: colorTrans2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorGrey2,
                  style: BorderStyle.solid,
                  width: 0.8,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              child: Obx(
                () => AnimatedIconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  size: 14,
                  onPressed: () {
                    isLiked.value = !isLiked.value;
                    debugPrint("isLiked: ${isLiked.value}");

                    Future.microtask(() =>
                        MyHome.pushLikeOrDislike(x, rental, isLiked.value));
                  },
                  duration: const Duration(milliseconds: 500),
                  splashColor: Colors.transparent,
                  icons: <AnimatedIconItem>[
                    AnimatedIconItem(
                      icon: Icon(
                        FontAwesome.heart,
                        size: 14,
                        color: isLiked.value
                            ? Get.theme.colorScheme.secondary
                            : Get.theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //dialog rent book
  static final List<dynamic> methods = [
    {"title": "Credit Card", "icon": ""},
    {"title": "Paypal", "icon": ""},
    {"title": "Cash", "icon": ""}
  ];

  static final isProcessBook = false.obs;
  static final idxMethod = 0.obs;
  static final TextEditingController _fullname = TextEditingController();
  static final TextEditingController _date = TextEditingController();

  static showDialogBooking(final UserModel user, final RentalModel rental) {
    _fullname.text = '';
    _date.text = '';
    _email.text = '';

    idxMethod.value = 0;
    stepProcess.value = 1;

    final myPref = Get.find<MyPref>();

    return showCupertinoModalBottomSheet(
      context: Get.context!,
      isDismissible: false,
      builder: (context) => Container(
        width: Get.width,
        height: Get.height,
        color: mainBackgroundcolor.withOpacity(.9),
        child: Container(
          width: Get.width,
          height: Get.height,
          margin: const EdgeInsets.only(top: 20, bottom: 0),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height,
                  margin: const EdgeInsets.only(top: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(22),
                        child: Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              MyTheme.conerRadius,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Get.theme.colorScheme.secondary
                                    .withOpacity(.5),
                                blurRadius: 2.0,
                                offset: const Offset(1, 2),
                              )
                            ],
                          ),
                          child: Obx(
                            () => isProcessBook.value
                                ? childProcessing()
                                : childBooking(rental, myPref),
                          ),
                        ),
                      ),
                      //spaceHeight5,
                      Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                if (stepProcess.value == 2 &&
                                    idxMethod.value == 0) {
                                  stepProcess.value = 1;

                                  dataFormCard.value = {
                                    "no": "",
                                    "exp": "",
                                    "cname": "",
                                    "cvv": "",
                                    "focus": "1",
                                  };
                                } else {
                                  Get.back();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: const EdgeInsets.only(
                                    left: 0, right: 0, bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Cancel",
                                        style: textSmall.copyWith(fontSize: 18))
                                  ],
                                ),
                              ),
                            ),
                            if (!isProcessBook.value) spaceWidth10,
                            if (!isProcessBook.value)
                              InkWell(
                                onTap: () async {
                                  String fullnm = _fullname.text.trim();
                                  if (fullnm.isEmpty || fullnm.length < 3) {
                                    EasyLoading.showToast(
                                        'Fullname invalid...');
                                    return;
                                  }

                                  String dateRange = _date.text.trim();
                                  if (dateRange.isEmpty ||
                                      dateRange.length < 3) {
                                    EasyLoading.showToast(
                                        'Date Range selection invalid...');
                                    return;
                                  }

                                  debugPrint("method value ${idxMethod.value}");

                                  if (idxMethod.value == 2) {
                                    MyTheme.showToast('Please wait...');
                                    await doPostNewRent(XController.to, rental,
                                        dateRange, "Cash", "Method Cash");
                                    //Get.back();
                                  } else if ((stepProcess.value == 2 ||
                                          stepProcess.value == 3) &&
                                      (idxMethod.value == 0 ||
                                          idxMethod.value == 1)) {
                                    String em = _email.text.trim();
                                    if (idxMethod.value == 1 &&
                                        (em.isEmpty || !GetUtils.isEmail(em))) {
                                      EasyLoading.showToast('Email invalid...');
                                      return;
                                    }

                                    MyTheme.showToast('Please wait...');

                                    await doPostNewRent(
                                        XController.to,
                                        rental,
                                        dateRange,
                                        idxMethod.value == 1
                                            ? "Paypal"
                                            : "Credit Card",
                                        idxMethod.value == 1
                                            ? em
                                            : jsonEncode(dataFormCard));
                                    await Future.delayed(
                                        const Duration(seconds: 1), () {
                                      stepProcess.value = 1;
                                      dataFormCard.value = {
                                        "no": "",
                                        "exp": "",
                                        "cname": "",
                                        "cvv": "",
                                        "focus": "1",
                                      };
                                    });
                                  } else if (idxMethod.value == 0) {
                                    stepProcess.value = 2;
                                  } else if (idxMethod.value == 1) {
                                    stepProcess.value = 3;
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  margin: const EdgeInsets.only(
                                      left: 0, right: 0, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Get.theme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Obx(
                                        () => Text(
                                          (stepProcess.value == 2 ||
                                                      stepProcess.value == 3) &&
                                                  (idxMethod.value == 0 ||
                                                      idxMethod.value == 1)
                                              ? "Payment"
                                              : "Book",
                                          style: textBold.copyWith(
                                              color: Get.theme.canvasColor,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      spaceHeight20,
                      spaceHeight10,
                    ],
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
      ),
    );
  }

  static doPostNewRent(
      final XController x,
      final RentalModel rental,
      final String duration,
      final String payment,
      final String descPayment) async {
    isProcessBook.value = true;

    await Future.delayed(const Duration(seconds: 2));

    try {
      final jsonBody = jsonEncode({
        "lat": x.latitude,
        "ir": "${rental.id}",
        "dr": duration,
        "iu": "${x.thisUser.value.id}",
        "cr": x.myPref.pCurrency.val,
        "tt": "${rental.price}",
        "py": payment,
        "dp": descPayment,
        "up": "${rental.unitPrice}",
      });
      debugPrint(jsonBody);
      final response =
          await x.provider.pushResponse('trans/insert_trans', jsonBody);

      if (response != null && response.statusCode == 200) {
        dynamic dtresult = jsonDecode(response.bodyString!);

        if (dtresult['code'] == '200') {
          x.asyncHome();
        }

        await Future.delayed(const Duration(seconds: 1));
        isProcessBook.value = false;
        Get.back();
        EasyLoading.showSuccess("Process successful...");

        Future.microtask(() => showDialogSuccess());
      }
    } catch (e) {
      debugPrint("error $e");
    }
  }

  static showDialogSuccess() {
    return showCupertinoModalBottomSheet(
      context: Get.context!,
      isDismissible: false,
      builder: (context) => Container(
        width: Get.width,
        height: Get.height / 1.15,
        color: mainBackgroundcolor.withOpacity(.9),
        child: Container(
          width: Get.width,
          height: Get.height,
          margin: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height,
                  margin: const EdgeInsets.only(top: 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(22),
                        child: Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              MyTheme.conerRadius,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Get.theme.colorScheme.secondary
                                    .withOpacity(.5),
                                blurRadius: 5.0,
                                offset: const Offset(2, 5),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: Get.width,
                                child: Text(
                                  "Booking successful...\nThank you",
                                  textAlign: TextAlign.center,
                                  style:
                                      Get.theme.textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              spaceHeight20,
                              Image.asset("assets/green-success.gif",
                                  width: 180),
                              spaceHeight20,
                            ],
                          ),
                        ),
                      ),
                      spaceHeight10,
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
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Close",
                                      style: textSmall.copyWith(fontSize: 18))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceHeight20,
                      spaceHeight20,
                    ],
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
      ),
    );
  }

  static final TextEditingController _email = TextEditingController();
  static Widget childFormPaypal(final RentalModel rental, final MyPref myPref) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 1,
                color: Get.theme.colorScheme.secondary,
                style: BorderStyle.solid,
              ),
            ),
            child: TextField(
              controller: _email,
              decoration: MyTheme.inputFormAccent('Email Paypal',
                  Get.theme.canvasColor, Get.theme.primaryColor),
            ),
          ),
        ),
        spaceHeight10,
      ],
    );
  }

  static final dataFormCard = {
    "no": "",
    "exp": "",
    "cname": "",
    "cvv": "",
    "focus": "1",
  }.obs;

  static final GlobalKey<FormState> formCardKey = GlobalKey<FormState>();

  static Widget childFormCreditCard(
      final RentalModel rental, final MyPref myPref) {
    return Column(
      children: [
        Obx(
          () => CreditCardWidget(
            onCreditCardWidgetChange: (_) {},
            cardNumber: dataFormCard['no'].toString(),
            expiryDate: dataFormCard['exp'].toString(),
            cardHolderName: dataFormCard['cname'].toString(),
            cvvCode: dataFormCard['cvv'].toString(),
            showBackView: int.parse(dataFormCard['focus'].toString()) == 1,
            cardBgColor: mainBackgroundcolor,
            obscureCardNumber: true,
            obscureCardCvv: true,
            height: 135,
            textStyle: const TextStyle(
              color: MyTheme.iconColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            width: Get.width,
            animationDuration: const Duration(milliseconds: 1000),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          child: CreditCardForm(
            cardNumber: dataFormCard['no'].toString(),
            expiryDate: dataFormCard['exp'].toString(),
            cardHolderName: dataFormCard['cname'].toString(),
            cvvCode: dataFormCard['cvv'].toString(),
            formKey: formCardKey, // Required
            onCreditCardModelChange: (CreditCardModel creditCardModel) {
              String cardNumber = creditCardModel.cardNumber;
              String expiryDate = creditCardModel.expiryDate;
              String cardHolderName = creditCardModel.cardHolderName;
              String cvvCode = creditCardModel.cvvCode;
              bool isCvvFocused = creditCardModel.isCvvFocused;

              dataFormCard.value = {
                "no": cardNumber,
                "exp": expiryDate,
                "cname": cardHolderName,
                "cvv": cvvCode,
                "focus": isCvvFocused ? "1" : "0",
              };
            }, // Required
            // themeColor: Colors.red,
            obscureCvv: true,
            obscureNumber: true,
            // cardNumberDecoration: MyTheme.inputFormAccent(
            //   'XXXX XXXX XXXX XXXX',
            //   Get.theme.canvasColor,
            //   Get.theme.primaryColor,
            // ).copyWith(
            //   labelText: 'Number',
            //   contentPadding: const EdgeInsets.all(5),
            // ),
            // expiryDateDecoration: MyTheme.inputFormAccent(
            //   'XX/XX',
            //   Get.theme.canvasColor,
            //   Get.theme.primaryColor,
            // ).copyWith(
            //   labelText: 'Expired Date',
            //   contentPadding: const EdgeInsets.all(5),
            // ),
            // cvvCodeDecoration: MyTheme.inputFormAccent(
            //   'XXX',
            //   Get.theme.canvasColor,
            //   Get.theme.primaryColor,
            // ).copyWith(
            //   labelText: 'CVV',
            //   contentPadding: const EdgeInsets.all(5),
            // ),
            // cardHolderDecoration: MyTheme.inputFormAccent(
            //   'Card Holder Name',
            //   Get.theme.canvasColor,
            //   Get.theme.primaryColor,
            // ).copyWith(
            //   labelText: 'Card Holder',
            //   contentPadding: const EdgeInsets.all(5),
            // ),
          ),
        ),
      ],
    );
  }

  static Widget childFormBooking(
      final RentalModel rental, final MyPref myPref) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 1,
                color: Get.theme.colorScheme.secondary,
                style: BorderStyle.solid,
              ),
            ),
            child: TextField(
                controller: _fullname,
                decoration:
                    MyTheme.inputForm('Fullname', Get.theme.canvasColor)),
          ),
        ),
        spaceHeight10,
        InkWell(
          onTap: () async {
            showDialogDate();
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 1,
                  color: Get.theme.colorScheme.secondary,
                  style: BorderStyle.solid,
                ),
              ),
              child: TextField(
                  controller: _date,
                  enabled: false,
                  decoration: MyTheme.inputForm(
                      'Select Date Range', Get.theme.canvasColor)),
            ),
          ),
        ),
        spaceHeight20,
        //view payment
        Container(
          width: Get.width,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          margin: const EdgeInsets.only(bottom: 10),
          child: const Text("Payment Method", style: textBold),
        ),
        Container(
          width: Get.width,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 10),
          child: Column(
            children: [
              Wrap(
                children: methods.map((e) {
                  final int index = methods.indexOf(e);
                  return Obx(
                    () => InkWell(
                      onTap: () {
                        idxMethod.value = index;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: index == idxMethod.value
                              ? Get.theme.primaryColor
                              : mainBackgroundcolor,
                        ),
                        child: Text(
                          "${e['title']}",
                          style: textBold.copyWith(
                            color: index == idxMethod.value
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget childProcessing() {
    return Column(
      children: [
        Text(
          "Process...",
          style: Get.theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        spaceHeight20,
        Image.asset("assets/loading2.gif", width: 120),
        spaceHeight20,
      ],
    );
  }

  static final stepProcess = 1.obs;
  static Widget childBooking(final RentalModel rental, final MyPref myPref) {
    String unitPrice = "${rental.unitPrice}".tr;
    return Column(
      children: [
        Container(
          width: Get.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Text(
            "Rent at ${rental.title}",
            textAlign: TextAlign.center,
            style: Get.theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          width: Get.width,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Icon(Feather.map_pin, size: 12, color: Colors.grey),
                  spaceWidth5,
                  Text("${rental.address}",
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Text(
                    "${myPref.pCurrency.val}. ${MyTheme.formatCounterNumber(rental.price!)} /$unitPrice",
                    style: textSmall.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Get.theme.primaryColor)),
              ),
            ],
          ),
        ),
        stepProcess.value == 2 ? const SizedBox(height: 1) : spaceHeight10,
        Obx(() => stepProcess.value == 1
            ? childFormBooking(rental, myPref)
            : stepProcess.value == 2
                ? childFormCreditCard(rental, myPref)
                : childFormPaypal(rental, myPref)),
      ],
    );
  }

  static showDialogDate() async {
    Get.dialog(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: mainBackgroundcolor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Date Range'),
          centerTitle: true,
          elevation: 0.3,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: mainBackgroundcolor,
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SfDateRangePicker(
            confirmText: "Set Date",
            cancelText: "Cancel",
            showActionButtons: true,
            onSubmit: (_) {
              Get.back();
            },
            onCancel: () {
              _date.text = '';
              Get.back();
            },
            backgroundColor: Colors.white,
            view: DateRangePickerView.month,
            selectionMode: DateRangePickerSelectionMode.range,
            selectionTextStyle: const TextStyle(color: Colors.white),
            selectionColor: Colors.blue,
            startRangeSelectionColor: Get.theme.primaryColor,
            endRangeSelectionColor: Get.theme.primaryColor,
            rangeSelectionColor: Get.theme.colorScheme.secondary,
            rangeTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              //debugPrint(args.value);
              if (args.value is PickerDateRange) {
                String dtarange =
                    '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} - ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
                //debugPrint(_range);

                _date.text = dtarange;
              }
            },
          ),
        ),
      ),
    ));
  }
}
