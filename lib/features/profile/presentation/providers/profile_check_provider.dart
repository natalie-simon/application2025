import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'profile_provider.dart';

/// Service pour gérer la vérification du profil après connexion
class ProfileCheckService {
  static bool _isChecking = false;

  static void checkProfileAfterLogin(BuildContext context, WidgetRef ref) {
    if (_isChecking) {
      AppLogger.debug('Vérification du profil déjà en cours, ignorer', tag: 'PROFILE_CHECK');
      return;
    }
    _isChecking = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Vérifier que le context est encore valide
        if (!context.mounted) {
          AppLogger.debug('Context non monté, annulation de la vérification du profil', tag: 'PROFILE_CHECK');
          _isChecking = false;
          return;
        }

        final authState = ref.read(authProvider);

        if (!authState.isAuthenticated) {
          AppLogger.debug('Utilisateur non authentifié, pas de vérification du profil', tag: 'PROFILE_CHECK');
          _isChecking = false;
          return;
        }

        AppLogger.info('Vérification du profil après connexion', tag: 'PROFILE_CHECK');

        // Attendre que le profil soit chargé (avec timeout)
        int attempts = 0;
        const maxAttempts = 20; // 2 secondes max
        const delayMs = 100;

        ProfileState profileState;
        do {
          profileState = ref.read(profileProvider);
          if (profileState.profile != null || !profileState.isLoading) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: delayMs));
          attempts++;
        } while (attempts < maxAttempts);

        // Si pas de profil chargé après le timeout, considérer comme incomplet
        bool isIncomplete = profileState.profile == null;

        // Si nous avons un profil, vérifier s'il est complet
        if (profileState.profile != null) {
          isIncomplete = profileState.profile!.isEmpty || !profileState.profile!.isComplete;
        }

        AppLogger.debug('État du profil: incomplete=$isIncomplete, profil=${profileState.profile != null}, attempts=$attempts', tag: 'PROFILE_CHECK');

        if (isIncomplete) {
          AppLogger.info('Profil incomplet détecté, redirection vers l\'écran de configuration', tag: 'PROFILE_CHECK');

          if (context.mounted) {
            // Utiliser pushReplacement pour éviter que l'utilisateur puisse revenir en arrière
            context.pushReplacement('/profile/edit?setup=true');
          }
        } else {
          AppLogger.info('Profil complet, redirection vers les activités', tag: 'PROFILE_CHECK');

          if (context.mounted) {
            // Rediriger vers l'agenda des activités si le profil est complet
            context.pushReplacement('/activities');
          }
        }
      } catch (e) {
        AppLogger.error('Erreur lors de la vérification du profil', error: e, tag: 'PROFILE_CHECK');
      } finally {
        _isChecking = false;
      }
    });
  }
}

/// Provider pour vérifier automatiquement le profil
final profileCheckProvider = Provider<ProfileCheckService>((ref) {
  return ProfileCheckService();
});