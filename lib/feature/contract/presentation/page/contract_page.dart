import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:datn_app/common/components/app_background.dart';

import '../../../../common/constant/colors.dart';
import '../bloc/contract_bloc.dart';
import '../bloc/contract_event.dart';
import '../bloc/contract_state.dart';


class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  @override
  void initState() {
    super.initState();
    _fetchContracts();
  }

  void _fetchContracts() {
    if (mounted) {
      context.read<ContractBloc>().add(const FetchUserContractsEvent());
    }
  }

  // Hàm dịch contractType sang tiếng Việt
  String translateContractType(String contractType) {
    switch (contractType.toUpperCase()) {
      case 'LONG_TERM':
        return 'Hợp đồng dài hạn';
      case 'SHORT_TERM':
        return 'Hợp đồng ngắn hạn';
      default:
        return contractType;
    }
  }

  // Hàm dịch status sang tiếng Việt
  String translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Đang hoạt động';
      case 'PENDING':
        return 'Đang chờ duyệt';
      case 'EXPIRED':
        return 'Hết hạn';
      case 'TERMINATED':
        return 'Đã chấm dứt';
      default:
        return status;
    }
  }

  // Hàm định dạng thời gian
  String formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(parsedDate);
    } catch (e) {
      return dateTime; // Trả về giá trị gốc nếu parse thất bại
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBackground(
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Text(
                            "Hợp đồng của tôi",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: BlocBuilder<ContractBloc, ContractState>(
                        builder: (context, state) {
                          print('Current state: $state'); // Debugging
                          if (state is ContractLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is ContractError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.errorMessage,
                                    style: const TextStyle(
                                      color: AppColors.buttonError,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<ContractBloc>().add(
                                        const FetchUserContractsEvent(),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.buttonPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Thử lại',
                                      style: TextStyle(color: AppColors.cardBackground),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is ContractListLoaded) {
                            if (state.contracts.isEmpty) {
                              return const Center(child: Text('Không có hợp đồng nào'));
                            }
                            return ListView.builder(
                              itemCount: state.contracts.length,
                              itemBuilder: (context, index) {
                                final contract = state.contracts[index];
                                Color statusColor;
                                switch (contract.status.toUpperCase()) {
                                  case 'ACTIVE':
                                    statusColor = Colors.green.shade600;
                                    break;
                                  case 'PENDING':
                                    statusColor = Colors.yellow.shade700;
                                    break;
                                  case 'EXPIRED':
                                  case 'TERMINATED':
                                    statusColor = Colors.red.shade600;
                                    break;
                                  default:
                                    statusColor = Colors.grey.shade600;
                                }
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Colors.white.withOpacity(0.80),
                                    shadowColor: Colors.black.withOpacity(0.10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.description, color: Color(0xFF2563EB), size: 28),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Hợp đồng #${contract.contractId}',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          // Room Section
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFDBEAFE), Color(0xFFE0E7FF)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.04),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.meeting_room, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text('Phòng: ${contract.roomName}', style: const TextStyle(color: Color(0xFF334155), fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.location_on, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text('Khu vực: ${contract.areaName ?? 'N/A'}', style: const TextStyle(color: Color(0xFF334155), fontSize: 16)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          // Contract Details Section
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFF3E8FF), Color(0xFFFFE4E6)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.purple.withOpacity(0.04),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.description, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text('Loại hợp đồng: ${translateContractType(contract.contractType)}', style: const TextStyle(color: Color(0xFF334155), fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.info, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Trạng thái: ${translateStatus(contract.status)}',
                                                      style: TextStyle(
                                                        color: statusColor,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          // Date Section
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text('Ngày bắt đầu: ${formatDateTime(contract.startDate)}', style: const TextStyle(color: Color(0xFF334155), fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text('Ngày kết thúc: ${formatDateTime(contract.endDate)}', style: const TextStyle(color: Color(0xFF334155), fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.access_time, size: 20, color: Color(0xFF64748B)),
                                                    const SizedBox(width: 8),
                                                    Text('Ngày tạo: ${formatDateTime(contract.createdAt)}', style: const TextStyle(color: Color(0xFF334155), fontSize: 16)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Vui lòng tải hợp đồng'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ContractBloc>().add(
                                      const FetchUserContractsEvent(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Tải hợp đồng',
                                    style: TextStyle(color: AppColors.cardBackground),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}