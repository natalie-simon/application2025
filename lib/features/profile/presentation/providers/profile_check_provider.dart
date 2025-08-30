import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'profile_provider.dart';

/// Service pour gérer la vérification du profil après connexion
class ProfileCheckService {
  static void checkProfileAfterLogin(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Vérifier que le context est encore valide
      if (!context.mounted) {
        AppLogger.debug('Context non monté, annulation de la vérification du profil', tag: 'PROFILE_CHECK');
        return;
      }
      
      final authState = ref.read(authProvider);
      
      if (!authState.isAuthenticated) {
        AppLogger.debug('Utilisateur non authentifié, pas de vérification du profil', tag: 'PROFILE_CHECK');
        return;
      }

      AppLogger.info('Vérification du profil après connexion', tag: 'PROFILE_CHECK');

      try {
        // Vérification immédiate sans JWT profil dans le token
        final profileState = ref.read(profileProvider);
        
        // Si pas de profil chargé, considérer comme incomplet
        bool isIncomplete = profileState.profile == null;
        
        // Si nous avons un profil, vérifier s'il est complet
        if (profileState.profile != null) {
          isIncomplete = profileState.profile!.isEmpty || !profileState.profile!.isComplete;
        }

        AppLogger.debug('État du profil: incomplete=$isIncomplete, profil=${profileState.profile != null}', tag: 'PROFILE_CHECK');

        if (isIncomplete) {
          AppLogger.info('Profil incomplet détecté, redirection vers l\'écran de configuration', tag: 'PROFILE_CHECK');
          
          if (context.mounted) {
            // Utiliser pushReplacement pour éviter que l'utilisateur puisse revenir en arrière
            context.pushReplacement('/profile/edit?setup=true');
          }
        } else {
          AppLogger.info('Profil complet, aucune action requise', tag: 'PROFILE_CHECK');
        }
      } catch (e) {
        AppLogger.error('Erreur lors de la vérification du profil', error: e, tag: 'PROFILE_CHECK');
      }
    });
  }
}

/// Provider pour vérifier automatiquement le profil
final profileCheckProvider = Provider<ProfileCheckService>((ref) {
  return ProfileCheckService();
});