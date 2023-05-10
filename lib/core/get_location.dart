import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:homerental/core/my_pref.dart';
import 'package:homerental/core/xcontroller.dart';
import 'package:intl/intl.dart';

class GetLocation {
  MyPref? _box = Get.find<MyPref>();
  MyPref get box => _box!;

  setBox(final MyPref box) {
    _box = box;
  }

  GetLocation._internal() {
    debugPrint("GetLocation._internal...");
    init();
  }

  static final GetLocation _instance = GetLocation._internal();
  static GetLocation get instance => _instance;

  Position? _position;
  Position get position => _position!;

  String? _latitude;
  String get latitude => _latitude ?? "";

  String? _currentAddress;
  String get currentAddress => _currentAddress ?? "";

  String? _country;
  String get country => _country ?? "";

  String? _shortAddr;
  String get shortAddr => _shortAddr ?? "";

  init() async {
    debugPrint("init geolocation...");
    getLatitudeAddress();

    try {
      //await Geolocator.requestPermission();
      LocationPermission checkLocation = await Geolocator.checkPermission();
      if (checkLocation == LocationPermission.denied ||
          checkLocation == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint("");
    }

    try {
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      ).then((Position? position) {
        if (position != null) {
          _position = position;

          saveLatitude(_position!);
        }
      });
    } catch (e) {
      debugPrint("");
    }

    Future.microtask(() => listenStreamPosition());
  }

  final isDoneListener = false.obs;

  listenStreamPosition() {
    debugPrint(
        " listenStreamPosition get latest latitude already check ${isDoneListener.value}");

    if (isDoneListener.value && box.pLatitude.val != '') return;

    final locationSetting = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1000 * 1,
      //forceAndroidLocationManager: true,
      timeLimit: Duration(milliseconds: latitude == "" ? 1000 : 1000 * 120),
    );

    Geolocator.getPositionStream(locationSettings: locationSetting)
        .listen((Position? position) {
      if (position != null) {
        debugPrint(
            " listenStreamPosition listener updated ${DateFormat.Hms().format(DateTime.now())}");
        saveLatitude(position);

        Future.delayed(const Duration(milliseconds: 800), () {
          XController.to.asyncLatitude();

          isDoneListener.value = true;
        });
      }
    });
  }

  getLatitudeAddress() {
    try {
      String lat = box.pLatitude.val;
      if (lat != '') {
        _latitude = lat;
        debugPrint(latitude.toString());
      }
    } catch (e) {
      debugPrint("");
    }

    try {
      String add = box.pLocation.val;
      if (add != '') {
        _currentAddress = add;

        String firstAddress = getSplitCurrentAddress(1).trim();
        if (firstAddress == '') {
          firstAddress = getSplitCurrentAddress(2).trim();
        }
        _shortAddr = "$firstAddress ${getSplitCurrentAddress(5).trim()}";
        debugPrint(_shortAddr);
      } else {
        if (latitude != '') {
          var split = latitude.split(",");
          getAddressFromLatitude(
              double.parse(split[0]), double.parse(split[1]));
        }
      }
    } catch (e) {
      debugPrint("");
    }
  }

  saveLatitude(final Position position) {
    _position = position;
    _latitude = "${position.latitude},${position.longitude}";

    debugPrint("saveLatitude: $latitude");

    //box.put(MyTheme.prefLatitude, _latitude);
    box.pLatitude.val = latitude;
    getAddressFromLatitude(position.latitude, position.longitude);

    //Future.microtask(() => XController.to.asyncLatitude());
  }

  getAddressFromLatitude(double getLatitude, double getLongitude) async {
    if (_latitude != null && latitude != '') {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(getLatitude, getLongitude);
      Placemark place = placemarks[0];
      _currentAddress =
          "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}, ${place.isoCountryCode}, ${place.postalCode}";

      String locality = place.subLocality ?? '';
      if (locality.trim() == '') {
        locality = "${place.locality}";
      }

      _country = "${place.isoCountryCode}";
      _shortAddr = "${locality.trim()}, ${place.isoCountryCode}";

      debugPrint(shortAddr);
      debugPrint(currentAddress);

      box.pAddress.val = shortAddr;
      box.pLocation.val = currentAddress;
      box.pCountry.val = country;
      //box.put(MyTheme.prefLocation, currentAddress);
      //box.put(MyTheme.prefCountry, country);
    }
  }

  String getShortCurrentAddress() {
    var result = "";
    if (_currentAddress != null) {
      var split = _currentAddress!.split(",");
      result = "${split[1]} ${split[2]}";
      //return result;
    } else {
      var getAdd = box.pLocation.val;
      if (getAdd.isNotEmpty) {
        _currentAddress = getAdd;
        return getShortCurrentAddress();
      }
    }

    return result;
  }

  String getSplitCurrentAddress(index) {
    var result = "";

    try {
      if (_currentAddress != null) {
        var split = _currentAddress!.split(",");
        result = split[index]; // + " " + split[2];
      } else {
        var getAdd = box.pLocation.val;
        if (getAdd.isNotEmpty) {
          _currentAddress = getAdd;
          return getSplitCurrentAddress(index);
        }
      }
    } catch (e) {
      debugPrint("");
    }

    return result;
  }
}
