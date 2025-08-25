import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/article.dart';

part 'api_response_models.g.dart';

/// Modèle pour la réponse API des articles par catégorie
/// Endpoint: GET /api/articles/categorie/{categorie}?page={page}&limit={limit}
/// 
/// Exemple de réponse JSON:
/// ```json
/// [
///   {
///     "id": 26,
///     "titre": "deux",
///     "contenu": "<p>deux</p>",
///     "statut": "BROUILLON",
///     "categorie": "VISITEURS",
///     "image": {
///       "url": "https://apitest.nataliesimon.fr/uploads/image.png"
///     },
///     "redacteur": {
///       "email": "user@example.com"
///     }
///   }
/// ]
/// ```
@JsonSerializable()
class ArticleApiResponse {
  final int id;
  final String titre;
  final String contenu;
  final String statut;
  final String categorie;
  final ArticleImageApi? image;
  final ArticleRedacteurApi? redacteur;

  const ArticleApiResponse({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.statut,
    required this.categorie,
    this.image,
    this.redacteur,
  });

  factory ArticleApiResponse.fromJson(Map<String, dynamic> json) => 
      _$ArticleApiResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArticleApiResponseToJson(this);

  /// Convertit la réponse API en objet Article du domaine
  Article toDomainModel() {
    return Article(
      id: id,
      titre: titre,
      contenu: contenu,
      statut: statut,
      categorie: categorie,
      image: image?.toDomainModel(),
      redacteur: redacteur?.toDomainModel(),
    );
  }
}

/// Modèle pour l'image d'un article dans la réponse API
@JsonSerializable()
class ArticleImageApi {
  final String url;

  const ArticleImageApi({
    required this.url,
  });

  factory ArticleImageApi.fromJson(Map<String, dynamic> json) => 
      _$ArticleImageApiFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArticleImageApiToJson(this);

  /// Convertit vers le modèle du domaine
  ArticleImage toDomainModel() {
    return ArticleImage(url: url);
  }
}

/// Modèle pour le rédacteur d'un article dans la réponse API
@JsonSerializable()
class ArticleRedacteurApi {
  final String email;

  const ArticleRedacteurApi({
    required this.email,
  });

  factory ArticleRedacteurApi.fromJson(Map<String, dynamic> json) => 
      _$ArticleRedacteurApiFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArticleRedacteurApiToJson(this);

  /// Convertit vers le modèle du domaine
  ArticleRedacteur toDomainModel() {
    return ArticleRedacteur(email: email);
  }
}

/// Réponse pour la liste d'articles par catégorie
/// Type: List<ArticleApiResponse>
/// 
/// Utilisation:
/// ```dart
/// final List<dynamic> jsonList = response.data;
/// final articles = jsonList
///     .map((json) => ArticleApiResponse.fromJson(json))
///     .map((apiModel) => apiModel.toDomainModel())
///     .toList();
/// ```
typedef ArticlesCategorieResponse = List<ArticleApiResponse>;

/// Extensions utiles pour la conversion
extension ArticleApiResponseListExtension on List<ArticleApiResponse> {
  /// Convertit une liste de réponses API en liste d'articles du domaine
  List<Article> toDomainModels() {
    return map((apiModel) => apiModel.toDomainModel()).toList();
  }
}

/// Classe utilitaire pour parser les réponses API
class ArticleApiResponseParser {
  /// Parse une réponse JSON de liste d'articles
  /// 
  /// Exemple:
  /// ```dart
  /// final jsonResponse = [{"id": 1, "titre": "Test", ...}, ...];
  /// final articles = ArticleApiResponseParser.parseArticlesList(jsonResponse);
  /// ```
  static List<Article> parseArticlesList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ArticleApiResponse.fromJson(json as Map<String, dynamic>))
        .map((apiModel) => apiModel.toDomainModel())
        .toList();
  }

  /// Parse une réponse JSON d'un seul article
  static Article parseArticle(Map<String, dynamic> json) {
    return ArticleApiResponse.fromJson(json).toDomainModel();
  }
}

/// Constantes pour les valeurs d'énumération
class ArticleApiConstants {
  static const List<String> validStatuts = ['PUBLIE', 'BROUILLON', 'CORBEILLE'];
  static const List<String> validCategories = ['VISITEURS', 'INFORMATIONS', 'ANNONCES'];
  
  /// Vérifie si un statut est valide
  static bool isValidStatut(String statut) {
    return validStatuts.contains(statut.toUpperCase());
  }
  
  /// Vérifie si une catégorie est valide
  static bool isValidCategorie(String categorie) {
    return validCategories.contains(categorie.toUpperCase());
  }
}

/// Modèle pour les erreurs API
@JsonSerializable()
class ApiError {
  final String message;
  final int? code;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    this.code,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => 
      _$ApiErrorFromJson(json);
  
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}