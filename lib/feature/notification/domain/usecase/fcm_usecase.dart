import '../repository/fcm_repository.dart';

class GetFcmToken {
  final FcmRepository repository;

  GetFcmToken(this.repository);

  Future<String?> call() async {
    print('GetFcmToken: Executing');
    return await repository.getFcmToken();
  }
}

class SendFcmToken {
  final FcmRepository repository;

  SendFcmToken(this.repository);

  Future<void> call(String token, String jwtToken) async {
    print('SendFcmToken: Executing with token=$token');
    await repository.sendFcmToken(token, jwtToken);
  }
}