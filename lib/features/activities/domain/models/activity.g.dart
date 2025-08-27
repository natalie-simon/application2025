// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String,
      startDateTime: DateTime.parse(json['date_heure_debut'] as String),
      endDateTime: DateTime.parse(json['date_heure_fin'] as String),
      registeredCount: (json['nombreInscrits'] as num).toInt(),
      categorie:
          ActivityCategory.fromJson(json['categorie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'date_heure_debut': instance.startDateTime.toIso8601String(),
      'date_heure_fin': instance.endDateTime.toIso8601String(),
      'nombreInscrits': instance.registeredCount,
      'categorie': instance.categorie,
    };
