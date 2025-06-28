import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import 'create_report_page.dart';
import 'report_detail_bottom_sheet.dart';
import '../../domain/entity/report_entity.dart';
import '../../domain/entity/report_type_entity.dart';
import '../../../../common/widgets/pagination_controls.dart';
import 'package:datn_app/common/components/app_background.dart';
import '../../../../common/utils/responsive_utils.dart';

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

  void _applyFilters() {
    setState(() {
      _filteredReports = _allReports.where((report) {
        bool matchesStatus = _filterStatus == 'All' || report.status == _filterStatus;
        bool matchesSearch = _searchQuery.isEmpty ||
            report.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesStatus && matchesSearch;
      }).toList();
      // Sắp xếp theo thời gian tạo mới nhất
      _filteredReports.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!));
      });
    });
  }

  String _getReportTypeName(int? reportTypeId, List<ReportTypeEntity> reportTypes) {
    if (reportTypeId == null || reportTypes.isEmpty) return 'Không xác định';
    try {
      final reportType = reportTypes.firstWhere(
        (type) => type.reportTypeId == reportTypeId,
        orElse: () => ReportTypeEntity(reportTypeId: 0, name: 'Không xác định'),
      );
      return reportType.name;
    } catch (e) {
      debugPrint('Error in _getReportTypeName: $e');
      return 'Không xác định';
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
    return AppBackground(
      child: Stack(
        children: [
          BlocBuilder<ReportBloc, ReportState>(
            buildWhen: (previous, current) {
              return current is ReportLoading || current is ReportLoaded || current is ReportError;
            },
            builder: (context, state) {
              // Loading overlay
              if (state is ReportLoading && _isInitialLoad) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(context, 6),
                          vertical: ResponsiveUtils.hp(context, 2)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: ResponsiveUtils.wp(context, 6),
                              height: ResponsiveUtils.wp(context, 6),
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blue),
                            ),
                            SizedBox(width: ResponsiveUtils.wp(context, 4)),
                            Text(
                              'Đang tải...', 
                              style: TextStyle(fontSize: ResponsiveUtils.sp(context, 16))
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              // Main content
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Padding(
                      padding: EdgeInsets.all(ResponsiveUtils.wp(context, 4)),
                      child: Card(
                        elevation: 10,
                        color: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(context, 5),
                            vertical: ResponsiveUtils.hp(context, 2)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.assignment, color: Colors.blue, size: ResponsiveUtils.sp(context, 28)),
                                  SizedBox(width: ResponsiveUtils.wp(context, 2.5)),
                                  Text(
                                    "Báo cáo của tôi",
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.sp(context, 22),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.refresh, color: Colors.blue, size: ResponsiveUtils.sp(context, 28)),
                                    tooltip: 'Làm mới',
                                    onPressed: () async {
                                      setState(() {
                                        _isInitialLoad = true;
                                      });
                                      context.read<ReportBloc>().add(const GetMyReportsEvent(page: 1, limit: 50));
                                      context.read<ReportBloc>().add(const GetReportTypesEvent(page: 1, limit: 1000));
                                    },
                                  ),
                                  SizedBox(width: ResponsiveUtils.wp(context, 1.5)),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 0,
                                      padding: EdgeInsets.all(ResponsiveUtils.wp(context, 3)),
                                    ),
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
                                    child: Icon(Icons.add, size: ResponsiveUtils.sp(context, 24)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(context, 5)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _currentPage = 1;
                              _applyFilters();
                            });
                          },
                          style: TextStyle(fontSize: ResponsiveUtils.sp(context, 15)),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm báo cáo...',
                            hintStyle: TextStyle(fontSize: ResponsiveUtils.sp(context, 15)),
                            prefixIcon: Icon(Icons.search, color: Colors.blueGrey, size: ResponsiveUtils.sp(context, 20)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.wp(context, 4.5),
                              vertical: ResponsiveUtils.hp(context, 2)
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.hp(context, 1.2)),
                    // Status Filters as modern badges
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(context, 4)),
                      child: SizedBox(
                        height: ResponsiveUtils.hp(context, 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildStatusBadge('All', 'Tất cả', _allReports.length, _filterStatus == 'All', Colors.blue),
                              SizedBox(width: ResponsiveUtils.wp(context, 2)),
                              _buildStatusBadge('PENDING', 'Đang chờ xử lý', _allReports.where((r) => r.status == 'PENDING').length, _filterStatus == 'PENDING', Colors.orange),
                              SizedBox(width: ResponsiveUtils.wp(context, 2)),
                              _buildStatusBadge('RECEIVED', 'Đã tiếp nhận', _allReports.where((r) => r.status == 'RECEIVED').length, _filterStatus == 'RECEIVED', Colors.indigo),
                              SizedBox(width: ResponsiveUtils.wp(context, 2)),
                              _buildStatusBadge('IN_PROGRESS', 'Đang xử lý', _allReports.where((r) => r.status == 'IN_PROGRESS').length, _filterStatus == 'IN_PROGRESS', Colors.amber),
                              SizedBox(width: ResponsiveUtils.wp(context, 2)),
                              _buildStatusBadge('RESOLVED', 'Đã giải quyết', _allReports.where((r) => r.status == 'RESOLVED').length, _filterStatus == 'RESOLVED', Colors.green),
                              SizedBox(width: ResponsiveUtils.wp(context, 2)),
                              _buildStatusBadge('CLOSED', 'Đã đóng', _allReports.where((r) => r.status == 'CLOSED').length, _filterStatus == 'CLOSED', Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.hp(context, 1.2)),
                    // Reports Grid/List
                    Expanded(
                      child: BlocBuilder<ReportBloc, ReportState>(
                        buildWhen: (previous, current) {
                          // Always rebuild on loading or loaded
                          return current is ReportLoading || current is ReportLoaded || current is ReportError;
                        },
                        builder: (context, state) {
                          if (state is ReportLoading && _isInitialLoad) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is ReportLoaded) {
                            if (_isInitialLoad) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _isInitialLoad = false;
                                  _allReports = state.reports;
                                  _applyFilters();
                              });
                            });
                            }
                          }
                          List<ReportTypeEntity> reportTypes = state is ReportLoaded ? state.reportTypes : [];
                          int startIndex = (_currentPage - 1) * _limit;
                          int endIndex = startIndex + _limit;
                          if (endIndex > _filteredReports.length) endIndex = _filteredReports.length;
                          List<ReportEntity> paginatedReports = startIndex < _filteredReports.length
                              ? _filteredReports.sublist(startIndex, endIndex)
                              : [];
                          if (_filteredReports.isEmpty) {
                            return Center(
                              child: Card(
                                color: Colors.white.withOpacity(0.7),
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.wp(context, 8),
                                    vertical: ResponsiveUtils.hp(context, 5)
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _allReports.isEmpty ? "Chưa có báo cáo nào" : "Không tìm thấy báo cáo phù hợp",
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils.sp(context, 18), 
                                          color: Colors.black54, 
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      SizedBox(height: ResponsiveUtils.hp(context, 2.2)),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          elevation: 0,
                                          padding: EdgeInsets.all(ResponsiveUtils.wp(context, 4)),
                                        ),
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
                                        child: Icon(Icons.add, size: ResponsiveUtils.sp(context, 28)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          // Grid of glassy report cards
                          return Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.wp(context, 3),
                                    vertical: ResponsiveUtils.hp(context, 0.3)
                                  ),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: ResponsiveUtils.isTablet(context) ? 2 : 1,
                                    childAspectRatio: ResponsiveUtils.isTablet(context) ? 3.5 : 4.0,
                                    mainAxisSpacing: ResponsiveUtils.hp(context, 1),
                                    crossAxisSpacing: ResponsiveUtils.wp(context, 3),
                                  ),
                                  itemCount: paginatedReports.length,
                                  itemBuilder: (context, index) {
                                    final report = paginatedReports[index];
                                    return _buildReportCard(report, reportTypes, () {
                                      _showReportDetailBottomSheet(report, reportTypes);
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: PaginationControls(
                                  currentPage: _currentPage,
                                  totalItems: _filteredReports.length,
                                  limit: _limit,
                                  onPageChanged: (page) {
                                    setState(() {
                                      _currentPage = page;
                                    });
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
            },
          ),
        ],
      ),
    );
  }

  // Modern badge for status filter
  Widget _buildStatusBadge(String key, String label, int count, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = key;
          _currentPage = 1;
          _applyFilters();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.wp(context, 3),
          vertical: ResponsiveUtils.hp(context, 0.8)
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? color : Colors.blueGrey.withOpacity(0.18), width: 1.2),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(context, 12),
              ),
            ),
            SizedBox(width: ResponsiveUtils.wp(context, 1)),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(context, 1.5),
                  vertical: ResponsiveUtils.hp(context, 0.2)
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.18) : color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.sp(context, 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Modern glassy report card with fixed height
  Widget _buildReportCard(ReportEntity report, List<ReportTypeEntity> reportTypes, VoidCallback onTap) {
    final statusInfo = _getStatusInfo(report.status);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white.withOpacity(0.9),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: 90, // Fixed height to prevent overflow
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status indicator - left colored strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusInfo.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              
              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(context, 2.5),
                    vertical: ResponsiveUtils.hp(context, 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top row with title and type
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon and title
                          Expanded(
                            flex: 7,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  statusInfo.icon, 
                                  color: statusInfo.color, 
                                  size: ResponsiveUtils.sp(context, 18)
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    report.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveUtils.sp(context, 14),
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Type badge
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getReportTypeName(report.reportTypeId, reportTypes),
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ResponsiveUtils.sp(context, 10),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Bottom row with status and date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusInfo.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: statusInfo.color.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusInfo.icon,
                                  color: statusInfo.color,
                                  size: ResponsiveUtils.sp(context, 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusInfo.label,
                                  style: TextStyle(
                                    color: statusInfo.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.sp(context, 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Date
                          Text(
                            '${report.createdAt != null ? _formatDate(report.createdAt!) : ''}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.sp(context, 10),
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Status info for card
  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'PENDING':
        return _StatusInfo('Đang chờ xử lý', Colors.orange, Icons.access_time);
      case 'RECEIVED':
        return _StatusInfo('Đã tiếp nhận', Colors.indigo, Icons.mark_email_read_rounded);
      case 'IN_PROGRESS':
        return _StatusInfo('Đang xử lý', Colors.amber, Icons.sync);
      case 'RESOLVED':
        return _StatusInfo('Đã giải quyết', Colors.green, Icons.check_circle_outline);
      case 'CLOSED':
        return _StatusInfo('Đã đóng', Colors.grey, Icons.cancel_outlined);
      default:
        return _StatusInfo(status, Colors.blueGrey, Icons.description);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;
  _StatusInfo(this.label, this.color, this.icon);
}