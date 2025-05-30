abstract class RegistrationEvent {
  const RegistrationEvent();
}

class CreateRegistrationEvent extends RegistrationEvent {
  final String nameStudent;
  final String email;
  final String phoneNumber;
  final int roomId;
  final String? information;
  final int numberOfPeople;

  const CreateRegistrationEvent({
    required this.nameStudent,
    required this.email,
    required this.phoneNumber,
    required this.roomId,
    this.information,
    required this.numberOfPeople,
  });
}