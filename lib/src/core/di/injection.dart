import 'package:datn_app/src/core/di/invidiual_di/bill_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/contract_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/notification_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/payment_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/registration_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/report_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/room_injection.dart';
import 'package:datn_app/src/core/di/invidiual_di/service_injection.dart';
import 'package:flutter/material.dart'; // Thêm để dùng GlobalKey
import 'package:get_it/get_it.dart';

import '../../../common/constant/api_constant.dart';
import '../network/api_client.dart';
import 'invidiual_di/auth_injection.dart';

final getIt = GetIt.instance;

Future<void> setup(GlobalKey<NavigatorState> navigatorKey) async {
  // Đăng ký ApiService làm singleton
  getIt.registerSingleton<ApiService>(ApiService(baseUrl: getAPIbaseUrl()));

  // Đăng ký dependencies cho từng module
  registerAuthDependencies();
  registerReportDependencies();
  registerNotificationDependencies(navigatorKey); // Truyền navigatorKey
  registerPaymentDependencies();
  registerBillDependencies();
  registerServiceDependencies();
  registerContractDependencies();
  registerRoomDependencies();
  registerRegistrationDependencies();
}