import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/app/my_home.dart';
import 'package:homerental/auth/sign_in_screen.dart';
import 'package:homerental/core/firebase_auth_service.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/core/size_config.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:homerental/main.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/button_container.dart';
import 'package:homerental/widgets/icon_back.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key) {
    Future.delayed(const Duration(milliseconds: 2200), () {
      x.asyncUuidToken();
    });
  }

  final XController x = XController.to;

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
            mainBackgroundcolor3,
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
            body: Container(
              width: Get.width,
              height: Get.height,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 30, left: 10),
                      child: const Text(
                        "Free Registration",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: const Text(
                        "Find more benefits with our units and services. Just take a few minutes process",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    spaceHeight20,
                    inputFullname(),
                    spaceHeight20,
                    inputEmail(),
                    spaceHeight20,
                    inputPassword(),
                    spaceHeight20,
                    inputRePassword(),
                    spaceHeight10,
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: FractionalOffset.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'By Signing up ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: fontFamily,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'you accept the ${MyTheme.appName}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              TextSpan(
                                text: ' User Agreement and Privacy & Policy',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // navigate to desired screen
                                    debugPrint("User agreement clicked...");
                                  },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            debugPrint("signin up clicked..");
                            String nm = textFullname.value;
                            String em = textEmail.value;
                            String pass = textPassword.value;
                            String repass = textRePassword.value;

                            if (nm
                                .trim()
                                .length < 4) {
                              MyTheme.showSnackbar(
                                  'Fullname invalid! Min 4 characters');
                              return;
                            }

                            if (em
                                .trim()
                                .length < 3 || !GetUtils.isEmail(em)) {
                              MyTheme.showSnackbar("Email invalid!");
                              return;
                            }

                            if (pass
                                .trim()
                                .length < 6) {
                              MyTheme.showSnackbar(
                                  "Password invalid!, Min. 6 aplhanumeric!");
                              return;
                            }

                            if (repass
                                .trim()
                                .length < 6) {
                              MyTheme.showSnackbar(
                                  "Re-Password invalid!, Min. 6 aplhanumeric!");
                              return;
                            }

                            if (pass.trim() != repass.trim()) {
                              MyTheme.showSnackbar(
                                  "Password & RePassword not equal!");
                              return;
                            }

                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');

                            CoolAlert.show(
                                context: Get.context!,
                                backgroundColor: Get.theme.canvasColor,
                                type: CoolAlertType.confirm,
                                text:
                                'Do you want to procced this registration with email $em?',
                                confirmBtnText: 'Yes',
                                cancelBtnText: 'No',
                                confirmBtnColor: Colors.green,
                                onConfirmBtnTap: () async {
                                  Get.back();
                                  Future.microtask(() => pushRegister(x));
                                });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: const ButtonContainer(
                              text: "Signing Up",
                            ),
                          ),
                        ),
                      ),
                    ),
                    spaceHeight20,
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                              text: 'Already have account? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: fontFamily,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'LogIn Here',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      fontFamily: fontFamily,
                                      fontSize: 16,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // navigate to desired screen
                                        Get.back();
                                        Future.microtask(() =>
                                            Get.to(
                                                SignInScreen(),
                                                transition: Transition
                                                    .cupertino));
                                      })
                              ]),
                        ),
                      ),
                    ),
                    spaceHeight50,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // fullname
  final textFullname = ''.obs;
  final TextEditingController _fullname = TextEditingController();

  Widget inputFullname() {
    _fullname.text = textFullname.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
          controller: _fullname,
          onChanged: (text) {
            textFullname.value = text;
          },
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.text,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(
              FontAwesome.user,
              size: 18,
              color: Get.theme.colorScheme.background,
            ),
            border: InputBorder.none,
            hintText: "Fullname",
          ),
        ),
      ),
    );
  }

  // email address
  final textEmail = ''.obs;
  final TextEditingController _email = TextEditingController();

  Widget inputEmail() {
    _email.text = textEmail.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
          controller: _email,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (!GetUtils.isEmail(value!)) {
              return "Email invalid!";
            } else {
              return null;
            }
          },
          onChanged: (text) {
            textEmail.value = text;
          },
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(
              FontAwesome.envelope,
              size: 18,
              color: Get.theme.colorScheme.background,
            ),
            border: InputBorder.none,
            hintText: "Email",
          ),
        ),
      ),
    );
  }

  // password
  final textPassword = ''.obs;
  final isSecured = true.obs;
  final TextEditingController _password = TextEditingController();

  Widget inputPassword() {
    _password.text = textPassword.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
        child: Obx(
              () =>
              TextFormField(
                controller: _password,
                onChanged: (text) {
                  textPassword.value = text;
                },
                obscureText: isSecured.value,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    FontAwesome.key,
                    size: 18,
                    color: Get.theme.colorScheme.background,
                  ),
                  border: InputBorder.none,
                  hintText: "Password",
                  suffixIcon: InkWell(
                    onTap: () {
                      isSecured.value = !isSecured.value;
                    },
                    child: Icon(
                      isSecured.value ? FontAwesome.eye : FontAwesome.eye_slash,
                      size: 18,
                      color: Get.theme.colorScheme.background,
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // re-password
  final textRePassword = ''.obs;
  final isSecuredRe = true.obs;
  final TextEditingController _repassword = TextEditingController();

  Widget inputRePassword() {
    _repassword.text = textRePassword.value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
        child: Obx(
              () =>
              TextFormField(
                controller: _repassword,
                onChanged: (text) {
                  textRePassword.value = text;
                },
                obscureText: isSecuredRe.value,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    FontAwesome.key,
                    size: 18,
                    color: Get.theme.colorScheme.background,
                  ),
                  border: InputBorder.none,
                  hintText: "Retype Password",
                  suffixIcon: InkWell(
                    onTap: () {
                      isSecuredRe.value = !isSecuredRe.value;
                    },
                    child: Icon(
                      isSecuredRe.value ? FontAwesome.eye : FontAwesome
                          .eye_slash,
                      size: 18,
                      color: Get.theme.colorScheme.background,
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

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
              "Sign Up",
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
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              child: Image.asset(
                "assets/icon_home220.png",
                width: 22,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //push registration
  pushRegister(final XController x) async {
    EasyLoading.show(status: 'Loading...');

    String em = textEmail.value.toString().trim();
    String ps = textPassword.value.toString().trim();

    // check email first
    bool passChecked = false;
    try {
      final datapush = {
        "em": em,
      };

      debugPrint(jsonEncode(datapush));

      final response = await x.provider
          .pushResponse('api/checkEmailPhone', jsonEncode(datapush));
      if (response != null && response.statusCode == 200) {
        dynamic dataresult = jsonDecode(response.bodyString!);
        //debugPrint(_result);

        if (dataresult['code'] != '200') {
          passChecked = true;
        }
      }
    } catch (e) {
      debugPrint("");
    }

    try {
      if (!passChecked) {
        EasyLoading.dismiss();

        EasyLoading.showToast("Email already exist, try another one");
        return;
      }

      // push email Firebase
      FirebaseAuthService fauth = x.notificationFCMManager.firebaseAuthService;
      await fauth.firebaseSignUpByEmailPwd(em, ps);

      await Future.delayed(const Duration(milliseconds: 1200));

      String? uid = await fauth.getFirebaseUserId();
      if (uid == null) {
        EasyLoading.dismiss();
        return;
      }

      final MyPref myPref = MyPref.to;

      final datapush = {
        "em": em,
        "ps": ps,
        "is": x.install['id_install'] ?? "",
        "lat": myPref.pLatitude.val,
        "loc": myPref.pLocation.val,
        "cc": myPref.pCountry.val,
        "fn": textFullname.value.toString().trim(),
        "uf": uid,
      };

      //debugPrint(datapush);

      final response =
      await x.provider.pushResponse('api/register', jsonEncode(datapush));
      //debugPrint(response);

      if (response != null && response.statusCode == 200) {
        EasyLoading.dismiss();
        dynamic dataresult = jsonDecode(response.bodyString!);

        if (dataresult['code'] == '200') {
          dynamic member = dataresult['result'][0];

          Future.microtask(() => successRegister(x, member));
          Future.delayed(const Duration(milliseconds: 2200), () {
            Get.offAll(MyHome());
          });
        } else {
          await Future.delayed(const Duration(milliseconds: 2200), () async {
            EasyLoading.dismiss();

            CoolAlert.show(
              backgroundColor: Get.theme.colorScheme.background,
              context: Get.context!,
              type: CoolAlertType.error,
              text: "${dataresult['message']}",
              //autoCloseDuration: Duration(seconds: 10),
            );

            await Future.delayed(const Duration(milliseconds: 2200), () {
              x.notificationFCMManager.firebaseAuthService.signOut();
            });
          });
        }
      } else {
        EasyLoading.dismiss();
        await Future.delayed(const Duration(milliseconds: 2200), () {
          x.notificationFCMManager.firebaseAuthService.signOut();
        });
      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  static successRegister(final XController x, final dynamic member) async {
    //dynamic member = _result['result'][0];

    x.doLogin(member);

    await Future.delayed(const Duration(milliseconds: 3200), () {
      EasyLoading.dismiss();
    });
  }
}
