import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/articles/presentation/screens/article_detail_screen.dart';
import '../../features/activities/presentation/screens/activities_screen.dart';

/// Configuration des routes de l'application
final appRouterProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      // Route d'accueil (accessible à tous)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Route d'article détaillé
      GoRoute(
        path: '/article/:id',
        name: 'article',
        builder: (context, state) {
          final idString = state.pathParameters['id']!;
          final id = int.parse(idString);
          return ArticleDetailScreen(articleId: id);
        },
      ),
      
      // Route des activités
      GoRoute(
        path: '/activities',
        name: 'activities',
        builder: (context, state) => const ActivitiesScreen(),
      ),
      
      // Routes futures (commentées pour l'instant)
      /*
      GoRoute(
        path: '/members',
        name: 'members',
        builder: (context, state) => const MembersListScreen(),
      ),
      
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      */
    ],
    
    // Gestion des erreurs de navigation
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La route "${state.matchedLocation}" n\'existe pas.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Extension pour faciliter la navigation
extension AppRouterExtension on GoRouter {
  /// Navigation vers l'écran de login
  void goToLogin() => go('/login');
  
  /// Navigation vers l'écran d'accueil
  void goToHome() => go('/');
  
  /// Déconnexion (va automatiquement vers login grâce au redirect)
  void logout() => go('/login');
  
  /// Navigation vers un article
  void goToArticle(int articleId) => go('/article/$articleId');
  
  /// Navigation vers les activités
  void goToActivities() => go('/activities');
}