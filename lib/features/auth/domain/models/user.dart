import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Énumération pour les rôles utilisateur
enum UserRole {
  @JsonValue('USER')
  user,
  @JsonValue('REDAC')
  redacteur,
  @JsonValue('ADMIN')
  admin
}

/// Modèle utilisateur selon l'API ASSBT
@JsonSerializable()
class User extends Equatable {
  final int id;
  final String email;
  final UserRole role;
  @JsonKey(name: 'est_supprime')
  final bool estSupprime;
  final String? prenom;
  final String? nom;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.estSupprime = false,
    this.prenom,
    this.nom,
  });

  /// Création depuis JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Conversion vers JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Copie avec modifications
  User copyWith({
    int? id,
    String? email,
    UserRole? role,
    bool? estSupprime,
    String? prenom,
    String? nom,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      estSupprime: estSupprime ?? this.estSupprime,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
    );
  }

  /// Vérification des permissions
  bool get isAdmin => role == UserRole.admin;
  bool get isRedacteur => role == UserRole.redacteur || isAdmin;
  bool get isActiveUser => !estSupprime;

  /// Nom d'affichage du rôle
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.redacteur:
        return 'Rédacteur';
      case UserRole.user:
        return 'Utilisateur';
    }
  }

  /// Nom complet pour affichage (prénom + nom si disponibles, sinon email)
  String get displayName {
    if (prenom != null && nom != null && prenom!.isNotEmpty && nom!.isNotEmpty) {
      return '$prenom $nom';
    }
    return email;
  }

  @override
  List<Object?> get props => [id, email, role, estSupprime, prenom, nom];

  @override
  String toString() => 'User(id: $id, email: $email, role: $role, estSupprime: $estSupprime)';
}