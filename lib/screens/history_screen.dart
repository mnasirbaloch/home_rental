import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/app/my_home.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/core/size_config.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/trans_model.dart';
import 'package:homerental/pages/bycategory.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/button_container.dart';
import 'package:homerental/widgets/icon_back.dart';
import 'package:homerental/widgets/image_clip.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HistoryScreen extends StatelessWidget {
  final XController x = XController.to;

  HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyPref myPref = MyPref.to;
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: mainBackgroundcolor,
        title: topIcon(),
        elevation: 0.1,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getProportionateScreenHeight(15)),
              Obx(() => rowMenus(selectedOpt.value, myPref)),
              SizedBox(height: getProportionateScreenHeight(55)),
              SizedBox(height: getProportionateScreenHeight(155)),
            ],
          ),
        ),
      ),
    );
  }

  final selectedOpt = 0.obs;
  final List<String> catOptions = ["upcoming".tr, "past".tr];
  Widget rowMenus(final int selectedOption, final MyPref myPref) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: catOptions.map(
                (e) {
                  final index = catOptions.indexOf(e);
                  return InkWell(
                    onTap: () {
                      selectedOpt.value = index;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e,
                            style: TextStyle(
                                fontSize: (index == selectedOption) ? 15 : 14,
                                color: (index == selectedOption)
                                    ? Colors.black87
                                    : Colors.grey[400],
                                fontWeight: (index == selectedOption)
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                          if (index == selectedOption)
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              color: Get.theme.primaryColor,
                              height: 3,
                              width: 25,
                            )
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          spaceHeight20,
          spaceHeight10,
          Obx(
            () => selectedOption == 0
                ? listTrans(x.itemHome.value.trans!, selectedOption, myPref)
                : listPastTrans(
                    x.itemHome.value.trans!, selectedOption, myPref),
          ),
          spaceHeight5,
        ],
      ),
    );
  }

  Widget listTrans(
      final List<TransModel> temps, final int indexTrans, final MyPref myPref) {
    debugPrint("build listTrans..");

    final List<TransModel> trans = [];
    for (var element in temps) {
      if (element.status! < 3) {
        trans.add(element);
      }
    }

    return Container(
      child: trans.isEmpty
          ? Container(child: ByCategory.noDataFound())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: trans.map((TransModel e) {
                RentalModel rental = e.rent!; //findRentalById(e.idRent!);
                String unitPrice = "${rental.unitPrice}".tr;
                final int status = e.status ?? 0;

                // status = 1 (checkin), 2 = stayed, 3 = done, 4 =void
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

                return InkWell(
                  onTap: () {
                    //Get.to(DetailRental(rental: rental));
                    MyHome.showDialogTrans(x, e);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: colorBoxShadow,
                          blurRadius: 1.0,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: ImageClip(
                            url: '${rental.image}',
                            width: 80,
                            height: 80,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "#${e.no} - ${e.payment}",
                                style: textBold.copyWith(
                                  fontSize: 11,
                                  color: colorTrans2,
                                ),
                              ),
                              SizedBox(
                                width: Get.width / 1.9,
                                child: Text(
                                  "${rental.title}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textBold.copyWith(
                                    fontSize: 13,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Get.width / 1.8,
                                child: Text(
                                  "${e.duration}\n$descPay",
                                  style: textSmallGrey.copyWith(
                                      color: Colors.black54),
                                ),
                              ),
                              Container(
                                width: GetPlatform.isAndroid
                                    ? Get.width / 1.8
                                    : Get.width / 1.6,
                                height: 40,
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\n${e.currency}. ${MyTheme.numberFormat(e.total!)} /$unitPrice",
                                      style: textBold.copyWith(
                                        color: Get.theme.primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          debugPrint("button clicked..");
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 10, left: 0),
                                          child: status == 1
                                              ? InkWell(
                                                  onTap: () {
                                                    showDialogUpdateTrans(
                                                        XController.to,
                                                        e,
                                                        false);
                                                  },
                                                  child: ButtonContainer(
                                                    text: "options".tr,
                                                    sizeText: 11,
                                                    paddingHorizontal: 10,
                                                    paddingVertical: 5,
                                                    linearGradient:
                                                        LinearGradient(
                                                      colors: [
                                                        Colors.grey,
                                                        Colors.grey
                                                            .withOpacity(.98)
                                                      ],
                                                    ),
                                                    boxShadow: const BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 3.0,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ),
                                                )
                                              : status == 3
                                                  ? InkWell(
                                                      onTap: () {
                                                        showDialogUpdateTrans(
                                                            XController.to,
                                                            e,
                                                            true);
                                                      },
                                                      child: ButtonContainer(
                                                        text: "Done",
                                                        sizeText: 11,
                                                        paddingHorizontal: 10,
                                                        paddingVertical: 5,
                                                        linearGradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.green,
                                                            Colors.green
                                                                .withOpacity(
                                                                    .98)
                                                          ],
                                                        ),
                                                        boxShadow:
                                                            const BoxShadow(
                                                          color: Colors.green,
                                                          blurRadius: 3.0,
                                                          offset: Offset(1, 2),
                                                        ),
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        showDialogUpdateTrans(
                                                            XController.to,
                                                            e,
                                                            true);
                                                      },
                                                      child:
                                                          const ButtonContainer(
                                                        text: "Checkin",
                                                        sizeText: 11,
                                                        paddingHorizontal: 10,
                                                        paddingVertical: 5,
                                                      ),
                                                    ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget listPastTrans(
      final List<TransModel> temps, final int indexTrans, final MyPref myPref) {
    debugPrint("build listPastTrans..");

    final List<TransModel> trans = [];
    for (var element in temps) {
      if (element.status! > 2) {
        trans.add(element);
      }
    }

    return Container(
      child: trans.isEmpty
          ? Container(child: ByCategory.noDataFound())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: trans.map((TransModel e) {
                final int index = trans.indexOf(e);
                RentalModel rental = e.rent!;

                String unitPrice = "${rental.unitPrice}".tr;
                final int status = e.status!;

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

                return InkWell(
                  onTap: () {
                    //Get.to(DetailRental(rental: rental));
                    MyHome.showDialogTrans(x, e);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: colorBoxShadowGrey,
                          blurRadius: 1.0,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: ImageClip(
                            url: '${rental.image}',
                            width: 85,
                            height: 85,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("#${e.no} - ${e.payment}",
                                      style: textBold.copyWith(
                                          fontSize: 11, color: colorTrans2)),
                                  SizedBox(
                                    width: Get.width / 1.9,
                                    child: Text(
                                      "${rental.title}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textBold.copyWith(
                                        fontSize: 13,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width / 1.8,
                                    child: Text(
                                      "${e.duration}\n$descPay",
                                      style: textSmallGrey.copyWith(
                                          color: Colors.black54),
                                    ),
                                  ),
                                  Container(
                                    width: GetPlatform.isAndroid
                                        ? Get.width / 1.8
                                        : Get.width / 1.65,
                                    height: 40,
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\n${e.currency}. ${MyTheme.numberFormat(e.total!)} /$unitPrice",
                                          style: textBold.copyWith(
                                            color: Get.theme.primaryColor,
                                          ),
                                        ),
                                        status != 4
                                            ? const Icon(Feather.check_circle,
                                                color: Colors.green, size: 18)
                                            : const Icon(Feather.x,
                                                color: Colors.red, size: 18),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    CoolAlert.show(
                                        context: Get.context!,
                                        backgroundColor: Get.theme.canvasColor,
                                        type: CoolAlertType.confirm,
                                        title: 'confirmation'.tr,
                                        text: 'confirm_delete'.tr,
                                        confirmBtnText: 'yes'.tr,
                                        cancelBtnText: 'cancel'.tr,
                                        confirmBtnColor: Colors.green,
                                        onConfirmBtnTap: () async {
                                          Get.back();
                                          final jsonBody = jsonEncode({
                                            "it": "${e.id}",
                                            "iu": "${x.thisUser.value.id}",
                                            "act": "delete",
                                            "lat": x.latitude,
                                          });
                                          debugPrint(jsonBody);

                                          await x.provider.pushResponse(
                                              'trans/update_trans', jsonBody);
                                          trans.removeAt(index);
                                          x.asyncHome();
                                          EasyLoading.showSuccess(
                                              'Delete successful...');
                                        });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colorGrey2,
                                          style: BorderStyle.solid,
                                          width: 0.8,
                                        ),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.all(3),
                                      child: Icon(
                                        FontAwesome.trash,
                                        size: 16,
                                        color: Get.theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget topIcon() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 0),
            child: IconBack(callback: () {
              x.setIndexBar(0);
            }),
          ),
          Container(
            padding: const EdgeInsets.only(top: 0),
            child: Text(
              "history".tr,
              style: const TextStyle(
                fontSize: 18,
                color: colorTrans2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  //update status
  showDialogUpdateTrans(final XController x, final TransModel trans,
      final bool isAlreadyCheckin) {
    return showModalBottomSheet(
      barrierColor: Get.theme.disabledColor.withOpacity(.4),
      context: Get.context!,
      builder: (context) => Container(
        width: Get.width,
        height: Get.height / 2.2,
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
                                "Update Status",
                                style:
                                    Get.theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      spaceHeight20,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isAlreadyCheckin)
                            InkWell(
                              onTap: () {
                                Get.back();
                                postUpdateTrans(x, trans.id!, 2);
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
                                  children: const [
                                    Text(
                                      "Checkin",
                                    )
                                  ],
                                ),
                              ),
                            ),
                          spaceWidth10,
                          InkWell(
                            onTap: () {
                              Get.back();
                              postUpdateTrans(x, trans.id!, 3);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Done",
                                    style: textBold.copyWith(
                                      color: Get.theme.canvasColor,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          spaceWidth10,
                          InkWell(
                            onTap: () {
                              Get.back();
                              postUpdateTrans(x, trans.id!, 4);
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
                                    "Cancel",
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

  static postUpdateTrans(
      final XController x, final String idTrans, final int status) async {
    try {
      EasyLoading.show(status: 'Loading...');
      await Future.delayed(const Duration(milliseconds: 1900));

      final jsonBody = jsonEncode({
        "lat": x.latitude,
        "it": idTrans,
        "st": "$status",
        "iu": x.thisUser.value.id!
      });
      debugPrint(jsonBody);
      final response =
          await x.provider.pushResponse('trans/update_trans', jsonBody);

      if (response != null && response.statusCode == 200) {
        dynamic dataresult = jsonDecode(response.bodyString!);

        if (dataresult['code'] == '200') {
          x.asyncHome();
        }

        EasyLoading.showSuccess("Update successful...");

        Future.microtask(() => x.asyncHome());
      }
    } catch (e) {
      debugPrint("error $e");
    }
  }
}
