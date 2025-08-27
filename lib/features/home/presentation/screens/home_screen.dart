import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/article_carousel.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../articles/presentation/providers/articles_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAuthenticated = authState.isAuthenticated;
    
    // Charger les articles au démarrage
    final articlesState = ref.watch(articlesProvider);
    
    // Charger les articles si pas encore fait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (articlesState.articles.isEmpty && !articlesState.isLoading && articlesState.error == null) {
        ref.read(articlesProvider.notifier).loadHomeArticles();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ASSBT'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textShine,
        actions: [
          // Indicateur de statut de connexion
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAuthenticated ? Icons.check_circle : Icons.person_outline,
                  color: isAuthenticated ? Colors.green : AppColors.textShine.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isAuthenticated ? 'Connecté' : 'Invité',
                  style: TextStyle(
                    color: isAuthenticated ? Colors.green : AppColors.textShine.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(articlesProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header avec logo et titre
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Logo ASSBT
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.waves,
                              size: 40,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      isAuthenticated 
                        ? 'Bienvenue dans ASSBT !' 
                        : 'Découvrez ASSBT !',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Association Sportive de Subaquatique du Bassin Toulonnais',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    
                    // Info utilisateur connecté
                    if (isAuthenticated && user != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connecté en tant que ${user.roleDisplayName}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Carousel d'articles
              const SizedBox(height: 16),
              if (articlesState.isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ] else if (articlesState.error != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Impossible de charger les articles',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            articlesState.error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.read(articlesProvider.notifier).refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textShine,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (articlesState.articles.isNotEmpty) ...[
                ArticleCarousel(
                  articles: articlesState.articles,
                  height: 250,
                  onArticleTap: (article) {
                    // Naviguer vers la page de l'article
                    context.go('/article/${article.id}');
                  },
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun article disponible',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Section informations complémentaires
              const SizedBox(height: 32),
              
              if (!isAuthenticated) ...[
                // Message d'invitation à se connecter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.login,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Mode Invité',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connectez-vous depuis le menu pour accéder à toutes les fonctionnalités de l\'association.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) => ElevatedButton.icon(
                              onPressed: () => Scaffold.of(context).openDrawer(),
                              icon: const Icon(Icons.menu),
                              label: const Text('Ouvrir le menu'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textShine,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  children: [
                    Text(
                      '🚧 Application en cours de développement 🚧',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Prochaines fonctionnalités :\n• Module Membres\n• Gestion des articles\n• Profil utilisateur',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}