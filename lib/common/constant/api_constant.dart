import 'package:flutter/foundation.dart' show kIsWeb;

String getAPIbaseUrl() {
  if (kIsWeb) {
    // Trên web, sử dụng localhost hoặc IP của máy host
    return 'http://localhost:5000/api';
    // Nếu bạn chạy API trên một IP khác, thay localhost bằng IP của máy (ví dụ: 'http://192.168.x.x:5000/api')
  } else {
    // Trên mobile (Android emulator), sử dụng 10.0.2.2
    return 'http://10.0.2.2:5000/api';
  }
}