import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/feature/room/presentations/pages/view_room.dart';
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
import 'feature/bill/presentation/bloc/bill_bloc/bill_bloc.dart';
import 'feature/bill/presentation/bloc/payment_bloc/payment_bloc.dart';
import 'feature/contract/presentation/bloc/contract_bloc.dart';
import 'feature/notification/presentation/bloc/notification_bloc.dart';
import 'feature/notification/presentation/service/fcm_service.dart';
import 'feature/register/presentation/bloc/registration_bloc.dart';
import 'feature/report/presentation/bloc/report_bloc.dart';
import 'feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import 'feature/service/presentation/bloc/service_bloc.dart';
import 'components/bottom_app_bar.dart';
import 'firebase_options.dart';

// Create a global RouteObserver instance to track route changes
final RouteObserver<ModalRoute<dynamic>> routeObserver = RouteObserver<ModalRoute<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tạo một GlobalKey duy nhất để sử dụng cho toàn bộ ứng dụng
  final navigatorKey = GlobalKey<NavigatorState>();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Lỗi khởi tạo Firebase: $e');
    // Không sử dụng Get.snackbar ở đây vì Get chưa được khởi tạo
  }
  print('Setting up dependency injection...');
  try {
    await setup(navigatorKey);
  } catch (e) {
    print('Error setting up dependency injection: $e');
  }
  try {
    final fcmService = getIt<FcmService>();
    await fcmService.init(null);
  } catch (e) {
    print('Error initializing FCM: $e');
  }
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {    
    return GetMaterialApp(
      navigatorKey: navigatorKey, // Sử dụng navigatorKey được truyền vào
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      initialRoute: '/welcome',
      navigatorObservers: [routeObserver],
      getPages: [
        GetPage(name: '/welcome', page: () => const WelcomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/forgot_password', page: () => const ForgotPasswordPage()),
        GetPage(name: '/reset_password', page: () => const ResetPasswordPage()),
        GetPage(name: '/login_bottom_bar', page: () => const KBottomAppBar()),
        GetPage(name: '/view_room', page: () => const ViewRoom()),
        // Note: RoomRegistrationPage requires parameters so it's better to use direct navigation with BlocProvider
      ],
      builder: (context, child) {
        // Thêm MediaQuery để đảm bảo scale phù hợp trên tất cả các thiết bị
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.2);
        
        // We're using mediaQueryData.copyWith below
        
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaleFactor: scale,
            boldText: false, // Disable bold text which can trigger spell check
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (ctx) => getIt<AuthBloc>()),
              BlocProvider(create: (ctx) => getIt<NotificationBloc>()),
              BlocProvider(create: (ctx) => getIt<ReportBloc>()),
              BlocProvider(create: (ctx) => getIt<BillBloc>()),
              BlocProvider(create: (ctx) => getIt<PaymentTransactionBloc>()),
              BlocProvider(create: (ctx) => getIt<ServiceBloc>()),
              BlocProvider(create: (ctx) => getIt<ContractBloc>()),
              BlocProvider(create: (ctx) => getIt<RoomBloc>()),
              // Create RegistrationBloc lazily to avoid the null value exception
              BlocProvider<RegistrationBloc>(
                create: (ctx) => getIt<RegistrationBloc>(),
                lazy: true,
              ),
            ],
            child: child!,
          ),
        );
      },
    );
  }
}