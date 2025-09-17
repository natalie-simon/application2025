import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/utils/logger.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/user.dart';

/// Clés de stockage sécurisé
class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'auth_user';
  static const String savedEmail = 'saved_email';
  static const String savedPassword = 'saved_password';
  static const String rememberMe = 'remember_me';
}

/// État d'authentification
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier pour la gestion de l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier(this._authService, this._secureStorage) : super(const AuthState()) {
    _loadStoredAuth();
  }

  /// Chargement des données d'authentification stockées
  Future<void> _loadStoredAuth() async {
    AppLogger.info('Chargement des données d\'authentification stockées', tag: 'AUTH_PROVIDER');

    try {
      final storedToken = await _secureStorage.read(key: StorageKeys.token);
      final storedUserJson = await _secureStorage.read(key: StorageKeys.user);

      if (storedToken != null && storedUserJson != null) {
        // Validation du token (optionnel)
        final isValid = await _authService.validateToken(storedToken);
        
        if (isValid) {
          final userMap = Map<String, dynamic>.from(
            Map.from(Uri.splitQueryString(storedUserJson))
          );
          final user = User.fromJson(userMap);

          state = state.copyWith(
            user: user,
            token: storedToken,
            isAuthenticated: true,
          );

          AppLogger.auth('Authentification automatique réussie', email: user.email);
        } else {
          // Token invalide, nettoyage
          await _clearStoredAuth();
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement de l\'authentification', tag: 'AUTH_PROVIDER', error: e);
      await _clearStoredAuth();
    }
  }

  /// Chargement des identifiants sauvegardés
  Future<SavedCredentials?> loadSavedCredentials() async {
    try {
      AppLogger.info('Tentative de chargement des identifiants sauvegardés', tag: 'AUTH_PROVIDER');
      
      final rememberMe = await _secureStorage.read(key: StorageKeys.rememberMe);
      AppLogger.debug('RememberMe status: $rememberMe', tag: 'AUTH_PROVIDER');
      
      if (rememberMe != 'true') {
        AppLogger.info('Aucun identifiant à charger (rememberMe: $rememberMe)', tag: 'AUTH_PROVIDER');
        return null;
      }

      final email = await _secureStorage.read(key: StorageKeys.savedEmail);
      final password = await _secureStorage.read(key: StorageKeys.savedPassword);
      
      AppLogger.debug('Identifiants trouvés - Email: ${email != null ? "***@${email.split('@').last}" : "null"}, Password: ${password != null ? "****" : "null"}', tag: 'AUTH_PROVIDER');

      if (email != null && password != null) {
        AppLogger.info('Identifiants sauvegardés chargés avec succès pour: ***@${email.split('@').last}', tag: 'AUTH_PROVIDER');
        return SavedCredentials(email: email, password: password);
      } else {
        AppLogger.warning('Identifiants incomplets trouvés dans le stockage', tag: 'AUTH_PROVIDER');
      }
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des identifiants sauvegardés', tag: 'AUTH_PROVIDER', error: e);
    }
    
    AppLogger.info('Aucun identifiant valide trouvé', tag: 'AUTH_PROVIDER');
    return null;
  }

  /// Sauvegarde des identifiants
  Future<void> saveCredentials(String email, String password, bool remember) async {
    try {
      AppLogger.info('Tentative de sauvegarde des identifiants - Remember: $remember, Email: ***@${email.split('@').last}', tag: 'AUTH_PROVIDER');
      
      if (remember) {
        await _secureStorage.write(key: StorageKeys.savedEmail, value: email);
        await _secureStorage.write(key: StorageKeys.savedPassword, value: password);
        await _secureStorage.write(key: StorageKeys.rememberMe, value: 'true');
        
        AppLogger.info('Identifiants sauvegardés avec succès pour: ***@${email.split('@').last}', tag: 'AUTH_PROVIDER');
      } else {
        AppLogger.info('Suppression des identifiants sauvegardés (remember=false)', tag: 'AUTH_PROVIDER');
        await _clearSavedCredentials();
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la sauvegarde des identifiants', tag: 'AUTH_PROVIDER', error: e);
    }
  }

  /// Suppression des identifiants sauvegardés
  Future<void> _clearSavedCredentials() async {
    AppLogger.info('Suppression des identifiants sauvegardés du stockage sécurisé', tag: 'AUTH_PROVIDER');
    
    await _secureStorage.delete(key: StorageKeys.savedEmail);
    await _secureStorage.delete(key: StorageKeys.savedPassword);
    await _secureStorage.delete(key: StorageKeys.rememberMe);
    
    AppLogger.debug('Identifiants sauvegardés supprimés avec succès', tag: 'AUTH_PROVIDER');
  }

  /// Connexion utilisateur
  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.auth('Tentative de connexion', email: email);

      final loginRequest = LoginRequest(email: email, password: password);
      final authResponse = await _authService.signIn(loginRequest);

      // Décoder le JWT pour extraire les informations utilisateur
      final decodedToken = JwtDecoder.decode(authResponse.token);
      
      // Créer un User à partir des données du JWT
      final userRole = _parseUserRole(decodedToken['role'] as String?);
      final userId = (decodedToken['sub'] as num?)?.toInt() ?? 0;
      
      // Extraire le profil depuis le JWT
      String? prenom;
      String? nom;
      
      if (decodedToken['profil'] != null) {
        final profil = decodedToken['profil'] as Map<String, dynamic>;
        prenom = profil['prenom'] as String?;
        nom = profil['nom'] as String?;
        AppLogger.info('Profil extrait du JWT: $prenom $nom', tag: 'AUTH_PROVIDER');
      }

      // Créer l'utilisateur avec les données du profil JWT
      final finalUser = User(
        id: userId,
        email: decodedToken['email'] as String? ?? email,
        role: userRole,
        estSupprime: false,
        prenom: prenom,
        nom: nom,
      );

      // Stockage sécurisé
      await _secureStorage.write(key: StorageKeys.token, value: authResponse.token);
      await _secureStorage.write(key: StorageKeys.user, value: finalUser.toString());

      // Sauvegarder les identifiants si demandé
      await saveCredentials(email, password, rememberMe);

      state = state.copyWith(
        user: finalUser,
        token: authResponse.token,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );

      AppLogger.auth('Connexion réussie', email: finalUser.displayName);
    } catch (e) {
      AppLogger.error('Erreur de connexion', tag: 'AUTH_PROVIDER', error: e);

      String errorMessage;
      if (e is AuthServiceException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Erreur de connexion: ${e.toString()}';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        isAuthenticated: false,
      );
    }
  }

  /// Déconnexion utilisateur
  Future<void> signOut() async {
    AppLogger.auth('Déconnexion utilisateur');

    await _clearStoredAuth();

    state = const AuthState(
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    );

    AppLogger.auth('Déconnexion réussie');
  }

  /// Nettoyage des données stockées
  Future<void> _clearStoredAuth() async {
    await _secureStorage.delete(key: StorageKeys.token);
    await _secureStorage.delete(key: StorageKeys.user);
  }

  /// Effacer les erreurs
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Rafraîchissement du profil utilisateur
  Future<void> refreshUserProfile() async {
    if (state.token == null) return;

    try {
      final userProfile = await _authService.getCurrentUser(state.token!);
      final updatedUser = User.fromJson(userProfile['data'] ?? userProfile);
      
      state = state.copyWith(user: updatedUser);
      
      // Mise à jour du stockage
      await _secureStorage.write(key: StorageKeys.user, value: updatedUser.toString());
    } catch (e) {
      AppLogger.error('Erreur lors du rafraîchissement du profil', tag: 'AUTH_PROVIDER', error: e);
    }
  }

  /// Connexion avec token existant (ex: après inscription)
  Future<void> loginWithToken(String token, Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.auth('Connexion automatique avec token', email: userData['email'] as String?);

      // Créer un User à partir des données reçues
      final user = User.fromJson(userData);

      // Stockage sécurisé
      await _secureStorage.write(key: StorageKeys.token, value: token);
      await _secureStorage.write(key: StorageKeys.user, value: user.toString());

      state = state.copyWith(
        user: user,
        token: token,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );

      AppLogger.auth('Connexion automatique réussie', email: user.displayName);
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion automatique', tag: 'AUTH_PROVIDER', error: e);

      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la connexion automatique',
        isAuthenticated: false,
      );
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<void> forgotPassword(String email) async {
    try {
      AppLogger.auth('Demande de réinitialisation de mot de passe', email: email);
      
      await _authService.forgotPassword(email);
      
      AppLogger.auth('Demande de réinitialisation envoyée avec succès', email: email);
    } catch (e) {
      AppLogger.error('Erreur lors de la demande de réinitialisation', tag: 'AUTH_PROVIDER', error: e);
      
      if (e is AuthServiceException) {
        throw e.message;
      } else {
        throw 'Erreur inattendue lors de la demande de réinitialisation';
      }
    }
  }

  /// Convertit le rôle string en UserRole enum
  UserRole _parseUserRole(String? roleString) {
    switch (roleString?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'REDAC':
        return UserRole.redacteur;
      case 'USER':
      default:
        return UserRole.user;
    }
  }
}

/// Provider du service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider du stockage sécurisé
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider principal d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(authService, secureStorage);
});

/// Provider pour vérifier si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Provider pour récupérer l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Classe pour les identifiants sauvegardés
class SavedCredentials {
  final String email;
  final String password;

  const SavedCredentials({
    required this.email,
    required this.password,
  });
}