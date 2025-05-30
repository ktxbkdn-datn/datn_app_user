part of 'room_bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class FetchRoomsEvent extends RoomEvent {
  final int page;
  final int limit;
  final int? minCapacity;
  final int? maxCapacity;
  final double? minPrice;
  final double? maxPrice;
  final bool? available;
  final String? search;
  final int? areaId;

  const FetchRoomsEvent({
    this.page = 1,
    this.limit = 10,
    this.minCapacity,
    this.maxCapacity,
    this.minPrice,
    this.maxPrice,
    this.available,
    this.search,
    this.areaId,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    minCapacity,
    maxCapacity,
    minPrice,
    maxPrice,
    available,
    search,
    areaId,
  ];
}

class FetchRoomByIdEvent extends RoomEvent {
  final int roomId;

  const FetchRoomByIdEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class FetchRoomImagesEvent extends RoomEvent {
  final int roomId;

  const FetchRoomImagesEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class FetchAreasEvent extends RoomEvent {
  final int page;
  final int limit;

  const FetchAreasEvent({this.page = 1, this.limit = 100});

  @override
  List<Object?> get props => [page, limit];
}

class FilterRoomsByAreaEvent extends RoomEvent {
  final int? areaId;

  const FilterRoomsByAreaEvent(this.areaId);

  @override
  List<Object?> get props => [areaId];
}