import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile extends Equatable {
  final int id;
  final String? nom;
  final String? prenom;
  final String? telephone;
  @JsonKey(name: 'communication_mail')
  final bool communicationMail;
  @JsonKey(name: 'communication_sms')
  final bool communicationSms;
  @JsonKey(name: 'avatarId')
  final int? avatarId;
  @JsonKey(name: 'membreId')
  final int membreId;

  const Profile({
    required this.id,
    this.nom,
    this.prenom,
    this.telephone,
    required this.communicationMail,
    required this.communicationSms,
    this.avatarId,
    required this.membreId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    bool? communicationMail,
    bool? communicationSms,
    int? avatarId,
    int? membreId,
  }) {
    return Profile(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      communicationMail: communicationMail ?? this.communicationMail,
      communicationSms: communicationSms ?? this.communicationSms,
      avatarId: avatarId ?? this.avatarId,
      membreId: membreId ?? this.membreId,
    );
  }

  String get displayName {
    final prenomStr = prenom ?? '';
    final nomStr = nom ?? '';
    final fullName = '$prenomStr $nomStr'.trim();
    return fullName.isNotEmpty ? fullName : '';
  }

  bool get isEmpty {
    return (nom?.isEmpty ?? true) && 
           (prenom?.isEmpty ?? true) && 
           (telephone?.isEmpty ?? true);
  }

  bool get isComplete {
    return nom?.isNotEmpty == true && 
           prenom?.isNotEmpty == true &&
           telephone?.isNotEmpty == true;
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        prenom,
        telephone,
        communicationMail,
        communicationSms,
        avatarId,
        membreId,
      ];
}