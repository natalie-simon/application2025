// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberProfile _$MemberProfileFromJson(Map<String, dynamic> json) =>
    MemberProfile(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      telephone: json['telephone'] as String?,
      communicationMail: json['communication_mail'] as bool,
      communicationSms: json['communication_sms'] as bool,
      avatarId: (json['avatarId'] as num?)?.toInt(),
      membreId: (json['membreId'] as num).toInt(),
    );

Map<String, dynamic> _$MemberProfileToJson(MemberProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'communication_mail': instance.communicationMail,
      'communication_sms': instance.communicationSms,
      'avatarId': instance.avatarId,
      'membreId': instance.membreId,
    };

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      isDeleted: json['est_supprime'] as bool,
      role: json['role'] as String,
      profil: json['profil'] == null
          ? null
          : MemberProfile.fromJson(json['profil'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'est_supprime': instance.isDeleted,
      'role': instance.role,
      'profil': instance.profil,
    };

ActivityParticipant _$ActivityParticipantFromJson(Map<String, dynamic> json) =>
    ActivityParticipant(
      id: (json['id'] as num).toInt(),
      observations: json['observations'] as String?,
      registrationDate: DateTime.parse(json['dateInscription'] as String),
      membreId: (json['membreId'] as num).toInt(),
      activiteId: (json['activiteId'] as num).toInt(),
      membre: Member.fromJson(json['membre'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ActivityParticipantToJson(
        ActivityParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'observations': instance.observations,
      'dateInscription': instance.registrationDate.toIso8601String(),
      'membreId': instance.membreId,
      'activiteId': instance.activiteId,
      'membre': instance.membre,
    };
