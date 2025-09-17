import 'package:flutter/foundation.dart';

/// Classe utilitaire pour la gestion des logs de l'application
class AppLogger {
  static const String _logPrefix = '🔐 ASSBT';
  
  /// Log d'information générale
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix INFO: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
    }
  }
  
  /// Log d'erreur
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
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
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix WARNING: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
    }
  }
  
  /// Log de debug (développement uniquement)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      debugPrint('$_logPrefix DEBUG: $tagPrefix$message - ${DateTime.now().toString().substring(0, 19)}');
    }
  }
  
  /// Log pour les API calls
  static void apiCall(String method, String endpoint, {int? statusCode, String? tag}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final statusText = statusCode != null ? ' (Status: $statusCode)' : '';
      debugPrint('$_logPrefix API: $tagPrefix$method $endpoint$statusText - ${DateTime.now().toString().substring(0, 19)}');
    }
  }
  
  /// Log pour les authentifications
  static void auth(String message, {String? email}) {
    if (kDebugMode) {
      final emailText = email != null ? ' for $email' : '';
      debugPrint('$_logPrefix AUTH: $message$emailText - ${DateTime.now().toString().substring(0, 19)}');
    }
  }
}