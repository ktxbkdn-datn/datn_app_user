
import '../repository/registration_repository.dart';

class CreateRegistration {
  final RegistrationRepository repository;

  CreateRegistration(this.repository);

  Future<String> call({
    required String nameStudent,
    required String email,
    required String phoneNumber,
    required int roomId,
    String? information,
    required int numberOfPeople,
  }) async {
    return await repository.createRegistration(
      nameStudent: nameStudent,
      email: email,
      phoneNumber: phoneNumber,
      roomId: roomId,
      information: information,
      numberOfPeople: numberOfPeople,
    );
  }
}