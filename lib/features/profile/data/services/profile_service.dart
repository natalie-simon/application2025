import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/profile.dart';

class ProfileService {
  static String get baseUrl => '${EnvConfig.apiBaseUrl}/profile';

  /// Récupérer le profil de l'utilisateur connecté
  Future<Profile?> getCurrentProfile(String token) async {
    try {
      AppLogger.info('Récupération du profil utilisateur', tag: 'PROFILE_SERVICE');

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final profileData = responseData['data'] ?? responseData;
        
        if (profileData == null) {
          AppLogger.info('Aucun profil trouvé', tag: 'PROFILE_SERVICE');
          return null;
        }

        AppLogger.info('Profil récupéré avec succès', tag: 'PROFILE_SERVICE');
        return Profile.fromJson(profileData);
      } else if (response.statusCode == 404) {
        AppLogger.info('Profil non trouvé (404)', tag: 'PROFILE_SERVICE');
        return null;
      } else {
        AppLogger.error('Erreur lors de la récupération du profil: ${response.statusCode}', tag: 'PROFILE_SERVICE');
        throw ProfileServiceException('Erreur lors de la récupération du profil: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Exception lors de la récupération du profil', error: e, tag: 'PROFILE_SERVICE');
      if (e is ProfileServiceException) {
        rethrow;
      }
      throw ProfileServiceException('Erreur de connexion lors de la récupération du profil');
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

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${EnvConfig.apiBaseUrl}/profils/create'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter les champs texte
      request.fields['nom'] = nom;
      request.fields['prenom'] = prenom;
      request.fields['telephone'] = telephone;
      request.fields['communication_mail'] = communicationMail.toString();
      request.fields['communication_sms'] = communicationSms.toString();

      // Ajouter l'avatar si fourni
      if (avatarFile != null) {
        final mimeType = lookupMimeType(avatarFile.path);
        final mediaType = mimeType != null ? MediaType.parse(mimeType) : MediaType('image', 'jpeg');

        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
            contentType: mediaType,
          ),
        );
      }

      AppLogger.debug('Données envoyées: nom=$nom, prenom=$prenom, telephone=$telephone', tag: 'PROFILE_SERVICE');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');
      AppLogger.debug('Corps de la réponse: ${response.body}', tag: 'PROFILE_SERVICE');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final profileData = responseData['data'] ?? responseData;

        AppLogger.info('Profil mis à jour avec succès', tag: 'PROFILE_SERVICE');
        return Profile.fromJson(profileData);
      } else {
        final errorMessage = 'Erreur lors de la mise à jour du profil: ${response.statusCode}';
        AppLogger.error(errorMessage, tag: 'PROFILE_SERVICE');
        
        try {
          final errorData = json.decode(response.body);
          throw ProfileServiceException(errorData['message'] ?? errorMessage);
        } catch (e) {
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

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Détection du type MIME
      final mimeType = lookupMimeType(imageFile.path);
      final mediaType = mimeType != null ? MediaType.parse(mimeType) : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.debug('Statut de la réponse: ${response.statusCode}', tag: 'PROFILE_SERVICE');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
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
}

/// Exception personnalisée pour les erreurs du service profil
class ProfileServiceException implements Exception {
  final String message;

  ProfileServiceException(this.message);

  @override
  String toString() => 'ProfileServiceException: $message';
}