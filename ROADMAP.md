# Roadmap ASSBT Flutter - Focus Membres

## 📋 Phase 1: Configuration de Base

### 1. Setup initial du projet
- [x] Créer la structure Flutter de base
- [ ] Configurer `pubspec.yaml` avec les dépendances essentielles
- [ ] Créer la structure des dossiers selon l'architecture recommandée

**Dépendances à ajouter:**
```yaml
dependencies:
  # State Management
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9
  
  # HTTP & API
  dio: ^5.3.4
  json_annotation: ^4.8.1
  
  # JWT & Auth
  jwt_decoder: ^2.0.1
  flutter_secure_storage: ^9.0.0
  
  # Navigation
  go_router: ^12.1.3
  
  # Utils
  equatable: ^2.0.5
  intl: ^0.19.0

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

### 2. Thème et Design System ASSBT
- [ ] Créer `lib/core/theme/app_colors.dart` avec les couleurs ASSBT
- [ ] Configurer `lib/core/theme/app_theme.dart` pour dark/light mode
- [ ] Setup des composants UI de base

**Couleurs ASSBT:**
- Primary: `#134074`
- Dark: `#0B2545` 
- Text Shine: `#EEF4ED`
- Text Light: `#8DA9C4`

---

## 🔐 Phase 2: Authentification & Sécurité

### 3. Modèles de données
- [ ] Créer `lib/features/auth/domain/models/user.dart`
- [ ] Créer les modèles `Profil`, `Avatar`
- [ ] Générer les serializers JSON avec `build_runner`

### 4. Service d'authentification
- [ ] Créer `lib/shared/services/api_service.dart`
- [ ] Configuration Dio avec intercepteurs JWT
- [ ] Créer `lib/features/auth/presentation/providers/auth_provider.dart`
- [ ] Gestion du stockage sécurisé (FlutterSecureStorage)

### 5. Écrans d'authentification
- [ ] Créer `lib/features/auth/presentation/screens/login_screen.dart`
- [ ] Gestion des états de chargement et erreurs
- [ ] Validation des formulaires

---

## 👥 Phase 3: Module Membres (🎯 PRIORITÉ)

### 6. Modèles membres
- [ ] Créer `lib/features/members/domain/models/member.dart`
- [ ] Modèle pour les informations détaillées des membres
- [ ] Serialization JSON pour les données membres

### 7. Services membres
- [ ] Créer `lib/features/members/data/repositories/members_repository.dart`
- [ ] API endpoints pour récupérer les membres
- [ ] Créer `lib/features/members/presentation/providers/members_provider.dart`
- [ ] Gestion d'état avec Riverpod

### 8. Interface membres
- [ ] Créer `lib/features/members/presentation/screens/members_list_screen.dart`
- [ ] Liste des membres avec filtres de recherche
- [ ] Créer `lib/features/members/presentation/screens/member_detail_screen.dart`
- [ ] Composants réutilisables: `MemberCard`, `MemberAvatar`
- [ ] Système de recherche et tri des membres

**Fonctionnalités membres prioritaires:**
- Liste complète des membres
- Recherche par nom/prénom
- Filtres par rôle/statut
- Profil détaillé avec informations de contact
- Interface responsive

---

## 🏗️ Phase 4: Navigation & Structure

### 9. Configuration GoRouter
- [ ] Créer `lib/core/router/app_router.dart`
- [ ] Routes principales avec garde d'authentification
- [ ] Navigation entre écrans membres
- [ ] Gestion des paramètres de route

### 10. Layout principal
- [ ] Créer `lib/shared/widgets/app_scaffold.dart`
- [ ] AppBar avec navigation et recherche
- [ ] Menu principal orienté membres
- [ ] Navigation bottom/drawer
- [ ] Gestion responsive mobile/tablet

---

## 📱 Phase 5: Fonctionnalités Membres Avancées

### 11. Fonctionnalités sociales membres
- [ ] Annuaire des membres avec catégories
- [ ] Système de favoris/contacts fréquents  
- [ ] Export de la liste des membres
- [ ] Statistiques des membres (nombre par rôle, etc.)

### 12. Profil utilisateur
- [ ] Créer `lib/features/profile/presentation/screens/profile_screen.dart`
- [ ] Gestion du profil personnel
- [ ] Upload d'avatar avec `image_picker`
- [ ] Modification des informations personnelles
- [ ] Préférences utilisateur

---

## 🚀 Phase 6: Optimisation & Finalisation

### 13. Performance & Cache
- [ ] Mise en cache des données membres avec `hive` ou `shared_preferences`
- [ ] Optimisation des requêtes API (pagination, filtres côté serveur)
- [ ] Images en cache avec `cached_network_image`
- [ ] Gestion offline basique

### 14. Tests & Qualité
- [ ] Tests unitaires des services membres
- [ ] Tests d'intégration pour l'authentification
- [ ] Tests widgets pour les écrans principaux
- [ ] Analyse statique avec `flutter analyze`

### 15. Déploiement
- [ ] Configuration build de production
- [ ] Optimisation des assets et images
- [ ] Configuration CI/CD
- [ ] Documentation utilisateur

---

## 🎯 Milestones

### Milestone 1: MVP Membres (Semaine 2-3)
- Authentification fonctionnelle
- Liste des membres avec recherche basique
- Navigation entre écrans

### Milestone 2: Interface Complète (Semaine 4-5)
- Interface membres complète avec filtres
- Profil détaillé des membres
- Thème ASSBT appliqué

### Milestone 3: Version Beta (Semaine 6-7)
- Toutes les fonctionnalités membres
- Tests et optimisations
- Prêt pour déploiement test

---

## 📝 Notes Techniques

### API Endpoints Requis
```
GET /api/members - Liste des membres
GET /api/members/{id} - Détail d'un membre  
GET /api/members/search?q={query} - Recherche
POST /api/auth/login - Authentification
GET /api/auth/me - Profil utilisateur
```

### Architecture Cible
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── router/
├── features/
│   ├── auth/
│   ├── members/     # 🎯 FOCUS
│   └── profile/
├── shared/
│   ├── widgets/
│   ├── services/
│   └── utils/
└── main.dart
```

Cette roadmap priorise le module membres tout en gardant une architecture solide et évolutive.