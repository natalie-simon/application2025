# Guide de Démarrage Flutter ASSBT

## 🎯 Architecture Recommandée (basée sur ASSBT Vue.js)

### Structure du Projet
```
lib/
├── core/                     # Configuration & constantes
│   ├── constants/
│   ├── theme/
│   └── config/
├── features/                 # Modules fonctionnels (comme components/modules/)
│   ├── auth/
│   │   ├── data/            # Services & repositories
│   │   ├── domain/          # Models & use cases
│   │   └── presentation/    # Screens & widgets
│   ├── articles/
│   ├── activities/
│   ├── calendar/
│   └── members/
├── shared/                  # Composants réutilisables
│   ├── widgets/
│   ├── services/
│   └── utils/
└── main.dart
```

## 🚀 Commandes de Démarrage

### 1. Initialisation du projet
```bash
flutter create assbt_app --org fr.lesbulleurstoulonnais
cd assbt_app
```

### 2. Dependencies essentielles
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management (équivalent Pinia)
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9
  
  # HTTP & API (équivalent Axios)
  dio: ^5.3.4
  json_annotation: ^4.8.1
  
  # JWT & Auth
  jwt_decoder: ^2.0.1
  flutter_secure_storage: ^9.0.0
  
  # Navigation (équivalent Vue Router)
  go_router: ^12.1.3
  
  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Calendar (équivalent FullCalendar)
  table_calendar: ^3.0.9
  
  # Forms & Validation (équivalent Zod)
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Utils
  equatable: ^2.0.5
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

## 🎨 Thème ASSBT Flutter

### Configuration des couleurs
```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF134074);      // --assbt-primary
  static const Color dark = Color(0xFF0B2545);         // --assbt-dark
  static const Color textShine = Color(0xFFEEF4ED);    // --assbt-text-shine
  static const Color textLight = Color(0xFF8DA9C4);    // --assbt-text-light
  
  // Mode clair
  static const Color textPrimary = Color(0xFF1A202C);   // --theme-text-primary
  static const Color textSecondary = Color(0xFF4A5568); // --theme-text-secondary
}

// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.dark,
      onSurface: AppColors.textShine,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textShine, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.textLight),
    ),
  );
  
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.textSecondary),
    ),
  );
}
```

## 🔐 Authentification (équivalent store/auth.ts)

### Models
```dart
// lib/features/auth/domain/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final int id;
  final String email;
  final String role;
  final Profil profil;
  
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.profil,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  @override
  List<Object?> get props => [id, email, role, profil];
}

@JsonSerializable()
class Profil extends Equatable {
  final String nom;
  final String prenom;
  final Avatar? avatar;
  
  const Profil({
    required this.nom,
    required this.prenom,
    this.avatar,
  });
  
  factory Profil.fromJson(Map<String, dynamic> json) => _$ProfilFromJson(json);
  Map<String, dynamic> toJson() => _$ProfilToJson(this);
  
  @override
  List<Object?> get props => [nom, prenom, avatar];
}
```

### Auth Provider (équivalent useAuthStore)
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../auth/domain/models/user.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });
  
  bool get isAuthenticated => token != null && !JwtDecoder.isExpired(token!);
  bool get isAdmin => user?.role == 'ADMIN';
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());
  
  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    
    try {
      // Appel API login
      final response = await _authService.login(email, password);
      final token = response['token'];
      final userData = JwtDecoder.decode(token);
      
      state = AuthState(
        token: token,
        user: User.fromJson(userData),
      );
      
      // Sauvegarder en local
      await _secureStorage.write(key: 'jwt_token', value: token);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }
  
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

## 📱 Modules Principaux

### 1. Articles (équivalent components/modules/articles)
```dart
// lib/features/articles/presentation/screens/articles_screen.dart
class ArticlesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Articles"),
        backgroundColor: AppColors.primary,
      ),
      body: articles.when(
        data: (articlesList) => ListView.builder(
          itemCount: articlesList.length,
          itemBuilder: (context, index) => ArticleCard(
            article: articlesList[index],
          ),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text("Erreur: $error"),
      ),
    );
  }
}
```

### 2. Calendrier (équivalent calendrier/CalendrierMembreAssbt.vue)
```dart
// lib/features/calendar/presentation/screens/calendar_screen.dart
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activitiesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendrier"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          TableCalendar<Activity>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getActivitiesForDay(day, activities.value ?? []),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: activities.when(
              data: (activitiesList) => ListView(
                children: _getActivitiesForDay(_selectedDay, activitiesList)
                    .map((activity) => ActivityCard(activity: activity))
                    .toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text("Erreur: $error"),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🌐 Services API (équivalent services/)

### Configuration Dio
```dart
// lib/shared/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://api-prod.lesbulleurstoulonnais.fr/api";
  static const _storage = FlutterSecureStorage();
  
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
  
  Future<Response> get(String path) => _dio.get(path);
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data}) => _dio.put(path, data: data);
  Future<Response> delete(String path) => _dio.delete(path);
}
```

## 📱 Navigation (équivalent Vue Router)

### Configuration GoRouter
```dart
// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/articles',
      builder: (context, state) => const ArticlesScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
```

## 🏗️ App Principal

### Configuration main.dart
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: AssbtApp()));
}

class AssbtApp extends StatelessWidget {
  const AssbtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ASSBT App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
```

## 🚀 Scripts de Génération

### Génération des modèles JSON
```bash
# Générer les fichiers .g.dart
flutter packages pub run build_runner build

# Générer en mode watch
flutter packages pub run build_runner watch
```

## 📋 Checklist de Démarrage

- [ ] Créer le projet Flutter
- [ ] Configurer pubspec.yaml avec les dépendances
- [ ] Implémenter le thème ASSBT
- [ ] Configurer l'authentification JWT
- [ ] Créer les modèles de données
- [ ] Configurer les services API
- [ ] Implémenter la navigation
- [ ] Créer les écrans principaux (Articles, Calendrier, Profil)
- [ ] Tester l'intégration API
- [ ] Configurer le build de production

## 🎯 Fonctionnalités Prioritaires (Version Allégée)

1. **Authentification** - Login/Logout avec JWT
2. **Articles** - Lecture des actualités
3. **Calendrier** - Visualisation des activités
4. **Profil** - Gestion du profil utilisateur
5. **Navigation** - Menu principal avec onglets

Cette structure vous donne une base solide pour démarrer un projet Flutter en reprenant l'architecture et les bonnes pratiques d'ASSBT Vue.js.