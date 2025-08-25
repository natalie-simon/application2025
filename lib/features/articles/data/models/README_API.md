# API Articles - Format des Réponses

## 📋 Endpoint: Articles par Catégorie

**URL:** `GET /api/articles/categorie/{categorie}`  
**Paramètres:** `?page={page}&limit={limit}`  
**Exemple:** `/api/articles/categorie/visiteurs?page=1&limit=9`

## 📄 Format de Réponse

### Structure JSON
```json
[
  {
    "id": 26,
    "titre": "deux",
    "contenu": "<p>deux</p>",
    "statut": "BROUILLON",
    "categorie": "VISITEURS",
    "image": {
      "url": "https://apitest.nataliesimon.fr/uploads/fluxusdt-2025-07-08-18-02-11-1753163606642-73905b36-dd99-4e04-b226-daa0aeff1058.png"
    },
    "redacteur": {
      "email": "ybah2201@gmail.com"
    }
  },
  {
    "id": 29,
    "titre": "nouveau titre",
    "contenu": "<p>he voilou la suite</p>",
    "statut": "PUBLIE",
    "categorie": "VISITEURS",
    "image": {
      "url": "https://apitest.nataliesimon.fr/uploads/solusdt-2025-07-08-15-10-55-1756145201893-d8f3f61f-2f85-413b-8193-3f39984a7696.png"
    },
    "redacteur": {
      "email": "ybah2201@gmail.com"
    }
  }
]
```

## 🏗️ Structure des Données

### Article
| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `id` | `number` | ✅ | Identifiant unique de l'article |
| `titre` | `string` | ✅ | Titre de l'article |
| `contenu` | `string` | ✅ | Contenu HTML de l'article |
| `statut` | `string` | ✅ | Statut de publication |
| `categorie` | `string` | ✅ | Catégorie de l'article |
| `image` | `object` | ❌ | Image associée à l'article |
| `redacteur` | `object` | ❌ | Informations du rédacteur |

### Image
| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `url` | `string` | ✅ | URL complète de l'image |

### Rédacteur
| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `email` | `string` | ✅ | Email du rédacteur |

## 📊 Valeurs d'Énumération

### Statuts
- `PUBLIE` - Article publié et visible
- `BROUILLON` - Article en cours de rédaction
- `CORBEILLE` - Article archivé

### Catégories
- `VISITEURS` - Articles pour visiteurs
- `INFORMATIONS` - Articles d'information
- `ANNONCES` - Annonces officielles

## 🔧 Utilisation dans le Code

### Parsing Manuel (actuel)
```dart
Widget _buildArticlesList(BuildContext context, List<dynamic> articles) {
  final articleList = articles.map((articleData) {
    final data = articleData as Map<String, dynamic>;
    return Article(
      id: data['id'] ?? 0,
      titre: data['titre'] ?? 'Article sans titre',
      contenu: data['contenu'] ?? '',
      statut: data['statut'] ?? 'BROUILLON',
      categorie: data['categorie'] ?? 'VISITEURS',
      image: data['image'] != null ? ArticleImage(url: data['image']['url']) : null,
      redacteur: data['redacteur'] != null ? ArticleRedacteur(email: data['redacteur']['email']) : null,
    );
  }).toList();
  // ...
}
```

### Parsing avec Modèles API (recommandé)
```dart
import '../data/models/api_response_models.dart';

// Dans le service
List<Article> fetchArticlesByCategory(String category, int page, int limit) async {
  final response = await dio.get('/api/articles/categorie/$category?page=$page&limit=$limit');
  return ArticleApiResponseParser.parseArticlesList(response.data);
}

// Dans le widget
Widget _buildArticlesList(BuildContext context, List<Article> articles) {
  return ArticleSlider(
    articles: articles,
    title: 'Articles récents',
    onArticleTap: (article) => _showArticle(article),
  );
}
```

## 🚨 Gestion d'Erreurs

### Erreurs Possibles
- **400** - Paramètres invalides
- **404** - Catégorie non trouvée
- **500** - Erreur serveur

### Format d'Erreur
```json
{
  "message": "Catégorie non trouvée",
  "code": 404,
  "details": {
    "categorie": "invalid_category"
  }
}
```

## 📝 Notes de Développement

1. **Images CORS**: Les images externes peuvent être bloquées par CORS sur web
2. **Contenu HTML**: Le champ `contenu` contient du HTML brut à nettoyer
3. **Dates**: Actuellement aucun champ de date n'est retourné par l'API
4. **Pagination**: L'API ne retourne pas de métadonnées de pagination

## 🔄 Migration Recommandée

Pour améliorer la robustesse du code, il est recommandé de :

1. Utiliser les modèles API typés (`api_response_models.dart`)
2. Ajouter une validation des données
3. Implémenter une gestion d'erreur centralisée
4. Ajouter des tests pour le parsing des réponses

## 📚 Exemples d'URL

- Visiteurs: `/api/articles/categorie/visiteurs?page=1&limit=6`
- Informations: `/api/articles/categorie/informations?page=1&limit=10`
- Annonces: `/api/articles/categorie/annonces?page=2&limit=5`