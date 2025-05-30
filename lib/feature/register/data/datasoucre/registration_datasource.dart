

import '../../../../src/core/network/api_client.dart';

abstract class RegistrationRemoteDataSource {
  Future<String> createRegistration({
    required String nameStudent,
    required String email,
    required String phoneNumber,
    required int roomId,
    String? information,
    required int numberOfPeople,
  });
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  final ApiService apiService;

  RegistrationRemoteDataSourceImpl(this.apiService);

  @override
  Future<String> createRegistration({
    required String nameStudent,
    required String email,
    required String phoneNumber,
    required int roomId,
    String? information,
    required int numberOfPeople,
  }) async {
    try {
      final response = await apiService.post('/registrations', {
        'name_student': nameStudent,
        'email': email,
        'phone_number': phoneNumber,
        'room_id': roomId,
        'information': information,
        'number_of_people': numberOfPeople,
      });

      return response['message'] as String;
    } catch (e) {
      throw Exception('Failed to create registration: $e');
    }
  }
}