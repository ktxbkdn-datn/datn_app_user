import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar({
  required String title,
  required String message,
  Color backgroundColor = Colors.grey,
  Color? colorText,
  Duration duration = const Duration(seconds: 3),
  SnackPosition snackPosition = SnackPosition.BOTTOM,
  Widget? icon,
  TextButton? mainButton,
  bool isDismissible = false,
}) {
  Get.closeAllSnackbars();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: colorText ?? Colors.white,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: duration,
      isDismissible: isDismissible,
      icon: icon,
      mainButton: mainButton,
    );
  });
}