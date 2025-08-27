// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityDetail _$ActivityDetailFromJson(Map<String, dynamic> json) =>
    ActivityDetail(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String,
      contenu: json['contenu'] as String?,
      startDateTime: DateTime.parse(json['date_heure_debut'] as String),
      endDateTime: DateTime.parse(json['date_heure_fin'] as String),
      cancellationReason: json['motif_annulation'] as String?,
      maxParticipants: (json['max_participant'] as num).toInt(),
      waitingListCount: (json['nbr_attente'] as num).toInt(),
      registrationDeadline:
          DateTime.parse(json['date_heure_limite_inscription'] as String),
      categorieId: (json['categorieId'] as num).toInt(),
      categorie:
          ActivityCategory.fromJson(json['categorie'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => ActivityParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActivityDetailToJson(ActivityDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'contenu': instance.contenu,
      'date_heure_debut': instance.startDateTime.toIso8601String(),
      'date_heure_fin': instance.endDateTime.toIso8601String(),
      'motif_annulation': instance.cancellationReason,
      'max_participant': instance.maxParticipants,
      'nbr_attente': instance.waitingListCount,
      'date_heure_limite_inscription':
          instance.registrationDeadline.toIso8601String(),
      'categorieId': instance.categorieId,
      'categorie': instance.categorie,
      'participants': instance.participants,
    };
