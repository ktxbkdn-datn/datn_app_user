import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/register_usecase.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final CreateRegistration createRegistration;

  RegistrationBloc(this.createRegistration) : super(const RegistrationInitial()) {
    on<CreateRegistrationEvent>(_onCreateRegistration);
  }

  Future<void> _onCreateRegistration(
      CreateRegistrationEvent event,
      Emitter<RegistrationState> emit,
      ) async {
    emit(const RegistrationLoading());

    try {
      final message = await createRegistration(
        nameStudent: event.nameStudent,
        email: event.email,
        phoneNumber: event.phoneNumber,
        roomId: event.roomId,
        information: event.information,
        numberOfPeople: event.numberOfPeople,
      );
      emit(RegistrationSuccess(message));
    } catch (e) {
      emit(RegistrationFailure(e.toString()));
    }
  }
}