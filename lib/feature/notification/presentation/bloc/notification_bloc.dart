import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/repository/fcm_repository.dart';
import '../../domain/usecase/noti_media_usecase.dart';
import '../../domain/usecase/noti_recipient_usecase.dart';
import '../../domain/usecase/noti_type_usecase.dart';
import '../../domain/usecase/noti_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetUserNotifications getUserNotifications;
  final GetPublicNotifications getPublicNotifications;
  final MarkNotificationAsRead markNotificationAsRead;
  final MarkAllNotificationsAsRead markAllNotificationsAsRead;
  final GetUnreadNotificationsCount getUnreadNotificationsCount;
  final GetAllNotificationTypes getAllNotificationTypes;
  final GetNotificationMedia getNotificationMedia;
  final DeleteNotification deleteNotification;
  final FcmRepository fcmRepository; // Thêm FcmRepository

  NotificationBloc({
    required this.getUserNotifications,
    required this.getPublicNotifications,
    required this.markNotificationAsRead,
    required this.markAllNotificationsAsRead,
    required this.getUnreadNotificationsCount,
    required this.getAllNotificationTypes,
    required this.getNotificationMedia,
    required this.deleteNotification,
    required this.fcmRepository,
  }) : super(NotificationInitial()) {
    on<FetchUserNotificationsEvent>(_onFetchUserNotifications);
    on<FetchPublicNotificationsEvent>(_onFetchPublicNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<FetchUnreadNotificationsCountEvent>(_onFetchUnreadNotificationsCount);
    on<FetchNotificationTypesEvent>(_onFetchNotificationTypes);
    on<FetchNotificationMediaEvent>(_onFetchNotificationMedia);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<NewFcmNotificationReceived>(_onNewFcmNotificationReceived); // Thêm handler
  }

  Future<void> _onFetchUserNotifications(
      FetchUserNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing FetchUserNotificationsEvent: page=${event.page}, limit=${event.limit}, isRead=${event.isRead}');
    emit(NotificationLoading());
    final result = await getUserNotifications(
      page: event.page,
      limit: event.limit,
      isRead: event.isRead,
    );
    result.fold(
          (failure) {
        print('FetchUserNotifications failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (notifications) {
        print('FetchUserNotifications succeeded: ${notifications.length} notifications');
        emit(UserNotificationsLoaded(notifications: notifications));
      },
    );
  }

  Future<void> _onFetchPublicNotifications(
      FetchPublicNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing FetchPublicNotificationsEvent: page=${event.page}, limit=${event.limit}');
    emit(NotificationLoading());
    final result = await getPublicNotifications(
      page: event.page,
      limit: event.limit,
    );
    result.fold(
          (failure) {
        print('FetchPublicNotifications failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (notifications) {
        print('FetchPublicNotifications succeeded: ${notifications.length} notifications');
        emit(PublicNotificationsLoaded(notifications: notifications));
      },
    );
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing MarkNotificationAsReadEvent with notificationId: ${event.notificationId}');
    emit(NotificationLoading());
    final result = await markNotificationAsRead(event.notificationId);
    result.fold(
          (failure) {
        print('MarkNotificationAsRead failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (recipient) {
        print('MarkNotificationAsRead succeeded: recipientId=${recipient.id}');
        emit(NotificationMarkedAsRead(recipient: recipient));
        add(const FetchUserNotificationsEvent(page: 1, limit: 50, isRead: null));
        add(const FetchUnreadNotificationsCountEvent());
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(
      MarkAllNotificationsAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing MarkAllNotificationsAsReadEvent');
    emit(NotificationLoading());
    final result = await markAllNotificationsAsRead();
    result.fold(
          (failure) {
        print('MarkAllNotificationsAsRead failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (_) {
        print('MarkAllNotificationsAsRead succeeded');
        emit(const AllNotificationsMarkedAsRead());
        add(const FetchUserNotificationsEvent(page: 1, limit: 50, isRead: null));
        add(const FetchUnreadNotificationsCountEvent());
      },
    );
  }

  Future<void> _onFetchUnreadNotificationsCount(
      FetchUnreadNotificationsCountEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing FetchUnreadNotificationsCountEvent');
    emit(NotificationLoading());
    final result = await getUnreadNotificationsCount();
    result.fold(
          (failure) {
        print('FetchUnreadNotificationsCount failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (count) {
        print('FetchUnreadNotificationsCount succeeded: count=$count');
        emit(UnreadNotificationsCountLoaded(count: count));
      },
    );
  }

  Future<void> _onFetchNotificationTypes(
      FetchNotificationTypesEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing FetchNotificationTypesEvent: page=${event.page}, limit=${event.limit}');
    emit(NotificationLoading());
    final result = await getAllNotificationTypes(
      page: event.page,
      limit: event.limit,
    );
    result.fold(
          (failure) {
        print('FetchNotificationTypes failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (types) {
        print('FetchNotificationTypes succeeded: ${types.length} types');
        emit(NotificationTypesLoaded(types: types));
      },
    );
  }

  Future<void> _onFetchNotificationMedia(
      FetchNotificationMediaEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing FetchNotificationMediaEvent: notificationId=${event.notificationId}, fileType=${event.fileType}');
    emit(NotificationLoading());
    final result = await getNotificationMedia(
      notificationId: event.notificationId,
      fileType: event.fileType,
    );
    result.fold(
          (failure) {
        print('FetchNotificationMedia failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (media) {
        print('FetchNotificationMedia succeeded: ${media.length} media items');
        emit(NotificationMediaLoaded(media: media));
      },
    );
  }

  Future<void> _onDeleteNotification(
      DeleteNotificationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing DeleteNotificationEvent with notificationId: ${event.notificationId}');
    emit(NotificationLoading());
    final result = await deleteNotification(event.notificationId);
    result.fold(
          (failure) {
        print('DeleteNotification failed: ${failure.message}');
        emit(NotificationError(message: failure.message));
      },
          (_) {
        print('DeleteNotification succeeded');
        emit(const NotificationDeleted());
        add(const FetchUserNotificationsEvent(page: 1, limit: 50, isRead: null));
        add(const FetchUnreadNotificationsCountEvent());
      },
    );
  }

  Future<void> _onNewFcmNotificationReceived(
      NewFcmNotificationReceived event,
      Emitter<NotificationState> emit,
      ) async {
    print('Processing NewFcmNotificationReceived: ${event.message.data}');
    emit(NewFcmNotification(event.message));

    // Cập nhật danh sách thông báo và số lượng chưa đọc
    add(const FetchUserNotificationsEvent(page: 1, limit: 50, isRead: null));
    add(const FetchUnreadNotificationsCountEvent());
  }
}