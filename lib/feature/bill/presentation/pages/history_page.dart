import 'package:datn_app/common/constant/colors.dart';
import 'package:datn_app/common/widgets/pagination_controls.dart';
import 'package:flutter/foundation.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 600.0;
    final contentWidth = screenWidth > maxContentWidth ? maxContentWidth : screenWidth;
    final horizontalPadding = screenWidth > maxContentWidth ? 16.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lịch sử thanh toán',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: kIsWeb ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: _isFetchingBills ? Colors.grey : Colors.white,
                                  size: 24,
                                ),
                                onPressed: _isFetchingBills ? null : () => _fetchBills(_currentPage),
                                tooltip: 'Làm mới',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () => Get.back(),
                                tooltip: 'Quay lại',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: BlocConsumer<BillBloc, BillState>(
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
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state is BillEmpty || _bills.isEmpty) {
                              return const Center(child: Text('Bạn chưa có hóa đơn nào đã thanh toán'));
                            }
                            if (state is BillError) {
                              return Center(
                                child: Text('Lỗi: ${state.message}'),
                              );
                            }
                            return Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _bills.length,
                                    itemBuilder: (context, index) {
                                      final bill = _bills[index];
                                      final serviceName = bill.toJson()['service_name'] ?? 'Không xác định';
                                      return Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Hóa đơn $serviceName #${bill.billId}",
                                                      style: TextStyle(
                                                        fontSize: kIsWeb ? 14 : 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '${bill.totalAmount.toStringAsFixed(2)} VNĐ',
                                                      style: TextStyle(
                                                        fontSize: kIsWeb ? 16 : 18,
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Trạng thái: ${mapPaymentStatusToVietnamese(bill.paymentStatus)}',
                                                      style: TextStyle(
                                                        fontSize: kIsWeb ? 12 : 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Ngày thanh toán: ${formatDate(bill.paidAt)}',
                                                      style: TextStyle(
                                                        fontSize: kIsWeb ? 12 : 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (state is BillLoaded)
                                  PaginationControls(
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
                              ],
                            );
                          },
                        ),
                      ),
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

