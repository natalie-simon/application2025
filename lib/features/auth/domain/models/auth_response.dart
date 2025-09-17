import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

/// Modèle pour la réponse d'authentification
@JsonSerializable()
class AuthResponse extends Equatable {
  final bool success;
  final String message;
  final AuthData data;

  const AuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  /// Création depuis JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  /// Conversion vers JSON
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];

  @override
  String toString() => 'AuthResponse(success: $success, message: $message, data: $data)';
}

/// Données d'authentification (token + user)
@JsonSerializable()
class AuthData extends Equatable {
  final String token;
  final User user;

  const AuthData({
    required this.token,
    required this.user,
  });

  /// Création depuis JSON
  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);

  /// Conversion vers JSON
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);

  @override
  List<Object?> get props => [token, user];

  @override
  String toString() => 'AuthData(token: ${token.substring(0, 20)}..., user: $user)';
}