import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';
import 'secure_logging_interceptor.dart';

/// Configuration centralisée et sécurisée pour Dio
/// Gère les interceptors, timeouts et paramètres selon l'environnement
class DioConfig {
  static Dio? _instance;

  /// Instance singleton de Dio configurée
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  /// Crée et configure une nouvelle instance Dio
  static Dio _createDio() {
    final dio = Dio();

    // Configuration de base
    dio.options = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: EnvConfig.connectionTimeout,
      receiveTimeout: EnvConfig.apiTimeout,
      sendTimeout: EnvConfig.apiTimeout,
      headers: EnvConfig.defaultHeaders,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    // Ajout des interceptors selon la configuration
    _addInterceptors(dio);

    // Log de la configuration au démarrage
    AppLogger.logConfiguration();
    AppLogger.info('Dio configuré pour ${EnvConfig.environmentName}', tag: 'DIO_CONFIG');

    return dio;
  }

  /// Ajoute les interceptors appropriés selon l'environnement
  static void _addInterceptors(Dio dio) {
    // Interceptor de logging sécurisé (toujours ajouté)
    dio.interceptors.add(SecureLoggingInterceptor());

    // Interceptor de retry pour les erreurs réseau (production et développement)
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: (message) {
          AppLogger.warning('Retry attempt: $message', tag: 'HTTP_RETRY');
        },
        retries: EnvConfig.apiRetryAttempts,
        retryDelays: List.generate(
          EnvConfig.apiRetryAttempts,
          (index) => EnvConfig.retryDelay * (index + 1),
        ),
      ),
    );

    // Interceptor de validation de réponse
    dio.interceptors.add(ResponseValidationInterceptor());
  }

  /// Force la recréation de l'instance (utile pour les tests)
  static void reset() {
    _instance = null;
  }

  /// Crée une instance Dio temporaire avec configuration spécifique
  static Dio createCustomDio({
    String? baseUrl,
    Duration? timeout,
    Map<String, String>? headers,
  }) {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: baseUrl ?? EnvConfig.apiBaseUrl,
      connectTimeout: timeout ?? EnvConfig.connectionTimeout,
      receiveTimeout: timeout ?? EnvConfig.apiTimeout,
      sendTimeout: timeout ?? EnvConfig.apiTimeout,
      headers: {...EnvConfig.defaultHeaders, ...?headers},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    // Ajouter seulement l'interceptor de logging sécurisé
    dio.interceptors.add(SecureLoggingInterceptor());

    return dio;
  }
}

/// Interceptor simple de retry pour gérer les erreurs réseau
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(milliseconds: 1000),
      Duration(milliseconds: 2000),
      Duration(milliseconds: 3000),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    int attempt = 0;
    for (int i = 0; i < retries; i++) {
      attempt++;

      if (i > 0) {
        final delay = retryDelays.length > i - 1 ? retryDelays[i - 1] : retryDelays.last;
        logPrint?.call('Waiting ${delay.inMilliseconds}ms before retry attempt $attempt');
        await Future.delayed(delay);
      }

      try {
        logPrint?.call('Retry attempt $attempt for ${err.requestOptions.method} ${err.requestOptions.path}');

        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        if (i == retries - 1) {
          // Dernière tentative échouée
          if (e is DioException) {
            handler.next(e);
          } else {
            handler.next(err);
          }
          return;
        }
      }
    }
  }

  /// Détermine si l'erreur justifie un retry
  bool _shouldRetry(DioException err) {
    // Retry pour les erreurs de connexion et timeouts
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

/// Interceptor de validation des réponses
class ResponseValidationInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Validation de base de la réponse
    if (response.statusCode == null) {
      AppLogger.warning('Response without status code', tag: 'RESPONSE_VALIDATION');
    }

    // Validation du contenu selon le Content-Type
    final contentType = response.headers.value('content-type');
    if (contentType != null && contentType.contains('application/json')) {
      if (response.data == null) {
        AppLogger.warning('Empty JSON response', tag: 'RESPONSE_VALIDATION');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log des erreurs de validation spécifiques
    if (err.response?.statusCode == 401) {
      AppLogger.critical('Unauthorized access - Token may be expired', tag: 'AUTH_ERROR');
    } else if (err.response?.statusCode == 403) {
      AppLogger.critical('Forbidden access - Insufficient permissions', tag: 'AUTH_ERROR');
    }

    handler.next(err);
  }
}