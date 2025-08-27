import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// Configuration des routes de l'application
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      // Si pas connecté et pas sur la page de login, rediriger vers login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Si connecté et sur la page de login, rediriger vers home
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      // Sinon, laisser la navigation normale
      return null;
    },
    routes: [
      // Route de connexion
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Route d'accueil (protégée)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
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
}