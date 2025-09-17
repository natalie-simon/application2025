import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Modèle pour les données de connexion
@JsonSerializable()
class LoginRequest extends Equatable {
  final String email;
  @JsonKey(name: 'mot_de_passe')
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Création depuis JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  /// Conversion vers JSON
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  /// Validation des champs
  bool get isValid => email.isNotEmpty && email.contains('@') && password.isNotEmpty;

  /// Messages d'erreur de validation
  String? get emailError {
    if (email.isEmpty) return 'L\'email est requis';
    if (!email.contains('@')) return 'Format d\'email invalide';
    return null;
  }

  String? get passwordError {
    if (password.isEmpty) return 'Le mot de passe est requis';
    if (password.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
    return null;
  }

  /// Copie avec modifications
  LoginRequest copyWith({
    String? email,
    String? password,
  }) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [email, password];

  @override
  String toString() => 'LoginRequest(email: $email, password: [HIDDEN])';
}