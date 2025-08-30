// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String?,
  prenom: json['prenom'] as String?,
  telephone: json['telephone'] as String?,
  communicationMail: json['communication_mail'] as bool,
  communicationSms: json['communication_sms'] as bool,
  avatarId: (json['avatarId'] as num?)?.toInt(),
  membreId: (json['membreId'] as num).toInt(),
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'telephone': instance.telephone,
  'communication_mail': instance.communicationMail,
  'communication_sms': instance.communicationSms,
  'avatarId': instance.avatarId,
  'membreId': instance.membreId,
};
