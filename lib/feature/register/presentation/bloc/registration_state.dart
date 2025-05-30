abstract class RegistrationState {
  const RegistrationState();
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

class RegistrationSuccess extends RegistrationState {
  final String message;

  const RegistrationSuccess(this.message);
}

class RegistrationFailure extends RegistrationState {
  final String error;

  const RegistrationFailure(this.error);
}