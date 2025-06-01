import 'package:datn_app/common/constant/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../../../common/constant/api_constant.dart';
import '../bloc/bill_bloc/bill_bloc.dart';
import '../bloc/bill_bloc/bill_event.dart';
import '../bloc/bill_bloc/bill_state.dart';
import '../bloc/payment_bloc/payment_bloc.dart';
import '../bloc/payment_bloc/payment_event.dart';
import '../bloc/payment_bloc/payment_state.dart';
import '../../../service/presentation/bloc/service_bloc.dart';
import '../../../service/presentation/bloc/service_event.dart';
import '../../../service/presentation/bloc/service_state.dart';
import '../../domain/entity/bill_entities.dart';
import 'history_page.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> services = [];
  List<MonthlyBill> lastBills = [];
  bool _isFetchingBills = false;
  Timer? _pollingTimer;
  String? _currentTransactionId;
  String? _paymentUrl;
  int? _lastFailedBillId;
  bool _isTabActive = true;
  bool _isServicesLoaded = false;
  int? _lastSelectedServiceId;
  bool _hasSubmitted = false;
  AppColors appColors = AppColors();
  Timer? _refreshDebounceTimer; // For debouncing refresh
  late TextEditingController _currentReadingController; // Controller for meter reading

  @override
  void initState() {
    super.initState();
    _currentReadingController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });
    Future.microtask(() {
      context.read<BillBloc>().add(const ResetBillStateEvent());
    });
    context.read<ServiceBloc>().add(const FetchServicesEvent());
    _fetchBills();
  }

  @override
  void dispose() {
    _currentReadingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _refreshDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      print('App paused (background), stopping polling');
      _isTabActive = false;
      _pollingTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      print('App resumed (foreground), resuming polling if needed');
      _isTabActive = true;
      if (_currentTransactionId != null) {
        _startPolling(_currentTransactionId!);
      }
    }
  }

  void _fetchBills() {
    if (_isFetchingBills) return;
    setState(() {
      _isFetchingBills = true;
    });
    context.read<BillBloc>().add(const GetMyBillsEvent(page: 1, limit: 10));
  }

  void _refreshData() {
    if (_isFetchingBills) return;
    // Debounce refresh to prevent rapid state changes
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isFetchingBills = true;
      });
      context.read<BillBloc>().add(const GetMyBillsEvent(page: 1, limit: 10));
    });
  }

  void _showMeterReadingSheet(BuildContext context, String serviceTitle, int serviceId) {
    if (!_isServicesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang tải danh sách dịch vụ, vui lòng chờ...")),
      );
      return;
    }

    print('Opening meter reading sheet for service: $serviceTitle, service_id: $serviceId');

    setState(() {
      _lastSelectedServiceId = serviceId;
    });

    bool isBottomSheetActive = true; // Track if bottom sheet is active

    // Lấy thời gian thực tế
    DateTime now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

    // Tính toán các năm và tháng hợp lệ (chỉ tháng hiện tại và tháng liền trước)
    List<int> availableYears = [];
    List<Map<String, dynamic>> availableYearMonths = [];

    // Tháng hiện tại và tháng liền trước
    DateTime earliestDate = DateTime(currentYear, currentMonth - 1, 1);
    DateTime latestDate = now;

    // Tạo danh sách các năm
    for (int year = earliestDate.year; year <= latestDate.year; year++) {
      availableYears.add(year);
    }

    // Tạo danh sách các tháng hợp lệ theo từng năm
    for (int year = earliestDate.year; year <= latestDate.year; year++) {
      int startMonth = (year == earliestDate.year) ? earliestDate.month : 1;
      int endMonth = (year == latestDate.year) ? latestDate.month : 12;

      for (int month = startMonth; month <= endMonth; month++) {
        availableYearMonths.add({
          'year': year,
          'month': month < 10 ? '0$month' : '$month',
        });
      }
    }

    // Mặc định chọn năm và tháng hiện tại
    int selectedYear = currentYear;
    String selectedMonth = DateFormat('MM').format(now);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            // Ẩn bàn phím trước khi đóng bottom sheet
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 300));
            isBottomSheetActive = false; // Mark bottom sheet as closed
            return true;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nhập chỉ số $serviceTitle",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: "Chọn năm",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: availableYears.map((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: isBottomSheetActive
                          ? (int? newValue) {
                              setModalState(() {
                                selectedYear = newValue!;
                                int earliestMonthForYear = (selectedYear == earliestDate.year) ? earliestDate.month : 1;
                                int latestMonthForYear = (selectedYear == latestDate.year) ? latestDate.month : 12;
                                int currentSelectedMonth = int.parse(selectedMonth);
                                if (currentSelectedMonth < earliestMonthForYear) {
                                  selectedMonth = earliestMonthForYear < 10 ? '0$earliestMonthForYear' : '$earliestMonthForYear';
                                } else if (currentSelectedMonth > latestMonthForYear) {
                                  selectedMonth = latestMonthForYear < 10 ? '0$latestMonthForYear' : '$latestMonthForYear';
                                }
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: "Chọn tháng",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: availableYearMonths
                          .where((ym) => ym['year'] == selectedYear)
                          .map((ym) => DropdownMenuItem<String>(
                                value: ym['month'],
                                child: Text('Tháng ${ym['month']}'),
                              ))
                          .toList(),
                      onChanged: isBottomSheetActive
                          ? (String? newValue) {
                              setModalState(() {
                                selectedMonth = newValue!;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currentReadingController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Chỉ số tháng này",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      enabled: isBottomSheetActive,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: isBottomSheetActive
                            ? () async {
                                if (_currentReadingController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Vui lòng nhập chỉ số tháng này")),
                                  );
                                  return;
                                }
                                double current;
                                try {
                                  current = double.parse(_currentReadingController.text);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Chỉ số phải là một số hợp lệ")),
                                  );
                                  return;
                                }
                                if (current < 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Chỉ số không được âm")),
                                  );
                                  return;
                                }

                                String billMonth = '$selectedYear-$selectedMonth';
                                print('Selected bill month: $billMonth');

                                DateTime selectedDate = DateTime(selectedYear, int.parse(selectedMonth));
                                DateTime currentDate = DateTime(now.year, now.month);
                                int monthsDifference = ((currentDate.year - selectedDate.year) * 12 + currentDate.month - selectedDate.month).abs();

                                if (monthsDifference > 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Chỉ được phép gửi chỉ số cho tháng hiện tại hoặc tháng liền trước")),
                                  );
                                  return;
                                }

                                Map<String, Map<String, double>> readings = {
                                  serviceId.toString(): {
                                    'current': current,
                                  },
                                };
                                print('Submitting reading for service_id: $serviceId, value: $current, readings: $readings');

                                // Ẩn bàn phím trước khi gửi sự kiện
                                print('Before unfocus: Keyboard visible=${MediaQuery.of(context).viewInsets.bottom > 0}');
                                FocusScope.of(context).unfocus();
                                await Future.delayed(const Duration(milliseconds: 300));
                                print('After unfocus: Keyboard visible=${MediaQuery.of(context).viewInsets.bottom > 0}');

                                setState(() {
                                  _hasSubmitted = true;
                                });

                                context.read<BillBloc>().add(SubmitBillDetailEvent(
                                  billMonth: billMonth,
                                  readings: readings,
                                ));

                                // Mark bottom sheet as closed before popping
                                isBottomSheetActive = false;
                                // Đóng bottom sheet sau khi gửi sự kiện
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text("Submit"),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      // Clear the controller's text instead of disposing
      _currentReadingController.clear();
    });
  }

  Future<void> _launchURL(String url, String transactionId) async {
    final Uri uri = Uri.parse(url);
    try {
      LaunchMode mode = kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;
      if (kIsWeb) {
        print('Opening URL on web: $url');
        await launchUrl(
          uri,
          mode: mode,
          webOnlyWindowName: '_blank',
        );
      } else {
        print('Opening URL on mobile: $url');
        await launchUrl(
          uri,
          mode: mode,
        );
      }
      _startPolling(transactionId);
    } catch (e) {
      print('Error launching URL: $e\nStack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể mở URL thanh toán. Vui lòng thử lại.'),
          action: SnackBarAction(
            label: 'Thử lại',
            onPressed: () {
              if (_paymentUrl != null && _currentTransactionId != null) {
                _launchURL(_paymentUrl!, _currentTransactionId!);
              }
            },
          ),
        ),
      );
    }
  }

  void _startPolling(String transactionId) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng hoàn tất thanh toán trên tab mới và quay lại ứng dụng.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
    print('Starting polling for transaction ID: $transactionId');
    _currentTransactionId = transactionId;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isTabActive) return;
      print('Polling transaction ID: $transactionId');
      context.read<PaymentTransactionBloc>().add(GetPaymentTransactionByIdEvent(
        transactionId: transactionId,
      ));
    });
  }

  void _stopPolling() {
    print('Stopping polling');
    _pollingTimer?.cancel();
    _currentTransactionId = null;
    setState(() {
      _paymentUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 600.0;
    final contentWidth = screenWidth > maxContentWidth ? maxContentWidth : screenWidth;
    final horizontalPadding = screenWidth > maxContentWidth ? 16.0 : 16.0;

    return ScaffoldMessenger(
      child: Scaffold(
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
                    child: MultiBlocListener(
                      listeners: [
                        BlocListener<ServiceBloc, ServiceState>(
                          listener: (context, state) {
                            if (state is ServiceLoaded) {
                              print('ServiceLoaded: ${state.services}');
                              setState(() {
                                services = state.services.map((service) {
                                  Color color;
                                  switch (service.name.toLowerCase()) {
                                    case 'Điện':
                                      color = Colors.blue;
                                      break;
                                    case 'Nước':
                                      color = Colors.orange;
                                      break;
                                    default:
                                      color = Colors.grey;
                                  }
                                  return {
                                    'title': service.name,
                                    'color': color,
                                    'service_id': service.serviceId,
                                  };
                                }).toList();
                                print('Updated services: $services');
                                _isServicesLoaded = true;
                              });
                            } else if (state is ServiceError) {
                              print('Service error: ${state.message}\nStack trace: ${StackTrace.current}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Lỗi tải dịch vụ: Vui lòng thử lại.'),
                                  action: SnackBarAction(
                                    label: 'Thử lại',
                                    onPressed: () {
                                      context.read<ServiceBloc>().add(const FetchServicesEvent());
                                    },
                                  ),
                                ),
                              );
                              setState(() {
                                _isServicesLoaded = false;
                              });
                            }
                          },
                        ),
                        BlocListener<PaymentTransactionBloc, PaymentTransactionState>(
                          listener: (context, state) {
                            if (state is PaymentTransactionLoaded && state.selectedTransaction != null) {
                              final transaction = state.selectedTransaction!;
                              print('Transaction ID: ${transaction.transactionId} (Type: ${transaction.transactionId.runtimeType})');
                              if (transaction.paymentUrl != null) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đang chuyển hướng đến trang thanh toán...'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                print('Automatically launching URL: ${transaction.paymentUrl}');
                                _launchURL(transaction.paymentUrl!, transaction.transactionId);
                                if (kIsWeb) {
                                  setState(() {
                                    _paymentUrl = transaction.paymentUrl;
                                  });
                                }
                              } else if (_currentTransactionId == transaction.transactionId) {
                                if (transaction.status == 'SUCCESS') {
                                  print('Payment successful');
                                  _stopPolling();
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Thanh toán thành công cho giao dịch #${transaction.transactionId}'),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                  _refreshData();
                                } else if (transaction.status == 'FAILED') {
                                  print('Payment failed');
                                  _stopPolling();
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Thanh toán thất bại cho giao dịch #${transaction.transactionId}'),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }
                            } else if (state is PaymentTransactionError) {
                              print('Payment error: ${state.message}\nStack trace: ${StackTrace.current}');
                              _stopPolling();
                              String displayMessage = 'Không thể thanh toán. Vui lòng thử lại.';
                              if (state.message.contains('Phương thức thanh toán không hợp lệ')) {
                                displayMessage = 'Phương thức thanh toán VNPay hiện không khả dụng. Vui lòng thử lại sau.';
                              } else if (state.message.contains('Hóa đơn đã được thanh toán')) {
                                displayMessage = 'Hóa đơn này đã được thanh toán.';
                              } else if (state.message.contains('Bạn không có quyền thanh toán hóa đơn này')) {
                                displayMessage = 'Bạn không có quyền thanh toán hóa đơn này.';
                              } else if (state.message.contains('Resource not found')) {
                                print('Ignoring "Resource not found" error during polling');
                                context.read<PaymentTransactionBloc>().add(ResetPaymentTransactionStateEvent());
                                return;
                              }
                              if (_isTabActive) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(displayMessage),
                                    action: _lastFailedBillId != null
                                        ? SnackBarAction(
                                            label: 'Thử lại',
                                            onPressed: () {
                                              if (_lastFailedBillId != null) {
                                                context.read<PaymentTransactionBloc>().add(
                                                      CreatePaymentTransactionEvent(
                                                        billId: _lastFailedBillId!,
                                                        paymentMethod: 'VNPAY',
                                                        returnUrl: getAPIbaseUrl() + "/payment-transactions/callback",
                                                      ),
                                                    );
                                              }
                                            },
                                          )
                                        : null,
                                  ),
                                );
                              }
                              context.read<PaymentTransactionBloc>().add(ResetPaymentTransactionStateEvent());
                            }
                          },
                        ),
                      ],
                      child: BlocConsumer<BillBloc, BillState>(
                        listener: (context, state) {
                          print('BillBloc state: $state, _hasSubmitted: $_hasSubmitted');
                          if (state is BillError && _hasSubmitted) {
                            print('Bill error received: ${state.message}');
                            String displayMessage = 'Lỗi khi nộp chỉ số. Vui lòng thử lại.';

                            if (state.message.contains('Đã có người gửi chỉ số')) {
                              displayMessage = 'Chỉ số cho tháng này đã được gửi. Vui lòng chọn tháng khác.';
                            } else if (state.message.contains('Không thể gửi chỉ số cho tháng')) {
                              displayMessage = state.message;
                            } else if (state.message.contains('Vui lòng nhập chỉ số hiện tại cho dịch vụ')) {
                              displayMessage = state.message;
                            } else if (state.message.contains('Chỉ số hiện tại phải lớn hơn')) {
                              displayMessage = state.message;
                            } else if (state.message.contains('Chỉ số không được âm')) {
                              displayMessage = state.message;
                            } else if (state.message.contains('Không tìm thấy hóa đơn nào')) {
                              displayMessage = 'Không tìm thấy hóa đơn nào cho tháng này.';
                            } else if (state.message.contains('Dữ liệu trả về không đúng định dạng')) {
                              displayMessage = 'Lỗi hệ thống: Dữ liệu trả về không đúng định dạng. Vui lòng thử lại.';
                            }

                            print('Showing SnackBar with cleaned SnackBars');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(displayMessage),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } else if (state is BillLoaded && _hasSubmitted) {
                            print('Bill submission successful, showing success SnackBar');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã gửi chỉ số thành công'),
                                duration: Duration(seconds: 4),
                              ),
                            );
                            _refreshData();
                          }

                          if (state is BillLoaded || state is BillError || state is BillEmpty) {
                            print('Resetting _hasSubmitted and updating _isFetchingBills');
                            setState(() {
                              _hasSubmitted = false;
                              _isFetchingBills = false;
                            });
                          }
                        },
                        builder: (context, billState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Trang thanh toán',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: kIsWeb ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nhập báo cáo chỉ số',
                                    style: TextStyle(
                                      fontSize: kIsWeb ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Lịch sử giao dịch',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: kIsWeb ? 14 : 16,
                                        shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(() => const HistoryScreen());
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                flex: 3,
                                child: BlocBuilder<ServiceBloc, ServiceState>(
                                  builder: (context, state) {
                                    if (state is ServiceLoading) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (services.isEmpty) {
                                      return const Center(child: Text('Không có dịch vụ nào để hiển thị'));
                                    }
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: kIsWeb && screenWidth > maxContentWidth ? 3 : 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 1.2,
                                      ),
                                      itemCount: services.length,
                                      itemBuilder: (context, index) {
                                        final service = services[index];
                                        return GestureDetector(
                                          onTap: () {
                                            if (!_isServicesLoaded) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Đang tải danh sách dịch vụ, vui lòng chờ...")),
                                              );
                                              return;
                                            }
                                            _showMeterReadingSheet(context, service['title'], service['service_id']);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  service['title'],
                                                  style: TextStyle(
                                                    fontSize: kIsWeb ? 14 : 16,
                                                    color: Colors.black87,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  height: 2,
                                                  width: 20,
                                                  color: service['color'],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hoá đơn thanh toán',
                                    style: TextStyle(
                                      fontSize: kIsWeb ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color: _isFetchingBills ? Colors.grey : Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: _isFetchingBills ? null : _refreshData,
                                    tooltip: 'Làm mới',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (kIsWeb && _paymentUrl != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print('Opening payment URL on web: $_paymentUrl');
                                          _launchURL(_paymentUrl!, _currentTransactionId!);
                                        },
                                        child: Text(
                                          "Nhấn để thanh toán qua VNPay",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_currentTransactionId != null) {
                                            print('Checking transaction status: $_currentTransactionId');
                                            context.read<PaymentTransactionBloc>().add(GetPaymentTransactionByIdEvent(
                                              transactionId: _currentTransactionId!,
                                            ));
                                          }
                                        },
                                        child: const Text("Kiểm tra trạng thái thanh toán"),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: BlocBuilder<PaymentTransactionBloc, PaymentTransactionState>(
                                  builder: (context, paymentState) {
                                    if (billState is BillLoading || paymentState is PaymentTransactionLoading) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (billState is BillLoaded) {
                                      lastBills = billState.bills.where((bill) {
                                        return bill.billId != null &&
                                            bill.totalAmount > 0 &&
                                            bill.paymentStatus != 'PAID';
                                      }).toList();
                                    } else if (billState is BillEmpty || billState is BillError) {
                                      lastBills = [];
                                    }
                                    if (lastBills.isEmpty) {
                                      return const Center(child: Text('Không có hóa đơn cần thanh toán'));
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: lastBills.length,
                                      itemBuilder: (context, index) {
                                        final bill = lastBills[index];
                                        final serviceName = bill.serviceName ?? 'Không xác định';
                                        return Card(
                                          key: ValueKey(bill.billId), // Unique key for stable identity
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
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    print('Bill ID: ${bill.billId} (Type: ${bill.billId.runtimeType})');
                                                    if (bill.billId == null) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Hóa đơn không hợp lệ. Vui lòng thử lại sau.')),
                                                      );
                                                      return;
                                                    }
                                                    setState(() {
                                                      _lastFailedBillId = bill.billId;
                                                    });
                                                    context.read<PaymentTransactionBloc>().add(
                                                          CreatePaymentTransactionEvent(
                                                            billId: bill.billId!,
                                                            paymentMethod: 'VNPAY',
                                                            returnUrl: getAPIbaseUrl() + "/payment-transactions/callback",
                                                          ),
                                                        );
                                                  },
                                                  child: Text(
                                                    "Thanh toán",
                                                    style: TextStyle(fontSize: kIsWeb ? 12 : 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}