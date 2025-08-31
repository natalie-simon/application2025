# Notes de Version et Build - ASSBT

## 📱 Affichage du numéro de build

### Exigence utilisateur
**Date** : 31 août 2025  
**Demande** : Le numéro de build doit apparaître dans l'application

### Configuration actuelle
- **Version app** : Définie dans `pubspec.yaml` (ex: `0.7.0-beta+1`)
- **Modal "À propos"** : Affiche version et branche dans `lib/shared/widgets/app_drawer.dart`
- **Headers API** : Version envoyée dans `X-Client-Version` via `lib/core/config/env_config.dart`

### Implémentation requise
Pour les futures versions, s'assurer que :

1. **Modal "À propos"** doit afficher :
   - ✅ Numéro de version (ex: 0.7.0-beta+1)
   - ✅ Nom de la branche courante 
   - ⚠️ **NOUVEAU** : Numéro de build visible pour l'utilisateur

2. **Options d'implémentation** :
   - Ajouter le build number dans la modal à côté de la version
   - Ou créer une section détaillée avec version + build + date
   - Ou afficher dans un écran "Informations techniques"

### Fichiers concernés
- `pubspec.yaml` : Source de vérité pour version+build
- `lib/shared/widgets/app_drawer.dart` : Modal "À propos" 
- `lib/core/config/env_config.dart` : Headers API avec version

### Rappel important
**Chaque nouveau build doit inclure** :
- Mise à jour du numéro de version dans `pubspec.yaml`
- Mise à jour de la modal "À propos" avec la nouvelle version
- Mise à jour des headers API avec la nouvelle version
- **NOUVEAU** : Affichage visible du numéro de build pour diagnostic utilisateur

---
*Note créée le 31 août 2025 suite à demande utilisateur*