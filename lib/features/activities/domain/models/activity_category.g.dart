// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityCategory _$ActivityCategoryFromJson(Map<String, dynamic> json) =>
    ActivityCategory(
      id: (json['id'] as num).toInt(),
      label: json['lbl_categorie'] as String,
      withEquipment: json['avec_equipement'] as bool,
      couleur: json['couleur'] as String,
    );

Map<String, dynamic> _$ActivityCategoryToJson(ActivityCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lbl_categorie': instance.label,
      'avec_equipement': instance.withEquipment,
      'couleur': instance.couleur,
    };
