import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/auth/sign_in_screen.dart';
import 'package:homerental/auth/sign_up_screen.dart';
import 'package:homerental/core/size_config.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/button_container.dart';

class IntroScreen extends StatelessWidget {
  final XController x = XController.to;

  IntroScreen({Key? key}) : super(key: key) {
    Future.delayed(const Duration(milliseconds: 2200), () {
      x.asyncLatitude();
      //x.asyncUuidToken();
    });
  }

  final PageController controller = PageController(initialPage: 0);

  final titles = [
    "Help you to rent futuristic home",
    "Your apartment dream in your pocket",
    "Seamless, single click to pay"
  ];
  final images = [
    'assets/slide05_trans.png',
    'assets/slide04_trans.png',
    'assets/slide03_trans.png'
  ];

  //int numberOfPages=3;
  //int currentPage=0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
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
          body: Container(
            width: Get.width,
            padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spaceHeight20,
                  spaceHeight5,
                  Container(
                    width: Get.width,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/icon_home220.png",
                          width: 30,
                          height: 35,
                        ),
                        Text(
                          MyTheme.appVersion,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            color: Get.theme.colorScheme.background,
                          ),
                        )
                      ],
                    ),
                  ),
                  //spaceHeight5,
                  pageController(),
                  Obx(() => createIndicator(indexSelected.value)),
                  spaceHeight20,
                  Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          debugPrint("sign in clicked..");
                          Get.to(SignInScreen(), transition: Transition.fadeIn);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: const ButtonContainer(
                            text: "Sign In",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          debugPrint("sign up clicked..");
                          Get.to(SignUpScreen(), transition: Transition.zoom);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: ButtonContainer(
                            text: "Sign Up",
                            linearGradient: LinearGradient(
                              colors: [
                                colorGrey,
                                colorGrey.withOpacity(.98),
                              ],
                            ),
                            boxShadow: BoxShadow(
                              color: Get.theme.disabledColor.withOpacity(.5),
                              blurRadius: 3.0,
                              offset: const Offset(1, 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  spaceHeight5,
                  // Container(
                  //   alignment: Alignment.center,
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Container(
                  //         margin: const EdgeInsets.only(right: 10),
                  //         color: Colors.black38,
                  //         width: Get.width / 3.3,
                  //         height: 0.5,
                  //       ),
                  //       const Text("Or", style: TextStyle(color: colorGrey)),
                  //       Container(
                  //         margin: const EdgeInsets.only(left: 10),
                  //         color: Colors.black38,
                  //         width: Get.width / 3.3,
                  //         height: 0.5,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // spaceHeight10,
                  // Container(
                  //   alignment: Alignment.center,
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       InkWell(
                  //         onTap: () {
                  //           EasyLoading.showToast("Dummy action...");
                  //         },
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           margin: const EdgeInsets.only(right: 20),
                  //           padding: const EdgeInsets.all(5),
                  //           decoration: BoxDecoration(
                  //             color: Colors.blue[900],
                  //             borderRadius: BorderRadius.circular(60),
                  //           ),
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(60),
                  //             child: const Icon(FontAwesome.facebook_f,
                  //                 size: 18, color: Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           EasyLoading.showToast("Dummy action...");
                  //         },
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           padding: const EdgeInsets.all(5),
                  //           margin: const EdgeInsets.only(right: 20),
                  //           decoration: BoxDecoration(
                  //             color: Colors.red,
                  //             borderRadius: BorderRadius.circular(60),
                  //           ),
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(60),
                  //             child: const Icon(FontAwesome.google_plus,
                  //                 size: 15, color: Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           EasyLoading.showToast("Dummy action...");
                  //         },
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           padding: const EdgeInsets.all(5),
                  //           margin: const EdgeInsets.only(right: 0),
                  //           decoration: BoxDecoration(
                  //             color: Colors.black,
                  //             borderRadius: BorderRadius.circular(60),
                  //           ),
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(60),
                  //             child: const Icon(FontAwesome.apple,
                  //                 size: 18, color: Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  spaceHeight50,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final indexSelected = 0.obs;

  Widget pageController() {
    return SizedBox(
      width: Get.width,
      height: Get.height / 2.3,
      child: PageView.builder(
        onPageChanged: (int index) {
          indexSelected.value = index;
        },
        controller: controller,
        itemCount: titles.length,
        itemBuilder: (BuildContext context, int index) {
          return eachPage(titles[index], images[index]);
        },
      ),
    );
  }

  Widget eachPage(final String title, final String image) {
    return Container(
      color: Colors.transparent,
      width: Get.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(55),
            ),
            child: Image.asset(
              image,
              fit: BoxFit.scaleDown,
              height: getProportionateScreenHeight(300),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  /// Size of points
  final double size = 8.0;

  /// Spacing of points
  final double spacing = 4.0;

  Widget createIndicator(final int selectedIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(titles.length, (int index) {
        return _buildIndicator(
            index, titles.length, size, spacing, selectedIndex);
      }),
    );
  }

  Widget _buildIndicator(int index, int pageCount, double dotSize,
      double spacing, int selectedIndex) {
    // Is the current page selected?
    bool isCurrentPageSelected = index == selectedIndex;

    return SizedBox(
      height: size,
      width: size + (2 * spacing),
      child: Center(
        child: Material(
          color: isCurrentPageSelected
              ? Get.theme.colorScheme.secondary
              : Get.theme.disabledColor,
          type: MaterialType.circle,
          child: SizedBox(
            width: dotSize,
            height: dotSize,
          ),
        ),
      ),
    );
  }
}
