import 'package:equatable/equatable.dart';

import '../../../room/domain/entities/room_entity.dart';



class RegistrationEntity extends Equatable {
  final int registrationId;
  final String nameStudent;
  final String email;
  final String phoneNumber;
  final String status;
  final String? information;
  final DateTime createdAt;
  final int numberOfPeople;
  final DateTime? meetingDatetime;
  final String meetingLocation;
  final RoomEntity? roomDetails;

  const RegistrationEntity({
    required this.registrationId,
    required this.nameStudent,
    required this.email,
    required this.phoneNumber,
    required this.status,
    this.information,
    required this.createdAt,
    required this.numberOfPeople,
    this.meetingDatetime,
    required this.meetingLocation,
    this.roomDetails,
  });

  @override
  List<Object?> get props => [
    registrationId,
    nameStudent,
    email,
    phoneNumber,
    status,
    information,
    createdAt,
    numberOfPeople,
    meetingDatetime,
    meetingLocation,
    roomDetails,
  ];
}