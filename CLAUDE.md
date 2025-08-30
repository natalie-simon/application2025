# Consignes Claude Code - ASSBT

## Build APK
À chaque génération d'APK, s'assurer que :

1. **Modal "À propos"** affiche :
   - Nom de la branche actuelle (obtenu via `git branch`)
   - Numéro de version (depuis `pubspec.yaml`)
   
2. **Commandes à exécuter** :
   - `git branch` pour obtenir la branche courante
   - Lire `pubspec.yaml` ligne `version:` pour le numéro
   - Mettre à jour le fichier `lib/shared/widgets/app_drawer.dart` dans `_showAboutDialog()`

## Implémentation actuelle
La modal "À propos" se trouve dans :
- **Fichier** : `lib/shared/widgets/app_drawer.dart`
- **Méthode** : `_showAboutDialog(BuildContext context)`
- **Déclencheur** : Clic sur "À propos" dans le drawer (mode non-connecté)

## Automatisation recommandée
Pour les prochaines versions, considérer :
- Lecture dynamique du nom de branche via package Flutter
- Lecture automatique de la version depuis `pubspec.yaml`
- Affichage de la date de build

## Logging
- Logger dans le fichier worklog du jour ce qui doit l'être au fur et à mesure
- Logger dans le fichier work du jour à chaque fois que l'utilisateur dit qu'il valide

---
*Consignes établies le 27 août 2025*
*Dernière mise à jour le 30 août 2025*