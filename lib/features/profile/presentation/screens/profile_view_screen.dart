import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/assbt_button.dart';
import '../providers/profile_provider.dart';

class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/profile/edit');
            },
            tooltip: 'Modifier le profil',
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.profile == null
              ? _buildEmptyProfile(context, theme)
              : _buildProfileContent(context, theme, profileState.profile!),
    );
  }

  Widget _buildEmptyProfile(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Profil non configuré',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre profil n\'est pas encore configuré.\nCliquez sur le bouton ci-dessous pour le compléter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            AssbtButton(
              text: 'Configurer mon profil',
              onPressed: () => context.go('/profile/edit?setup=true'),
              icon: const Icon(Icons.person_add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ThemeData theme, profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar et nom
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: profile.avatarId != null
                      ? ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.displayName.isNotEmpty 
                      ? profile.displayName 
                      : 'Nom non défini',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Informations personnelles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informations personnelles',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    context,
                    icon: Icons.badge_outlined,
                    label: 'Nom',
                    value: profile.nom ?? 'Non défini',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    context,
                    icon: Icons.person_outline,
                    label: 'Prénom',
                    value: profile.prenom ?? 'Non défini',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: profile.telephone ?? 'Non défini',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Préférences de communication
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Préférences de communication',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildPreferenceRow(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Notifications par email',
                    isEnabled: profile.communicationMail,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildPreferenceRow(
                    context,
                    icon: Icons.sms_outlined,
                    label: 'Notifications par SMS',
                    isEnabled: profile.communicationSms,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Bouton de modification
          AssbtButton(
            text: 'Modifier mon profil',
            onPressed: () => context.go('/profile/edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceRow(BuildContext context, {
    required IconData icon,
    required String label,
    required bool isEnabled,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.success : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isEnabled ? 'Activé' : 'Désactivé',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isEnabled ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}