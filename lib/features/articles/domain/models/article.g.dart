// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      statut: json['statut'] as String,
      categorie: json['categorie'] as String,
      dateCreation: json['date_creation'] == null
          ? null
          : DateTime.parse(json['date_creation'] as String),
      dateModification: json['date_modification'] == null
          ? null
          : DateTime.parse(json['date_modification'] as String),
      image: json['image'] == null
          ? null
          : ArticleImage.fromJson(json['image'] as Map<String, dynamic>),
      redacteur: json['redacteur'] == null
          ? null
          : ArticleRedacteur.fromJson(
              json['redacteur'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'contenu': instance.contenu,
      'statut': instance.statut,
      'categorie': instance.categorie,
      'date_creation': instance.dateCreation?.toIso8601String(),
      'date_modification': instance.dateModification?.toIso8601String(),
      'image': instance.image,
      'redacteur': instance.redacteur,
    };

ArticleImage _$ArticleImageFromJson(Map<String, dynamic> json) => ArticleImage(
      url: json['url'] as String,
    );

Map<String, dynamic> _$ArticleImageToJson(ArticleImage instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

ArticleRedacteur _$ArticleRedacteurFromJson(Map<String, dynamic> json) =>
    ArticleRedacteur(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ArticleRedacteurToJson(ArticleRedacteur instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ArticlesResponse _$ArticlesResponseFromJson(Map<String, dynamic> json) =>
    ArticlesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : ArticlesMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArticlesResponseToJson(ArticlesResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

ArticlesMeta _$ArticlesMetaFromJson(Map<String, dynamic> json) => ArticlesMeta(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$ArticlesMetaToJson(ArticlesMeta instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };
