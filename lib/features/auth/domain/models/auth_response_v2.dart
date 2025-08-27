import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response_v2.g.dart';

/// Modèle pour la réponse d'authentification (format réel de l'API)
@JsonSerializable()
class AuthResponseV2 extends Equatable {
  @JsonKey(name: 'accessToken')
  final String token;

  const AuthResponseV2({
    required this.token,
  });

  /// Création depuis JSON
  factory AuthResponseV2.fromJson(Map<String, dynamic> json) => _$AuthResponseV2FromJson(json);

  /// Conversion vers JSON
  Map<String, dynamic> toJson() => _$AuthResponseV2ToJson(this);

  @override
  List<Object?> get props => [token];

  @override
  String toString() => 'AuthResponseV2(token: ${token.substring(0, 20)}...)';
}

/// Profil utilisateur dans le token JWT
@JsonSerializable()
class UserProfile extends Equatable {
  final int id;
  final String nom;
  final String prenom;
  final String? telephone;
  @JsonKey(name: 'communication_mail')
  final bool? communicationMail;
  @JsonKey(name: 'communication_sms')
  final bool? communicationSms;
  @JsonKey(name: 'avatarId')
  final int? avatarId;
  @JsonKey(name: 'membreId')
  final int membreId;
  final dynamic avatar; // peut être null

  const UserProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.communicationMail,
    this.communicationSms,
    this.avatarId,
    required this.membreId,
    this.avatar,
  });

  /// Création depuis JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  /// Conversion vers JSON
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  String get fullName => '$prenom $nom';

  @override
  List<Object?> get props => [id, nom, prenom, telephone, communicationMail, communicationSms, avatarId, membreId, avatar];

  @override
  String toString() => 'UserProfile(id: $id, nom: $nom, prenom: $prenom, membreId: $membreId)';
}