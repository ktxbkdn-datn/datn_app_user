

import '../../domain/repository/registration_repository.dart';
import '../datasoucre/registration_datasource.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationRemoteDataSource remoteDataSource;

  RegistrationRepositoryImpl(this.remoteDataSource);

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
      return await remoteDataSource.createRegistration(
        nameStudent: nameStudent,
        email: email,
        phoneNumber: phoneNumber,
        roomId: roomId,
        information: information,
        numberOfPeople: numberOfPeople,
      );
    } catch (e) {
      throw Exception('Failed to create registration: $e');
    }
  }
}