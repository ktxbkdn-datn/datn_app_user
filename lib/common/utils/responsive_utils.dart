import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  // Padding, margin dựa trên kích thước màn hình
  static double hp(BuildContext context, double percent) => 
      MediaQuery.of(context).size.height * (percent / 100);
  static double wp(BuildContext context, double percent) => 
      MediaQuery.of(context).size.width * (percent / 100);
      
  // Safe area (tránh notch, camera, etc.)
  static EdgeInsets safeAreaInsets(BuildContext context) => 
      MediaQuery.of(context).padding;
      
  // Điều chỉnh font size theo kích thước màn hình
  static double sp(BuildContext context, double size) {
    // Giả sử thiết kế ban đầu cho màn hình 375x812 (iPhone X)
    var baseWidth = 375.0;
    return size * screenWidth(context) / baseWidth;
  }
  
  // Kiểm tra thiết bị là điện thoại, tablet hay desktop
  static bool isPhone(BuildContext context) => 
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1200;
      
  // Orientation
  static bool isPortrait(BuildContext context) => 
      MediaQuery.of(context).orientation == Orientation.portrait;
  static bool isLandscape(BuildContext context) => 
      MediaQuery.of(context).orientation == Orientation.landscape;

  // Tạo kích thước Grid dựa theo kích thước màn hình
  static double getResponsiveGridItemSize(BuildContext context, int columns) {
    final width = MediaQuery.of(context).size.width;
    double itemWidth;
    
    if (width < 600) {
      // Điện thoại: 2 cột
      itemWidth = (width - (16 * (2 + 1))) / 2;
    } else if (width < 1200) {
      // Tablet: columns hoặc 3 cột, tùy theo cái nào nhỏ hơn
      final cols = columns > 3 ? 3 : columns;
      itemWidth = (width - (16 * (cols + 1))) / cols;
    } else {
      // Desktop: columns cột
      itemWidth = (width - (16 * (columns + 1))) / columns;
    }
    
    return itemWidth;
  }
  
  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < 600) {
      return const EdgeInsets.all(16.0);
    } else if (width < 1200) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  // Responsive text theme
  static TextTheme getResponsiveTextTheme(BuildContext context, TextTheme baseTheme) {
    final scale = isPhone(context) ? 1.0 : (isTablet(context) ? 1.1 : 1.2);
    
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: (baseTheme.displayLarge?.fontSize ?? 96) * scale,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: (baseTheme.displayMedium?.fontSize ?? 60) * scale,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: (baseTheme.displaySmall?.fontSize ?? 48) * scale,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: (baseTheme.headlineLarge?.fontSize ?? 40) * scale,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: (baseTheme.headlineMedium?.fontSize ?? 34) * scale,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * scale,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: (baseTheme.titleLarge?.fontSize ?? 20) * scale,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * scale,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * scale,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * scale,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * scale,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * scale,
      ),
    );
  }
}
