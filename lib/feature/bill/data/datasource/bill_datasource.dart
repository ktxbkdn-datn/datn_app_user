import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/bill_models.dart';

abstract class BillRemoteDataSource {
  Future<Either<Failure, String>> submitBillDetail({
    required String billMonth,
    required Map<String, Map<String, double>> readings,
  });

  Future<Either<Failure, List<BillDetailModel>>> getMyBillDetails();

  Future<Either<Failure, (List<MonthlyBillModel>, int)>> getMyBills({
    int page = 1,
    int limit = 10,
    String? billMonth,
    String? paymentStatus,
  });
  Future<Either<Failure, List<BillDetailModel>>> getRoomBillDetails({
    required int roomId,
    required int year,
    required int serviceId, // thêm serviceId
  });
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final ApiService apiService;

  BillRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, String>> submitBillDetail({
    required String billMonth,
    required Map<String, Map<String, double>> readings,
  }) async {
    try {
      final body = {
        'bill_month': billMonth,
        'readings': readings,
      };
      final response = await apiService.post('/bill-details', body);
      if (response == null) {
        throw ApiException('Phản hồi từ server là null');
      }
      // Kiểm tra kiểu dữ liệu của response
      if (response is Map<String, dynamic>) {
        if (response.containsKey('message')) {
          return Right(response['message'] as String);
        } else {
          throw ApiException('Phản hồi từ server không đúng định dạng: Map không chứa key "message"');
        }
      } else {
        throw ApiException('Phản hồi từ server không đúng định dạng: kỳ vọng Map với key "message", nhận được: ${response.runtimeType}');
      }
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<BillDetailModel>>> getMyBillDetails() async {
    try {
      final response = await apiService.get('/my-bill-details');
      if (response == null) {
        throw ApiException('Phản hồi từ server là null');
      }
      List<dynamic> responseList;
      dynamic responseData = response;
      if (responseData is List<dynamic>) {
        responseList = responseData;
      } else if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is List<dynamic>) {
          responseList = responseData['data'] as List<dynamic>;
        } else {
          throw ApiException('Phản hồi từ server không đúng định dạng: Map không chứa key "data" hoặc "data" không phải List');
        }
      } else {
        throw ApiException('Phản hồi từ server không đúng định dạng: kỳ vọng List hoặc Map với key "data" chứa List, nhận được: ${response.runtimeType}');
      }
      final billDetails = responseList
          .map<BillDetailModel>((json) {
        if (json is Map<String, dynamic>) {
          return BillDetailModel.fromJson(json);
        } else {
          throw ApiException('Phần tử trong danh sách không đúng định dạng: kỳ vọng Map<String, dynamic>, nhận được: ${json.runtimeType}');
        }
      })
          .toList();
      return Right(billDetails);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, (List<MonthlyBillModel>, int)>> getMyBills({
    int page = 1,
    int limit = 10,
    String? billMonth,
    String? paymentStatus,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (billMonth != null) 'bill_month': billMonth,
        if (paymentStatus != null) 'payment_status': paymentStatus,
      };
      final response = await apiService.get('/my-bills', queryParams: queryParams);
      if (response == null) {
        throw ApiException('Phản hồi từ server là null');
      }
      dynamic responseData = response;
      if (responseData is Map<String, dynamic> && responseData['bills'] is List<dynamic>) {
        final bills = (responseData['bills'] as List<dynamic>)
            .map((json) {
              if (json is Map<String, dynamic>) {
                return MonthlyBillModel.fromJson(json);
              } else {
                throw ApiException('Phần tử trong danh sách không đúng định dạng: kỳ vọng Map<String, dynamic>, nhận được: ${json.runtimeType}');
              }
            })
            .toList();
        final totalItems = responseData['total_items'] as int? ?? 0;
        return Right((bills, totalItems));
      } else {
        throw ApiException('Phản hồi từ server không đúng định dạng: kỳ vọng Map với key "bills" và "total_items", nhận được: ${responseData.runtimeType}');
      }
    } catch (e) {
      return Left(_handleError(e));
    }
  }  @override  Future<Either<Failure, List<BillDetailModel>>> getRoomBillDetails({
    required int roomId,
    required int year,
    required int serviceId, // thêm serviceId
  }) async {
    try {
      print('\n=== BILL DATASOURCE: GET ROOM BILL DETAILS ===');
      print('Making API call to: /bill-details/room/$roomId');
      print('with parameters:');
      print('year: $year');
      print('service_id: $serviceId');
      
      final queryParams = <String, String>{
        'year': year.toString(),
        'service_id': serviceId.toString(), // truyền service_id
      };
      
      final response = await apiService.get('/bill-details/room/$roomId', queryParams: queryParams);
      print('API response received: ${response != null ? 'success' : 'null'}');
      
      if (response == null) {
        throw ApiException('Phản hồi từ server là null');
      }
      List<dynamic> responseList;
      if (response is List<dynamic>) {
        responseList = response;
      } else if (response is Map<String, dynamic> && response['data'] is List<dynamic>) {
        responseList = response['data'] as List<dynamic>;
      } else {
        throw ApiException('Phản hồi từ server không đúng định dạng: kỳ vọng List hoặc Map với key "data" chứa List, nhận được: ${response.runtimeType}');
      }
      final validItems = responseList.where((item) => item != null).toList();
      final billDetails = validItems
          .map<BillDetailModel>((json) {
        if (json is Map<String, dynamic>) {
          return BillDetailModel.fromJson(json);
        } else {
          throw ApiException('Phản hồi từ server không đúng định dạng: kỳ vọng Map<String, dynamic>, nhận được: ${json.runtimeType}');
        }
      }).toList();
      return Right(billDetails);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ApiException) {
      if (error.message.contains('Không tìm thấy hóa đơn nào')) {
        return ServerFailure('Không tìm thấy hóa đơn nào');
      }
      if (error.message.contains('Không tìm thấy phòng')) {
        return ServerFailure('Không tìm thấy phòng. Vui lòng nhập chỉ số điện/nước trước để hệ thống ghi nhận phòng của bạn.');
      }
      if (error.message.contains('Bạn không có hợp đồng hoạt động nào')) {
        return ServerFailure('Bạn không có hợp đồng hoạt động nào');
      }
      if (error.message.contains('Phản hồi từ server không đúng định dạng')) {
        return ServerFailure('Lỗi hệ thống: Dữ liệu trả về không đúng định dạng');
      }
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else if (error.toString().contains('TypeError')) {
      return ServerFailure('Lỗi hệ thống: Dữ liệu trả về không đúng định dạng');
    } else {
      return ServerFailure('Lỗi không xác định: $error');
    }
  }
}