import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/articles_service.dart';
import '../../domain/models/article.dart';

/// État des articles
class ArticlesState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalRecords;
  final String? searchQuery;

  const ArticlesState({
    this.articles = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalRecords = 0,
    this.searchQuery,
  });

  ArticlesState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalRecords,
    String? searchQuery,
  }) {
    return ArticlesState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalRecords: totalRecords ?? this.totalRecords,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Provider du service Articles
final articlesServiceProvider = Provider<ArticlesService>((ref) {
  return ArticlesService();
});

/// Notifier pour la gestion des articles visiteurs
class ArticlesNotifier extends StateNotifier<ArticlesState> {
  final ArticlesService _articlesService;

  ArticlesNotifier(this._articlesService) : super(const ArticlesState());

  /// Charge les articles d'accueil pour la landing page
  Future<void> loadHomeArticles({bool forceRefresh = false}) async {
    if (forceRefresh || state.articles.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      if (kDebugMode) {
        debugPrint('🔄 Chargement des articles d\'accueil...');
      }

      // Charger depuis l'API uniquement
      final articles = await _articlesService.getHomeArticles();

      state = state.copyWith(
        articles: articles,
        isLoading: false,
        error: null,
        totalRecords: articles.length,
      );

      if (kDebugMode) {
        debugPrint('✅ ${articles.length} articles chargés depuis l\'API');
      }
    } catch (e) {
      String errorMessage = 'Erreur inconnue';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Pas de connexion internet disponible';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Délai de connexion dépassé';
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage = 'Erreur de certificat SSL';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Serveur indisponible';
      } else {
        errorMessage = 'Erreur réseau: ${e.toString()}';
      }

      if (kDebugMode) {
        debugPrint('❌ Erreur chargement articles API: $e');
        debugPrint('📱 Message d\'erreur: $errorMessage');
      }

      state = state.copyWith(
        articles: [],
        isLoading: false,
        error: errorMessage,
        totalRecords: 0,
      );
    }
  }

  /// Recharge les articles (pull-to-refresh)
  Future<void> refresh() async {
    await loadHomeArticles(forceRefresh: true);
  }

  /// Efface l'erreur
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Provider principal des articles visiteurs
final articlesProvider = StateNotifierProvider<ArticlesNotifier, ArticlesState>((ref) {
  final service = ref.watch(articlesServiceProvider);
  return ArticlesNotifier(service);
});

/// Provider pour un article spécifique
final articleByIdProvider = FutureProvider.family<Article, int>((ref, id) async {
  final service = ref.watch(articlesServiceProvider);
  return service.getArticleById(id);
});