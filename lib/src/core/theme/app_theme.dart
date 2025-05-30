import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.white, // Primary color: White
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.grey, // Dùng grey để tạo color scheme
        accentColor: Colors.grey[200], // Màu phụ: Grey[200]
      ).copyWith(
        primary: Colors.white, // Đảm bảo primary color là trắng
        onPrimary: Colors.black, // Văn bản/icon trên primary color là đen
        secondary: Colors.black, // Secondary color: Black
        onSecondary: Colors.white, // Văn bản/icon trên secondary color là trắng
        surface: Colors.white, // Đảm bảo màu bề mặt (bao gồm TextField) là trắng
        onSurface: Colors.black, // Văn bản trên bề mặt (bao gồm TextField) là đen
      ),
      scaffoldBackgroundColor: Colors.white, // Nền của Scaffold là trắng
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // AppBar màu trắng
        foregroundColor: Colors.black, // Icon và text trên AppBar màu đen
        elevation: 0, // Không có bóng cho AppBar
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Văn bản chính màu đen
        bodyMedium: TextStyle(color: Colors.black), // Văn bản phụ màu đen
        titleLarge: TextStyle(color: Colors.black), // Tiêu đề lớn màu đen
        bodySmall: TextStyle(color: Colors.black), // Đảm bảo các kiểu văn bản khác cũng màu đen
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black, // Màu nút mặc định: Đen
        textTheme: ButtonTextTheme.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black), // Viền màu đen
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Nền của ElevatedButton: Đen
          foregroundColor: Colors.white, // Text/icon trên ElevatedButton: Trắng
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black), // Viền mặc định màu đen
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black), // Viền khi focus màu đen
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black), // Viền khi không focus màu đen
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black), // Viền khi disabled màu đen
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red), // Viền khi có lỗi màu đỏ
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red), // Viền khi focus và có lỗi màu đỏ
        ),
        filled: true,
        fillColor: Colors.grey[200], // Nền của TextField: Grey[200]
        labelStyle: const TextStyle(color: Colors.black), // Label màu đen
        hintStyle: const TextStyle(color: Colors.black54), // Hint màu đen nhạt
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding bên trong TextField
        // Đảm bảo văn bản gõ ra là màu đen
        floatingLabelStyle: const TextStyle(color: Colors.black), // Label khi nổi lên màu đen
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black, // Màu con trỏ: Đen
        selectionColor: Colors.black26, // Màu vùng chọn: Đen nhạt
        selectionHandleColor: Colors.black, // Màu tay cầm vùng chọn: Đen
      ),
      cardTheme: CardThemeData(
        color: Colors.white, // Nền của Card: Trắng
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}