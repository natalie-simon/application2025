// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleApiResponse _$ArticleApiResponseFromJson(Map<String, dynamic> json) =>
    ArticleApiResponse(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      statut: json['statut'] as String,
      categorie: json['categorie'] as String,
      image: json['image'] == null
          ? null
          : ArticleImageApi.fromJson(json['image'] as Map<String, dynamic>),
      redacteur: json['redacteur'] == null
          ? null
          : ArticleRedacteurApi.fromJson(
              json['redacteur'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ArticleApiResponseToJson(ArticleApiResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'contenu': instance.contenu,
      'statut': instance.statut,
      'categorie': instance.categorie,
      'image': instance.image,
      'redacteur': instance.redacteur,
    };

ArticleImageApi _$ArticleImageApiFromJson(Map<String, dynamic> json) =>
    ArticleImageApi(url: json['url'] as String);

Map<String, dynamic> _$ArticleImageApiToJson(ArticleImageApi instance) =>
    <String, dynamic>{'url': instance.url};

ArticleRedacteurApi _$ArticleRedacteurApiFromJson(Map<String, dynamic> json) =>
    ArticleRedacteurApi(email: json['email'] as String);

Map<String, dynamic> _$ArticleRedacteurApiToJson(
  ArticleRedacteurApi instance,
) => <String, dynamic>{'email': instance.email};

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  message: json['message'] as String,
  code: (json['code'] as num?)?.toInt(),
  details: json['details'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'details': instance.details,
};
