
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
      color: buttonColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: borderSideColor, 
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        nameButton,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}