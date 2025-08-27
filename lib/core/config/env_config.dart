import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class EnvConfig {
  // Configuration API
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-prod.lesbulleurstoulonnais.fr/api',
  );
  
  static const bool _modeDevBool = bool.fromEnvironment(
    'MODE_DEV',
    defaultValue: true,
  );

  // Configuration pour différents environnements
  static String get apiBaseUrl {
    if (kDebugMode) {
      // Mode développement
      return _apiBaseUrl;
    } else {
      // Mode production
      return 'https://api-prod.lesbulleurstoulonnais.fr/api';
    }
  }
  
  static bool get isDevMode => kDebugMode && _modeDevBool;
  
  // URLs spécifiques
  static String get authUrl => '$apiBaseUrl/auth';
  static String get membersUrl => '$apiBaseUrl/members';
  static String get articlesUrl => '$apiBaseUrl/articles';
  static String get activitiesUrl => '$apiBaseUrl/activities';
  
  // Configuration de debug
  static bool get enableLogging => isDevMode;
  static bool get showDebugBanner => isDevMode;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Affichage des informations de configuration
  static void logConfig() {
    AppLogger.info('=== ASSBT App Configuration ===', tag: 'CONFIG');
    AppLogger.info('API Base URL: $apiBaseUrl', tag: 'CONFIG');
    AppLogger.info('Dev Mode: $isDevMode', tag: 'CONFIG');
    AppLogger.info('Debug Mode: $kDebugMode', tag: 'CONFIG');
    AppLogger.info('Auth URL: $authUrl', tag: 'CONFIG');
    AppLogger.info('================================', tag: 'CONFIG');
  }
}