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
      if (kDebugMode) {
        debugPrint('❌ Erreur chargement articles API, utilisation du fallback: $e');
      }

      // Utiliser des articles de démonstration en cas d'erreur réseau
      final fallbackArticles = [
        const Article(
          id: 1,
          titre: "Sortie plongée aux îles d'Hyères",
          contenu: "<p>Une magnifique sortie plongée est organisée le week-end prochain aux îles d'Hyères. Venez découvrir les fonds marins exceptionnels de la région!</p><p>Rendez-vous à 8h au port de Toulon.</p>",
          statut: "PUBLIE",
          categorie: "VISITEURS",
          image: ArticleImage(url: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=600&fit=crop"),
          redacteur: ArticleRedacteur(email: "demo@assbt.fr"),
        ),
        const Article(
          id: 2,
          titre: "Assemblée générale 2025",
          contenu: "<p>L'assemblée générale annuelle de l'ASSBT aura lieu le mois prochain. Tous les membres sont invités à y participer pour découvrir le bilan de l'année et les projets à venir.</p><p>Date : 15 février 2025 à 19h</p>",
          statut: "PUBLIE",
          categorie: "VISITEURS",
          image: ArticleImage(url: "https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=600&fit=crop"),
          redacteur: ArticleRedacteur(email: "demo@assbt.fr"),
        ),
        const Article(
          id: 3,
          titre: "Nouveau matériel de plongée",
          contenu: "<p>L'association vient d'acquérir du nouveau matériel de plongée de dernière génération. Les membres peuvent désormais bénéficier d'équipements de qualité supérieure.</p><p>Réservations au local tous les mardis soirs.</p>",
          statut: "PUBLIE",
          categorie: "VISITEURS",
          image: ArticleImage(url: "https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800&h=600&fit=crop"),
          redacteur: ArticleRedacteur(email: "demo@assbt.fr"),
        ),
      ];

      state = state.copyWith(
        articles: fallbackArticles,
        isLoading: false,
        error: null, // Pas d'erreur visible, on utilise le fallback
        totalRecords: fallbackArticles.length,
      );

      if (kDebugMode) {
        debugPrint('✅ ${fallbackArticles.length} articles de démonstration chargés');
      }
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