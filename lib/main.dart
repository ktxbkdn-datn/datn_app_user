import 'package:datn_app/feature/welcome_page/welcome_page.dart';
import 'package:datn_app/src/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'common/theme/theme.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/forgot_password_page.dart';
import 'feature/auth/presentation/pages/login_page.dart';
import 'feature/auth/presentation/pages/reset_password_page.dart';
import 'feature/bill/presentation/bill_bloc/bill_bloc.dart';
import 'feature/bill/presentation/payment_bloc/payment_bloc.dart';
import 'feature/contract/presentation/bloc/contract_bloc.dart';
import 'feature/notification/presentation/bloc/notification_bloc.dart';
import 'feature/notification/presentation/service/fcm_service.dart';
import 'feature/register/presentation/bloc/registration_bloc.dart';
import 'feature/report/presentation/bloc/report_bloc.dart';
import 'feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'feature/service/presentation/bloc/service_bloc.dart';
import 'components/bottom_app_bar.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    Get.snackbar('Lỗi', 'Không thể khởi tạo Firebase: $e', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 5));
  }

  print('Setting up dependency injection...');
  try {
    await setup(GlobalKey<NavigatorState>());
    print('Dependency injection setup completed');
  } catch (e) {
    print('Error setting up dependency injection: $e');
  }

  print('Initializing FCM...');
  try {
    final fcmService = getIt<FcmService>();
    await fcmService.init(null);
    print('FCM initialized successfully');
  } catch (e) {
    print('Error initializing FCM: $e');
  }

  print('Running app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/login_bottom_bar': (context) => const KBottomAppBar(),
      },
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => getIt<AuthBloc>()),
          BlocProvider(create: (ctx) => getIt<NotificationBloc>()),
          BlocProvider(create: (ctx) => getIt<ReportBloc>()),
          BlocProvider(create: (ctx) => getIt<BillBloc>()),
          BlocProvider(create: (ctx) => getIt<PaymentTransactionBloc>()),
          BlocProvider(create: (ctx) => getIt<ServiceBloc>()),
          BlocProvider(create: (ctx) => getIt<ContractBloc>()),
          BlocProvider(create: (ctx) => getIt<RoomBloc>()),
          BlocProvider(create: (ctx) => getIt<RegistrationBloc>()),
        ],
        child: child!,
      ),
    );
  }
}