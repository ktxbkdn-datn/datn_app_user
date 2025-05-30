import 'package:equatable/equatable.dart';

class MonthlyBill extends Equatable {
  final int? billId;
  final int userId;
  final int detailId;
  final int roomId;
  final String billMonth;
  final double totalAmount;
  final String paymentStatus;
  final String? createdAt;
  final String? paymentMethodAllowed;
  final String? paidAt;
  final String? transactionReference;
  final Map<String, dynamic>? userDetails;
  final Map<String, dynamic>? roomDetails;
  final int billDetailId;
  final String? serviceName; // Thêm service_name

  const MonthlyBill({
    this.billId,
    required this.userId,
    required this.detailId,
    required this.roomId,
    required this.billMonth,
    required this.totalAmount,
    required this.paymentStatus,
    this.createdAt,
    this.paymentMethodAllowed,
    this.paidAt,
    this.transactionReference,
    this.userDetails,
    this.roomDetails,
    required this.billDetailId,
    this.serviceName,
  });

  factory MonthlyBill.fromJson(Map<String, dynamic> json) {
    return MonthlyBill(
      billId: json['bill_id'] as int?,
      userId: json['user_id'] as int? ?? 0,
      detailId: json['detail_id'] as int? ?? 0,
      roomId: json['room_id'] as int? ?? 0,
      billMonth: json['bill_month'] as String? ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0.0') ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      createdAt: json['created_at'] as String?,
      paymentMethodAllowed: json['payment_method_allowed'] as String?,
      paidAt: json['paid_at'] as String?,
      transactionReference: json['transaction_reference'] as String?,
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
      'created_at': createdAt,
      'payment_method_allowed': paymentMethodAllowed,
      'paid_at': paidAt,
      'transaction_reference': transactionReference,
      'user_details': userDetails,
      'room_details': roomDetails,
      'bill_detail_id': billDetailId,
      'service_name': serviceName, // Thêm service_name
    };
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
    createdAt,
    paymentMethodAllowed,
    paidAt,
    transactionReference,
    userDetails,
    roomDetails,
    billDetailId,
    serviceName,
  ];
}

class BillDetail extends Equatable {
  final int? detailId;
  final int rateId;
  final double previousReading;
  final double currentReading;
  final double price;
  final int roomId;
  final String billMonth;
  final int? submittedBy;
  final String? submittedAt;

  const BillDetail({
    this.detailId,
    required this.rateId,
    required this.previousReading,
    required this.currentReading,
    required this.price,
    required this.roomId,
    required this.billMonth,
    this.submittedBy,
    this.submittedAt,
  });

  factory BillDetail.fromJson(Map<String, dynamic> json) {
    return BillDetail(
      detailId: json['detail_id'] as int?,
      rateId: json['rate_id'] as int? ?? 0,
      previousReading: double.tryParse(json['previous_reading']?.toString() ?? '0.0') ?? 0.0,
      currentReading: double.tryParse(json['current_reading']?.toString() ?? '0.0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      roomId: json['room_id'] as int? ?? 0,
      billMonth: json['bill_month'] as String? ?? '',
      submittedBy: json['submitted_by'] as int?,
      submittedAt: json['submitted_at'] as String?,
    );
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
    };
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