# Git Flow Workflow - ASSBT Flutter App

## 🌊 Configuration Git Flow

Le projet utilise **Git Flow** avec une convention de nommage spécifique pour les features.

### Branches principales
- `master` - Production releases
- `develop` - Development integration

### Convention de nommage des features
**Format:** `fc_<nom_de_la_feature>`

Exemples :
```bash
git flow feature start fc_setup_dependencies
git flow feature start fc_auth_system
git flow feature start fc_members_module
git flow feature start fc_member_list
git flow feature start fc_member_profile
```

## 📋 Workflow par Phase (selon ROADMAP.md)

### Phase 1: Configuration de Base
```bash
# Setup initial
git flow feature start fc_setup_dependencies
git flow feature finish fc_setup_dependencies

# Thème ASSBT
git flow feature start fc_theme_setup
git flow feature finish fc_theme_setup
```

### Phase 2: Authentification
```bash
# Modèles de données
git flow feature start fc_auth_models
git flow feature finish fc_auth_models

# Service d'authentification  
git flow feature start fc_auth_service
git flow feature finish fc_auth_service

# Écrans de login
git flow feature start fc_login_screens
git flow feature finish fc_login_screens
```

### Phase 3: Module Membres (Priorité)
```bash
# Modèles membres
git flow feature start fc_members_models
git flow feature finish fc_members_models

# Services membres
git flow feature start fc_members_service
git flow feature finish fc_members_service

# Liste des membres
git flow feature start fc_members_list
git flow feature finish fc_members_list

# Profil détaillé
git flow feature start fc_member_detail
git flow feature finish fc_member_detail

# Recherche et filtres
git flow feature start fc_members_search
git flow feature finish fc_members_search
```

### Phase 4: Navigation
```bash
# Configuration GoRouter
git flow feature start fc_navigation_setup
git flow feature finish fc_navigation_setup

# Layout principal
git flow feature start fc_main_layout
git flow feature finish fc_main_layout
```

### Phase 5: Fonctionnalités Avancées
```bash
# Annuaire membres
git flow feature start fc_members_directory
git flow feature finish fc_members_directory

# Profil utilisateur
git flow feature start fc_user_profile
git flow feature finish fc_user_profile
```

### Phase 6: Optimisation
```bash
# Performance et cache
git flow feature start fc_performance_optimization
git flow feature finish fc_performance_optimization

# Tests
git flow feature start fc_testing_suite
git flow feature finish fc_testing_suite
```

## 🚀 Releases

### Créer une release
```bash
# Version 0.1.0 - MVP Membres
git flow release start 0.1.0
git flow release finish 0.1.0

# Version 0.2.0 - Interface Complète
git flow release start 0.2.0
git flow release finish 0.2.0

# Version 1.0.0 - Version Beta
git flow release start 1.0.0
git flow release finish 1.0.0
```

### Hotfixes (si nécessaire)
```bash
git flow hotfix start fc_critical_bug_fix
git flow hotfix finish fc_critical_bug_fix
```

## 📝 Bonnes pratiques

### Messages de commit
```bash
git commit -m "feat(members): add member list with search functionality

- Implement MembersListScreen with search bar
- Add MemberCard widget for list items  
- Integrate with MembersProvider for state management
- Add basic filtering by name/email

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Types de commits
- `feat(scope):` - Nouvelle fonctionnalité
- `fix(scope):` - Correction de bug
- `refactor(scope):` - Refactoring de code
- `style(scope):` - Modifications de style/formatage
- `test(scope):` - Ajout/modification de tests
- `docs(scope):` - Documentation

### Scopes principaux
- `auth` - Authentification
- `members` - Module membres  
- `profile` - Profil utilisateur
- `navigation` - Navigation/routing
- `theme` - Thème et UI
- `api` - Services API

## 🎯 Commandes de démarrage rapide

```bash
# Démarrer la première feature
git flow feature start fc_setup_dependencies

# Voir les features en cours
git flow feature list

# Basculer sur develop
git checkout develop

# Voir l'état du repository
git status
```

Ce workflow assure une organisation claire du développement avec la convention `fc_` pour toutes les features.