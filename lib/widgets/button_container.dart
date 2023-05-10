import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonContainer extends StatelessWidget {
  final String text;
  final VoidCallback? callback;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final double? sizeText;
  final LinearGradient? linearGradient;
  final BoxShadow? boxShadow;

  const ButtonContainer({
    Key? key,
    required this.text,
    this.callback,
    this.paddingHorizontal,
    this.paddingVertical,
    this.sizeText,
    this.linearGradient,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal ?? 0, vertical: paddingVertical ?? 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          boxShadow ??
              BoxShadow(
                color: Get.theme.primaryColor,
                blurRadius: 3.0,
                offset: const Offset(1, 2),
              )
        ],
        gradient: linearGradient ??
            LinearGradient(
              colors: [
                Get.theme.primaryColor,
                Get.theme.primaryColor.withOpacity(.95),
              ],
            ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: sizeText ?? 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
