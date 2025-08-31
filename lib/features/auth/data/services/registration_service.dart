import 'package:dio/dio.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/logger.dart';

class RegistrationService {
  final Dio _dio;
  
  RegistrationService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>?> registerMember({
    required String email,
    required String motDePasse,
    required String confirmation,
    required String clef,
  }) async {
    try {
      AppLogger.info('[REGISTRATION] Début inscription membre: $email');
      
      final data = {
        'email': email.trim(),
        'mot_de_passe': motDePasse,
        'confirmation': confirmation,
        'clef': clef.trim(),
      };

      AppLogger.debug('[REGISTRATION_API] *** Request ***');
      AppLogger.debug('[REGISTRATION_API] uri: ${EnvConfig.membersBaseUrl}/register');
      AppLogger.debug('[REGISTRATION_API] method: POST');
      AppLogger.debug('[REGISTRATION_API] data: $data');
      
      final response = await _dio.post(
        '${EnvConfig.membersBaseUrl}/register',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      AppLogger.debug('[REGISTRATION_API] *** Response ***');
      AppLogger.debug('[REGISTRATION_API] statusCode: ${response.statusCode}');
      AppLogger.debug('[REGISTRATION_API] data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppLogger.info('[REGISTRATION] Inscription réussie pour: $email');
        // Retourner les données de réponse (incluent probablement token + infos user)
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = response.data?['message'] ?? 'Erreur lors de l\'inscription';
        AppLogger.error('[REGISTRATION] Échec inscription: $errorMessage (${response.statusCode})');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      AppLogger.error('[REGISTRATION] DioException: ${e.message}');
      AppLogger.debug('[REGISTRATION_API] Response data: ${e.response?.data}');
      
      if (e.response != null) {
        final errorData = e.response!.data;
        String errorMessage = 'Erreur lors de l\'inscription';
        
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }
        
        throw Exception(errorMessage);
      } else {
        throw Exception('Erreur de connexion au serveur');
      }
    } catch (e) {
      AppLogger.error('[REGISTRATION] Erreur inattendue: $e');
      throw Exception('Erreur inattendue lors de l\'inscription');
    }
  }
}