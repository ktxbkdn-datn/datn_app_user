import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constant/colors.dart';
import '../../../../common/widgets/filter_tab.dart';
import '../../../../common/widgets/pagination_controls.dart';
import '../../domain/entity/report_entity.dart';
import '../../domain/entity/report_type_entity.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import 'create_report_page.dart';
import 'report_detail_bottom_sheet.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _limit = 10;
  String _filterStatus = 'All';
  String _searchQuery = '';
  List<ReportEntity> _allReports = [];
  List<ReportEntity> _filteredReports = [];
  bool _isInitialLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Fetch fresh data from the server
    context.read<ReportBloc>().add(const GetMyReportsEvent(page: 1, limit: 50));
    context.read<ReportBloc>().add(const GetReportTypesEvent(page: 1, limit: 1000));
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token'); // Use SharedPreferences as per logs
    if (token != null) {
      try {
        final decoded = JwtDecoder.decode(token);
        final userId = int.tryParse(decoded['sub'] ?? '');
        if (userId == null) {
          print('Invalid user ID in JWT: ${decoded['sub']}');
        }
        return userId;
      } catch (e) {
        print('Error decoding JWT: $e');
      }
    } else {
      print('No access token found in SharedPreferences');
    }
    return null;
  }

  void _applyFilters() {
    setState(() {
      _filteredReports = _allReports.where((report) {
        bool matchesStatus = _filterStatus == 'All' || report.status == _filterStatus;
        bool matchesSearch = _searchQuery.isEmpty ||
            report.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  String _getReportTypeName(int? reportTypeId, List<ReportTypeEntity> reportTypes) {
    if (reportTypeId == null || reportTypes.isEmpty) return 'Không xác định';
    try {
      final reportType = reportTypes.firstWhere(
        (type) => type.reportTypeId == reportTypeId,
        orElse: () => ReportTypeEntity(reportTypeId: 0, name: 'Không xác định'),
      );
      return reportType.name ?? 'Không xác định';
    } catch (e) {
      debugPrint('Error in _getReportTypeName: $e');
      return 'Không xác định';
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Đang chờ xử lý';
      case 'RECEIVED':
        return 'Đã tiếp nhận';
      case 'IN_PROGRESS':
        return 'Đang xử lý';
      case 'RESOLVED':
        return 'Đã giải quyết';
      case 'CLOSED':
        return 'Đã đóng';
      default:
        return status;
    }
  }

  void _showReportDetailBottomSheet(ReportEntity report, List<ReportTypeEntity> reportTypes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ReportDetailBottomSheet(
          report: report,
          reportTypes: reportTypes,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: BlocListener<ReportBloc, ReportState>(
              listener: (context, state) async {
                if (state is ReportError) {
                  Get.snackbar(
                    'Lỗi',
                    'Lỗi: ${state.message}',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(8),
                    borderRadius: 8,
                  );
                } else if (state is ReportLoaded) {
                  final userId = await _getCurrentUserId();
                  if (userId == null) {
                    Get.snackbar(
                      'Lỗi',
                      'Không thể xác định người dùng. Vui lòng đăng nhập lại.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  setState(() {
                    _allReports = List<ReportEntity>.from(state.reports)
                        .where((report) => report.userId == userId)
                        .toList()
                      ..sort((a, b) => b.reportId.compareTo(a.reportId));
                    _isInitialLoad = false;
                    _applyFilters();
                    print('Fetched ${state.reports.length} reports, filtered to ${_allReports.length} for userId: $userId');
                  });
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Report",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 36),
                              onPressed: () async {
                                setState(() {
                                  _isInitialLoad = true;
                                });
                                context.read<ReportBloc>().add(const GetMyReportsEvent(page: 1, limit: 50));
                                context.read<ReportBloc>().add(const GetReportTypesEvent(page: 1, limit: 1000));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white, size: 36),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateReportScreen(),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    _isInitialLoad = true;
                                  });
                                  context.read<ReportBloc>().add(const GetMyReportsEvent(page: 1, limit: 50));
                                  context.read<ReportBloc>().add(const GetReportTypesEvent(page: 1, limit: 1000));
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _currentPage = 1;
                          _applyFilters();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm báo cáo...',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterTab(
                            label: 'Tất cả (${_allReports.length})',
                            isSelected: _filterStatus == 'All',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'All';
                                _currentPage = 1;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          FilterTab(
                            label: 'Đang chờ xử lý (${_allReports.where((r) => r.status == 'PENDING').length})',
                            isSelected: _filterStatus == 'PENDING',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'PENDING';
                                _currentPage = 1;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          FilterTab(
                            label: 'Đã tiếp nhận (${_allReports.where((r) => r.status == 'RECEIVED').length})',
                            isSelected: _filterStatus == 'RECEIVED',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'RECEIVED';
                                _currentPage = 1;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          FilterTab(
                            label: 'Đang xử lý (${_allReports.where((r) => r.status == 'IN_PROGRESS').length})',
                            isSelected: _filterStatus == 'IN_PROGRESS',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'IN_PROGRESS';
                                _currentPage = 1;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          FilterTab(
                            label: 'Đã giải quyết (${_allReports.where((r) => r.status == 'RESOLVED').length})',
                            isSelected: _filterStatus == 'RESOLVED',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'RESOLVED';
                                _currentPage = 1;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          FilterTab(
                            label: 'Đã đóng (${_allReports.where((r) => r.status == 'CLOSED').length})',
                            isSelected: _filterStatus == 'CLOSED',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'CLOSED';
                                _currentPage = 1;
                                _applyFilters();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ReportBloc, ReportState>(
                      builder: (context, state) {
                        if (state is ReportLoading && _isInitialLoad) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is ReportError) {
                          return Center(child: Text('Lỗi: ${state.message}'));
                        }

                        List<ReportTypeEntity> reportTypes = state is ReportLoaded ? state.reportTypes : [];

                        int startIndex = (_currentPage - 1) * _limit;
                        int endIndex = startIndex + _limit;
                        if (endIndex > _filteredReports.length) endIndex = _filteredReports.length;
                        List<ReportEntity> paginatedReports = startIndex < _filteredReports.length
                            ? _filteredReports.sublist(startIndex, endIndex)
                            : [];

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: paginatedReports.length,
                                itemBuilder: (context, index) {
                                  final report = paginatedReports[index];
                                  return GestureDetector(
                                    onTap: () {
                                      _showReportDetailBottomSheet(report, reportTypes);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16.0),
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _getReportTypeName(report.reportTypeId, reportTypes),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Trạng thái: ${_translateStatus(report.status)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            PaginationControls(
                              currentPage: _currentPage,
                              totalItems: _filteredReports.length,
                              limit: _limit,
                              onPageChanged: (page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}