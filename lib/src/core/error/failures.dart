// lib/core/error/failures.dart
abstract class Failure {
  String get message;
}

class ServerFailure implements Failure {
  @override
  final String message;

  ServerFailure(this.message);

  @override
  String toString() => '$message';
}

class NetworkFailure implements Failure {
  @override
  final String message;

  NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}