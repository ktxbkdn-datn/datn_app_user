import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoSpellCheckText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextHeightBehavior? textHeightBehavior;
  final bool? softWrap;
  final String? semanticsLabel;
  final StrutStyle? strutStyle;

  const NoSpellCheckText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textHeightBehavior,
    this.softWrap,
    this.semanticsLabel,
    this.strutStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a special style that helps prevent spell check highlighting
    final finalStyle = style?.copyWith(
      // Adding height and letterSpacing can help prevent spell check
      height: style?.height ?? 1.0,
      letterSpacing: style?.letterSpacing ?? 0.0,
      // Force non-default font helps prevent spell check in some cases
      fontFamily: style?.fontFamily ?? 'System',
      // Adding decoration can help prevent spell check in some cases
      decoration: style?.decoration ?? TextDecoration.none,
    ) ?? const TextStyle(
      height: 1.0,
      fontFamily: 'System',
      decoration: TextDecoration.none,
    );
    
    // Use a stack with ClipRect to prevent spell check underlines
    return Stack(
      children: [
        ClipRect(
          child: Text(
            text,
            style: finalStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            semanticsLabel: semanticsLabel ?? text,
            textHeightBehavior: textHeightBehavior,
            softWrap: softWrap,
            strutStyle: strutStyle,
          ),
        ),
      ],
    );
  }
}
