import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../domain/models/article.dart';
import '../providers/articles_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final int articleId;
  
  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleByIdProvider(articleId));
    final navigation = ref.watch(articleNavigationProvider(articleId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (navigation.totalArticles > 1) ...[
            Text(
              '${navigation.currentIndex + 1}/${navigation.totalArticles}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      drawer: const AppDrawer(),
      body: articleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) {
          AppLogger.error('Erreur lors du chargement de l\'article $articleId', 
                         tag: 'ARTICLE_DETAIL', error: error);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur lors du chargement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(articleByIdProvider(articleId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        },
        data: (article) => _buildArticleContent(context, article),
      ),
      bottomNavigationBar: _buildNavigationBar(context, ref, navigation),
    );
  }

  Widget _buildArticleContent(BuildContext context, Article article) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de l'article
          if (article.image?.url != null)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.image?.url ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey300,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Titre
          Text(
            article.titre,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Métadonnées
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                article.redacteur?.email ?? 'Auteur inconnu',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.category,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                article.categorie.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contenu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.grey300,
                width: 1,
              ),
            ),
            child: Text(
              // Nettoyer le HTML basique pour l'affichage
              article.contenu.replaceAll(RegExp(r'<[^>]*>'), ''),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context, WidgetRef ref, ArticleNavigation navigation) {
    if (!navigation.hasPrevious && !navigation.hasNext) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey300,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton retour à l'accueil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.home, size: 16),
                label: const Text('Retour à l\'accueil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Navigation entre articles
            if (navigation.hasPrevious || navigation.hasNext)
              Row(
                children: [
                  // Bouton Article précédent
                  Expanded(
                    child: navigation.hasPrevious
                        ? ElevatedButton.icon(
                            onPressed: () {
                              context.go('/article/${navigation.previousArticle!.id}');
                            },
                            icon: const Icon(Icons.arrow_back_ios, size: 16),
                            label: Text(
                              'Précédent',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              elevation: 0,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Bouton Article suivant
                  Expanded(
                    child: navigation.hasNext
                        ? ElevatedButton.icon(
                            onPressed: () {
                              context.go('/article/${navigation.nextArticle!.id}');
                            },
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            label: Text(
                              'Suivant',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}