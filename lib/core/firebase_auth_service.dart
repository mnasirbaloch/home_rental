import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/models/user_model.dart';
import 'package:homerental/auth/succes_signup_screen.dart';
import 'package:homerental/theme.dart';

class FirebaseAuthService {
  MyPref? _box = Get.find<MyPref>();
  MyPref get box => _box!;

  setBox(final MyPref box) {
    _box = box;
  }

  FirebaseAuthService._internal() {
    // save the client so that it can be used else where
    _firebaseAuth = FirebaseAuth.instance;

    try {
      var isLogged = box.pLogin.val;
      logPrint("isLogged: $isLogged");
      if (isLogged) {
        getFirebaseUserId();
        listenUserChange();
      }
    } catch (e) {
      debugPrint("");
    }
  }

  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  static FirebaseAuthService get instance => _instance;

  FirebaseAuth? _firebaseAuth;
  FirebaseAuth get firebaseAuth => _firebaseAuth!;

  User? _firebaseUser;
  User get firebaseUser => _firebaseUser!;

  isSignedIn() async {
    if (_firebaseAuth == null) return false;
    return (_firebaseAuth!.currentUser != null);
  }

  dynamic _member;
  dynamic get member => _member;

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  listenUserChange() {
    _firebaseAuth!.authStateChanges().listen((User? user) {
      if (user == null) {
        logPrint('User is currently signed out!');
        var isLogged = false;

        try {
          isLogged = box.pLogin.val;
        } catch (e) {
          debugPrint("");
        }

        if (isLogged) {
          //reauthenticating
          var mmb = box.pMember.val;
          if (mmb != '') {
            _member = jsonDecode(mmb);
            _userModel = UserModel.fromJson(_member);
            //logPrint(member);

            reAuthentication(userModel.email!, getPassword()!);
          }
        }
      } else {
        logPrint('User is signed in!');
        _firebaseUser = user;
      }
    });
  }

  getFirebaseUserId() async {
    try {
      _firebaseUser = _firebaseAuth!.currentUser;
      return (_firebaseUser == null) ? null : _firebaseUser!.uid;
    } catch (e) {
      debugPrint("");
    }

    return null;
  }

  firebaseSignInByEmailPwd(String email, String passwd) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, //"barry.allen@example.com",
        password: passwd, //"SuperSecretPassword!",
      );

      _firebaseUser = userCredential.user;
      savePassword(passwd);

      try {
        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
          EasyLoading.dismiss();
          showEmailVerifyDialog();
        }
      } catch (e) {
        debugPrint("");
      }

      // listen
      listenUserChange();

      //EasyLoading.showSuccess("Login success...");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        logPrint('No user found for that email.');

        //await firebaseSignUpByEmailPwd(email, passwd);
      } else if (e.code == 'wrong-password') {
        logPrint('Wrong password provided for that user.');
      }
    }
  }

  gotoEmailVerifyScreen(final bool usingPhone) async {
    logPrint("gotoEmailVerifyScreen is running");
    try {
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }
    } catch (e) {
      logPrint("Error gotoEmailVerifyScreen $e");
    }

    EasyLoading.dismiss();
    Get.offAll(SuccessSignup(usingPhone: usingPhone));
  }

  static showEmailVerifyDialog() {
    CoolAlert.show(
      context: Get.context!,
      backgroundColor: Get.theme.canvasColor,
      type: CoolAlertType.info,
      text:
          "Already sent to your email for verification, click link in your body email to procced registration successfully...",
      title: 'Information',
      onConfirmBtnTap: () {
        Get.back();
      },
      //autoCloseDuration: Duration(seconds: 10),
    );
  }

  savePassword(String? ppaswd) {
    box.pPassword.val = ppaswd!;
  }

  getPassword() {
    return box.pPassword.val;
  }

  final getVerificationId = "".obs;
  loginPhoneUser(String phone) async {
    FirebaseAuth fauth = FirebaseAuth.instance;

    fauth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        logPrint("[FirebaseAuth] verificationCompleted");
        UserCredential result = await fauth.signInWithCredential(credential);
        User? user = result.user;

        if (user != null) {
          _firebaseUser = user;
        } else {
          logPrint("[FirebaseAuth] Error user is Null");
        }
      },
      verificationFailed: (FirebaseAuthException exception) {
        logPrint("[FirebaseAuth] $exception");
      },
      codeSent: (String? verificationId, [int? forceResendingToken]) {
        logPrint("[FirebaseAuth] showDialog SMS Code");
        getVerificationId.value = verificationId!;
      },
      codeAutoRetrievalTimeout: (String? text) {
        logPrint("text: $text");
      },
    );
  }

  doVerifyCode(final String smsCode) async {
    logPrint("doVerifyCode smsCode: $smsCode");

    FirebaseAuth fauth = FirebaseAuth.instance;
    try {
      String? verificationId = getVerificationId.value;
      //String smsCode = 'xxxx';

      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      // Sign the user in (or link) with the credential
      UserCredential result = await fauth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        logPrint("[FirebaseAuth] doVerifyCode success uid ${user.uid}");
        _firebaseUser = user;

        Future.microtask(() => listenUserChange());
      } else {
        logPrint("[FirebaseAuth] doVerifyCode Error user is Null");
      }
    } catch (e) {
      logPrint("doVerifyCode error: ${e.toString()}");
      EasyLoading.showToast(
          "You have to many login attemps, try a few hours later...");
    }
  }

  firebaseUpdatePassword(final String? newPassword) async {
    //User currentUser = firebaseUser;
    User currentUser = FirebaseAuth.instance.currentUser!;
    currentUser.updatePassword(newPassword!).then((_) {
      // Password has been updated.
      //_firebaseAuth!.currentUser!.updatePassword(newPassword);
      _firebaseUser = currentUser;
      logPrint("UpdatePassword success");

      savePassword(newPassword);

      Future.delayed(const Duration(seconds: 2), () {
        //reAuthentication(currentUser.email!, newPassword);
      });
    }).catchError((err) {
      // An error has occured.
      logPrint("Error: updatePassword ${err.toString()}");
    });
  }

  firebaseSignUpByEmailPwd(String email, String passwd) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email, //"barry.allen@example.com",
        password: passwd, //"SuperSecretPassword!",
      );
      _firebaseUser = userCredential.user;

      try {
        savePassword(passwd);
      } catch (e) {
        debugPrint("");
      }

      try {
        if (!userCredential.user!.emailVerified) {
          userCredential.user!.sendEmailVerification();
        }

        gotoEmailVerifyScreen(false);
      } catch (e) {
        debugPrint("");
      }

      // listen
      listenUserChange();

      //EasyLoading.showSuccess("Process success...");
    } on FirebaseAuthException catch (e) {
      String datamsg = 'The password provided is too weak.';
      if (e.code == 'weak-password') {
        logPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        logPrint('The account already exists for that email.');
        datamsg = 'The account already exists for that email.';
      }

      EasyLoading.showError('Error: $datamsg');
    } catch (e) {
      logPrint(e);

      EasyLoading.showError('Error: $e');
    }
  }

  reAuthentication(final String email, final String password) async {
    try {
      // Create a credential
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);

      // Reauthenticate
      final UserCredential userCredential = await _firebaseAuth!.currentUser!
          .reauthenticateWithCredential(credential);

      _firebaseUser = userCredential.user;

      // listen
      listenUserChange();
    } catch (e) {
      debugPrint("");
    }
  }

  signOut() async {
    await _firebaseAuth!.signOut();
  }
}
