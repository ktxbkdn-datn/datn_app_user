import 'package:flutter/material.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';

/// Extension trên Widget để dễ dàng áp dụng các padding và margin responsive
extension ResponsiveWidgetExtension on Widget {
  /// Áp dụng padding responsive theo tỷ lệ phần trăm của kích thước màn hình
  Widget paddingAll(BuildContext context, double percent) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.wp(context, percent)),
      child: this,
    );
  }

  /// Padding theo chiều ngang
  Widget paddingHorizontal(BuildContext context, double percent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(context, percent)),
      child: this,
    );
  }

  /// Padding theo chiều dọc
  Widget paddingVertical(BuildContext context, double percent) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(context, percent)),
      child: this,
    );
  }

  /// Padding với các giá trị tùy chỉnh
  Widget paddingOnly(BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveUtils.wp(context, left),
        top: ResponsiveUtils.hp(context, top),
        right: ResponsiveUtils.wp(context, right),
        bottom: ResponsiveUtils.hp(context, bottom),
      ),
      child: this,
    );
  }

  /// Áp dụng margin responsive theo tỷ lệ phần trăm của kích thước màn hình
  Widget marginAll(BuildContext context, double percent) {
    return Container(
      margin: EdgeInsets.all(ResponsiveUtils.wp(context, percent)),
      child: this,
    );
  }

  /// Margin theo chiều ngang
  Widget marginHorizontal(BuildContext context, double percent) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(context, percent)),
      child: this,
    );
  }

  /// Margin theo chiều dọc
  Widget marginVertical(BuildContext context, double percent) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(context, percent)),
      child: this,
    );
  }

  /// Margin với các giá trị tùy chỉnh
  Widget marginOnly(BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: ResponsiveUtils.wp(context, left),
        top: ResponsiveUtils.hp(context, top),
        right: ResponsiveUtils.wp(context, right),
        bottom: ResponsiveUtils.hp(context, bottom),
      ),
      child: this,
    );
  }

  /// Thêm kích thước tương đối với chiều rộng màn hình
  Widget withWidth(BuildContext context, double percent) {
    return SizedBox(
      width: ResponsiveUtils.wp(context, percent),
      child: this,
    );
  }

  /// Thêm kích thước tương đối với chiều cao màn hình
  Widget withHeight(BuildContext context, double percent) {
    return SizedBox(
      height: ResponsiveUtils.hp(context, percent),
      child: this,
    );
  }

  /// Áp dụng font size responsive
  Widget withResponsiveText(BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    if (this is Text) {
      final Text textWidget = this as Text;
      return Text(
        textWidget.data ?? '',
        style: (textWidget.style ?? const TextStyle()).copyWith(
          fontSize: fontSize != null ? ResponsiveUtils.sp(context, fontSize) : null,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: textAlign ?? textWidget.textAlign,
        maxLines: maxLines ?? textWidget.maxLines,
        overflow: overflow ?? textWidget.overflow,
      );
    }
    return this;
  }

  /// Widget thích ứng với kích thước màn hình
  Widget responsive(BuildContext context, {
    Widget Function(BuildContext)? phone,
    Widget Function(BuildContext)? tablet,
    Widget Function(BuildContext)? desktop,
  }) {
    if (ResponsiveUtils.isPhone(context) && phone != null) {
      return phone(context);
    } else if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet(context);
    } else if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop(context);
    }
    return this;
  }
}
