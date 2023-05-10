import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:homerental/theme.dart';

class IconBack extends StatelessWidget {
  final VoidCallback? callback;
  const IconBack({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (callback != null) {
          callback!();
        } else {
          Get.back();
        }
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Icon(
          FontAwesome.chevron_left,
          size: 13,
          color: Get.theme.disabledColor,
        ),
      ),
    );
  }
}
