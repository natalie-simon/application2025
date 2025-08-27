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
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
  'est_supprime': instance.estSupprime,
};

const _$UserRoleEnumMap = {
  UserRole.user: 'USER',
  UserRole.redacteur: 'REDAC',
  UserRole.admin: 'ADMIN',
};
