import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    context.read<ContractBloc>().add(const FetchUserContractsEvent());
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

    return Scaffold(
      body: Stack(
        children: [
          // Glassmorphism Background
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Text(
                                          'Hợp đồng #${contract.contractId}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Room Section
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.glassmorphismStart.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.meeting_room, size: 20, color: AppColors.textSecondary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Phòng: ${contract.roomName}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 20, color: AppColors.textSecondary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Khu vực: ${contract.areaName ?? 'N/A'}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Contract Details Section
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.glassmorphismEnd.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.category, size: 20, color: AppColors.textSecondary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Loại hợp đồng: ${translateContractType(contract.contractType)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Icon(Icons.info, size: 20, color: AppColors.textSecondary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Trạng thái: ${translateStatus(contract.status)}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: contract.status == 'ACTIVE'
                                                          ? AppColors.buttonSuccess
                                                          : contract.status == 'EXPIRED' ||
                                                          contract.status == 'TERMINATED'
                                                          ? AppColors.buttonError
                                                          : AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Date Section
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Ngày bắt đầu: ${formatDateTime(contract.startDate)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Ngày kết thúc: ${formatDateTime(contract.endDate)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Ngày tạo: ${formatDateTime(contract.createdAt)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
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
    );
  }
}