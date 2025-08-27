import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/user.dart';

/// Clés de stockage sécurisé
class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'auth_user';
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
    if (kDebugMode) {
      debugPrint('🔄 Chargement des données d\'authentification stockées');
    }

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

          if (kDebugMode) {
            debugPrint('✅ Authentification automatique réussie: ${user.email}');
          }
        } else {
          // Token invalide, nettoyage
          await _clearStoredAuth();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur lors du chargement de l\'authentification: $e');
      }
      await _clearStoredAuth();
    }
  }

  /// Connexion utilisateur
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (kDebugMode) {
        debugPrint('🔄 Tentative de connexion: $email');
      }

      final loginRequest = LoginRequest(email: email, password: password);
      final authResponse = await _authService.signIn(loginRequest);

      // Créer un User à partir du token et du profil
      User user;
      if (authResponse.profil != null) {
        user = User(
          id: authResponse.profil!.id,
          email: email, // L'email n'est pas dans le profil, on utilise celui de la connexion
          role: UserRole.user, // Défaut, à ajuster selon les besoins
          estSupprime: false,
        );
      } else {
        // Fallback si pas de profil
        user = User(
          id: 0,
          email: email,
          role: UserRole.user,
          estSupprime: false,
        );
      }

      // Stockage sécurisé
      await _secureStorage.write(key: StorageKeys.token, value: authResponse.token);
      await _secureStorage.write(key: StorageKeys.user, value: user.toString());

      state = state.copyWith(
        user: user,
        token: authResponse.token,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );

      if (kDebugMode) {
        debugPrint('✅ Connexion réussie: ${user.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur de connexion: $e');
      }

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
    if (kDebugMode) {
      debugPrint('🔄 Déconnexion utilisateur');
    }

    await _clearStoredAuth();

    state = const AuthState(
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    );

    if (kDebugMode) {
      debugPrint('✅ Déconnexion réussie');
    }
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
      if (kDebugMode) {
        debugPrint('❌ Erreur lors du rafraîchissement du profil: $e');
      }
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