import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/network/dio_config.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/profile.dart';

class ProfileService {
  late final Dio _dio;

  ProfileService() {
    // Utilisation de la configuration Dio sécurisée centralisée
    _dio = DioConfig.createCustomDio(
      baseUrl: EnvConfig.profileBaseUrl,
      headers: {
        ...EnvConfig.defaultHeaders,
        'X-Service': 'profile',
      },
    );

    // Log de la configuration au démarrage (respecte la config de logging)
    AppLogger.info('ProfileService configuré pour: ${EnvConfig.environmentName}', tag: 'PROFILE_SERVICE');
  }

  /// Récupérer le profil de l'utilisateur connecté depuis le JWT
  Future<Profile?> getCurrentProfile(String token) async {
    try {
      AppLogger.info('Récupération du profil utilisateur depuis le JWT', tag: 'PROFILE_SERVICE');

      // Décoder le JWT pour extraire les données de profil
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      if (decodedToken['profil'] == null) {
        AppLogger.info('Aucun profil trouvé dans le JWT', tag: 'PROFILE_SERVICE');
        return null;
      }

      final profil = decodedToken['profil'] as Map<String, dynamic>;
      final userId = (decodedToken['sub'] as num?)?.toInt() ?? 0;
      
      AppLogger.debug('Données JWT profil: $profil', tag: 'PROFILE_SERVICE');
      
      // Construire un objet Profile à partir des données JWT
      final profileData = {
        'id': profil['id'] ?? 0,
        'nom': profil['nom'],
        'prenom': profil['prenom'], 
        'telephone': profil['telephone'],
        'communication_mail': profil['communication_mail'] ?? true,
        'communication_sms': profil['communication_sms'] ?? false,
        'avatarId': profil['avatarId'],
        'membreId': userId,
      };

      AppLogger.debug('ProfileData construit: $profileData', tag: 'PROFILE_SERVICE');
      AppLogger.info('Profil récupéré depuis JWT avec succès', tag: 'PROFILE_SERVICE');
      return Profile.fromJson(profileData);
    } catch (e) {
      AppLogger.error('Exception lors de la récupération du profil depuis JWT', error: e, tag: 'PROFILE_SERVICE');
      if (e is ProfileServiceException) {
        rethrow;
      }
      throw ProfileServiceException('Erreur lors du décodage du profil JWT');
    }
  }

  /// Créer ou mettre à jour le profil
  Future<Profile> updateProfile({
    required String token,
    required String nom,
    required String prenom,
    required String telephone,
    required bool communicationMail,
    required bool communicationSms,
    File? avatarFile,
  }) async {
    try {
      AppLogger.info('Mise à jour du profil utilisateur', tag: 'PROFILE_SERVICE');

      // Récupérer l'ID utilisateur depuis le JWT
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final profileId = decodedToken['profil']?['id'];
      
      if (profileId == null) {
        throw ProfileServiceException('ID du profil non trouvé dans le token');
      }

      // Si pas d'avatar, utiliser une requête JSON simple
      if (avatarFile == null) {
        final response = await _dio.put(
          '/$profileId',
          data: {
            'nom': nom,
            'prenom': prenom,
            'telephone': telephone,
            'communication_mail': communicationMail,
            'communication_sms': communicationSms,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );

        AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');
        AppLogger.debug('Corps de la réponse: ${response.data}', tag: 'PROFILE_SERVICE');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          final profileData = responseData['data'] ?? responseData;

          AppLogger.info('Profil mis à jour avec succès', tag: 'PROFILE_SERVICE');
          return Profile.fromJson(profileData);
        } else {
          final errorMessage = 'Erreur lors de la mise à jour du profil: ${response.statusCode}';
          AppLogger.error(errorMessage, tag: 'PROFILE_SERVICE');
          throw ProfileServiceException(errorMessage);
        }
      } else {
        // Si avatar fourni, utiliser FormData avec Dio
        final formData = FormData.fromMap({
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'communication_mail': communicationMail.toString(),
          'communication_sms': communicationSms.toString(),
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
          ),
        });

        AppLogger.debug('Données envoyées: nom=$nom, prenom=$prenom, telephone=$telephone', tag: 'PROFILE_SERVICE');

        final response = await _dio.put(
          '/$profileId',
          data: formData,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            contentType: Headers.multipartFormDataContentType,
          ),
        );

        AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');
        AppLogger.debug('Corps de la réponse: ${response.data}', tag: 'PROFILE_SERVICE');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          final profileData = responseData['data'] ?? responseData;

          AppLogger.info('Profil mis à jour avec succès', tag: 'PROFILE_SERVICE');
          return Profile.fromJson(profileData);
        } else {
          final errorMessage = 'Erreur lors de la mise à jour du profil: ${response.statusCode}';
          AppLogger.error(errorMessage, tag: 'PROFILE_SERVICE');
          throw ProfileServiceException(errorMessage);
        }
      }
    } catch (e) {
      AppLogger.error('Exception lors de la mise à jour du profil', error: e, tag: 'PROFILE_SERVICE');
      if (e is ProfileServiceException) {
        rethrow;
      }
      throw ProfileServiceException('Erreur de connexion lors de la mise à jour du profil');
    }
  }

  /// Upload d'avatar
  Future<Profile> uploadAvatar({
    required String token,
    required File imageFile,
  }) async {
    try {
      AppLogger.info('Upload d\'avatar', tag: 'PROFILE_SERVICE');

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/avatar',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final profileData = responseData['data'] ?? responseData;

        AppLogger.info('Avatar uploadé avec succès', tag: 'PROFILE_SERVICE');
        return Profile.fromJson(profileData);
      } else {
        final errorMessage = 'Erreur lors de l\'upload de l\'avatar: ${response.statusCode}';
        AppLogger.error(errorMessage, tag: 'PROFILE_SERVICE');
        throw ProfileServiceException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Exception lors de l\'upload d\'avatar', error: e, tag: 'PROFILE_SERVICE');
      if (e is ProfileServiceException) {
        rethrow;
      }
      throw ProfileServiceException('Erreur de connexion lors de l\'upload d\'avatar');
    }
  }

  /// Supprimer l'avatar
  Future<Profile> deleteAvatar({
    required String token,
  }) async {
    try {
      AppLogger.info('Suppression d\'avatar', tag: 'PROFILE_SERVICE');

      final response = await _dio.delete(
        '/avatar',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Récupérer le profil mis à jour
        final updatedProfile = await getCurrentProfile(token);

        AppLogger.info('Avatar supprimé avec succès', tag: 'PROFILE_SERVICE');
        if (updatedProfile != null) {
          return updatedProfile;
        } else {
          throw ProfileServiceException('Erreur lors de la récupération du profil mis à jour');
        }
      } else {
        final errorMessage = 'Erreur lors de la suppression de l\'avatar: ${response.statusCode}';
        AppLogger.error(errorMessage, tag: 'PROFILE_SERVICE');
        throw ProfileServiceException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Exception lors de la suppression d\'avatar', error: e, tag: 'PROFILE_SERVICE');
      if (e is ProfileServiceException) {
        rethrow;
      }
      throw ProfileServiceException('Erreur de connexion lors de la suppression d\'avatar');
    }
  }
}

/// Exception personnalisée pour les erreurs du service profil
class ProfileServiceException implements Exception {
  final String message;

  ProfileServiceException(this.message);

  @override
  String toString() => 'ProfileServiceException: $message';
}