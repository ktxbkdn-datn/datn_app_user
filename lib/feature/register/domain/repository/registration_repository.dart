abstract class RegistrationRepository {
  Future<String> createRegistration({
    required String nameStudent,
    required String email,
    required String phoneNumber,
    required int roomId,
    String? information,
    required int numberOfPeople,
  });
}