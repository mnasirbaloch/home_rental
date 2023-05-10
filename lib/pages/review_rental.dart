import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/core/size_config.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/models/rental_model.dart';
import 'package:homerental/models/review_model.dart';
import 'package:homerental/pages/detail_rental.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/icon_back.dart';

class ReviewRental extends StatelessWidget {
  final RentalModel? rentalModel;
  final List<ReviewModel>? reviews;
  final String? title;

  ReviewRental({Key? key, required this.rentalModel, this.reviews, this.title})
      : super(key: key) {
    int duration = 1500;
    if (reviews != null && reviews!.isNotEmpty) {
      duration = 0;
    }
    Future.delayed(Duration(milliseconds: duration), () {
      final XController x = XController.to;
      if (x.itemPassReview.value.result != null) {
        datas.value = x.itemPassReview.value.reviews!;
        temps.value = x.itemPassReview.value.reviews!;
      } else if (reviews != null && reviews!.isNotEmpty) {
        datas.value = reviews!;
        temps.value = reviews!;
      } else {
        //try to push one more time
        if (rentalModel!.id != null) {
          Future.microtask(() => x.getReviewByRent(rentalModel!, ""));
          Future.delayed(Duration(milliseconds: duration), () {
            if (x.itemPassReview.value.result != null) {
              datas.value = x.itemPassReview.value.reviews!;
              temps.value = x.itemPassReview.value.reviews!;
            }
          });
        }
      }
      isLoading.value = false;
    });
  }

  final datas = <ReviewModel>[].obs;
  final temps = <ReviewModel>[].obs;
  final isLoading = true.obs;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final XController x = XController.to;
    final MyPref myPref = MyPref.to;

    return Container(
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
        appBar: AppBar(
          backgroundColor: mainBackgroundcolor,
          title: topIcon(x),
          elevation: 0.1,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getProportionateScreenHeight(5)),
              Obx(
                () => !isLoading.value && temps.isNotEmpty
                    ? inputSearch(x)
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: getProportionateScreenHeight(15)),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getProportionateScreenHeight(10)),
                      Obx(() => isLoading.value
                          ? MyTheme.loadingCircular()
                          : datas.isEmpty
                              ? noDataFound()
                              : listReview(datas, myPref)),
                      SizedBox(height: getProportionateScreenHeight(55)),
                      SizedBox(height: getProportionateScreenHeight(155)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget noDataFound() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: Get.width / 1.2,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Image.asset(
              "assets/nodata_found.png",
              height: Get.height / 3,
            ),
            Text("No data found!",
                style: TextStyle(color: Get.theme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget listReview(final List<ReviewModel> reviews, final MyPref myPref) {
    final double thisWidth = Get.width;
    return SizedBox(
      width: Get.width,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: reviews.map((e) {
          return Container(
              child: DetailRental.createSingleReview(thisWidth, e));
        }).toList(),
      ),
    );
  }

  final TextEditingController _query = TextEditingController();
  Widget inputSearch(final XController x) {
    _query.text = '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Get.theme.canvasColor,
            Get.theme.canvasColor.withOpacity(.98)
          ],
        ),
      ),
      child: SizedBox(
        width: Get.width,
        child: TextFormField(
          controller: _query,
          onChanged: (String? text) {
            final List<ReviewModel> latests = x.itemPassReview.value.reviews!;
            if (text!.isNotEmpty &&
                text.trim().isNotEmpty &&
                latests.isNotEmpty) {
              var models = latests.where((ReviewModel element) {
                return element.review!
                    .toLowerCase()
                    .contains(text.trim().toLowerCase());
              }).toList();

              if (models.isNotEmpty) {
                datas.value = models;
              } else {
                datas.value = [];
              }
            } else {
              datas.value = temps;
            }
          },
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(
              FontAwesome.search,
              size: 14,
              color: Get.theme.colorScheme.background,
            ),
            border: InputBorder.none,
            hintText: "type_keyword".tr,
            suffixIcon: InkWell(
              onTap: () {
                _query.text = '';
                datas.value = temps;
              },
              child: Icon(
                FontAwesome.remove,
                size: 14,
                color: Get.theme.colorScheme.background,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget topIcon(final XController x) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 0),
            child: const IconBack(),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              "${title ?? rentalModel!.title}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
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
}
