import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/assbt_card.dart';
import '../../../../shared/widgets/article_slider.dart';
import '../../../../shared/widgets/article_card.dart';
import '../../../../shared/widgets/article_carousel.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../articles/presentation/providers/articles_provider.dart';
import '../../../articles/domain/models/article.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les articles au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articlesProvider.notifier).loadHomeArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Fond identique au bandeau
      appBar: AppBar(
        title: const Text('ASSBT'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec logo et titre
            _buildHeader(context),
            
            // Section principale avec fond blanc
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Section info membres (remplace connexion)
                    _buildMemberInfoSection(context),
                    const SizedBox(height: 32),
                    
                    // Actualités
                    _buildNewsSection(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Logo du club ASSBT
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(46),
              child: Image.asset(
                'assets/images/logo/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ASSBT',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Association Sportive et Sociale\ndes Bulleurs Toulonnais',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textShine,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header du drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ASSBT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Les Bulleurs Toulonnais',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textShine,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                
                // Section Membre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ESPACE MEMBRE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                ListTile(
                  leading: const Icon(Icons.login, color: AppColors.primary),
                  title: const Text('Se connecter'),
                  subtitle: const Text('Accès membres ASSBT'),
                  onTap: () {
                    Navigator.pop(context);
                    _showLoginDialog(context);
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.person_add, color: AppColors.primary),
                  title: const Text('Créer un compte'),
                  subtitle: const Text('Nouveau membre'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRegisterDialog(context);
                  },
                ),
                
                const Divider(height: 32),
                
                // Section Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'NAVIGATION',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                ListTile(
                  leading: const Icon(Icons.home, color: AppColors.primary),
                  title: const Text('Accueil'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.article, color: AppColors.primary),
                  title: const Text('Toutes les actualités'),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Actualités');
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: const Text('À propos'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.contact_mail, color: AppColors.primary),
                  title: const Text('Contact'),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Contact');
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'ASSBT © 2025',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations membres',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        AssbtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejoignez l\'ASSBT',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Découvrez la plongée avec les Bulleurs Toulonnais. Formations, sorties et convivialité au rendez-vous !',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '💡 Membres ASSBT : utilisez le menu ☰ pour vous connecter',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSection(BuildContext context) {
    final articlesState = ref.watch(articlesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actualités',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if (articlesState.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Gestion des états de chargement et d'erreur
        if (articlesState.error != null)
          _buildErrorState(context, articlesState.error!)
        else if (articlesState.articles.isEmpty && !articlesState.isLoading)
          _buildEmptyState(context)
        else if (articlesState.articles.isNotEmpty)
          ArticleCarousel(
            articles: articlesState.articles,
            autoPlayDuration: const Duration(seconds: 4),
            height: 350,
            onArticleTap: (article) => _showArticleComingSoon(context),
          )
        else
          _buildLoadingState(context),
      ],
    );
  }

  Widget _buildArticlesList(BuildContext context, List<Article> articles) {
    if (articles.isEmpty) return _buildEmptyState(context);
    
    return Column(
      children: [
        // Article en vedette (premier de la liste)
        if (articles.isNotEmpty)
          FeaturedArticle(
            article: articles.first,
            onTap: (article) => _showArticleComingSoon(context),
          ),
        const SizedBox(height: 24),
        
        // Articles récents en slider horizontal
        if (articles.length > 1)
          ArticleSlider(
            articles: articles.skip(1).toList(),
            title: 'Articles récents',
            cardType: ArticleCardType.medium,
            cardWidth: 260,
            cardHeight: 280,
            onArticleTap: (article) => _showArticleComingSoon(context),
            onSeeAll: () => _showComingSoon(context, 'Tous les articles'),
          ),
      ],
    );
  }

  Widget _buildSimpleArticlesList(BuildContext context, List<Article> articles) {
    if (articles.isEmpty) return _buildEmptyState(context);
    
    return Column(
      children: articles.map((article) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AssbtCard(
          onTap: () => _showArticleComingSoon(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                article.titre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Contenu (sans HTML)
              Text(
                article.contenu.replaceAll(RegExp(r'<[^>]*>'), ''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: article.statut == 'PUBLIE' 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.statut == 'PUBLIE' ? 'Publié' : 'Brouillon',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: article.statut == 'PUBLIE' 
                        ? AppColors.success 
                        : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return AssbtCard(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(articlesProvider.notifier).loadHomeArticles(forceRefresh: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AssbtCard(
      child: Column(
        children: [
          const Icon(
            Icons.article_outlined,
            color: AppColors.grey400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun article disponible',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les actualités ASSBT apparaîtront ici dès qu\'elles seront publiées.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: AssbtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }



  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} semaine${difference.inDays ~/ 7 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Récemment';
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.login, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Connexion Membre'),
          ],
        ),
        content: const Text('La fonctionnalité de connexion sera bientôt disponible.\n\nVous pourrez vous connecter avec vos identifiants ASSBT pour accéder à votre espace personnel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_add, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Créer un compte'),
          ],
        ),
        content: const Text('La création de compte membre sera bientôt disponible.\n\nVous pourrez créer votre compte ASSBT pour rejoindre la communauté des Bulleurs Toulonnais.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('À propos d\'ASSBT'),
          ],
        ),
        content: const Text('Association Sportive et Sociale des Bulleurs Toulonnais\n\nClub de plongée sous-marine fondé à Toulon, dédié à la découverte des fonds marins méditerranéens.\n\nFormations, sorties plongée et convivialité depuis de nombreuses années.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('La section $feature sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showArticleComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Article'),
        content: const Text('L\'affichage des articles sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}