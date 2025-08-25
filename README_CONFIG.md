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