import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/models/article.dart';

class ArticlesService {
  late final Dio _dio;

  ArticlesService() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.articlesUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
    ));

    if (EnvConfig.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('🌐 API: $obj'),
      ));
    }
  }

  /// Charge les articles par catégorie avec pagination (comme l'app Vue.js)
  Future<List<Article>> getArticlesByCategorie(
    String categorie, {
    int page = 1,
    int limit = 9,
  }) async {
    try {
      if (EnvConfig.enableLogging) {
        debugPrint('🔄 Chargement des articles catégorie: $categorie (page: $page, limit: $limit)');
      }

      // Construire l'URL selon la structure Vue.js : /categorie/visiteurs
      final endpoint = '/categorie/$categorie';
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _dio.get(endpoint, queryParameters: params);

      if (EnvConfig.enableLogging) {
        debugPrint('📡 Réponse API articles: ${response.statusCode}');
        debugPrint('📄 Données reçues: ${response.data}');
      }

      // La réponse peut être un objet avec data/meta ou directement un array
      List<dynamic> articlesList;
      
      if (response.data is Map<String, dynamic>) {
        // Si la réponse a une structure avec data
        if (response.data.containsKey('data')) {
          articlesList = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Format de réponse API inattendu - structure sans data');
        }
      } else if (response.data is List) {
        // Réponse directe avec liste d'articles
        articlesList = response.data as List<dynamic>;
      } else {
        throw Exception('Format de réponse API inattendu - attendu: List ou Object avec data, reçu: ${response.data.runtimeType}');
      }

      final articles = articlesList
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList(); // Pour l'instant on prend tous les articles, on pourra filtrer plus tard

      if (EnvConfig.enableLogging) {
        debugPrint('✅ ${articles.length} articles chargés');
        if (articles.isEmpty) {
          debugPrint('⚠️ Aucun article trouvé dans la catégorie $categorie');
        }
      }

      return articles;
    } on DioException catch (e) {
      if (EnvConfig.enableLogging) {
        debugPrint('❌ Erreur DioException: ${e.type}');
        debugPrint('📄 Détails erreur: ${e.response?.data ?? e.message}');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 0;
        final errorMessage = e.response!.data?['message'] ?? 
                           e.response!.data?.toString() ?? 
                           'Erreur serveur';
        throw ArticlesServiceException(
          'Erreur serveur ($statusCode): $errorMessage',
          statusCode,
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw const ArticlesServiceException(
          'Délai de connexion dépassé - Vérifiez votre connexion internet',
          0,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const ArticlesServiceException(
          'Impossible de se connecter au serveur - Vérifiez votre connexion',
          0,
        );
      } else {
        throw ArticlesServiceException(
          'Erreur de configuration: ${e.message}',
          0,
        );
      }
    } catch (e) {
      if (EnvConfig.enableLogging) {
        debugPrint('❌ Erreur générale: $e');
      }
      throw ArticlesServiceException('Erreur inattendue: $e', 0);
    }
  }

  /// Charge les articles pour la page d'accueil (catégorie 'visiteurs' pour la landing page)
  Future<List<Article>> getHomeArticles() {
    return getArticlesByCategorie('visiteurs', page: 1, limit: 6);
  }

  /// Charge les articles d'informations
  Future<List<Article>> getInformationArticles() {
    return getArticlesByCategorie('informations');
  }

  /// Charge les articles d'annonces
  Future<List<Article>> getAnnouncementArticles() {
    return getArticlesByCategorie('annonces');
  }

  /// Charge un article spécifique par son ID
  Future<Article> getArticleById(int id) async {
    try {
      if (EnvConfig.enableLogging) {
        debugPrint('🔄 Chargement article ID: $id');
      }

      final response = await _dio.get('/$id');
      
      if (EnvConfig.enableLogging) {
        debugPrint('📡 Article reçu: ${response.statusCode}');
      }

      return Article.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ArticlesServiceException('Article non trouvé', 404);
      }
      rethrow;
    }
  }
}

/// Exception personnalisée pour les erreurs du service Articles
class ArticlesServiceException implements Exception {
  final String message;
  final int statusCode;

  const ArticlesServiceException(this.message, this.statusCode);

  @override
  String toString() => 'ArticlesServiceException: $message';
}