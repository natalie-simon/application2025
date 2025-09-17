import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/profile_service.dart';
import '../../domain/models/profile.dart';

/// État du profil
class ProfileState {
  final Profile? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier pour la gestion du profil
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final Ref _ref;

  ProfileNotifier(this._profileService, this._ref) : super(const ProfileState()) {
    _loadCurrentProfile();
  }

  /// Chargement du profil actuel
  Future<void> _loadCurrentProfile() async {
    final authState = _ref.read(authProvider);
    if (authState.token == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Chargement du profil utilisateur', tag: 'PROFILE_PROVIDER');
      
      final profile = await _profileService.getCurrentProfile(authState.token!);
      
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      );

      AppLogger.info('Profil chargé: ${profile != null ? 'trouvé' : 'aucun profil'}', tag: 'PROFILE_PROVIDER');
    } catch (e) {
      AppLogger.error('Erreur lors du chargement du profil', error: e, tag: 'PROFILE_PROVIDER');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mise à jour du profil
  Future<void> updateProfile({
    required String nom,
    required String prenom,
    required String telephone,
    required bool communicationMail,
    required bool communicationSms,
    File? avatarFile,
  }) async {
    final authState = _ref.read(authProvider);
    if (authState.token == null) {
      throw Exception('Token d\'authentification manquant');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Mise à jour du profil', tag: 'PROFILE_PROVIDER');

      final updatedProfile = await _profileService.updateProfile(
        token: authState.token!,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        communicationMail: communicationMail,
        communicationSms: communicationSms,
        avatarFile: avatarFile,
      );

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );

      AppLogger.info('Profil mis à jour avec succès', tag: 'PROFILE_PROVIDER');
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du profil', error: e, tag: 'PROFILE_PROVIDER');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      rethrow;
    }
  }

  /// Upload d'avatar
  Future<void> uploadAvatar(File imageFile) async {
    final authState = _ref.read(authProvider);
    if (authState.token == null) {
      throw Exception('Token d\'authentification manquant');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Upload d\'avatar', tag: 'PROFILE_PROVIDER');

      final updatedProfile = await _profileService.uploadAvatar(
        token: authState.token!,
        imageFile: imageFile,
      );

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );

      AppLogger.info('Avatar uploadé avec succès', tag: 'PROFILE_PROVIDER');
    } catch (e) {
      AppLogger.error('Erreur lors de l\'upload d\'avatar', error: e, tag: 'PROFILE_PROVIDER');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      rethrow;
    }
  }

  /// Supprimer l'avatar
  Future<void> deleteAvatar() async {
    final authState = _ref.read(authProvider);
    if (authState.token == null) {
      throw Exception('Token d\'authentification manquant');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Suppression de l\'avatar', tag: 'PROFILE_PROVIDER');

      final updatedProfile = await _profileService.deleteAvatar(
        token: authState.token!,
      );

      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );

      AppLogger.info('Avatar supprimé avec succès', tag: 'PROFILE_PROVIDER');
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression de l\'avatar', error: e, tag: 'PROFILE_PROVIDER');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      
      rethrow;
    }
  }

  /// Rafraîchir le profil
  Future<void> refresh() async {
    await _loadCurrentProfile();
  }

  /// Vérifier si le profil est vide/incomplet
  bool get isProfileIncomplete {
    final profile = state.profile;
    return profile == null || profile.isEmpty || !profile.isComplete;
  }
}

/// Provider du service profil
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Provider principal du profil
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileNotifier(profileService, ref);
});

/// Provider pour vérifier si le profil est incomplet
final isProfileIncompleteProvider = Provider<bool>((ref) {
  final profileNotifier = ref.watch(profileProvider.notifier);
  return profileNotifier.isProfileIncomplete;
});