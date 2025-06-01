import 'package:datn_app/common/constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../register/presentation/page/room_registation_page.dart';
import 'dart:convert';
import 'dart:async';
import '../../../../common/constant/colors.dart';
import '../../../../common/widgets/pagination_controls.dart';
import '../../domain/entities/area_entity.dart';
import '../../data/models/area_model.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_image_entity.dart';
import '../bloc/room_bloc/room_bloc.dart';
import '../widget/full_screen.dart';
import '../widget/room_decrip.dart';

class ViewRoom extends StatefulWidget {
  final bool showBackButton;

  const ViewRoom({Key? key, this.showBackButton = false}) : super(key: key);

  @override
  _ViewRoomState createState() => _ViewRoomState();
}

class _ViewRoomState extends State<ViewRoom> {
  final ScrollController _scrollController = ScrollController();
  String _filterStatus = 'All';
  int? _selectedAreaId;
  List<RoomEntity> _allRooms = [];
  List<AreaModel> _allAreas = [];
  Map<int, List<RoomImageEntity>> _roomImages = {};
  Set<int> _pendingImageFetches = {};
  bool _isInitialLoad = true;
  bool _isLoadingAreas = true;
  bool _isLoadingRoomsFromServer = true;
  int _currentPage = 1;
  int _totalItems = 0;
  int _totalPages = 1;
  static const int _limit = 12;
  static String _baseUrl = getAPIbaseUrl();
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    Future.microtask(() async {
      context.read<RoomBloc>().add(const FetchAreasEvent(page: 1, limit: 100));
      await Future.delayed(const Duration(milliseconds: 100));
      context.read<RoomBloc>().add(const FetchRoomsEvent(page: 1, limit: _limit));
    });
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRooms = prefs.getString('rooms');
    final cachedAreas = prefs.getString('areas');
    final cachedFilterStatus = prefs.getString('room_filter_status') ?? 'All';
    final cachedAreaId = prefs.getInt('room_filter_area_id');
    final cachedPage = prefs.getInt('room_current_page') ?? 1;

    setState(() {
      _filterStatus = cachedFilterStatus;
      _selectedAreaId = cachedAreaId;
      _currentPage = cachedPage;
      _isInitialLoad = false;
    });

    if (cachedAreas != null) {
      try {
        final List<dynamic> json = jsonDecode(cachedAreas);
        setState(() {
          _allAreas = json.map((e) => AreaModel.fromJson(e)).toList();
          _isLoadingAreas = false;
        });
      } catch (e) {
        print('Error loading cached areas: $e');
        await prefs.remove('areas');
      }
    }
  }

  Future<void> _saveCachedData(List<RoomEntity> rooms, List<AreaModel> areas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rooms', jsonEncode(rooms.map((e) => e.toJson()).toList()));
    await prefs.setString('areas', jsonEncode(areas.map((e) => e.toJson()).toList()));
    await prefs.setString('room_filter_status', _filterStatus);
    await prefs.setInt('room_current_page', _currentPage);
    if (_selectedAreaId != null) {
      await prefs.setInt('room_filter_area_id', _selectedAreaId!);
    } else {
      await prefs.remove('room_filter_area_id');
    }
  }

  Future<void> _clearCacheAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rooms');
    await prefs.remove('areas');
    await prefs.remove('room_filter_status');
    await prefs.remove('room_filter_area_id');
    await prefs.remove('room_current_page');
    setState(() {
      _allRooms = [];
      _allAreas = [];
      _roomImages = {};
      _pendingImageFetches = {};
      _filterStatus = 'All';
      _selectedAreaId = null;
      _currentPage = 1;
      _totalItems = 0;
      _totalPages = 1;
      _isInitialLoad = true;
      _isLoadingAreas = true;
      _isLoadingRoomsFromServer = true;
    });
    context.read<RoomBloc>().add(const FetchAreasEvent(page: 1, limit: 100));
    await Future.delayed(const Duration(milliseconds: 100));
    context.read<RoomBloc>().add(const FetchRoomsEvent(page: 1, limit: _limit));
  }

  void _resetFilters() {
    setState(() {
      _filterStatus = 'All';
      _selectedAreaId = null;
      _currentPage = 1;
      _isLoadingRoomsFromServer = true;
      _saveCachedData(_allRooms, _allAreas);
    });
    context.read<RoomBloc>().add(const FetchRoomsEvent(page: 1, limit: _limit));
  }

  void _showImagesDialog(int roomId) {
    final images = _roomImages[roomId] ?? [];
    if (images.isNotEmpty) {
      _openImagesDialog(roomId, images);
      return;
    }

    setState(() {
      _isLoadingImages = true;
      _pendingImageFetches.add(roomId);
    });
    context.read<RoomBloc>().add(FetchRoomImagesEvent(roomId));
  }

  void _openImagesDialog(int roomId, List<RoomImageEntity> images) {
    showDialog(
      context: context,
      builder: (context) => FullScreenMediaDialog(
        roomId: roomId,
        images: images,
        onFetchImages: () {
          context.read<RoomBloc>().add(FetchRoomImagesEvent(roomId));
        },
      ),
    );
  }

  String sanitize(String input) {
    return input.replaceAll('<', '<').replaceAll('>', '>');
  }

  void _registerForRoom(RoomEntity room) {
    String areaName = 'Không xác định';
    final area = _allAreas.firstWhere(
      (area) => area.areaId == room.areaId,
      orElse: () => AreaModel(areaId: room.areaId, name: 'Không xác định'),
    );
    areaName = area.name;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomRegistrationPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (_isLoadingImages || _isLoadingRoomsFromServer)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
          SafeArea(
            child: BlocConsumer<RoomBloc, RoomState>(
              listener: (context, state) {
                if (state is RoomError) {
                  setState(() {
                    _isLoadingImages = false;
                    _isLoadingAreas = false;
                    _isLoadingRoomsFromServer = false;
                    _pendingImageFetches.clear();
                  });
                  Get.snackbar(
                    'Lỗi',
                    state.message,
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } else if (state is RoomsLoaded) {
                  setState(() {
                    _allRooms = state.rooms;
                    _totalItems = state.total;
                    _totalPages = state.pages;
                    _currentPage = state.currentPage;
                    _isInitialLoad = false;
                    _isLoadingRoomsFromServer = false;
                  });
                  _saveCachedData(state.rooms, _allAreas);
                } else if (state is AreasLoaded) {
                  setState(() {
                    _allAreas = state.areas as List<AreaModel>;
                    _isLoadingAreas = false;
                  });
                  print('Areas loaded: ${state.areas.map((a) => a.name).toList()}');
                  _saveCachedData(_allRooms, state.areas as List<AreaModel>);
                } else if (state is RoomImagesLoaded) {
                  setState(() {
                    _roomImages[state.roomId] = state.images;
                    _pendingImageFetches.remove(state.roomId);
                    _isLoadingImages = false;
                  });
                  print('Images loaded for room ${state.roomId}: ${state.images.map((i) => i.imageUrl).toList()}');
                  if (state.images.isNotEmpty) {
                    _openImagesDialog(state.roomId, state.images);
                  } else {
                    Get.snackbar(
                      'Thông báo',
                      'Chưa có ảnh hoặc video cho phòng này',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              },
              builder: (context, state) {
                List<RoomEntity> filteredRooms = _allRooms;
                if (_filterStatus != 'All') {
                  filteredRooms = _allRooms.where((room) => room.status == _filterStatus).toList();
                }
                if (_selectedAreaId != null) {
                  filteredRooms = filteredRooms.where((room) => room.areaId == _selectedAreaId).toList();
                }

                if (state is RoomError && filteredRooms.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.snackbar(
                      'Thông báo',
                      'Sử dụng dữ liệu cũ do lỗi: ${state.message}',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  });
                }

                List<AreaEntity> uniqueAreas = [];
                Set<int> seenAreaIds = {};
                for (var area in _allAreas) {
                  if (!seenAreaIds.contains(area.areaId)) {
                    seenAreaIds.add(area.areaId);
                    uniqueAreas.add(area);
                  }
                }

                if (_selectedAreaId != null &&
                    !uniqueAreas.any((area) => area.areaId == _selectedAreaId) &&
                    uniqueAreas.isNotEmpty) {
                  _selectedAreaId = null;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (widget.showBackButton)
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 36),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Danh sách phòng',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                                onPressed: _clearCacheAndRefresh,
                              ),
                            ],
                          ),
                   
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _filterStatus,
                                  dropdownColor: Colors.white.withOpacity(0.8),
                                  isExpanded: true,
                                  items: ['All', 'AVAILABLE', 'OCCUPIED']
                                      .map((status) => DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(
                                              status == 'All'
                                                  ? 'Tất cả trạng thái'
                                                  : status == 'AVAILABLE'
                                                      ? 'Còn chỗ trống'
                                                      : 'Hết chỗ trống',
                                              style: const TextStyle(color: Colors.black),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _filterStatus = value!;
                                      _saveCachedData(_allRooms, _allAreas);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _isLoadingAreas
                                    ? const Center(child: CircularProgressIndicator())
                                    : state is RoomError
                                        ? const Center(
                                            child: Text(
                                              'Lỗi tải khu vực',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          )
                                        : DropdownButton<int>(
                                            value: _selectedAreaId,
                                            dropdownColor: Colors.white.withOpacity(0.8),
                                            isExpanded: true,
                                            hint: const Text('Tất cả khu vực', style: TextStyle(color: Colors.white)),
                                            items: [
                                              const DropdownMenuItem<int>(
                                                value: null,
                                                child: Text('Tất cả khu vực'),
                                              ),
                                              ...uniqueAreas.map((area) => DropdownMenuItem<int>(
                                                    value: area.areaId,
                                                    child: Text(sanitize(area.name)),
                                                  )),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedAreaId = value;
                                                _currentPage = 1;
                                                _saveCachedData(_allRooms, _allAreas);
                                                if (value != null) {
                                                  context.read<RoomBloc>().add(FilterRoomsByAreaEvent(value));
                                                } else {
                                                  context.read<RoomBloc>().add(const FetchRoomsEvent(page: 1, limit: _limit));
                                                }
                                              });
                                            },
                                          ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoadingRoomsFromServer
                          ? const SizedBox()
                          : filteredRooms.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _allRooms.isEmpty
                                            ? 'Không có phòng'
                                            : 'Không có phòng phù hợp với bộ lọc',
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      if (_allRooms.isNotEmpty)
                                        TextButton(
                                          onPressed: _resetFilters,
                                          child: const Text(
                                            'Đặt lại bộ lọc',
                                            style: TextStyle(color: Colors.blue, fontSize: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  itemCount: filteredRooms.length,
                                  itemBuilder: (context, index) {
                                    final room = filteredRooms[index];
                                    return _buildRoomPage(room);
                                  },
                                ),
                    ),
                    if (filteredRooms.isNotEmpty && !_isLoadingRoomsFromServer)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: PaginationControls(
                          currentPage: _currentPage,
                          totalItems: _totalItems,
                          limit: _limit,
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                              _isLoadingRoomsFromServer = true;
                              _saveCachedData(_allRooms, _allAreas);
                            });
                            context.read<RoomBloc>().add(FetchRoomsEvent(
                              page: page,
                              limit: _limit,
                              areaId: _selectedAreaId,
                            ));
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomPage(RoomEntity room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sanitize(room.name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Mô tả:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ExpandableDescription(text: sanitize(room.description ?? 'Không có mô tả')),
            const SizedBox(height: 5),
            Text(
              'Giá: ${room.price} VND',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 5),
            Text(
              'Số người: ${room.currentPersonNumber}/${room.capacity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Trạng thái: ${room.status == 'AVAILABLE' ? 'Còn chỗ trống' : 'Đang cho thuê'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: room.status == 'AVAILABLE' ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _showImagesDialog(room.roomId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Xem ảnh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _registerForRoom(room),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Đăng ký chờ xem phòng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}