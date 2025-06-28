import 'package:equatable/equatable.dart';
import '../../domain/entity/bill_entities.dart';

class MonthlyBillModel extends Equatable {
  final int? billId;
  final int userId;
  final int detailId;
  final int roomId;
  final String billMonth;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethodAllowed;
  final String? transactionReference;
  final String? createdAt;
  final String? paidAt;
  final Map<String, dynamic>? userDetails;
  final Map<String, dynamic>? roomDetails;
  final int billDetailId;
  final String? serviceName; // Thêm service_name

  const MonthlyBillModel({
    this.billId,
    required this.userId,
    required this.detailId,
    required this.roomId,
    required this.billMonth,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethodAllowed,
    this.transactionReference,
    this.createdAt,
    this.paidAt,
    this.userDetails,
    this.roomDetails,
    required this.billDetailId,
    this.serviceName,
  });

  factory MonthlyBillModel.fromJson(Map<String, dynamic> json) {
    return MonthlyBillModel(
      billId: json['bill_id'] as int?,
      userId: json['user_id'] as int? ?? 0,
      detailId: json['detail_id'] as int? ?? 0,
      roomId: json['room_id'] as int? ?? 0,
      billMonth: json['bill_month'] as String? ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0.0') ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      paymentMethodAllowed: json['payment_method_allowed'] as String?,
      transactionReference: json['transaction_reference'] as String?,
      createdAt: json['created_at'] as String?,
      paidAt: json['paid_at'] as String?,
      userDetails: json['user_details'] as Map<String, dynamic>?,
      roomDetails: json['room_details'] as Map<String, dynamic>?,
      billDetailId: json['bill_detail_id'] as int? ?? 0,
      serviceName: json['service_name'] as String?, // Thêm service_name
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'user_id': userId,
      'detail_id': detailId,
      'room_id': roomId,
      'bill_month': billMonth,
      'total_amount': totalAmount.toString(),
      'payment_status': paymentStatus,
      'payment_method_allowed': paymentMethodAllowed,
      'transaction_reference': transactionReference,
      'created_at': createdAt,
      'paid_at': paidAt,
      'user_details': userDetails,
      'room_details': roomDetails,
      'bill_detail_id': billDetailId,
      'service_name': serviceName, // Thêm service_name
    };
  }

  MonthlyBill toEntity() {
    return MonthlyBill(
      billId: billId,
      userId: userId,
      detailId: detailId,
      roomId: roomId,
      billMonth: billMonth,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus,
      paymentMethodAllowed: paymentMethodAllowed,
      transactionReference: transactionReference,
      createdAt: createdAt,
      paidAt: paidAt,
      userDetails: userDetails,
      roomDetails: roomDetails,
      billDetailId: billDetailId,
      serviceName: serviceName,
    );
  }

  @override
  List<Object?> get props => [
    billId,
    userId,
    detailId,
    roomId,
    billMonth,
    totalAmount,
    paymentStatus,
    paymentMethodAllowed,
    transactionReference,
    createdAt,
    paidAt,
    userDetails,
    roomDetails,
    billDetailId,
    serviceName,
  ];
}

class BillDetailModel extends Equatable {
  final int? detailId;
  final int rateId;
  final double previousReading;
  final double currentReading;
  final double price;
  final int roomId;
  final String billMonth;
  final int? submittedBy;
  final String? submittedAt;
  final Map<String, dynamic>? rateDetails; // Thêm rate_details từ API

  const BillDetailModel({
    this.detailId,
    required this.rateId,
    required this.previousReading,
    required this.currentReading,
    required this.price,
    required this.roomId,
    required this.billMonth,
    this.submittedBy,
    this.submittedAt,
    this.rateDetails, // Thêm rate_details
  });

  factory BillDetailModel.fromJson(Map<String, dynamic> json) {
    print('Parsing BillDetailModel: $json');
    try {
      final detailId = json['detail_id'] as int?;
      final rateId = json['rate_id'] as int? ?? 0;
      final previousReading = double.tryParse(json['previous_reading']?.toString() ?? '0.0') ?? 0.0;
      final currentReading = double.tryParse(json['current_reading']?.toString() ?? '0.0') ?? 0.0;
      final price = double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0;
      final roomId = json['room_id'] as int? ?? 0;
      final billMonth = json['bill_month'] as String? ?? '';
      final submittedBy = json['submitted_by'] as int?;
      final submittedAt = json['submitted_at'] as String?;
      final rateDetails = json['rate_details'] as Map<String, dynamic>?;

      return BillDetailModel(
        detailId: detailId,
        rateId: rateId,
        previousReading: previousReading,
        currentReading: currentReading,
        price: price,
        roomId: roomId,
        billMonth: billMonth,
        submittedBy: submittedBy,
        submittedAt: submittedAt,
        rateDetails: rateDetails,
      );
    } catch (e) {
      print('Error parsing BillDetailModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'detail_id': detailId,
      'rate_id': rateId,
      'previous_reading': previousReading.toString(),
      'current_reading': currentReading.toString(),
      'price': price.toString(),
      'room_id': roomId,
      'bill_month': billMonth,
      'submitted_by': submittedBy,
      'submitted_at': submittedAt,
      'rate_details': rateDetails,
    };
  }

  BillDetail toEntity() {
    return BillDetail(
      detailId: detailId,
      rateId: rateId,
      previousReading: previousReading,
      currentReading: currentReading,
      price: price,
      roomId: roomId,
      billMonth: billMonth,
      submittedBy: submittedBy,
      submittedAt: submittedAt,
      rateDetails: rateDetails,
    );
  }

  @override
  List<Object?> get props => [
    detailId,
    rateId,
    previousReading,
    currentReading,
    price,
    roomId,
    billMonth,
    submittedBy,
    submittedAt,
  ];
}