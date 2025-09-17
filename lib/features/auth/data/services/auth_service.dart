import 'package:dio/dio.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/auth_response_v2.dart';
import '../../domain/models/login_request.dart';

class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.authBaseUrl,
      connectTimeout: EnvConfig.connectionTimeout,
      receiveTimeout: EnvConfig.apiTimeout,
      headers: EnvConfig.defaultHeaders,
    ));

    // Logging conditionnel basé sur la configuration d'environnement
    if (EnvConfig.enableApiLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (obj) => AppLogger.debug(obj.toString(), tag: 'AUTH_API'),
      ));
    }

    // Log de la configuration au démarrage (debug uniquement)
    if (EnvConfig.enableAppLogging) {
      AppLogger.info('AuthService configuré pour: ${EnvConfig.environmentName}', tag: 'AUTH_SERVICE');
      AppLogger.debug('Configuration: ${EnvConfig.debugInfo}', tag: 'AUTH_SERVICE');
    }
  }

  /// Connexion utilisateur
  Future<AuthResponseV2> signIn(LoginRequest loginRequest) async {
    try {
      AppLogger.auth('Tentative de connexion', email: loginRequest.email);

      // Validation côté client
      if (!loginRequest.isValid) {
        throw AuthServiceException(
          'Données de connexion invalides',
          400,
        );
      }

      final response = await _dio.post(
        '/sign-in',
        data: loginRequest.toJson(),
      );

      AppLogger.apiCall('POST', '/sign-in', statusCode: response.statusCode, tag: 'AUTH');

      final authResponse = AuthResponseV2.fromJson(response.data);

      AppLogger.auth('Connexion réussie - Token reçu: ${authResponse.token.substring(0, 20)}...');

      return authResponse;
    } on DioException catch (e) {
      AppLogger.error('Erreur DioException: ${e.type}', tag: 'AUTH', error: e.response?.data ?? e.message);

      String errorMessage = 'Erreur de connexion';
      int statusCode = e.response?.statusCode ?? 0;

      if (e.response != null) {
        // Gestion des erreurs spécifiques de l'API
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          // Gestion du cas où message est un array (validation errors)
          final messageField = responseData['message'];
          if (messageField is List) {
            errorMessage = messageField.cast<String>().join(', ');
          } else if (messageField is String) {
            errorMessage = messageField;
          } else {
            errorMessage = responseData['error']?.toString() ?? 'Erreur serveur';
          }
        }
        
        switch (statusCode) {
          case 401:
            errorMessage = 'Email ou mot de passe incorrect';
            break;
          case 403:
            errorMessage = 'Compte désactivé ou accès refusé';
            break;
          case 404:
            errorMessage = 'Service d\'authentification indisponible';
            break;
          case 429:
            errorMessage = 'Trop de tentatives, veuillez réessayer plus tard';
            break;
          case 500:
            errorMessage = 'Erreur serveur, veuillez réessayer';
            break;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Délai de connexion dépassé';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Impossible de se connecter au serveur';
      }

      throw AuthServiceException(errorMessage, statusCode);
    } catch (e) {
      AppLogger.error('Erreur générale auth', tag: 'AUTH', error: e);
      throw AuthServiceException('Erreur inattendue: $e', 0);
    }
  }

  /// Vérification du token (optionnel pour plus tard)
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/validate',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Récupération du profil utilisateur (pour GET /auth/me)
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      AppLogger.auth('Récupération du profil utilisateur');

      final response = await _dio.get(
        '/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      AppLogger.apiCall('GET', '/me', statusCode: response.statusCode, tag: 'AUTH');

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthServiceException('Token invalide ou expiré', 401);
      }
      throw AuthServiceException(
        'Erreur lors de la récupération du profil',
        e.response?.statusCode ?? 0,
      );
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      AppLogger.auth('Demande de réinitialisation de mot de passe pour: $email');

      final response = await _dio.post(
        '/forgot-password',
        data: {'email': email},
      );

      AppLogger.apiCall('POST', '/forgot-password', statusCode: response.statusCode, tag: 'AUTH');

      return response.data;
    } on DioException catch (e) {
      AppLogger.error('Erreur DioException forgot-password: ${e.type}', tag: 'AUTH', error: e.response?.data ?? e.message);

      String errorMessage = 'Erreur lors de la demande de réinitialisation';
      int statusCode = e.response?.statusCode ?? 0;

      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          final messageField = responseData['message'];
          if (messageField is String) {
            errorMessage = messageField;
          }
        }
        
        switch (statusCode) {
          case 404:
            errorMessage = 'Aucun compte associé à cette adresse email';
            break;
          case 429:
            errorMessage = 'Trop de demandes, veuillez réessayer plus tard';
            break;
          case 500:
            errorMessage = 'Erreur serveur, veuillez réessayer';
            break;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Délai de connexion dépassé';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Impossible de se connecter au serveur';
      }

      throw AuthServiceException(errorMessage, statusCode);
    } catch (e) {
      AppLogger.error('Erreur générale forgot-password', tag: 'AUTH', error: e);
      throw AuthServiceException('Erreur inattendue: $e', 0);
    }
  }
}

/// Exception personnalisée pour les erreurs d'authentification
class AuthServiceException implements Exception {
  final String message;
  final int statusCode;

  const AuthServiceException(this.message, this.statusCode);

  @override
  String toString() => 'AuthServiceException: $message (Status: $statusCode)';
}