import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

String getAPIbaseUrl() {

    // Local development
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://10.0.2.2:5000/api';
    }
    // return 'https://kytucxa.dev.dut.navia.io.vn/api';
}