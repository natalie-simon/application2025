import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'activity_category.dart';
import 'activity_participant.dart';

part 'activity_detail.g.dart';

@JsonSerializable()
class ActivityDetail extends Equatable {
  final int id;
  final String titre;
  final String? contenu;
  @JsonKey(name: 'date_heure_debut')
  final DateTime startDateTime;
  @JsonKey(name: 'date_heure_fin')
  final DateTime endDateTime;
  @JsonKey(name: 'motif_annulation')
  final String? cancellationReason;
  @JsonKey(name: 'max_participant')
  final int maxParticipants;
  @JsonKey(name: 'nbr_attente')
  final int waitingListCount;
  @JsonKey(name: 'date_heure_limite_inscription')
  final DateTime? registrationDeadline;
  final int categorieId;
  final ActivityCategory categorie;
  final List<ActivityParticipant> participants;

  const ActivityDetail({
    required this.id,
    required this.titre,
    this.contenu,
    required this.startDateTime,
    required this.endDateTime,
    this.cancellationReason,
    required this.maxParticipants,
    required this.waitingListCount,
    this.registrationDeadline,
    required this.categorieId,
    required this.categorie,
    required this.participants,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> json) =>
      _$ActivityDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityDetailToJson(this);

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

  int get registeredCount => participants.length;

  int get availableSpots => maxParticipants - registeredCount;

  bool get isFull => availableSpots <= 0;

  /// Date limite d'inscription effective (avec fallback sur startDateTime - 3h)
  DateTime get effectiveRegistrationDeadline {
    return registrationDeadline ?? startDateTime.subtract(const Duration(hours: 3));
  }

  bool get isRegistrationOpen => DateTime.now().isBefore(effectiveRegistrationDeadline);

  bool get isCancelled => cancellationReason != null;

  bool isUserRegistered(int userId) {
    return participants.any((p) => p.membre.id == userId);
  }

  ActivityParticipant? getUserParticipation(int userId) {
    try {
      return participants.firstWhere((p) => p.membre.id == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        titre,
        contenu,
        startDateTime,
        endDateTime,
        cancellationReason,
        maxParticipants,
        waitingListCount,
        registrationDeadline,
        categorieId,
        categorie,
        participants,
      ];

  @override
  String toString() => 'ActivityDetail(id: $id, titre: $titre)';
}