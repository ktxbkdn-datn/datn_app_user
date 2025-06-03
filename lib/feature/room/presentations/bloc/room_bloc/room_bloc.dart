import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/area_entity.dart';
import '../../../domain/entities/room_entity.dart';
import '../../../domain/entities/room_image_entity.dart';
import '../../../domain/usecases/room_usecase.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetRooms getRooms;
  final GetRoomById getRoomById;
  final GetRoomImages getRoomImages;
  final GetAreas getAreas;

  RoomBloc({
    required this.getRooms,
    required this.getRoomById,
    required this.getRoomImages,
    required this.getAreas,
  }) : super(const RoomInitial()) {
    on<FetchRoomsEvent>(_onFetchRooms);
    on<FetchRoomByIdEvent>(_onFetchRoomById);
    on<FetchRoomImagesEvent>(_onFetchRoomImages);
    on<FetchAreasEvent>(_onFetchAreas);
    on<FilterRoomsByAreaEvent>(_onFilterRoomsByArea);
  }

  Future<void> _onFetchRooms(FetchRoomsEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading(areas: state.areas));
    try {
      final response = await getRooms(
        page: event.page,
        limit: event.limit,
        minCapacity: event.minCapacity,
        maxCapacity: event.maxCapacity,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        available: event.available,
        search: event.search,
        areaId: event.areaId,
      );
      emit(RoomsLoaded(
        rooms: response['rooms'] as List<RoomEntity>,
        total: response['total'] as int,
        currentPage: response['current_page'] as int,
        pages: response['pages'] as int,
        areas: state.areas,
      ));
    } catch (e) {
      emit(RoomError(e.toString(), areas: state.areas));
    }
  }

  Future<void> _onFetchRoomById(FetchRoomByIdEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading(areas: state.areas));
    try {
      final room = await getRoomById(event.roomId);
      emit(RoomDetailLoaded(room, areas: state.areas));
    } catch (e) {
      emit(RoomError(e.toString(), areas: state.areas));
    }
  }

  Future<void> _onFetchRoomImages(FetchRoomImagesEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading(areas: state.areas));
    try {
      final images = await getRoomImages(event.roomId);
      emit(RoomImagesLoaded(event.roomId, images, areas: state.areas));
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('Không tìm thấy media')) {
        emit(RoomImagesLoaded(event.roomId, [], areas: state.areas));
      } else {
        emit(RoomError(e.toString(), areas: state.areas));
      }
    }
  }

  Future<void> _onFetchAreas(FetchAreasEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading(areas: state.areas));
    try {
      final areas = await getAreas();
      print('Fetched areas: ${areas.map((a) => a.name).toList()}');
      emit(AreasLoaded(
        loadedAreas: areas,
        total: areas.length,
        pages: 1,
        currentPage: 1,
      ));
    } catch (e) {
      print('Error fetching areas: $e');
      emit(RoomError(e.toString(), areas: state.areas));
    }
  }

  Future<void> _onFilterRoomsByArea(FilterRoomsByAreaEvent event, Emitter<RoomState> emit) async {
    emit(RoomLoading(areas: state.areas));
    try {
      final response = await getRooms(
        page: 1,
        limit: 12,
        areaId: event.areaId,
      );
      emit(RoomsLoaded(
        rooms: response['rooms'] as List<RoomEntity>,
        total: response['total'] as int,
        currentPage: response['current_page'] as int,
        pages: response['pages'] as int,
        areas: state.areas,
      ));
    } catch (e) {
      emit(RoomError(e.toString(), areas: state.areas));
    }
  }
}