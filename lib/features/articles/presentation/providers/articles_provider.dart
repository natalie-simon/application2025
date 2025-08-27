import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
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
      AppLogger.info('Chargement des articles d\'accueil', tag: 'ARTICLES_PROVIDER');

      // Charger depuis l'API
      final articles = await _articlesService.getHomeArticles();

      state = state.copyWith(
        articles: articles,
        isLoading: false,
        error: null,
        totalRecords: articles.length,
      );

      AppLogger.info('${articles.length} articles chargés depuis l\'API', tag: 'ARTICLES_PROVIDER');
    } catch (e) {
      AppLogger.error('Erreur chargement articles API', tag: 'ARTICLES_PROVIDER', error: e);

      state = state.copyWith(
        articles: [],
        isLoading: false,
        error: 'Impossible de charger les articles: ${e.toString()}',
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

/// Provider pour la navigation entre articles
final articleNavigationProvider = Provider.family<ArticleNavigation, int>((ref, currentArticleId) {
  final articlesState = ref.watch(articlesProvider);
  final articles = articlesState.articles;
  
  if (articles.isEmpty) {
    return const ArticleNavigation();
  }
  
  final currentIndex = articles.indexWhere((article) => article.id == currentArticleId);
  
  if (currentIndex == -1) {
    return const ArticleNavigation();
  }
  
  final hasPrevious = currentIndex > 0;
  final hasNext = currentIndex < articles.length - 1;
  
  return ArticleNavigation(
    previousArticle: hasPrevious ? articles[currentIndex - 1] : null,
    nextArticle: hasNext ? articles[currentIndex + 1] : null,
    currentIndex: currentIndex,
    totalArticles: articles.length,
  );
});

/// Classe pour la navigation entre articles
class ArticleNavigation {
  final Article? previousArticle;
  final Article? nextArticle;
  final int currentIndex;
  final int totalArticles;
  
  const ArticleNavigation({
    this.previousArticle,
    this.nextArticle,
    this.currentIndex = 0,
    this.totalArticles = 0,
  });
  
  bool get hasPrevious => previousArticle != null;
  bool get hasNext => nextArticle != null;
}