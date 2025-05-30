import 'package:datn_app/common/constant/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Thêm package intl để định dạng ngày
import '../../../../feature/bill/presentation/bill_bloc/bill_bloc.dart';
import '../../../../feature/bill/presentation/bill_bloc/bill_event.dart';
import '../../../../feature/bill/presentation/bill_bloc/bill_state.dart';
import '../../domain/entity/bill_entities.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isFetchingBills = false;

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

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  void _fetchBills() {
    if (_isFetchingBills) return;
    setState(() {
      _isFetchingBills = true;
    });
    context.read<BillBloc>().add(const GetMyBillsEvent(
      page: 1,
      limit: 10,
      paymentStatus: 'PAID',
    ));
  }

  // Hàm định dạng ngày
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
                            'Payment History',
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
                                onPressed: _isFetchingBills ? null : _fetchBills,
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
                        child: BlocBuilder<BillBloc, BillState>(
                          builder: (context, state) {
                            if (state is BillLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state is BillEmpty) {
                              return const Center(child: Text('Bạn chưa có hóa đơn nào đã thanh toán'));
                            }
                            if (state is BillError) {
                              if (state.message.contains('Không thể làm mới token')) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.offAllNamed('/login');
                                        },
                                        child: const Text('Đăng nhập lại'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Center(
                                child: Text('Lỗi: ${state.message}'),
                              );
                            }
                            if (state is BillLoaded) {
                              final bills = state.bills;
                              if (bills.isEmpty) {
                                return const Center(child: Text('Bạn chưa có hóa đơn nào đã thanh toán'));
                              }
                              return ListView.builder(
                                itemCount: bills.length,
                                itemBuilder: (context, index) {
                                  final bill = bills[index];
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
                              );
                            }
                            return const Center(child: Text('Vui lòng làm mới để tải dữ liệu'));
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