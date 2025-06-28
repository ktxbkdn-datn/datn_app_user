import 'dart:ui';
import 'package:datn_app/common/components/app_background.dart';
import 'package:datn_app/common/constant/api_constant.dart';
import 'package:datn_app/common/constant/colors.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/common/widgets/no_spell_check_text.dart';

import 'package:datn_app/feature/contract/presentation/bloc/contract_bloc.dart';
import 'package:datn_app/feature/contract/presentation/bloc/contract_event.dart';
import 'package:datn_app/feature/contract/presentation/bloc/contract_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

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
import 'history_meter_page.dart';
import 'meter_reading_sheet.dart';

// Global route observer to detect navigation changes
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver, RouteAware {
  List<Map<String, dynamic>> services = [];
  List<MonthlyBill> lastBills = [];
  bool _isFetchingBills = false;
  Timer? _pollingTimer;
  String? _currentTransactionId;
  String? _paymentUrl;
  int? _lastFailedBillId;
  bool _isTabActive = true;
  bool _isServicesLoaded = false;
  int? _roomIdFromContract;
  bool _hasSubmitted = false;
  AppColors appColors = AppColors();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Note: We've moved all context-dependent code to didChangeDependencies
    
    // Clear any existing snackbars on init (moved to didChangeDependencies)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // This will be handled in didChangeDependencies
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Register this as a route observer for lifecycle events
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    }
    
    // Clear any existing snackbars
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    
    // Clear any existing BillState
    if (mounted) {
      context.read<BillBloc>().add(const ResetBillStateEvent());
    }
    
    // Fetch services 
    if (mounted) {
      context.read<ServiceBloc>().add(const FetchServicesEvent());
    }
    
    // Fetch bills
    if (mounted) {
      _fetchBills();
    }
  }

  @override
  void dispose() {
    // Clean up resources
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _pollingTimer?.cancel();
    super.dispose();
  }
  
  // Route lifecycle methods
  @override
  void didPushNext() {
    // Route was pushed onto navigator and new route is topmost route.
    _isTabActive = false;
  }
  
  @override
  void didPopNext() {
    // Returning to this screen
    print('PaymentScreen is now visible after pop');
    _isTabActive = true;
    
    if (!mounted) return;
    
    // Check if we just returned from submitting a meter reading
    if (_hasSubmitted) {
      print('Returned after submitting meter reading, refreshing bills...');
      // Force refresh bills to get updated roomId
      context.read<BillBloc>().add(const GetMyBillsEvent(page: 1, limit: 10));
      
      // Also refresh contract data
      context.read<ContractBloc>().add(const FetchUserContractsEvent());
      
      // Reset submission flag after refreshing
      setState(() {
        _hasSubmitted = false;
      });
    }
    
    _refreshData();
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
      
      // Refresh bills when app resumes
      _refreshData();
    }
  }
  
  void _fetchBills() {
    if (_isFetchingBills || !mounted) return;
    
    setState(() {
      _isFetchingBills = true;
    });
    
    context.read<BillBloc>().add(const GetMyBillsEvent(page: 1, limit: 10));
  }
  
  void _refreshData() {
    if (_isFetchingBills || !mounted) return;
    
    setState(() {
      _isFetchingBills = true;
    });
    context.read<BillBloc>().add(const GetMyBillsEvent(page: 1, limit: 10));
  }

  void _showMeterReadingSheet(BuildContext context, String serviceTitle, int serviceId) {
    if (!_isServicesLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang tải danh sách dịch vụ, vui lòng chờ...")),
      );
      return;
    }
    
    print('Opening meter reading sheet for service: $serviceTitle, service_id: $serviceId');

    // Navigate to MeterReadingSheet instead of using showModalBottomSheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeterReadingSheet(
          serviceTitle: serviceTitle,
          serviceId: serviceId,
          onSubmit: (double currentReading, int selectedYear, String selectedMonth) {
            // This callback will be executed when user submits the reading
            String billMonth = '$selectedYear-$selectedMonth';
            print('Selected bill month: $billMonth');

            Map<String, Map<String, double>> readings = {
              serviceId.toString(): {
                'current': currentReading,
              },
            };
            print('Submitting reading for service_id: $serviceId, value: $currentReading, readings: $readings');

            if (mounted) {
              setState(() {
                _hasSubmitted = true;
              });
              
              context.read<BillBloc>().add(SubmitBillDetailEvent(
                billMonth: billMonth,
                readings: readings,
              ));
            }
          },
        ),
      ),
    );
  }

  Future<void> _launchURL(String url, String transactionId) async {
    final Uri uri = Uri.parse(url);
    
    // Always store payment URL and transaction ID for web fallback regardless of success/failure
    if (kIsWeb) {
      setState(() {
        _paymentUrl = url;
        _currentTransactionId = transactionId;
      });
    }
    
    try {
      print('Attempting to open URL: $url');
      
      if (kIsWeb) {
        print('Opening URL on web: $url');
        // On web, forcefully use the universal approach to improve compatibility
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
        
        print('URL launch result on web: $launched');
        
        if (!launched) {
          // Fallback for web if normal launch fails
          print('Normal launch failed, trying alternative methods');
          
          // Using window.open directly
          if (kIsWeb) {
            // This is a simpler approach that doesn't require the js library
            // It will only be executed on web platforms
            // ignore: undefined_prefixed_name
            try {
              // Try to directly open using window.open, which is universally supported
              await launchUrl(
                uri,
                webOnlyWindowName: '_self', // Try opening in the same window as fallback
              );
            } catch (e) {
              print('All launch attempts failed: $e');
              
              // Add additional user guidance for web - show a more obvious prompt
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Không thể tự động mở cổng thanh toán. Vui lòng nhấn vào nút "Mở lại cổng thanh toán" bên dưới.'),
                      duration: const Duration(seconds: 8),
                      action: SnackBarAction(
                        label: 'Đã hiểu',
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              });
            }
          }
        }
      } else {
        print('Opening URL on mobile: $url');
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        print('URL launch result on mobile: $launched');
        
        if (!launched) {
          // Try alternative launch mode if the first attempt fails
          print('External application launch failed, trying inAppWebView');
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
          print('InAppWebView launch result: $launched');
        }
      }
      
      // Start polling regardless of launch result
      _startPolling(transactionId);
    } catch (e) {
      print('Error launching URL: $e\nStack trace: ${StackTrace.current}');
      // Wrap in post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const NoSpellCheckText(text: 'Không thể mở URL thanh toán. Vui lòng thử lại.'),
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
      });
    }
  }
  void _startPolling(String transactionId) {
    if (!mounted) return;
    
    print('Starting polling for transaction ID: $transactionId');
    
    if (kIsWeb) {
      // Wrap in post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: NoSpellCheckText(text: 'Vui lòng hoàn tất thanh toán trên tab mới và quay lại ứng dụng.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      });
    }
    
    // Store transaction ID and cancel any existing polling
    _currentTransactionId = transactionId;
    _pollingTimer?.cancel();
    
    // Start new polling timer
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isTabActive || !mounted) return;
      
      print('Polling transaction ID: $transactionId (Attempt ${timer.tick})');
      
      if (mounted) {
        context.read<PaymentTransactionBloc>().add(GetPaymentTransactionByIdEvent(
          transactionId: transactionId,
        ));
      }
    });
  }
  void _stopPolling() {
    print('Stopping polling');
    _pollingTimer?.cancel();
    _currentTransactionId = null;
    setState(() {
      _paymentUrl = null;
    });
  }  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 600.0;
    final horizontalPadding = ResponsiveUtils.wp(context, 4);
    
    return AppBackground(
      child: MultiBlocListener(
        listeners: [
          BlocListener<ContractBloc, ContractState>(
            listener: (context, state) {
              if (state is ContractListLoaded && state.contracts.isNotEmpty) {
                // Get roomId from active contract
                final activeContract = state.contracts.firstWhere(
                  (contract) => contract.status == 'ACTIVE',
                  orElse: () => state.contracts.first,
                );
                setState(() {
                  _roomIdFromContract = activeContract.roomId;
                });
                print('Found roomId from contract: $_roomIdFromContract');
              } else if (state is ContractError) {
                print('Error fetching contracts: ${state.errorMessage}');
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                print('Pull-to-refresh triggered, refreshing data...');
                _refreshData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
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
                                    switch (service.serviceId) {
                                      case 1:
                                        color = Colors.orange;
                                        break;
                                      case 2:
                                        color = Colors.blue;
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
                                // Wrap in post-frame callback to avoid setState during build
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
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
                                  }
                                });
                                setState(() {
                                  _isServicesLoaded = false;
                                });
                              }
                            },
                          ),
                          BlocListener<PaymentTransactionBloc, PaymentTransactionState>(
                            listener: (context, state) {
                              if (!mounted) return; // Add mounted check at the start
                              
                              if (state is PaymentTransactionLoaded && state.selectedTransaction != null) {
                                final transaction = state.selectedTransaction!;
                                print('Transaction ID: ${transaction.transactionId} (Type: ${transaction.transactionId.runtimeType})');
                                if (transaction.paymentUrl != null) {
                                  // Schedule the SnackBar and URL launch after the build phase
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đang chuyển hướng đến trang thanh toán...'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    print('Automatically launching URL: ${transaction.paymentUrl}');
                                      
                                      // Store payment URL for web fallback
                                      if (kIsWeb) {
                                        setState(() {
                                          _paymentUrl = transaction.paymentUrl;
                                          _currentTransactionId = transaction.transactionId;
                                        });
                                      }
                                      
                                      // Launch URL after storing the information
                                      _launchURL(transaction.paymentUrl!, transaction.transactionId);
                                    }
                                  });
                                } else if (_currentTransactionId == transaction.transactionId) {
                                  if (transaction.status == 'SUCCESS') {
                                    print('Payment successful');
                                    _stopPolling();
                                    if (mounted) { // Add mounted check
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Thanh toán thành công cho giao dịch #${transaction.transactionId}'),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                      _refreshData();
                                    }
                                  } else if (transaction.status == 'FAILED') {
                                    print('Payment failed');
                                    _stopPolling();
                                    if (mounted) { // Add mounted check
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Thanh toán thất bại cho giao dịch #${transaction.transactionId}'),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  }
                                }                            } else if (state is PaymentTransactionError) {
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
                                  if (mounted) { // Add mounted check
                                    context.read<PaymentTransactionBloc>().add(ResetPaymentTransactionStateEvent());
                                  }
                                  return;
                                }
                                if (_isTabActive && mounted) { // Add mounted check
                                // Wrap in post-frame callback to avoid setState during build
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(displayMessage),
                                        action: _lastFailedBillId != null
                                            ? SnackBarAction(
                                                label: 'Thử lại',
                                                onPressed: () {
                                                  if (_lastFailedBillId != null && mounted) { // Add mounted check
                                                    print("Retrying payment for bill ID: $_lastFailedBillId (Type: ${_lastFailedBillId.runtimeType})");
                                                    
                                                    context.read<PaymentTransactionBloc>().add(
                                                          CreatePaymentTransactionEvent(
                                                            billId: _lastFailedBillId!,
                                                            paymentMethod: 'VNPAY',
                                                            returnUrl: getAPIbaseUrl()+"/payment-transactions/callback",
                                                          ),
                                                        );
                                                  }
                                                },
                                              )
                                            : SnackBarAction(
                                                label: '',
                                                onPressed: () {},
                                              ),
                                      ),
                                    );
                                  }
                                });
                                }
                                if (mounted) { // Add mounted check
                                  context.read<PaymentTransactionBloc>().add(ResetPaymentTransactionStateEvent());
                                }
                              }
                            },
                          ),
                        ],
                        child: BlocConsumer<BillBloc, BillState>(
                          listener: (context, state) {
                            print('BillBloc state: $state, _hasSubmitted: $_hasSubmitted');
                            if (!mounted) return; // Add mounted check
                            
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
                              if (mounted) { // Additional mounted check before showing SnackBar
                                // Wrap in post-frame callback to avoid setState during build
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(displayMessage),
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                });
                              }
                            } else if (state is BillLoaded && _hasSubmitted) {
                              print('Bill submission successful, showing success SnackBar');
                              if (mounted) { // Check mounted before showing SnackBar
                                // Wrap in post-frame callback to avoid setState during build
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã gửi chỉ số thành công'),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                });
                                _refreshData();
                              }
                            }                          if (state is BillLoaded || state is BillError || state is BillEmpty) {
                              print('Resetting _hasSubmitted and updating _isFetchingBills');
                              if (mounted) { // Add mounted check before setState
                                setState(() {
                                  _hasSubmitted = false;
                                  _isFetchingBills = false;
                                });
                              }
                            }
                          },
                          builder: (context, billState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header glassy card
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
                                        const NoSpellCheckText(
                                          text: 'Trang thanh toán',
                                          style: TextStyle(
                                            color: Colors.indigo,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Service grid glassy card
                                Card(
                                  elevation: 8,
                                  color: Colors.white.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  shadowColor: Colors.indigo.withOpacity(0.10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            NoSpellCheckText(
                                              text: 'Nhập báo cáo chỉ số',
                                              style: TextStyle(
                                                fontSize: ResponsiveUtils.sp(context, 18),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo,
                                              ),
                                            ),                                         
                                            TextButton.icon(
                                              icon: const Icon(Icons.history, color: Colors.indigo),
                                              label: const Text('Lịch sử chỉ số', style: TextStyle(color: Colors.indigo)),                                            onPressed: () {
                                                // Debug log: In ra thông tin hợp đồng và phòng
                                                print('\n=== DEBUG ROOM ID RESOLUTION ===');
                                                print('Getting roomId for history navigation');
                                                
                                                // Lấy roomId từ nhiều nguồn khác nhau
                                                int? roomId;
                                                
                                                // 0. Thử lấy từ contract trước (ưu tiên cao nhất)
                                                if (_roomIdFromContract != null) {
                                                  roomId = _roomIdFromContract;
                                                  print('Using roomId from contract: $roomId');
                                                }
                                                
                                                // 1. Thử lấy từ bills nếu không có từ contract
                                                final billState = context.read<BillBloc>().state;
                                                print('Current BillBloc state: $billState');
                                                
                                                if (billState is BillLoaded && billState.bills.isNotEmpty) {
                                                  roomId = billState.bills.first.roomId;
                                                  print('Found roomId from bills: $roomId');
                                                } else {
                                                  print('No roomId available from bills. BillState is: $billState');
                                                }
                                                  // 2. Nếu không có roomId từ bills, thử kiểm tra xem đã có lịch sử gửi chỉ số nào chưa
                                                if (roomId == null && _hasSubmitted) {
                                                  // Lưu ý: Điều này có nghĩa là người dùng đã gửi chỉ số trước đó
                                                  // nhưng roomId không được lưu, vì backend đã xử lý gửi chỉ số thành công
                                                  // nên roomId chắc chắn phải tồn tại trên server
                                                  print('User has submitted readings (_hasSubmitted=$_hasSubmitted), but roomId is not available from bills');
                                                  
                                                  // Hiển thị thông báo cho người dùng
                                                  // Wrap in post-frame callback to avoid setState during build
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Đang tải thông tin phòng...'),
                                                          duration: Duration(seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  });
                                                  
                                                  // Thử tải lại dữ liệu bills để có thông tin roomId
                                                  context.read<BillBloc>().add(const GetMyBillsEvent(page: 1, limit: 10));
                                                  return; // Thoát sớm, không mở trang lịch sử
                                                }
                                                  // 3. Không tìm thấy roomId - hiển thị thông báo lỗi
                                                if (roomId == null) {
                                                  print('Error: roomId is not available, cannot view history');
                                                  
                                                  // Hiển thị hộp thoại cho người dùng
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Thông tin phòng không có sẵn'),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [                                                                const NoSpellCheckText(
                                                                  text: 'Không thể tìm thấy thông tin phòng của bạn để xem lịch sử chỉ số.',
                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                          const SizedBox(height: 16),
                                                          const Text('Nguyên nhân có thể:'),
                                                          const SizedBox(height: 8),
                                                          const Text('• Bạn chưa có hợp đồng phòng'),
                                                          const Text('• Bạn chưa nhập chỉ số điện/nước'),
                                                          const Text('• Lỗi kết nối đến máy chủ'),
                                                          const SizedBox(height: 16),                                                                const NoSpellCheckText(
                                                                  text: 'Vui lòng thử nhập chỉ số điện/nước trước, hoặc liên hệ quản trị viên nếu vấn đề vẫn tiếp tục.',
                                                                  style: TextStyle(fontStyle: FontStyle.italic),
                                                                ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Đóng'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  return; // Thoát sớm, không mở trang lịch sử khi không có roomId
                                                }
                                                      // Tiếp tục chuyển đến trang lịch sử với roomId xác định
                                                print('\n=== NAVIGATING TO HISTORY METER PAGE ===');
                                                print('roomId source: ${_roomIdFromContract != null ? "CONTRACT" : "BILLS"}');
                                                print('roomId value: $roomId');
                                                print('Navigating to HistoryMeterPage with roomId: $roomId');
                                                
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => HistoryMeterPage(roomId: roomId!),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        BlocBuilder<ServiceBloc, ServiceState>(
                                          builder: (context, state) {
                                            if (state is ServiceLoading) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            if (services.isEmpty) {
                                              return Card(
                                                elevation: 0,
                                                color: Colors.white.withOpacity(0.8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                                                  child: Center(
                                                    child: NoSpellCheckText(text: 'Không có dịch vụ nào để hiển thị', style: TextStyle(color: Colors.grey)),
                                                  ),
                                                ),
                                              );
                                            }
                                            return GridView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: kIsWeb && screenWidth > maxContentWidth ? 3 : 2,
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 16,
                                                childAspectRatio: 1.2,
                                              ),
                                              itemCount: services.length,
                                              itemBuilder: (context, index) {
                                                final service = services[index];
                                                IconData iconData;
                                                Color iconColor;
                                                // Chọn icon và màu theo service_id hoặc tên dịch vụ
                                                if (service['service_id'] == 1 || service['title'].toString().toLowerCase().contains('điện')) {
                                                  iconData = Icons.flash_on;
                                                  iconColor = Colors.amber[700]!;
                                                } else if (service['service_id'] == 2 || service['title'].toString().toLowerCase().contains('nước')) {
                                                  iconData = Icons.water_drop;
                                                  iconColor = Colors.blue[600]!;
                                                } else {
                                                  iconData = Icons.miscellaneous_services;
                                                  iconColor = Colors.grey;
                                                }
                                                return InkWell(
                                                  borderRadius: BorderRadius.circular(16),
                                                  onTap: () {
                                                    if (!_isServicesLoaded) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text("Đang tải danh sách dịch vụ, vui lòng chờ...")),
                                                      );
                                                      return;
                                                    }
                                                    _showMeterReadingSheet(context, service['title'], service['service_id']);
                                                  },
                                                  child: Card(
                                                    elevation: 4,
                                                    color: Colors.white.withOpacity(0.85),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    shadowColor: (service['color'] as Color).withOpacity(0.10),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(iconData, color: iconColor, size: 38),
                                                          const SizedBox(height: 8),
                                                          NoSpellCheckText(
                                                            text: service['title'],
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.black87,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          const SizedBox(height: 6),
                                                          // Container(
                                                          //   height: 3,
                                                          //   width: 28,
                                                          //   decoration: BoxDecoration(
                                                          //     color: iconColor, // Nếu muốn cùng màu icon
                                                          //     borderRadius: BorderRadius.circular(2),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Unpaid bills glassy card
                                Card(
                                  elevation: 8,
                                  color: Colors.white.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  shadowColor: Colors.indigo.withOpacity(0.10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [                                              const NoSpellCheckText(
                                                text: 'Hoá đơn thanh toán',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                            Row(
                                              children: [
                                                IconButton(
                                              icon: const Icon(Icons.history, color: Colors.indigo, size: 22),
                                              tooltip: 'Lịch sử giao dịch',
                                              onPressed: () {
                                                Get.to(() => const HistoryScreen());
                                              },
                                            ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.refresh,
                                                    color: _isFetchingBills ? Colors.grey : Colors.indigo,
                                                    size: 24,
                                                  ),
                                                  onPressed: _isFetchingBills ? null : _refreshData,
                                                  tooltip: 'Làm mới',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        BlocBuilder<PaymentTransactionBloc, PaymentTransactionState>(
                                          builder: (context, paymentState) {
                                            if (billState is BillLoading || paymentState is PaymentTransactionLoading) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            if (billState is BillLoaded) {
                                              print("Processing bills from BillLoaded state");
                                              // Log all bills for debugging
                                              for (var bill in billState.bills) {
                                                print("Bill ID: ${bill.billId} (Type: ${bill.billId?.runtimeType}), "
                                                    "Amount: ${bill.totalAmount}, Status: ${bill.paymentStatus}");
                                              }
                                              
                                              lastBills = billState.bills.where((bill) {
                                                return bill.billId != null &&
                                                    bill.totalAmount > 0 &&
                                                    bill.paymentStatus != 'PAID';
                                              }).toList();
                                              
                                              // Log filtered bills
                                              print("Filtered bills for payment: ${lastBills.length}");
                                              for (var bill in lastBills) {
                                                print("Payment-eligible Bill ID: ${bill.billId}");
                                              }
                                            } else if (billState is BillEmpty || billState is BillError) {
                                              lastBills = [];
                                            }
                                            if (lastBills.isEmpty) {
                                              return Card(
                                                elevation: 0,
                                                color: Colors.white.withOpacity(0.8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                                                  child: Center(
                                                    child: NoSpellCheckText(text: 'Không có hóa đơn cần thanh toán', style: TextStyle(color: Colors.grey)),
                                                  ),
                                                ),
                                              );
                                            }
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: lastBills.length,
                                              itemBuilder: (context, index) {
                                                final bill = lastBills[index];
                                                final statusInfo = _getStatusInfo(bill.paymentStatus);
                                                return Card(
                                                  elevation: 6,
                                                  color: Colors.white.withOpacity(0.9),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  shadowColor: Colors.indigo.withOpacity(0.10),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(18.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [                                              NoSpellCheckText(
                                                text: "Hóa đơn ${bill.serviceName ?? 'Không xác định'} #${bill.billId}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                                              const SizedBox(height: 8),                                              NoSpellCheckText(
                                                text: '${bill.totalAmount.toStringAsFixed(0)} VNĐ',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                                              const SizedBox(height: 8),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: statusInfo['bgColor'],
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(statusInfo['icon'], color: statusInfo['iconColor'], size: 16),
                                                                        const SizedBox(width: 5),                                                        NoSpellCheckText(
                                                          text: statusInfo['label'],
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
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.blue,
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            if (bill.billId == null) {
                                                              // Use post-frame callback to show SnackBar safely
                                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                if (mounted) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(content: Text('Không thể xác định hóa đơn.')),
                                                                  );
                                                                }
                                                              });
                                                              return;
                                                            }
                                                            
                                                            // Hiển thị dialog xác nhận thanh toán
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text('Xác nhận thanh toán'),
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      'Bạn có chắc chắn muốn thanh toán hóa đơn này?',
                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                    ),
                                                                    SizedBox(height: 12),
                                                                    Text('Thông tin hóa đơn:'),
                                                                    SizedBox(height: 8),
                                                                    Text('• Dịch vụ: ${bill.serviceName ?? 'Không xác định'}'),
                                                                    Text('• Mã hóa đơn: #${bill.billId}'),
                                                                    Text('• Số tiền: ${bill.totalAmount.toStringAsFixed(0)} VNĐ'),
                                                                    SizedBox(height: 12),
                                                                    Text(
                                                                      'Bạn sẽ được chuyển đến cổng thanh toán VNPay.',
                                                                      style: TextStyle(fontStyle: FontStyle.italic),
                                                                    ),
                                                                  ],
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context),
                                                                    child: const Text('Hủy'),
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.blue,
                                                                      foregroundColor: Colors.white,
                                                                    ),
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                      
                                                                      if (bill.billId == null) {
                                                                        // Use post-frame callback to show SnackBar safely
                                                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                          if (mounted) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(content: Text('Hóa đơn không hợp lệ. Không tìm thấy ID hóa đơn.')),
                                                                            );
                                                                          }
                                                                        });
                                                                        return;
                                                                      }
                                                                      
                                                                      print("Preparing to pay bill with ID: ${bill.billId} (Type: ${bill.billId.runtimeType})");
                                                                      
                                                                      setState(() {
                                                                        _lastFailedBillId = bill.billId;
                                                                      });
                                                                      
                                                                      // In thông tin debug
                                                                      print("\n=== PAYMENT ATTEMPT ===");
                                                                      print("Preparing to pay bill with ID: ${bill.billId} (Type: ${bill.billId.runtimeType})");
                                                                      print("Return URL: http://kytucxa.dev.dut.navia.io.vn/payment-transactions/callback");
                                                                      
                                                                      // Thực hiện thanh toán
                                                                      context.read<PaymentTransactionBloc>().add(
                                                                            CreatePaymentTransactionEvent(
                                                                              billId: bill.billId!,
                                                                              paymentMethod: 'VNPAY',
                                                                              returnUrl: getAPIbaseUrl()+ "/payment-transactions/callback",
                                                                            ),
                                                                          );
                                                                    },
                                                                    child: const Text('Thanh toán ngay'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(Icons.credit_card, size: 18),
                                                              SizedBox(width: 6),
                                                              NoSpellCheckText(text: "Thanh toán", style: TextStyle(fontSize: 14)),
                                                            ],
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
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Web-specific payment links for ongoing transactions
                                if (kIsWeb && _paymentUrl != null && _currentTransactionId != null)
                                  Card(
                                    elevation: 8,
                                    color: Colors.white.withOpacity(0.8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    shadowColor: Colors.indigo.withOpacity(0.10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: NoSpellCheckText(
                                                  text: 'Giao dịch thanh toán đang diễn ra',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.indigo,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Nếu bạn chưa hoàn thành thanh toán, nhấn vào liên kết bên dưới để tiếp tục:',
                                            style: TextStyle(color: Colors.black87),
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.open_in_new),
                                                label: Text('Mở lại cổng thanh toán'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  _launchURL(_paymentUrl!, _currentTransactionId!);
                                                },
                                              ),
                                              OutlinedButton.icon(
                                                icon: Icon(Icons.refresh),
                                                label: Text('Kiểm tra trạng thái'),
                                                onPressed: () {
                                                  context.read<PaymentTransactionBloc>().add(
                                                    GetPaymentTransactionByIdEvent(
                                                      transactionId: _currentTransactionId!,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.center,
                                            child: TextButton(
                                              child: Text('Hủy giao dịch này'),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text('Xác nhận hủy'),
                                                    content: Text('Bạn có chắc chắn muốn hủy giao dịch thanh toán này?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text('Không'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          _stopPolling();
                                                          // Wrap in post-frame callback to avoid setState during build
                                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text('Đã hủy giao dịch thanh toán'),
                                                                ),
                                                              );
                                                            }
                                                          });
                                                        },
                                                        child: Text('Hủy giao dịch'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (kIsWeb && _paymentUrl != null && _currentTransactionId != null)
                                  const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void didPush() {
    print('PaymentScreen was pushed');
    if (!mounted) return;
    
    // Always call _refreshData when the page is pushed to the navigation stack
    _refreshData();
    
    // Also refresh contract data to get the latest roomId
    context.read<ContractBloc>().add(const FetchUserContractsEvent());
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch(status) {
      case 'PAID':
        return {
          'label': 'Đã thanh toán',
          'icon': Icons.check_circle,
          'iconColor': Colors.green,
          'textColor': Colors.green,
          'bgColor': Colors.green.withOpacity(0.1),
        };
      case 'PENDING':
        return {
          'label': 'Chờ thanh toán',
          'icon': Icons.pending,
          'iconColor': Colors.orange,
          'textColor': Colors.orange,
          'bgColor': Colors.orange.withOpacity(0.1),
        };
      case 'FAILED':
        return {
          'label': 'Thanh toán thất bại',
          'icon': Icons.error,
          'iconColor': Colors.red,
          'textColor': Colors.red,
          'bgColor': Colors.red.withOpacity(0.1),
        };
      case 'OVERDUE':
        return {
          'label': 'Quá hạn',
          'icon': Icons.warning,
          'iconColor': Colors.deepOrange,
          'textColor': Colors.deepOrange,
          'bgColor': Colors.deepOrange.withOpacity(0.1),
        };
      default:
        return {
          'label': 'Chưa thanh toán',
          'icon': Icons.payment,
          'iconColor': Colors.blue,
          'textColor': Colors.blue,
          'bgColor': Colors.blue.withOpacity(0.1),
        };
    }
  }
}