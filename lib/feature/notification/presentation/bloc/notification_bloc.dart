import 'package:bloc/bloc.dart';
import 'package:datn_app/feature/notification/domain/entity/notification_entity.dart';

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
  final FcmRepository fcmRepository;
  final Map<int, List<Notification>> _cache = {};
  static const int _maxCacheSize = 5;

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
    on<NewFcmNotificationReceived>(_onNewFcmNotificationReceived);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onFetchUserNotifications(
    FetchUserNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('Processing FetchUserNotificationsEvent: page=${event.page}, limit=${event.limit}, isRead=${event.isRead}');
    if (_cache.containsKey(event.page)) {
      print('Serving from cache: page=${event.page}');
      emit(UserNotificationsLoaded(
        notifications: _cache[event.page]!,
        totalItems: _cache[event.page]!.length, // Total items may need API refresh
      ));
      return;
    }

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
      (data) {
        print('FetchUserNotifications succeeded: ${data.$1.length} notifications, total=${data.$2}');
        _cache[event.page] = data.$1;
        if (_cache.length > _maxCacheSize) {
          final oldestPage = _cache.keys.reduce((a, b) => a < b ? a : b);
          _cache.remove(oldestPage);
        }
        emit(UserNotificationsLoaded(
          notifications: data.$1,
          totalItems: data.$2,
        ));
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
    add(const FetchUnreadNotificationsCountEvent());
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('Clearing cache');
    _cache.clear();
  }
}