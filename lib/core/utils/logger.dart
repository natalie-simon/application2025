import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// Classe utilitaire pour la gestion des logs de l'application
/// Respecte la configuration d'environnement pour la sécurité en production
class AppLogger {
  static const String _logPrefix = '🔐 ASSBT';

  /// Vérifie si les logs généraux sont activés selon la configuration
  static bool get _isGeneralLoggingEnabled =>
      kDebugMode && EnvConfig.enableAppLogging;

  /// Vérifie si les logs API sont activés selon la configuration
  static bool get _isApiLoggingEnabled =>
      kDebugMode && EnvConfig.enableApiLogging;

  /// Log d'information générale
  static void info(String message, {String? tag}) {
    if (_isGeneralLoggingEnabled) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix INFO: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
    }
  }
  
  /// Log d'erreur
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_isGeneralLoggingEnabled) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix ERROR: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
      if (error != null) {
        debugPrint('$_logPrefix ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_logPrefix STACK TRACE: $stackTrace');
      }
    }
  }
  
  /// Log d'avertissement
  static void warning(String message, {String? tag}) {
    if (_isGeneralLoggingEnabled) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix WARNING: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
    }
  }

  /// Log de debug (développement uniquement)
  static void debug(String message, {String? tag}) {
    if (_isGeneralLoggingEnabled) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix DEBUG: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
    }
  }

  /// Log pour les API calls - respecte la configuration API logging
  static void apiCall(String method, String endpoint, {int? statusCode, String? tag}) {
    if (_isApiLoggingEnabled) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final statusText = statusCode != null ? ' (Status: $statusCode)' : '';
      debugPrint('$_logPrefix API: $tagPrefix$method $endpoint$statusText - ${DateTime.now().toString().substring(0, 19)}');
    }
  }

  /// Log pour les authentifications - ATTENTION: données sensibles
  /// Ne log que les informations non-sensibles en production
  static void auth(String message, {String? email}) {
    if (_isGeneralLoggingEnabled) {
      // En production, on masque l'email pour la sécurité
      String emailText = '';
      if (email != null) {
        if (EnvConfig.isProduction) {
          // Masquer l'email en production : user@domain.com -> u***@d*****.com
          final parts = email.split('@');
          if (parts.length == 2) {
            final username = parts[0].length > 1 ? '${parts[0][0]}***' : '***';
            final domain = parts[1].length > 3 ? '${parts[1][0]}${'*' * (parts[1].length - 2)}${parts[1][parts[1].length - 1]}' : '***';
            emailText = ' for $username@$domain';
          } else {
            emailText = ' for ***@***';
          }
        } else {
          emailText = ' for $email';
        }
      }
      debugPrint('$_logPrefix AUTH: $message$emailText - ${DateTime.now().toString().substring(0, 19)}');
    }
  }

  /// Log critique (toujours affiché, même en production)
  /// Utilisé uniquement pour les erreurs critiques de sécurité
  static void critical(String message, {String? tag}) {
    final tagPrefix = tag != null ? '[$tag] ' : '';
    debugPrint('$_logPrefix CRITICAL: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
  }

  /// Affiche la configuration actuelle des logs
  static void logConfiguration() {
    if (_isGeneralLoggingEnabled) {
      debugPrint('$_logPrefix CONFIG: Environment: ${EnvConfig.environmentName}');
      debugPrint('$_logPrefix CONFIG: Production mode: ${EnvConfig.isProduction}');
      debugPrint('$_logPrefix CONFIG: General logging: ${EnvConfig.enableAppLogging}');
      debugPrint('$_logPrefix CONFIG: API logging: ${EnvConfig.enableApiLogging}');
      debugPrint('$_logPrefix CONFIG: Network debugging: ${EnvConfig.enableNetworkDebugging}');
    }
  }
}