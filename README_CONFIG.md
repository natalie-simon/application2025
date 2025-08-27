# Configuration ASSBT App

## Variables d'environnement

### Fichiers de configuration

- `.env` - Configuration de développement (trackée dans git)
- `.env.local` - Configuration locale (ignorée par git)
- `.env.production` - Configuration production (ignorée par git)
- `.env.example` - Exemple de configuration

### Variables disponibles

| Variable | Description | Défaut |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | URL de base de l'API | `http://localhost:3000/api` |
| `VITE_MODE_DEV` | Mode développement | `true` |

### URLs API

- **Développement local** : `http://localhost:3000/api`
- **Production** : `https://api-prod.lesbulleurstoulonnais.fr/api`

### Utilisation dans le code

```dart
import 'package:application/core/config/env_config.dart';

// URLs API
String apiUrl = EnvConfig.apiBaseUrl;
String authUrl = EnvConfig.authUrl;
String membersUrl = EnvConfig.membersUrl;

// Configuration
bool isDevMode = EnvConfig.isDevMode;
bool enableLogging = EnvConfig.enableLogging;
```

### Endpoints disponibles

| Endpoint | URL | Description |
|----------|-----|-------------|
| Auth | `/api/auth` | Authentification |
| Members | `/api/members` | Gestion des membres |
| Articles | `/api/articles` | Articles et actualités |
| Activities | `/api/activities` | Activités et événements |

### Configuration par environnement

#### Développement
```bash
VITE_API_BASE_URL=http://localhost:3000/api
VITE_MODE_DEV=true
```

#### Production
```bash
VITE_API_BASE_URL=https://api-prod.lesbulleurstoulonnais.fr/api
VITE_MODE_DEV=false
```

#### Test local avec proxy
```bash
VITE_API_BASE_URL=/api
VITE_MODE_DEV=true
```

---

## Builds de production

### Android APK
- **Fichier** : `build/app/outputs/flutter-apk/app-release.apk`
- **Taille** : 46.4 MB
- **Cible** : Android 5.0+ (API 21+)
- **Configuration** : Production avec API `https://api-prod.lesbulleurstoulonnais.fr`

### iOS IPA
- **Fichier** : `application.ipa`
- **Taille** : 7.3 MB  
- **Cible** : iOS 11.0+, Compatible iPhone 11
- **Configuration** : Production avec API `https://api-prod.lesbulleurstoulonnais.fr`

### Permissions réseau

#### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Dernière mise à jour
- **Date** : 27 août 2025
- **Version** : Production ready
- **API** : Connectée exclusivement (plus de données simulées)
- **Status** : ✅ Validé sur émulateurs Android/iOS