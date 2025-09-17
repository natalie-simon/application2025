import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'activity_category.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity extends Equatable {
  final int id;
  final String titre;
  @JsonKey(name: 'date_heure_debut')
  final DateTime startDateTime;
  @JsonKey(name: 'date_heure_fin')
  final DateTime endDateTime;
  @JsonKey(name: 'nombreInscrits')
  final int registeredCount;
  final ActivityCategory categorie;

  const Activity({
    required this.id,
    required this.titre,
    required this.startDateTime,
    required this.endDateTime,
    required this.registeredCount,
    required this.categorie,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  DateTime get startDate => DateTime(
        startDateTime.year,
        startDateTime.month,
        startDateTime.day,
      );

  Duration get duration => endDateTime.difference(startDateTime);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? '${minutes}min' : ''}';
    }
    return '${minutes}min';
  }

  @override
  List<Object?> get props => [
        id,
        titre,
        startDateTime,
        endDateTime,
        registeredCount,
        categorie,
      ];

  @override
  String toString() => 'Activity(id: $id, titre: $titre)';
}