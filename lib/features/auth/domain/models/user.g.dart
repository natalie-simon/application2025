// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  estSupprime: json['est_supprime'] as bool? ?? false,
  prenom: json['prenom'] as String?,
  nom: json['nom'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'est_supprime': instance.estSupprime,
  'prenom': instance.prenom,
  'nom': instance.nom,
};

const _$UserRoleEnumMap = {
  UserRole.user: 'USER',
  UserRole.redacteur: 'REDAC',
  UserRole.admin: 'ADMIN',
};
