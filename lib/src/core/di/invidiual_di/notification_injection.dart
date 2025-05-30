import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../../../../feature/notification/data/datasource/fcm_datasource.dart';
import '../../../../feature/notification/data/datasource/noti_datasource.dart';
import '../../../../feature/notification/data/datasource/noti_media_datasource.dart';
import '../../../../feature/notification/data/datasource/noti_recipient_datasource.dart';
import '../../../../feature/notification/data/datasource/noti_type_datasource.dart';
import '../../../../feature/notification/data/repository/fcm_repository_impl.dart';
import '../../../../feature/notification/data/repository/noti_media_repository_impl.dart';
import '../../../../feature/notification/data/repository/noti_recipient_repository_impl.dart';
import '../../../../feature/notification/data/repository/noti_repository_impl.dart';
import '../../../../feature/notification/data/repository/noti_type_repository_impl.dart';
import '../../../../feature/notification/domain/repository/fcm_repository.dart';
import '../../../../feature/notification/domain/repository/noti_media_repository.dart';
import '../../../../feature/notification/domain/repository/noti_recipient_repository.dart';
import '../../../../feature/notification/domain/repository/noti_repository.dart';
import '../../../../feature/notification/domain/repository/noti_type_repository.dart';
import '../../../../feature/notification/domain/usecase/fcm_usecase.dart';
import '../../../../feature/notification/domain/usecase/noti_media_usecase.dart';
import '../../../../feature/notification/domain/usecase/noti_recipient_usecase.dart';
import '../../../../feature/notification/domain/usecase/noti_type_usecase.dart';
import '../../../../feature/notification/domain/usecase/noti_usecase.dart';
import '../../../../feature/notification/presentation/bloc/notification_bloc.dart';
import '../../../../feature/notification/presentation/service/fcm_service.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerNotificationDependencies(GlobalKey<NavigatorState> navigatorKey) {
  // Đăng ký ApiService (nếu chưa có)
  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerSingleton<ApiService>(
      ApiService(baseUrl: 'https://your-backend-url'), // Thay bằng URL backend của bạn
    );
  }

  // Đăng ký Data Source
  getIt.registerSingleton<NotificationRemoteDataSource>(
    NotificationRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<NotificationRecipientRemoteDataSource>(
    NotificationRecipientRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<NotificationMediaRemoteDataSource>(
    NotificationMediaRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<NotificationTypeRemoteDataSource>(
    NotificationTypeRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký FCM Data Source (loại bỏ http.Client)
  getIt.registerSingleton<FcmDataSource>(
    FcmDataSourceImpl(
      firebaseMessaging: FirebaseMessaging.instance,
      localNotifications: FlutterLocalNotificationsPlugin(),
    ),
  );

  // Đăng ký Repository
  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()),
  );

  getIt.registerSingleton<NotificationRecipientRepository>(
    NotificationRecipientRepositoryImpl(getIt<NotificationRecipientRemoteDataSource>()),
  );

  getIt.registerSingleton<NotificationMediaRepository>(
    NotificationMediaRepositoryImpl(getIt<NotificationMediaRemoteDataSource>()),
  );

  getIt.registerSingleton<NotificationTypeRepository>(
    NotificationTypeRepositoryImpl(getIt<NotificationTypeRemoteDataSource>()),
  );

  // Đăng ký FCM Repository
  getIt.registerSingleton<FcmRepository>(
    FcmRepositoryImpl(getIt<FcmDataSource>()),
  );

  // Đăng ký Usecase
  getIt.registerSingleton<GetUserNotifications>(
    GetUserNotifications(getIt<NotificationRepository>()),
  );

  getIt.registerSingleton<GetPublicNotifications>(
    GetPublicNotifications(getIt<NotificationRepository>()),
  );

  getIt.registerSingleton<MarkNotificationAsRead>(
    MarkNotificationAsRead(getIt<NotificationRecipientRepository>()),
  );

  getIt.registerSingleton<MarkAllNotificationsAsRead>(
    MarkAllNotificationsAsRead(getIt<NotificationRecipientRepository>()),
  );

  getIt.registerSingleton<GetUnreadNotificationsCount>(
    GetUnreadNotificationsCount(getIt<NotificationRecipientRepository>()),
  );

  getIt.registerSingleton<GetAllNotificationTypes>(
    GetAllNotificationTypes(getIt<NotificationTypeRepository>()),
  );

  getIt.registerSingleton<GetNotificationMedia>(
    GetNotificationMedia(getIt<NotificationMediaRepository>()),
  );

  getIt.registerSingleton<DeleteNotification>(
    DeleteNotification(getIt<NotificationRecipientRepository>()),
  );

  // Đăng ký FCM Usecases
  getIt.registerSingleton<GetFcmToken>(
    GetFcmToken(getIt<FcmRepository>()),
  );

  getIt.registerSingleton<SendFcmToken>(
    SendFcmToken(getIt<FcmRepository>()),
  );

  // Đăng ký BLoC trước FcmService
  getIt.registerLazySingleton<NotificationBloc>(
    () => NotificationBloc(
      getUserNotifications: getIt<GetUserNotifications>(),
      getPublicNotifications: getIt<GetPublicNotifications>(),
      markNotificationAsRead: getIt<MarkNotificationAsRead>(),
      markAllNotificationsAsRead: getIt<MarkAllNotificationsAsRead>(),
      getUnreadNotificationsCount: getIt<GetUnreadNotificationsCount>(),
      getAllNotificationTypes: getIt<GetAllNotificationTypes>(),
      getNotificationMedia: getIt<GetNotificationMedia>(),
      deleteNotification: getIt<DeleteNotification>(),
      fcmRepository: getIt<FcmRepository>(),
    ),
  );

  // Đăng ký FCM Service sau NotificationBloc
  getIt.registerSingleton<FcmService>(
    FcmService(
      getFcmToken: getIt<GetFcmToken>(),
      sendFcmToken: getIt<SendFcmToken>(),
      notificationBloc: getIt<NotificationBloc>(),
      navigatorKey: navigatorKey,
    ),
  );
}