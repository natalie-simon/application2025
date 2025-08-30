import 'package:dio/dio.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/activity_detail.dart';

class ActivitiesService {
  late final Dio _dio;

  ActivitiesService() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.activitiesBaseUrl,
      connectTimeout: EnvConfig.connectionTimeout,
      receiveTimeout: EnvConfig.apiTimeout,
      headers: EnvConfig.defaultHeaders,
    ));

    // Logging conditionnel basé sur la configuration d'environnement
    if (EnvConfig.enableApiLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (obj) => AppLogger.debug(obj.toString(), tag: 'ACTIVITIES_API'),
      ));
    }

    // Log de la configuration au démarrage (debug uniquement)
    if (EnvConfig.enableAppLogging) {
      AppLogger.info('ActivitiesService configuré pour: ${EnvConfig.environmentName}', tag: 'ACTIVITIES_SERVICE');
    }
  }

  Future<List<Activity>> getActivities({String? token}) async {
    try {
      AppLogger.info('Chargement des activités', tag: 'ACTIVITIES');

      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await _dio.get('/activites', options: options);

      AppLogger.apiCall('GET', '/activites', statusCode: response.statusCode, tag: 'ACTIVITIES');

      final activitiesList = response.data as List<dynamic>;
      final activities = activitiesList
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('${activities.length} activités chargées', tag: 'ACTIVITIES');
      
      return activities;
    } on DioException catch (e) {
      AppLogger.error('Erreur DioException: ${e.type}', tag: 'ACTIVITIES', error: e.response?.data ?? e.message);

      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 0;
        final errorMessage = e.response!.data?['message'] ?? 
                           e.response!.data?.toString() ?? 
                           'Erreur serveur';
        
        switch (statusCode) {
          case 401:
            throw const ActivitiesServiceException('Token d\'authentification invalide', 401);
          case 403:
            throw const ActivitiesServiceException('Accès non autorisé aux activités', 403);
          case 404:
            throw const ActivitiesServiceException('Service des activités indisponible', 404);
          default:
            throw ActivitiesServiceException('Erreur serveur ($statusCode): $errorMessage', statusCode);
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw const ActivitiesServiceException(
          'Délai de connexion dépassé - Vérifiez votre connexion internet',
          0,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const ActivitiesServiceException(
          'Impossible de se connecter au serveur - Vérifiez votre connexion',
          0,
        );
      } else {
        throw ActivitiesServiceException(
          'Erreur de configuration: ${e.message}',
          0,
        );
      }
    } catch (e) {
      AppLogger.error('Erreur générale activités', tag: 'ACTIVITIES', error: e);
      throw ActivitiesServiceException('Erreur inattendue: $e', 0);
    }
  }

  Future<ActivityDetail> getActivityDetailById(int id, {String? token}) async {
    try {
      AppLogger.info('Chargement détails activité ID: $id', tag: 'ACTIVITIES');

      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await _dio.get('/activites/$id?participants=true', options: options);
      
      AppLogger.apiCall('GET', '/activites/$id?participants=true', statusCode: response.statusCode, tag: 'ACTIVITIES');

      return ActivityDetail.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ActivitiesServiceException('Activité non trouvée', 404);
      }
      rethrow;
    }
  }

  Future<void> registerForActivity(int activityId, {String? observations, required String token}) async {
    try {
      AppLogger.info('Inscription activité ID: $activityId', tag: 'ACTIVITIES');

      final data = <String, dynamic>{
        if (observations != null && observations.isNotEmpty) 'observations': observations,
      };

      final response = await _dio.post(
        '/activites/$activityId/inscription',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      AppLogger.apiCall('POST', '/activites/$activityId/inscription', statusCode: response.statusCode, tag: 'ACTIVITIES');
    } catch (e) {
      AppLogger.error('Erreur inscription activité', tag: 'ACTIVITIES', error: e);
      rethrow;
    }
  }

  Future<void> unregisterFromActivity(int activityId, {required String token}) async {
    try {
      AppLogger.info('Désinscription activité ID: $activityId', tag: 'ACTIVITIES');

      final response = await _dio.put(
        '/activites/$activityId/desinscription',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      AppLogger.apiCall('PUT', '/activites/$activityId/desinscription', statusCode: response.statusCode, tag: 'ACTIVITIES');
    } catch (e) {
      AppLogger.error('Erreur désinscription activité', tag: 'ACTIVITIES', error: e);
      rethrow;
    }
  }
}

class ActivitiesServiceException implements Exception {
  final String message;
  final int statusCode;

  const ActivitiesServiceException(this.message, this.statusCode);

  @override
  String toString() => 'ActivitiesServiceException: $message';
}