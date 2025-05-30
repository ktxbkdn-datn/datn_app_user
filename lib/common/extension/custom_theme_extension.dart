import 'package:flutter/material.dart';

import '../KColor.dart';

extension ExtendedTheme on BuildContext{
  CustomThemeExtension get theme{
    return Theme.of(this).extension<CustomThemeExtension>()!;
  }
}
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension>{
  static const lightMode = CustomThemeExtension(
    circleImageColor        : Color(0xff25d366),
    greyColor               : KColors.greyLight,
    blueColor               : KColors.blueLight,
    langBtnBgColor          : Color(0xfff7f8fa),
    langBtnHighlightColor   : Color(0xffe8eed),
    authAppbarTextColor     : KColors.greyLight,
  );
  static const darkMode = CustomThemeExtension(
    circleImageColor        : KColors.greenDark,
    greyColor               : KColors.greyDark,
    blueColor               : KColors.blueDark,
    langBtnBgColor          : Color(0xff182229),
    langBtnHighlightColor   : Color(0xff09141a),
    authAppbarTextColor     : KColors.greyDark,
  );

  final Color? circleImageColor;
  final Color? greyColor;
  final Color? blueColor;
  final Color? langBtnBgColor;
  final Color? langBtnHighlightColor;
  final Color? authAppbarTextColor;
  const CustomThemeExtension({
    this.circleImageColor,
    this.greyColor,
    this.blueColor,
    this.langBtnBgColor,
    this.langBtnHighlightColor,
    required  this.authAppbarTextColor
  });
  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? circleImageColor,
    Color? greyColor,
    Color? blueColor,
    Color? langBtnBgColor,
    Color? langBtnHighlightColor,
  }) {
    // TODO: implement copyWith
    return CustomThemeExtension(
      circleImageColor      :  circleImageColor      ?? this.circleImageColor,
      greyColor             :  greyColor             ?? this.greyColor,
      blueColor             :  blueColor             ?? this.blueColor,
      langBtnBgColor        :  langBtnBgColor        ?? this.langBtnBgColor,
      langBtnHighlightColor :  langBtnHighlightColor ?? this.langBtnHighlightColor,
      authAppbarTextColor   :  authAppbarTextColor   ?? this.authAppbarTextColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(covariant ThemeExtension<CustomThemeExtension>? other, double t) {
    if(other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      circleImageColor        : Color.lerp(circleImageColor     , other.circleImageColor      , t),
      greyColor               : Color.lerp(greyColor            , other.greyColor             , t),
      blueColor               : Color.lerp(blueColor            , other.blueColor             , t),
      langBtnBgColor          : Color.lerp(langBtnBgColor       , other.langBtnBgColor        , t),
      langBtnHighlightColor   : Color.lerp(langBtnHighlightColor, other.langBtnHighlightColor , t),
      authAppbarTextColor     : Color.lerp(authAppbarTextColor  , other.authAppbarTextColor   , t),
    );
  }
  
  
}