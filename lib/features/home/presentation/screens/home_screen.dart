import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/assbt_card.dart';
import '../../../../shared/widgets/assbt_button.dart';
import '../../../../shared/widgets/article_carousel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../articles/presentation/providers/articles_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASSBT'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            const SizedBox(height: 16),
            
            // Articles Carousel
            _buildArticlesCarousel(context, ref),
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 24),
            
            // Main Features
            _buildMainFeatures(context),
            const SizedBox(height: 24),
            
            // Recent Activity
            _buildRecentActivity(context),
            
            // Espace supplémentaire pour assurer le scroll
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return AssbtCard(
      child: Column(
        children: [
          // Logo placeholder
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waves,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bienvenue sur ASSBT',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Association Sportive et Sociale des Bulleurs Toulonnais',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AssbtButton(
                text: 'Voir les membres',
                icon: const Icon(Icons.people),
                onPressed: () {
                  // TODO: Navigate to members
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AssbtButton(
                text: 'Calendrier',
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // TODO: Navigate to calendar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonctionnalités principales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          context,
          icon: Icons.people_outline,
          title: 'Annuaire des membres',
          subtitle: 'Consultez la liste complète des membres ASSBT',
          onTap: () {
            // TODO: Navigate to members directory
          },
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context,
          icon: Icons.event,
          title: 'Activités & Événements',
          subtitle: 'Découvrez les prochaines sorties et événements',
          onTap: () {
            // TODO: Navigate to activities
          },
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context,
          icon: Icons.article,
          title: 'Articles & Actualités',
          subtitle: 'Restez informé des dernières nouvelles',
          onTap: () {
            // TODO: Navigate to articles
          },
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context,
          icon: Icons.person,
          title: 'Mon profil',
          subtitle: 'Gérez vos informations personnelles',
          onTap: () {
            // TODO: Navigate to profile
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AssbtListCard(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        AssbtCard(
          child: Column(
            children: [
              _buildActivityItem(
                context,
                icon: Icons.people_alt,
                title: 'Nouveau membre',
                subtitle: 'Jean Dupont a rejoint ASSBT',
                time: 'Il y a 2 heures',
              ),
              const Divider(),
              _buildActivityItem(
                context,
                icon: Icons.event,
                title: 'Prochaine sortie',
                subtitle: 'Sortie plongée aux îles d\'Hyères',
                time: 'Demain 9h00',
              ),
              const Divider(),
              _buildActivityItem(
                context,
                icon: Icons.article,
                title: 'Nouvel article',
                subtitle: 'Compte-rendu de la dernière AG',
                time: 'Il y a 1 jour',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesCarousel(BuildContext context, WidgetRef ref) {
    final articlesState = ref.watch(articlesProvider);
    
    return articlesState.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const SizedBox.shrink();
        }
        return ArticleCarousel(
          articles: articles,
          height: 180,
          onArticleTap: (article) {
            // TODO: Navigate to article detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Article: ${article.titre}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
      loading: () => Container(
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Erreur de chargement des articles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}