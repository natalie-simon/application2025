import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';

/// Configuration centralisée du cache réseau avec politiques intelligentes
class CacheConfig {
  static CacheStore? _store;
  static bool _initialized = false;

  /// Initialise le système de cache
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Créer le store Hive pour persistance
      _store = HiveCacheStore('./cache');

      await _store!.clean();
      _initialized = true;

      AppLogger.info('Cache système initialisé avec succès', tag: 'CACHE_CONFIG');
    } catch (e) {
      AppLogger.error('Erreur initialisation cache', tag: 'CACHE_CONFIG', error: e.toString());
    }
  }

  /// Interceptor de cache pour les articles (cache long)
  static DioCacheInterceptor get articlesCache => DioCacheInterceptor(
    options: CacheOptions(
      store: _store!,
      policy: _getCachePolicy(),
      hitCacheOnErrorExcept: [401, 403], // Cache même en cas d'erreur sauf auth
      priority: CachePriority.high,
      maxStale: const Duration(days: 7), // Garder max 7 jours en cache
      keyBuilder: (request) => 'articles_${request.uri.toString()}',
      allowPostMethod: false,
    ),
  );

  /// Interceptor de cache pour les activités (cache moyen)
  static DioCacheInterceptor get activitiesCache => DioCacheInterceptor(
    options: CacheOptions(
      store: _store!,
      policy: _getCachePolicy(),
      hitCacheOnErrorExcept: [401, 403],
      priority: CachePriority.normal,
      maxStale: const Duration(hours: 6), // Cache 6 heures
      keyBuilder: (request) => 'activities_${request.uri.toString()}',
      allowPostMethod: false,
    ),
  );

  /// Interceptor de cache pour les profils (cache court)
  static DioCacheInterceptor get profileCache => DioCacheInterceptor(
    options: CacheOptions(
      store: _store!,
      policy: CachePolicy.request, // Utilise le cache si disponible
      hitCacheOnErrorExcept: [401, 403],
      priority: CachePriority.low,
      maxStale: const Duration(minutes: 30), // Cache 30 minutes
      keyBuilder: (request) => 'profile_${request.uri.toString()}',
      allowPostMethod: false,
    ),
  );

  /// Interceptor de cache générique (configurable)
  static DioCacheInterceptor createCustomCache({
    required String keyPrefix,
    Duration? maxStale,
    CachePriority? priority,
    CachePolicy? policy,
  }) => DioCacheInterceptor(
    options: CacheOptions(
      store: _store!,
      policy: policy ?? _getCachePolicy(),
      hitCacheOnErrorExcept: [401, 403],
      priority: priority ?? CachePriority.normal,
      maxStale: maxStale ?? const Duration(hours: 1),
      keyBuilder: (request) => '${keyPrefix}_${request.uri.toString()}',
      allowPostMethod: false,
    ),
  );

  /// Détermine la politique de cache selon l'environnement
  static CachePolicy _getCachePolicy() {
    if (kDebugMode) {
      // En développement, politique hybride pour faciliter le debug
      return CachePolicy.refresh;
    } else {
      // En production, utiliser le cache quand disponible
      return CachePolicy.request;
    }
  }

  /// Vide tout le cache
  static Future<void> clearCache() async {
    if (_store != null) {
      await _store!.clean();
      AppLogger.info('Cache réseau vidé', tag: 'CACHE_CONFIG');
    }
  }

  /// Vide le cache pour un type de données spécifique
  static Future<void> clearCacheForKey(String keyPrefix) async {
    if (_store != null) {
      await _store!.deleteFromPath(
        RegExp('${keyPrefix}_.*'),
      );
      AppLogger.info('Cache vidé pour: $keyPrefix', tag: 'CACHE_CONFIG');
    }
  }

  /// Statistiques du cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    if (_store == null) return {'initialized': false};

    try {
      // Note: HiveCacheStore ne fournit pas de stats directement
      // On peut implémenter nos propres compteurs si nécessaire
      return {
        'initialized': _initialized,
        'store_type': 'HiveCacheStore',
        'environment': EnvConfig.environmentName,
        'policy': _getCachePolicy().toString(),
      };
    } catch (e) {
      AppLogger.warning('Erreur lecture stats cache', tag: 'CACHE_CONFIG');
      return {'error': e.toString()};
    }
  }

  /// Ferme proprement le cache
  static Future<void> dispose() async {
    if (_store != null) {
      await _store!.close();
      _store = null;
      _initialized = false;
      AppLogger.info('Cache système fermé', tag: 'CACHE_CONFIG');
    }
  }
}

/// Extension pour faciliter l'utilisation du cache dans les services
extension CacheExtension on Duration {
  /// Convertit une durée en CacheOptions
  CacheOptions toCacheOptions({
    CachePolicy? policy,
    CachePriority? priority,
    String? keyPrefix,
  }) {
    return CacheOptions(
      store: CacheConfig._store!,
      policy: policy ?? CacheConfig._getCachePolicy(),
      maxStale: this,
      priority: priority ?? CachePriority.normal,
      keyBuilder: keyPrefix != null
        ? (request) => '${keyPrefix}_${request.uri.toString()}'
        : (request) => request.uri.toString(),
    );
  }
}