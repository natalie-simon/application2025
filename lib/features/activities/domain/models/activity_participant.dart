import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'activity_participant.g.dart';

@JsonSerializable()
class MemberProfile extends Equatable {
  final int id;
  final String nom;
  final String prenom;
  final String? telephone;
  @JsonKey(name: 'communication_mail')
  final bool communicationMail;
  @JsonKey(name: 'communication_sms')
  final bool communicationSms;
  final int? avatarId;
  final int membreId;

  const MemberProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    required this.communicationMail,
    required this.communicationSms,
    this.avatarId,
    required this.membreId,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) =>
      _$MemberProfileFromJson(json);

  Map<String, dynamic> toJson() => _$MemberProfileToJson(this);

  String get displayName => '$prenom $nom';

  @override
  List<Object?> get props => [
        id,
        nom,
        prenom,
        telephone,
        communicationMail,
        communicationSms,
        avatarId,
        membreId,
      ];
}

@JsonSerializable()
class Member extends Equatable {
  final int id;
  final String email;
  @JsonKey(name: 'est_supprime')
  final bool isDeleted;
  final String role;
  final MemberProfile profil;

  const Member({
    required this.id,
    required this.email,
    required this.isDeleted,
    required this.role,
    required this.profil,
  });

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);

  @override
  List<Object?> get props => [id, email, isDeleted, role, profil];
}

@JsonSerializable()
class ActivityParticipant extends Equatable {
  final int id;
  final String? observations;
  @JsonKey(name: 'dateInscription')
  final DateTime registrationDate;
  final int membreId;
  final int activiteId;
  final Member membre;

  const ActivityParticipant({
    required this.id,
    this.observations,
    required this.registrationDate,
    required this.membreId,
    required this.activiteId,
    required this.membre,
  });

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) =>
      _$ActivityParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityParticipantToJson(this);

  @override
  List<Object?> get props => [
        id,
        observations,
        registrationDate,
        membreId,
        activiteId,
        membre,
      ];
}