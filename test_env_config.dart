/// Script de test pour valider la configuration EnvConfig
/// 
/// Usage:
/// ```bash
/// # Test production (défaut)
/// dart test_env_config.dart
/// 
/// # Test développement
/// dart --define=API_BASE_URL=http://localhost:3000 --define=PRODUCTION=false test_env_config.dart
/// 
/// # Test staging
/// dart --define=API_BASE_URL=https://api-staging.example.com --define=PRODUCTION=false test_env_config.dart
/// ```
import 'lib/core/config/env_config.dart';

void main() {
  print('=== Test de Configuration EnvConfig ===\n');
  
  // Afficher la configuration complète
  print('📋 Configuration détectée:');
  EnvConfig.debugInfo.forEach((key, value) {
    print('   $key: $value');
  });
  
  print('\n🌍 Environnement détecté: ${EnvConfig.environmentName}');
  
  // Validation de la configuration
  print('\n✅ Configuration valide: ${EnvConfig.isConfigurationValid}');
  
  // Test des endpoints
  print('\n🔗 Endpoints API:');
  print('   Auth: ${EnvConfig.authBaseUrl}');
  print('   Profile: ${EnvConfig.profileBaseUrl}');
  print('   Activities: ${EnvConfig.activitiesBaseUrl}');
  print('   Articles: ${EnvConfig.articlesBaseUrl}');
  print('   Members: ${EnvConfig.membersBaseUrl}');
  
  // Test des timeouts
  print('\n⏱️ Timeouts:');
  print('   API: ${EnvConfig.apiTimeout}');
  print('   Connection: ${EnvConfig.connectionTimeout}');
  print('   Retry Delay: ${EnvConfig.retryDelay}');
  
  // Test des headers
  print('\n📤 Headers par défaut:');
  EnvConfig.defaultHeaders.forEach((key, value) {
    print('   $key: $value');
  });
  
  // Test des flags de logging
  print('\n📝 Configuration Logging:');
  print('   API Logging: ${EnvConfig.enableApiLogging}');
  print('   App Logging: ${EnvConfig.enableAppLogging}');
  print('   Network Debug: ${EnvConfig.enableNetworkDebugging}');
  
  // Test du retry
  print('\n🔄 Configuration Retry:');
  print('   Attempts: ${EnvConfig.apiRetryAttempts}');
  print('   Delay: ${EnvConfig.retryDelayMs}ms');
  
  print('\n🎯 Test terminé avec succès!');
}