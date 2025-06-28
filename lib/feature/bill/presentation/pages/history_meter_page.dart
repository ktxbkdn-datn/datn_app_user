import 'package:datn_app/common/components/app_background.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';
import 'package:datn_app/feature/bill/presentation/bloc/bill_bloc/bill_bloc.dart';
import 'package:datn_app/feature/bill/presentation/bloc/bill_bloc/bill_event.dart';
import 'package:datn_app/feature/bill/presentation/bloc/bill_bloc/bill_state.dart';
import 'package:datn_app/feature/bill/presentation/pages/payment_page.dart'; // Import to access routeObserver
import 'package:datn_app/feature/service/domain/entity/service_entities.dart';
import 'package:datn_app/feature/service/presentation/bloc/service_bloc.dart';
import 'package:datn_app/feature/service/presentation/bloc/service_event.dart';
import 'package:datn_app/feature/service/presentation/bloc/service_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryMeterPage extends StatefulWidget {
  final int roomId;

  const HistoryMeterPage({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  State<HistoryMeterPage> createState() => _HistoryMeterPageState();
}

class _HistoryMeterPageState extends State<HistoryMeterPage> with RouteAware {
  int _selectedYear = DateTime.now().year;
  int _selectedServiceId = 1; // Default, will be updated when services are loaded
  bool _isLoading = false;
  List<Service> _services = [];


  final List<int> _availableYears = [
    DateTime.now().year - 2,
    DateTime.now().year - 1,
    DateTime.now().year,
  ];  @override
  void initState() {
    super.initState();
    // Log thông tin phòng để debug
    print('\n=== HISTORY METER PAGE INITIALIZED ===');
    print('ROOM ID: ${widget.roomId}');
    print('ROOM ID TYPE: ${widget.roomId.runtimeType}');
    print('HistoryMeterPage initialized with roomId: ${widget.roomId}');
    print('Current BillBloc state: ${context.read<BillBloc>().state}');
    
    // Kiểm tra tính hợp lệ của roomId
    if (widget.roomId <= 0) {
      print('Warning: Invalid roomId: ${widget.roomId}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID phòng không hợp lệ. Vui lòng quay lại và thử lại.')),
        );
      });
    }
    
    // Chỉ load services trước, không gọi API lấy lịch sử ngay
    _loadServices();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register with the RouteObserver
    final ModalRoute<dynamic>? modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute as PageRoute<dynamic>);
    }
  }
    @override
  void dispose() {
    // Safely unsubscribe from the route observer - protect against "used after disposed" errors
    try {
      routeObserver.unsubscribe(this);
    } catch (e) {
      print('Warning: Error unsubscribing from routeObserver: $e');
    }
    super.dispose();
  }
  
  // Called when returning to this screen
  @override
  void didPopNext() {
    print('HistoryMeterPage is now visible after pop');
    _loadServices();
    _loadBillDetails();
  }

  void _loadServices() {
    context.read<ServiceBloc>().add(const FetchServicesEvent());
  }  void _loadBillDetails() {
    setState(() {
      _isLoading = true;
    });

    print('\n=== LOADING BILL DETAILS ===');
    print('API CALL PARAMETERS:');
    print('roomId: ${widget.roomId}');
    print('year: $_selectedYear');
    print('serviceId: $_selectedServiceId');
    
    // Kiểm tra nếu roomId không hợp lệ
    if (widget.roomId <= 0) {
      print('Warning: Invalid roomId: ${widget.roomId}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID phòng không hợp lệ. Vui lòng quay lại và thử lại.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    context.read<BillBloc>().add(GetRoomBillDetailsEvent(
          roomId: widget.roomId,
          year: _selectedYear,
          serviceId: _selectedServiceId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,          title: Text('Lịch sử chỉ số'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),        body: BlocListener<ServiceBloc, ServiceState>(
          listener: (context, state) {
            if (state is ServiceLoaded) {
              setState(() {
                _services = state.services;
                // Chỉ khi đã load xong services và có ít nhất 1 service thì mới set serviceId và gọi API
                if (_services.isNotEmpty) {
                  _selectedServiceId = _services.first.serviceId;
                  // Sau khi có service_id, gọi API lấy lịch sử
                  _loadBillDetails();
                } else {
                  // Hiển thị thông báo nếu không có dịch vụ nào
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy dịch vụ nào')),
                  );
                }
              });
            } else if (state is ServiceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Không thể tải dịch vụ: ${state.message}')),
              );
            }
          },
          child: Column(
            children: [
              // Year and Service filters
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year filter
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Năm',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(context, 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedYear,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                                items: _availableYears.map((int year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(
                                      year.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedYear = newValue;
                                    });
                                    _loadBillDetails();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Service filter
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dịch vụ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),                            const SizedBox(height: 12),                            BlocBuilder<ServiceBloc, ServiceState>(
                              builder: (context, state) {
                                if (state is ServiceLoading) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                }
                                
                                if (state is ServiceError) {
                                  return Center(
                                    child: Text(
                                      'Lỗi: ${state.message}',
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  );
                                }
                                
                                if (_services.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Không có dịch vụ để hiển thị'),
                                    ),
                                  );
                                }
                                
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButton<int>(
                                    value: _selectedServiceId,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                                    items: _services.map((service) {
                                      return DropdownMenuItem<int>(
                                        value: service.serviceId,
                                        child: Text(
                                          service.name,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedServiceId = newValue;
                                        });
                                        _loadBillDetails();
                                      }
                                    },
                                  )
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                // Bill Details List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    print('Pull-to-refresh triggered, refreshing data...');
                    _loadBillDetails();
                  },
                  child: BlocConsumer<BillBloc, BillState>(
                    listener: (context, state) {
                      setState(() => _isLoading = false);                      if (state is BillError) {
                        String errorMessage = state.message;
                        IconData errorIcon = Icons.error_outline;
                        Color errorColor = Colors.red[300]!;
                        
                        // Hiển thị thông báo chi tiết hơn
                        if (state.message.contains('Không tìm thấy phòng')) {
                          errorMessage = 'Không tìm thấy phòng (ID: ${widget.roomId})\n\n'
                            'Nguyên nhân có thể:\n'
                            '1. Bạn chưa có hợp đồng phòng\n'
                            '2. Bạn chưa nhập chỉ số điện/nước\n'
                            '3. Lỗi kết nối đến máy chủ\n\n'
                            'Vui lòng quay lại và nhập chỉ số điện/nước trước để hệ thống ghi nhận phòng của bạn.';
                        } else if (state.message.contains('Không tìm thấy hóa đơn')) {
                          errorIcon = Icons.info_outline;
                          errorColor = Colors.orange[300]!;
                          errorMessage = 'Không tìm thấy dữ liệu hóa đơn cho phòng này.\n\n'
                            'Vui lòng thử nhập chỉ số điện/nước trước.';
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: errorColor.withOpacity(0.8),
                            duration: const Duration(seconds: 5),
                            action: SnackBarAction(
                              label: 'Đóng',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    },builder: (context, state) {
                    // Hiển thị loading indicator khi đang tải dữ liệu
                    if ((state is BillLoading || _isLoading) && _services.isNotEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang tải dữ liệu chỉ số...'),
                          ],
                        ),
                      );
                    }
                      // Trường hợp không có dữ liệu
                    if ((state is BillEmpty || (state is BillLoaded && state.billDetails.isEmpty)) && _services.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.data_usage, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Không có dữ liệu chỉ số cho năm $_selectedYear',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Thêm nút Thử lại
                            ElevatedButton.icon(
                              onPressed: _loadBillDetails,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Thử lại"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Trường hợp gặp lỗi
                    if (state is BillError) {
                      String errorMessage = state.message;
                      IconData errorIcon = Icons.error_outline;
                      Color errorColor = Colors.red[300]!;
                      
                      // Hiển thị thông báo chi tiết hơn
                      if (state.message.contains('Không tìm thấy phòng')) {
                        errorMessage = 'Không tìm thấy phòng (ID: ${widget.roomId})\n\n'
                          'Nguyên nhân có thể:\n'
                          '1. Bạn chưa có hợp đồng phòng\n'
                          '2. Bạn chưa nhập chỉ số điện/nước\n'
                          '3. Lỗi kết nối đến máy chủ\n\n'
                          'Vui lòng quay lại và nhập chỉ số điện/nước trước để hệ thống ghi nhận phòng của bạn.';
                      } else if (state.message.contains('Không tìm thấy hóa đơn')) {
                        errorIcon = Icons.info_outline;
                        errorColor = Colors.orange[300]!;
                        errorMessage = 'Không tìm thấy dữ liệu hóa đơn cho phòng này.\n\n'
                          'Vui lòng thử nhập chỉ số điện/nước trước.';
                      }
                      
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(errorIcon, size: 64, color: errorColor),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _loadBillDetails,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Thử lại"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text("Quay lại"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    // Trường hợp chưa tải được dịch vụ
                    if (_services.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Đang tải danh sách dịch vụ...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }                      if (state is BillLoaded) {
                        final details = state.billDetails;
                        
                        // Debug log
                        print('DEBUG: Bill Details Data Format:');
                        for (var detail in details) {
                          print('Month: ${detail.billMonth}, Current Reading: ${detail.currentReading}');
                        }
                        
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                          itemCount: details.length,
                          itemBuilder: (context, index) {
                            final detail = details[index];
                            
                            // Get month number from the API data
                            // Assume data format like: {"month": 1, "current_reading": 123.4}
                            // The index is 0-based, so we add 1 to get the month number (1-12)
                            final month = index + 1;
                            final hasReading = detail.currentReading > 0;
                            
                            return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Tháng $month',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  hasReading 
                                    ? _buildDetailRow('Chỉ số hiện tại', '${detail.currentReading}', Icons.speed, Colors.green, true)
                                    : _buildDetailRow('Chỉ số hiện tại', 'Chưa có dữ liệu', Icons.speed, Colors.grey)
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                      return const SizedBox();
                  },
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, Color color, [bool isHighlighted = false]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlighted ? 16 : 14,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                    color: isHighlighted ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
