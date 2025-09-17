/// Configuration des environnements pour l'application ASSBT
/// 
/// Permet de configurer différents environnements (dev/staging/production)
/// via les paramètres de compilation --dart-define
/// 
/// Exemple d'usage :
/// ```bash
/// # Développement
/// flutter run --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=PRODUCTION=false
/// 
/// # Staging
/// flutter build apk --dart-define=API_BASE_URL=https://api-staging.example.com --dart-define=PRODUCTION=false
/// 
/// # Production
/// flutter build apk --release --dart-define=API_BASE_URL=https://api-prod.lesbulleurstoulonnais.fr --dart-define=PRODUCTION=true
/// ```
class EnvConfig {
  /// Base URL de l'API - configurable par environnement
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-prod.lesbulleurstoulonnais.fr',
  );

  /// Mode production - affecte le logging et les validations
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: true,
  );

  /// Activation du logging détaillé des APIs
  static const bool enableApiLogging = bool.fromEnvironment(
    'ENABLE_API_LOGGING',
    defaultValue: !isProduction,
  );

  /// Activation du logging général de l'application
  static const bool enableAppLogging = bool.fromEnvironment(
    'ENABLE_APP_LOGGING',
    defaultValue: !isProduction,
  );

  /// Timeout pour les requêtes API en secondes
  static const int apiTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  /// Timeout pour les requêtes de connexion en secondes
  static const int connectionTimeoutSeconds = int.fromEnvironment(
    'CONNECTION_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  /// Version de l'API utilisée
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  /// Activation du mode debug réseau
  static const bool enableNetworkDebugging = bool.fromEnvironment(
    'ENABLE_NETWORK_DEBUG',
    defaultValue: !isProduction,
  );

  /// Nombre de tentatives de retry pour les requêtes échouées
  static const int apiRetryAttempts = int.fromEnvironment(
    'API_RETRY_ATTEMPTS',
    defaultValue: 3,
  );

  /// Délai entre les tentatives de retry en millisecondes
  static const int retryDelayMs = int.fromEnvironment(
    'RETRY_DELAY_MS',
    defaultValue: 1000,
  );

  // === ENDPOINTS API ===

  /// URL complète pour l'API d'authentification
  static String get authBaseUrl => '$apiBaseUrl/api/auth';

  /// URL complète pour l'API des profils utilisateur
  static String get profileBaseUrl => '$apiBaseUrl/api/profils';

  /// URL complète pour l'API des activités
  static String get activitiesBaseUrl => '$apiBaseUrl/api';

  /// URL complète pour l'API des articles
  static String get articlesBaseUrl => '$apiBaseUrl/api/articles';

  /// URL complète pour l'API des membres
  static String get membersBaseUrl => '$apiBaseUrl/api/membres';

  // === MÉTHODES UTILITAIRES ===

  /// Retourne la configuration complète sous forme de Map pour debugging
  static Map<String, dynamic> get debugInfo => {
        'apiBaseUrl': apiBaseUrl,
        'isProduction': isProduction,
        'enableApiLogging': enableApiLogging,
        'enableAppLogging': enableAppLogging,
        'apiTimeoutSeconds': apiTimeoutSeconds,
        'connectionTimeoutSeconds': connectionTimeoutSeconds,
        'apiVersion': apiVersion,
        'enableNetworkDebugging': enableNetworkDebugging,
        'apiRetryAttempts': apiRetryAttempts,
        'retryDelayMs': retryDelayMs,
      };

  /// Valide que la configuration est cohérente
  static bool get isConfigurationValid {
    return apiBaseUrl.isNotEmpty &&
           apiTimeoutSeconds > 0 &&
           connectionTimeoutSeconds > 0 &&
           apiRetryAttempts >= 0 &&
           retryDelayMs >= 0;
  }

  /// Retourne l'environnement détecté basé sur l'URL
  static String get environmentName {
    if (apiBaseUrl.contains('localhost') || apiBaseUrl.contains('127.0.0.1')) {
      return 'local';
    } else if (apiBaseUrl.contains('staging') || apiBaseUrl.contains('dev')) {
      return 'staging';
    } else {
      return 'production';
    }
  }

  /// Headers par défaut pour toutes les requêtes API
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Version': apiVersion,
        'X-Client-Version': '0.7.2',
        'X-Environment': environmentName,
      };

  /// Durées de timeout sous forme de Duration objects
  static Duration get apiTimeout => Duration(seconds: apiTimeoutSeconds);
  static Duration get connectionTimeout => Duration(seconds: connectionTimeoutSeconds);
  static Duration get retryDelay => Duration(milliseconds: retryDelayMs);
}