import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/profile.dart';

class ProfileService {
  static String get baseUrl => EnvConfig.profileBaseUrl;

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

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/create'),
      );

      // Ajouter tous les headers par défaut + authentification
      request.headers.addAll(EnvConfig.defaultHeaders);
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

      // Ajouter tous les headers par défaut + authentification
      request.headers.addAll(EnvConfig.defaultHeaders);
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