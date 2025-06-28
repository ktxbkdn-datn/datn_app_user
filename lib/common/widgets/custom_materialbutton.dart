
import 'package:flutter/material.dart';

class KtxButton extends StatelessWidget {
  Color buttonColor;
  Color textColor, borderSideColor; 
  String nameButton;
  final Function()? onTap;

  KtxButton({
    super.key,
    this.buttonColor = Colors.white,
    required this.nameButton,
    this.textColor = Colors.black,
    this.borderSideColor = Colors.black, 
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.infinity,
      onPressed: onTap,
      height: 60,
      color: onTap == null ? Colors.grey[300] : buttonColor, // Grey when disabled
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: onTap == null ? Colors.grey[400]! : borderSideColor, // Grey when disabled
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        nameButton,
        style: TextStyle(
          color: onTap == null ? Colors.grey[600] : textColor, // Grey when disabled
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}