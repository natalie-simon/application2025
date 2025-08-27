# Logs de travail ASSBT

Ce dossier contient les logs quotidiens de développement du projet ASSBT (Association Subaquatique du Bassin Toulonnais).

## Structure des dossiers

```
logs/
├── README.md              # Ce fichier
├── YYYY/                  # Année (ex: 2025/)
│   └── MM/               # Mois (ex: 08/ pour août)
│       └── YYYY-MM-DD.md # Log quotidien (ex: 2025-08-27.md)
```

## Format des logs quotidiens

Chaque fichier de log quotidien contient :

### Sections obligatoires
- **Résumé de la journée** : Vue d'ensemble des travaux
- **Travaux effectués** : Détail chronologique avec heures
- **Fichiers modifiés** : Liste des fichiers impactés
- **Issues résolues** : Bugs/TODOs traités
- **Tests effectués** : Validations réalisées

### Sections optionnelles  
- **Fonctionnalités livrées** : Features complétées
- **Prochaines étapes** : TODO pour sessions suivantes
- **Temps total** : Estimation durée travaux
- **Notes techniques** : Détails d'implémentation

## Convention d'écriture

### Horaires
- Format 24h : `15h30-16h00`
- Durée estimée en fin de section

### Émojis pour catégorisation
- 🔐 Authentification/Sécurité
- 🎨 Interface utilisateur/Design  
- 📱 Fonctionnalités mobile
- 📰 Gestion contenu/Articles
- 🛠️ Configuration/Build
- 🧪 Tests/QA
- 📦 Releases/Déploiement
- 🐛 Corrections bugs
- ⚡ Optimisations performance

### Status des tâches
- ✅ Terminé/Validé
- ❌ Échec/Problème
- ⏳ En cours
- 📋 Planifié
- 🔄 En révision

## Utilisation

1. **Début de session** : Créer/ouvrir le fichier du jour
2. **Pendant le travail** : Noter les modifications importantes
3. **Fin de session** : Compléter le résumé et les stats
4. **Commit git** : Inclure les logs dans les commits si pertinent

## Archives

Les logs sont conservés indéfiniment pour :
- Traçabilité des développements
- Documentation des décisions techniques  
- Suivi de l'évolution du projet
- Debug/Support en cas de problème

---
*Système de worklog mis en place le 27 août 2025*