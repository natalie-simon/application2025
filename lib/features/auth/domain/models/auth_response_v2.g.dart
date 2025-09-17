// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseV2 _$AuthResponseV2FromJson(Map<String, dynamic> json) =>
    AuthResponseV2(token: json['accessToken'] as String);

Map<String, dynamic> _$AuthResponseV2ToJson(AuthResponseV2 instance) =>
    <String, dynamic>{'accessToken': instance.token};

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  prenom: json['prenom'] as String,
  telephone: json['telephone'] as String?,
  communicationMail: json['communication_mail'] as bool?,
  communicationSms: json['communication_sms'] as bool?,
  avatarId: (json['avatarId'] as num?)?.toInt(),
  membreId: (json['membreId'] as num).toInt(),
  avatar: json['avatar'],
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'communication_mail': instance.communicationMail,
      'communication_sms': instance.communicationSms,
      'avatarId': instance.avatarId,
      'membreId': instance.membreId,
      'avatar': instance.avatar,
    };
