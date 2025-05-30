part of 'room_bloc.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];

  List<AreaEntity> get areas; // Define the getter only once in the parent class
}

class RoomInitial extends RoomState {
  final List<AreaEntity> _areas;

  const RoomInitial({List<AreaEntity> areas = const []}) : _areas = areas;

  @override
  List<AreaEntity> get areas => _areas;
}

class RoomLoading extends RoomState {
  final List<AreaEntity> _areas;

  const RoomLoading({List<AreaEntity> areas = const []}) : _areas = areas;

  @override
  List<AreaEntity> get areas => _areas;
}

class RoomsLoaded extends RoomState {
  final List<RoomEntity> rooms;
  final int total;
  final int currentPage;
  final int pages;
  final List<AreaEntity> _areas;

  const RoomsLoaded({
    required this.rooms,
    required this.total,
    required this.currentPage,
    required this.pages,
    List<AreaEntity> areas = const [],
  }) : _areas = areas;

  @override
  List<Object?> get props => [rooms, total, currentPage, pages, _areas];

  @override
  List<AreaEntity> get areas => _areas;
}

class RoomDetailLoaded extends RoomState {
  final RoomEntity room;
  final List<AreaEntity> _areas;

  const RoomDetailLoaded(this.room, {List<AreaEntity> areas = const []}) : _areas = areas;

  @override
  List<Object?> get props => [room, _areas];

  @override
  List<AreaEntity> get areas => _areas;
}

class RoomImagesLoaded extends RoomState {
  final int roomId;
  final List<RoomImageEntity> images;
  final List<AreaEntity> _areas;

  const RoomImagesLoaded(this.roomId, this.images, {List<AreaEntity> areas = const []}) : _areas = areas;

  @override
  List<Object?> get props => [roomId, images, _areas];

  @override
  List<AreaEntity> get areas => _areas;
}

class AreasLoaded extends RoomState {
  final List<AreaEntity> loadedAreas;
  final int total;
  final int pages;
  final int currentPage;

  const AreasLoaded({
    required this.loadedAreas,
    this.total = 0,
    this.pages = 1,
    this.currentPage = 1,
  });

  @override
  List<AreaEntity> get areas => loadedAreas;

  @override
  List<Object?> get props => [loadedAreas, total, pages, currentPage];
}

class RoomError extends RoomState {
  final String message;
  final List<AreaEntity> _areas;

  const RoomError(this.message, {List<AreaEntity> areas = const []}) : _areas = areas;

  @override
  List<Object?> get props => [message, _areas];

  @override
  List<AreaEntity> get areas => _areas;
}