import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homerental/theme.dart';

class MyPref {
  static MyPref get to => Get.find<MyPref>();
  static GetStorage _box() {
    return GetStorage(myStorageName);
  }

  //chat utility
  final pOnChatScreen = ReadWriteValue('p_onchatsreen', '', _box);

  //currency
  final pCurrency = ReadWriteValue('p_currency', 'USD', _box);
  final pLang = ReadWriteValue('p_lang', 'en', _box);

  //member & install
  final pUUID = ReadWriteValue('p_uuid', '', _box);
  final pTokenFCM = ReadWriteValue('p_tokenfcm', '', _box);
  final pFirst = ReadWriteValue('p_first', false, _box);

  final pLogin = ReadWriteValue('p_login', false, _box);
  final pInstall = ReadWriteValue('p_install', '', _box);
  final pMember = ReadWriteValue('p_member', '', _box);
  final pPassword = ReadWriteValue('p_password', '', _box);

  final pHome = ReadWriteValue('p_home', '', _box);
  final pSetting = ReadWriteValue('p_setting', '', _box);
  //member & install

  //location
  final pLatitude = ReadWriteValue('p_latitude', '', _box);
  final pLocation = ReadWriteValue('p_location', '', _box);
  final pCountry = ReadWriteValue('p_country', '', _box);
  final pAddress = ReadWriteValue('p_address', '', _box);
  //location
}
