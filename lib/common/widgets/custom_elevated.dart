import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? buttonWidth;
  final VoidCallback onPressed;
  final String text;
  Color? backgroundColor = Colors.blueAccent;
  Color? foregroundColor = Colors.white;
  double? textFontSize = 16;
  FontWeight? textFontWeight = FontWeight.bold;
  CustomElevatedButton({
    Key ? key, this.buttonWidth, required this.onPressed, required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.textFontSize,
    this.textFontWeight,
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: buttonWidth ?? MediaQuery.of(context).size.width - 100,
      child: ElevatedButton(
        onPressed   : onPressed,
        child       : Text(
            text,
            style: TextStyle(
              fontSize: textFontSize,
              fontWeight: textFontWeight,
            ),
        ),
        style       : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            splashFactory: NoSplash.splashFactory,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 1.5,
                )
            )
        ),),
    );
  }
}

