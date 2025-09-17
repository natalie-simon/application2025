import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';

/// Interceptor Dio sécurisé pour les logs des requêtes HTTP
/// Respecte la configuration d'environnement et masque les données sensibles en production
class SecureLoggingInterceptor extends Interceptor {

  /// Headers sensibles à masquer en production
  static const Set<String> _sensitiveHeaders = {
    'authorization',
    'cookie',
    'x-api-key',
    'x-auth-token',
    'auth-token',
    'bearer',
    'password',
    'secret',
  };

  /// Mots-clés sensibles dans les URLs à masquer
  static const Set<String> _sensitiveUrlKeywords = {
    'password',
    'token',
    'secret',
    'key',
    'auth',
    'credential',
  };

  /// Vérifie si les logs réseau sont activés
  bool get _isNetworkLoggingEnabled =>
      kDebugMode && EnvConfig.enableNetworkDebugging;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isNetworkLoggingEnabled) {
      final method = options.method.toUpperCase();
      final uri = _sanitizeUrl(options.uri.toString());

      AppLogger.apiCall(method, uri, tag: 'HTTP_REQUEST');

      // Log des headers (masqués en production)
      if (EnvConfig.enableApiLogging) {
        _logHeaders('REQUEST HEADERS', options.headers);

        // Log du body si présent (masqué en production)
        if (options.data != null) {
          _logRequestBody(options.data);
        }
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isNetworkLoggingEnabled) {
      final method = response.requestOptions.method.toUpperCase();
      final uri = _sanitizeUrl(response.requestOptions.uri.toString());
      final statusCode = response.statusCode;

      AppLogger.apiCall(method, uri, statusCode: statusCode, tag: 'HTTP_RESPONSE');

      // Log détaillé seulement si API logging activé
      if (EnvConfig.enableApiLogging) {
        _logHeaders('RESPONSE HEADERS', response.headers.map);

        // Log du body de réponse (masqué en production)
        if (response.data != null) {
          _logResponseBody(response.data);
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isNetworkLoggingEnabled) {
      final method = err.requestOptions.method.toUpperCase();
      final uri = _sanitizeUrl(err.requestOptions.uri.toString());
      final statusCode = err.response?.statusCode;

      AppLogger.error(
        'HTTP Error: $method $uri',
        tag: 'HTTP_ERROR',
        error: '${err.type}: ${err.message}',
      );

      if (statusCode != null) {
        AppLogger.apiCall(method, uri, statusCode: statusCode, tag: 'HTTP_ERROR');
      }

      // Log de l'erreur détaillée si API logging activé
      if (EnvConfig.enableApiLogging && err.response?.data != null) {
        _logResponseBody(err.response!.data, isError: true);
      }
    }

    handler.next(err);
  }

  /// Masque les informations sensibles dans les URLs
  String _sanitizeUrl(String url) {
    if (!EnvConfig.isProduction) {
      return url;
    }

    String sanitized = url;

    // Masquer les paramètres sensibles dans l'URL
    for (final keyword in _sensitiveUrlKeywords) {
      final regex = RegExp('($keyword=)[^&]*', caseSensitive: false);
      sanitized = sanitized.replaceAll(regex, '$keyword=***');
    }

    return sanitized;
  }

  /// Log les headers en masquant les informations sensibles
  void _logHeaders(String prefix, Map<String, dynamic> headers) {
    if (headers.isEmpty) return;

    final sanitizedHeaders = <String, dynamic>{};

    headers.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (EnvConfig.isProduction && _sensitiveHeaders.contains(lowerKey)) {
        sanitizedHeaders[key] = '***';
      } else {
        sanitizedHeaders[key] = value;
      }
    });

    AppLogger.debug('$prefix: $sanitizedHeaders', tag: 'HTTP_HEADERS');
  }

  /// Log le body de requête en masquant les données sensibles
  void _logRequestBody(dynamic data) {
    if (data == null) return;

    try {
      final bodyStr = data.toString();
      final sanitizedBody = _sanitizeJsonBody(bodyStr);
      AppLogger.debug('REQUEST BODY: $sanitizedBody', tag: 'HTTP_BODY');
    } catch (e) {
      AppLogger.debug('REQUEST BODY: [Binary or complex data]', tag: 'HTTP_BODY');
    }
  }

  /// Log le body de réponse en masquant les données sensibles
  void _logResponseBody(dynamic data, {bool isError = false}) {
    if (data == null) return;

    try {
      final bodyStr = data.toString();
      final sanitizedBody = _sanitizeJsonBody(bodyStr);
      final prefix = isError ? 'ERROR RESPONSE BODY' : 'RESPONSE BODY';
      AppLogger.debug('$prefix: $sanitizedBody', tag: 'HTTP_BODY');
    } catch (e) {
      AppLogger.debug('RESPONSE BODY: [Binary or complex data]', tag: 'HTTP_BODY');
    }
  }

  /// Masque les données sensibles dans les bodies JSON
  String _sanitizeJsonBody(String body) {
    if (!EnvConfig.isProduction) {
      return body;
    }

    String sanitized = body;

    // Patterns pour masquer les données sensibles
    final sensitivePatterns = [
      RegExp(r'("password"\s*:\s*")[^"]*(")', caseSensitive: false),
      RegExp(r'("token"\s*:\s*")[^"]*(")', caseSensitive: false),
      RegExp(r'("secret"\s*:\s*")[^"]*(")', caseSensitive: false),
      RegExp(r'("key"\s*:\s*")[^"]*(")', caseSensitive: false),
      RegExp(r'("email"\s*:\s*")[^"]*(")', caseSensitive: false),
      RegExp(r'("phone"\s*:\s*")[^"]*(")', caseSensitive: false),
    ];

    for (final pattern in sensitivePatterns) {
      sanitized = sanitized.replaceAll(pattern, r'$1***$2');
    }

    return sanitized;
  }
}