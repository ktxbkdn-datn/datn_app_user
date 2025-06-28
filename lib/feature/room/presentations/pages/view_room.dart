import 'package:datn_app/common/components/app_background.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/feature/room/presentations/widget/room_item_widget.dart';
import 'package:datn_app/common/widgets/pagination_controls.dart';
import 'package:datn_app/common/widgets/no_spell_check_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../register/presentation/page/room_registation_page.dart';
import '../../../register/presentation/bloc/registration_bloc.dart';
import 'dart:convert';
import 'dart:async';
import '../../domain/entities/area_entity.dart';
import '../../data/models/area_model.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_image_entity.dart';
import '../bloc/room_bloc/room_bloc.dart';
import '../widget/full_screen.dart';


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
  List<RoomEntity> _filteredRooms = [];
  List<AreaModel> _allAreas = [];
  Map<int, List<RoomImageEntity>> _roomImages = {};
  Set<int> _pendingImageFetches = {};
  bool _isLoadingAreas = true;
  bool _isLoadingRoomsFromServer = true;
  int _currentPage = 1;
  int _totalItems = 0;
  static const int _limit = 12;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    Future.microtask(() async {
      context.read<RoomBloc>().add(const FetchAreasEvent(page: 1, limit: 100));
      await Future.delayed(const Duration(milliseconds: 100));
      _fetchRooms();
    });
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedAreas = prefs.getString('areas');
    final cachedFilterStatus = prefs.getString('room_filter_status') ?? 'All';
    final cachedAreaId = prefs.getInt('room_filter_area_id');
    final cachedPage = prefs.getInt('room_current_page') ?? 1;

    setState(() {
      _filterStatus = cachedFilterStatus;
      _selectedAreaId = cachedAreaId;
      _currentPage = cachedPage;
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

  Future<void> _saveCachedData(List<AreaModel> areas) async {
    final prefs = await SharedPreferences.getInstance();
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
    await prefs.remove('areas');
    await prefs.remove('room_filter_status');
    await prefs.remove('room_filter_area_id');
    await prefs.remove('room_current_page');
    setState(() {
      _filteredRooms = [];
      _allAreas = [];
      _roomImages = {};
      _pendingImageFetches = {};
      _filterStatus = 'All';
      _selectedAreaId = null;
      _currentPage = 1;
      _totalItems = 0;
      _isLoadingAreas = true;
      _isLoadingRoomsFromServer = true;
    });
    context.read<RoomBloc>().add(const FetchAreasEvent(page: 1, limit: 100));
    await Future.delayed(const Duration(milliseconds: 100));
    _fetchRooms();
  }

  void _fetchRooms() {
    setState(() {
      _isLoadingRoomsFromServer = true;
    });
    context.read<RoomBloc>().add(FetchRoomsEvent(
      page: _currentPage,
      limit: _limit,
      areaId: _selectedAreaId,
      available: _filterStatus == 'All' ? null : _filterStatus == 'AVAILABLE' ? true : false,
    ));
  }

  void _resetFilters() {
    setState(() {
      _filterStatus = 'All';
      _selectedAreaId = null;
      _currentPage = 1;
      _isLoadingRoomsFromServer = true;
      _saveCachedData(_allAreas);
    });
    _fetchRooms();
  }

  void _showImagesDialog(int roomId) {
    final images = _roomImages[roomId] ?? [];
    if (images.isNotEmpty) {
      _openImagesDialog(roomId, images);
      return;
    }

    setState(() {
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
    try {
      // Try to access the bloc first to check if it's available
      final bloc = BlocProvider.of<RegistrationBloc>(context);
      
      // Wrap the RoomRegistrationPage with BlocProvider.value to ensure RegistrationBloc is available
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: bloc,
            child: RoomRegistrationPage(room: room),
          ),
        ),
      );
    } catch (e) {
      // If RegistrationBloc is not accessible for any reason, navigate without provider
      // The RoomRegistrationPage will create its own bloc instance if needed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomRegistrationPage(room: room),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          BlocConsumer<RoomBloc, RoomState>(
            listener: (context, state) {
              if (state is RoomError) {
                setState(() {
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
                  _filteredRooms = state.rooms;
                  _totalItems = state.total;
                  _currentPage = state.currentPage;
                  _isLoadingRoomsFromServer = false;
                });
                _saveCachedData(_allAreas);
              } else if (state is AreasLoaded) {
                setState(() {
                  _allAreas = state.areas as List<AreaModel>;
                  _isLoadingAreas = false;
                });
                print('Areas loaded: ${state.areas.map((a) => a.name).toList()}');
                _saveCachedData(state.areas as List<AreaModel>);
              } else if (state is RoomImagesLoaded) {
                setState(() {
                  _roomImages[state.roomId] = state.images;
                  _pendingImageFetches.remove(state.roomId);
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

              List<RoomEntity> displayedRooms = _filteredRooms;
              if (_filterStatus != 'All') {
                displayedRooms = _filteredRooms.where((room) => room.status == _filterStatus).toList();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await _clearCacheAndRefresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(ResponsiveUtils.wp(context, 2.5)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (widget.showBackButton)
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.black, 
                                          size: ResponsiveUtils.sp(context, 36)
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    SizedBox(width: ResponsiveUtils.wp(context, 2)),
                                    NoSpellCheckText(
                                      text: 'Danh sách phòng',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.sp(context, 24),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        letterSpacing: 0.2,
                                        shadows: [Shadow(color: Colors.black12, blurRadius: 2)],
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh, 
                                    color: Colors.black, 
                                    size: ResponsiveUtils.sp(context, 30)
                                  ),
                                  onPressed: _clearCacheAndRefresh,
                                  tooltip: 'Làm mới',
                                ),
                              ],
                            ),
                            SizedBox(height: ResponsiveUtils.hp(context, 1.2)),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 220, // Set a minimum width for the status dropdown
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const NoSpellCheckText(text: 'Trạng thái', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                                        const SizedBox(height: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                          child: DropdownButtonHideUnderline(
                                            child: Material(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: DropdownButton<String>(
                                                  value: _filterStatus,
                                                  dropdownColor: Colors.white.withOpacity(0.9),
                                                  isExpanded: true,
                                                  borderRadius: BorderRadius.circular(10),
                                                  style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500, fontSize: 15),
                                                  items: [
                                                    DropdownMenuItem(value: 'All', child: NoSpellCheckText(text: 'Tất cả trạng thái')),
                                                    DropdownMenuItem(value: 'AVAILABLE', child: NoSpellCheckText(text: 'Còn chỗ trống')),
                                                    DropdownMenuItem(value: 'OCCUPIED', child: NoSpellCheckText(text: 'Hết chỗ trống')),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _filterStatus = value!;
                                                      _currentPage = 1;
                                                      _isLoadingRoomsFromServer = true;
                                                      _saveCachedData(_allAreas);
                                                      _fetchRooms();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 220, // Set a minimum width for the area dropdown
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const NoSpellCheckText(text: 'Khu vực', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                                        const SizedBox(height: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                          child: DropdownButtonHideUnderline(
                                            child: _isLoadingAreas
                                                ? const Center(child: CircularProgressIndicator())
                                                : state is RoomError
                                                    ? const Center(
                                                        child: NoSpellCheckText(
                                                          text: 'Lỗi tải khu vực',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      )
                                                    : Material(
                                                        child: DropdownButton<int>(
                                                          value: _selectedAreaId,
                                                          dropdownColor: Colors.white.withOpacity(0.9),
                                                          isExpanded: true,
                                                          borderRadius: BorderRadius.circular(10),
                                                          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500, fontSize: 15),
                                                          hint: const NoSpellCheckText(text: 'Tất cả khu vực', style: TextStyle(color: Color(0xFF64748B))),
                                                          items: [
                                                            const DropdownMenuItem<int>(
                                                              value: null,
                                                              child: NoSpellCheckText(text: 'Tất cả khu vực'),
                                                            ),
                                                            ...uniqueAreas.map((area) => DropdownMenuItem<int>(
                                                                  value: area.areaId,
                                                                  child: NoSpellCheckText(text: sanitize(area.name)),
                                                                )),
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedAreaId = value;
                                                              _currentPage = 1;
                                                              _isLoadingRoomsFromServer = true;
                                                              _saveCachedData(_allAreas);
                                                              if (value != null) {
                                                                context.read<RoomBloc>().add(FilterRoomsByAreaEvent(value));
                                                              } else {
                                                                _fetchRooms();
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoadingRoomsFromServer)
                        const SizedBox(height: 300), // Placeholder for loading
                      if (!_isLoadingRoomsFromServer && displayedRooms.isEmpty)
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NoSpellCheckText(
                                  text: _totalItems == 0
                                      ? 'Không có phòng'
                                      : 'Không có phòng phù hợp với bộ lọc',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 18, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                if (_totalItems > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: TextButton(
                                      onPressed: _resetFilters,
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      child: const NoSpellCheckText(text: 'Đặt lại bộ lọc'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (!_isLoadingRoomsFromServer && displayedRooms.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: displayedRooms.length,
                          itemBuilder: (context, index) {
                            final room = displayedRooms[index];
                            return RoomItemWidget(
                              room: room,
                              sanitize: sanitize,
                              onShowImages: () => _showImagesDialog(room.roomId),
                              onRegister: () => _registerForRoom(room),
                            );
                          },
                        ),
                      if (displayedRooms.isNotEmpty && !_isLoadingRoomsFromServer)
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
                                _saveCachedData(_allAreas);
                              });
                              _fetchRooms();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoadingRoomsFromServer)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blue),
                        ),
                        SizedBox(width: 16),
                        NoSpellCheckText(text: 'Đang tải...', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}