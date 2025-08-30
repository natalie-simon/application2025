# Guide de Configuration Multi-Environnements
## EnvConfig - ASSBT Flutter App

---

## 🎯 Vue d'Ensemble

Le système `EnvConfig` permet de configurer l'application pour différents environnements (développement, staging, production) via des paramètres de compilation `--dart-define`.

**Avantages :**
- ✅ **Multi-environnements** sans recompilation
- ✅ **Configuration centralisée** et typée
- ✅ **Logging conditionnel** automatique
- ✅ **Validation** intégrée
- ✅ **Sécurité** renforcée (URLs hors du code)

---

## 🚀 Utilisation Rapide

### **Développement Local**
```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=PRODUCTION=false
```

### **Staging**
```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api-staging.example.com \
  --dart-define=PRODUCTION=false
```

### **Production** (défaut)
```bash
flutter build apk --release
# Utilise automatiquement https://api-prod.lesbulleurstoulonnais.fr
```

---

## ⚙️ Variables Disponibles

| Variable | Type | Défaut | Description |
|----------|------|--------|-------------|
| `API_BASE_URL` | String | `https://api-prod.lesbulleurstoulonnais.fr` | URL de base de l'API |
| `PRODUCTION` | bool | `true` | Mode production |
| `ENABLE_API_LOGGING` | bool | `!PRODUCTION` | Logs détaillés API |
| `ENABLE_APP_LOGGING` | bool | `!PRODUCTION` | Logs application |
| `API_TIMEOUT_SECONDS` | int | `30` | Timeout requêtes API |
| `CONNECTION_TIMEOUT_SECONDS` | int | `30` | Timeout connexion |
| `API_VERSION` | String | `v1` | Version API |
| `ENABLE_NETWORK_DEBUG` | bool | `!PRODUCTION` | Debug réseau |
| `API_RETRY_ATTEMPTS` | int | `3` | Tentatives de retry |
| `RETRY_DELAY_MS` | int | `1000` | Délai entre retry (ms) |

---

## 🔗 Endpoints Générés

L'`EnvConfig` génère automatiquement les endpoints complets :

```dart
// Basé sur API_BASE_URL = "https://api-prod.lesbulleurstoulonnais.fr"
EnvConfig.authBaseUrl      // → /api/auth
EnvConfig.profileBaseUrl   // → /api/profils  
EnvConfig.activitiesBaseUrl // → /api/activities
EnvConfig.articlesBaseUrl  // → /api/articles
EnvConfig.membersBaseUrl   // → /api/members
```

---

## 🛠️ Configuration Avancée

### **Développement avec Debug Complet**
```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=PRODUCTION=false \
  --dart-define=ENABLE_API_LOGGING=true \
  --dart-define=ENABLE_NETWORK_DEBUG=true \
  --dart-define=API_TIMEOUT_SECONDS=60
```

### **Tests avec Retry Agressif**
```bash
flutter test \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=API_RETRY_ATTEMPTS=5 \
  --dart-define=RETRY_DELAY_MS=500
```

### **Staging avec Logging Sélectif**
```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api-staging.example.com \
  --dart-define=PRODUCTION=false \
  --dart-define=ENABLE_API_LOGGING=true \
  --dart-define=ENABLE_APP_LOGGING=false
```

---

## 🧪 Validation de Configuration

### **Test Rapide**
```bash
# Valider configuration production
dart test_env_config.dart

# Valider configuration développement
dart --define=API_BASE_URL=http://localhost:3000 --define=PRODUCTION=false test_env_config.dart
```

### **Validation Programmatique**
```dart
// Dans votre code Dart
import 'package:myapp/core/config/env_config.dart';

void validateConfig() {
  if (!EnvConfig.isConfigurationValid) {
    throw Exception('Configuration invalide!');
  }
  
  print('Environnement: ${EnvConfig.environmentName}');
  print('API: ${EnvConfig.authBaseUrl}');
  print('Debug Info: ${EnvConfig.debugInfo}');
}
```

---

## 📋 Headers Automatiques

Toutes les requêtes incluent automatiquement :

```json
{
  "Content-Type": "application/json",
  "Accept": "application/json", 
  "X-API-Version": "v1",
  "X-Client-Version": "0.7.0-beta",
  "X-Environment": "production|staging|local"
}
```

**Usage dans les services :**
```dart
// ✅ AuthService
_dio = Dio(BaseOptions(
  baseUrl: EnvConfig.authBaseUrl,
  headers: EnvConfig.defaultHeaders, // Headers automatiques
));

// ✅ ProfileService  
request.headers.addAll(EnvConfig.defaultHeaders);
```

---

## 🔍 Debugging

### **Logs Conditionnels**
```dart
// Ne s'active qu'en mode debug
if (EnvConfig.enableApiLogging) {
  dio.interceptors.add(LogInterceptor(/* ... */));
}

if (EnvConfig.enableAppLogging) {
  AppLogger.info('Service configuré: ${EnvConfig.environmentName}');
}
```

### **Environnement Détecté**
- `local` : localhost, 127.0.0.1
- `staging` : URLs contenant "staging" ou "dev"
- `production` : autres URLs

---

## 🚨 Sécurité

### **Bonnes Pratiques**
```bash
# ✅ Bon - Variables d'environnement
export API_BASE_URL="https://api-prod.example.com"
flutter build apk --dart-define=API_BASE_URL=$API_BASE_URL

# ❌ Éviter - URLs dans les scripts publics
flutter build apk --dart-define=API_BASE_URL=https://secret-api.com
```

### **CI/CD Sécurisé**
```yaml
# GitHub Actions / GitLab CI
env:
  API_BASE_URL: ${{ secrets.API_BASE_URL }}
  
script:
  - flutter build apk --dart-define=API_BASE_URL=$API_BASE_URL
```

---

## 🏗️ Architecture Interne

### **Structure**
```
lib/core/config/
└── env_config.dart          # Configuration centralisée

lib/features/*/data/services/
├── auth_service.dart         # Utilise EnvConfig.authBaseUrl
├── profile_service.dart      # Utilise EnvConfig.profileBaseUrl  
├── activities_service.dart   # Utilise EnvConfig.activitiesBaseUrl
└── articles_service.dart     # Utilise EnvConfig.articlesBaseUrl
```

### **Migration Effectuée**
```dart
// ❌ Avant - URL hardcodée
_dio = Dio(BaseOptions(
  baseUrl: 'https://api-prod.lesbulleurstoulonnais.fr/api/auth',
));

// ✅ Après - Configuration dynamique
_dio = Dio(BaseOptions(
  baseUrl: EnvConfig.authBaseUrl,
  headers: EnvConfig.defaultHeaders,
  connectTimeout: EnvConfig.connectionTimeout,
));
```

---

## 💡 Exemples Pratiques

### **Développeur Backend**
```bash
# Tester avec backend local
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

### **QA Testing**  
```bash
# Tests sur staging
flutter build apk --dart-define=API_BASE_URL=https://api-staging.company.com
```

### **DevOps Production**
```bash
# Build production avec monitoring
flutter build apk --release --dart-define=ENABLE_NETWORK_DEBUG=true
```

---

## 🎯 Prochaines Étapes

### **Extensions Possibles**
- **API Keys** sécurisées via variables d'environnement
- **Certificate Pinning** conditionnel  
- **Feature Flags** par environnement
- **Analytics Keys** différenciées
- **Database URLs** multiples

### **Exemple Extension**
```dart
class EnvConfig {
  // Futures variables possibles
  static const String analyticsKey = String.fromEnvironment('ANALYTICS_KEY');
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const bool enableCrashReporting = bool.fromEnvironment('ENABLE_CRASH_REPORTING');
}
```

---

**✅ Configuration terminée et testée** - Prête pour tous les environnements !