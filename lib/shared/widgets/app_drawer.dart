import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/widgets/login_form.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAuthenticated = authState.isAuthenticated;

    return Drawer(
      child: Column(
        children: [
          // Header du drawer
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.dark],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ASSBT
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(
                      color: AppColors.textShine,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 76,
                      height: 76,
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
                  'ASSBT',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textShine,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu du drawer
          Expanded(
            child: isAuthenticated 
              ? _buildAuthenticatedDrawer(context, ref, user!)
              : _buildUnauthenticatedDrawer(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedDrawer(BuildContext context, WidgetRef ref, user) {
    return Column(
      children: [
        // Informations utilisateur
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.textShine.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    user.isAdmin
                        ? Icons.admin_panel_settings
                        : user.isRedacteur
                            ? Icons.edit
                            : Icons.person,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user.roleDisplayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Menu items
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.home, color: AppColors.primary),
                title: const Text('Accueil'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/');
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Activités'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/activities');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.primary),
                title: const Text('Mon Profil'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil - À implémenter')),
                  );
                },
              ),
              if (user.isAdmin) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.people, color: AppColors.primary),
                  title: const Text('Membres'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membres - À implémenter')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article, color: AppColors.primary),
                  title: const Text('Articles'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Articles - À implémenter')),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        
        // Bouton déconnexion
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          onTap: () => _showLogoutDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedDrawer(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Message de bienvenue
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.textShine.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue !',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connectez-vous pour accéder à toutes les fonctionnalités.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        
        // Formulaire de connexion
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const LoginForm(),
                const SizedBox(height: 16),
                Text(
                  'ou naviguez en mode invité',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('À propos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('À propos - À implémenter')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Fermer le drawer
              ref.read(authProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}