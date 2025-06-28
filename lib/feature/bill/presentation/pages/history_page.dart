import 'package:datn_app/common/components/app_background.dart';
import 'package:datn_app/common/constant/colors.dart';
import 'package:datn_app/common/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/bill_bloc/bill_bloc.dart';
import '../bloc/bill_bloc/bill_event.dart';
import '../bloc/bill_bloc/bill_state.dart';
import '../../domain/entity/bill_entities.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<MonthlyBill> _bills = [];
  bool _isFetchingBills = false;
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadCurrentPage();
    _fetchBills(_currentPage);
  }

  Future<void> _loadCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('history_current_page') ?? 1;
    });
  }

  Future<void> _saveCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('history_current_page', _currentPage);
  }

  void _fetchBills(int page) {
    if (_isFetchingBills) return;
    setState(() {
      _isFetchingBills = true;
    });
    context.read<BillBloc>().add(GetMyBillsEvent(
      page: page,
      limit: _limit,
      paymentStatus: 'PAID',
    ));
  }

  String mapPaymentStatusToVietnamese(String status) {
    switch (status) {
      case 'PAID':
        return 'Đã thanh toán';
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'FAILED':
        return 'Thanh toán thất bại';
      case 'OVERDUE':
        return 'Quá hạn';
      default:
        return status;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      return formatter.format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          // Loading overlay
          if (_isFetchingBills)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blue),
                        ),
                        SizedBox(width: 16),
                        Text('Đang tải...', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Main content
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchBills(_currentPage);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header card
                        Card(
                          elevation: 10,
                          color: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          shadowColor: Colors.blue.withOpacity(0.12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.indigo, size: 26),
                                      onPressed: () => Get.back(),
                                      tooltip: 'Quay lại',
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Lịch sử thanh toán',
                                      style: TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh, color: _isFetchingBills ? Colors.grey : Colors.indigo, size: 24),
                                  onPressed: _isFetchingBills ? null : () => _fetchBills(_currentPage),
                                  tooltip: 'Làm mới',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        BlocConsumer<BillBloc, BillState>(
                          listener: (context, state) {
                            setState(() {
                              _isFetchingBills = false;
                            });
                            if (state is BillError) {
                              Get.snackbar(
                                'Lỗi',
                                state.message,
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 3),
                              );
                              if (state.message.contains('Không thể làm mới token')) {
                                Get.offAllNamed('/login');
                              }
                            }
                            if (state is BillLoaded) {
                              setState(() {
                                _bills = state.bills;
                              });
                            }
                            if (state is BillEmpty) {
                              setState(() {
                                _bills = [];
                              });
                            }
                          },
                          builder: (context, state) {
                            if (state is BillLoading && _bills.isEmpty) {
                              return const SizedBox(height: 200);
                            }
                            if (state is BillEmpty || _bills.isEmpty) {
                              return Card(
                                elevation: 8,
                                color: Colors.white.withOpacity(0.7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                shadowColor: Colors.blue.withOpacity(0.10),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      'Bạn chưa có hóa đơn nào đã thanh toán',
                                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (state is BillError) {
                              return Card(
                                elevation: 8,
                                color: Colors.white.withOpacity(0.7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                shadowColor: Colors.red.withOpacity(0.10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      'Lỗi: ${state.message}',
                                      style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              );
                            }
                            // Bill cards grid
                            return Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1.9,
                                    mainAxisSpacing: 18,
                                  ),
                                  itemCount: _bills.length,
                                  itemBuilder: (context, index) {
                                    final bill = _bills[index];
                                    final serviceName = bill.toJson()['service_name'] ?? 'Không xác định';
                                    final statusInfo = _getStatusInfo(bill.paymentStatus);
                                    return Card(
                                      elevation: 8,
                                      color: Colors.white.withOpacity(0.8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      shadowColor: Colors.indigo.withOpacity(0.10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Hóa đơn $serviceName #${bill.billId}',
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      '${bill.totalAmount.toStringAsFixed(0)} VNĐ',
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: statusInfo['bgColor'],
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(statusInfo['icon'], color: statusInfo['iconColor'], size: 18),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        statusInfo['label'],
                                                        style: TextStyle(
                                                          color: statusInfo['textColor'],
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 14),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Tháng:', style: TextStyle(color: Colors.black54)),
                                                Text(bill.billMonth, style: const TextStyle(fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                            if (bill.paidAt != null)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text('Ngày thanh toán:', style: TextStyle(color: Colors.black54)),
                                                  Text(formatDate(bill.paidAt), style: const TextStyle(fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Ngày tạo:', style: TextStyle(color: Colors.black54)),
                                                Text(formatDate(bill.createdAt), style: const TextStyle(fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (state is BillLoaded)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: PaginationControls(
                                      currentPage: _currentPage,
                                      totalItems: state.billsPagination.totalItems,
                                      limit: _limit,
                                      onPageChanged: (newPage) {
                                        setState(() {
                                          _currentPage = newPage;
                                        });
                                        _saveCurrentPage();
                                        _fetchBills(newPage);
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'PAID':
        return {
          'label': 'Đã thanh toán',
          'bgColor': const Color(0xFFD1FAE5),
          'textColor': const Color(0xFF065F46),
          'icon': Icons.check_circle,
          'iconColor': const Color(0xFF10B981),
        };
      case 'PENDING':
        return {
          'label': 'Chờ thanh toán',
          'bgColor': const Color(0xFFFFF7CD),
          'textColor': const Color(0xFFB45309),
          'icon': Icons.access_time,
          'iconColor': const Color(0xFFF59E42),
        };
      case 'FAILED':
        return {
          'label': 'Thanh toán thất bại',
          'bgColor': const Color(0xFFFECACA),
          'textColor': const Color(0xFF991B1B),
          'icon': Icons.cancel,
          'iconColor': const Color(0xFFEF4444),
        };
      case 'OVERDUE':
        return {
          'label': 'Quá hạn',
          'bgColor': const Color(0xFFFFEDD5),
          'textColor': const Color(0xFFB45309),
          'icon': Icons.warning,
          'iconColor': const Color(0xFFF59E42),
        };
      default:
        return {
          'label': status,
          'bgColor': const Color(0xFFF3F4F6),
          'textColor': const Color(0xFF374151),
          'icon': Icons.receipt_long,
          'iconColor': const Color(0xFF6B7280),
        };
    }
  }
}

