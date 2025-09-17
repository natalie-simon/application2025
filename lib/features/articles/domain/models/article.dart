import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable()
class Article extends Equatable {
  final int id;
  final String titre;
  final String contenu;
  final String? statut; // "PUBLIE|BROUILLON|CORBEILLE"
  final String? categorie; // "VISITEURS|INFORMATIONS|ANNONCES"
  @JsonKey(name: 'date_creation')
  final DateTime? dateCreation;
  @JsonKey(name: 'date_modification')
  final DateTime? dateModification;
  final ArticleImage? image;
  final ArticleRedacteur? redacteur;

  const Article({
    required this.id,
    required this.titre,
    required this.contenu,
    this.statut,
    this.categorie,
    this.dateCreation,
    this.dateModification,
    this.image,
    this.redacteur,
  });

  // Propriétés de commodité pour la compatibilité
  String get title => titre;
  String get content => contenu;
  String? get status => statut;
  DateTime? get createdAt => dateCreation;
  DateTime? get updatedAt => dateModification;
  
  // Récupère l'image principale ou null
  String? get mainImageUrl => image?.url;
  
  // Vérifie si l'article est publié
  bool get isPublished => statut?.toUpperCase() == 'PUBLIE';

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);

  @override
  List<Object?> get props => [
        id,
        titre,
        contenu,
        statut,
        categorie,
        dateCreation,
        dateModification,
        image,
        redacteur,
      ];
}

@JsonSerializable()
class ArticleImage extends Equatable {
  final String url;

  const ArticleImage({
    required this.url,
  });

  factory ArticleImage.fromJson(Map<String, dynamic> json) => _$ArticleImageFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleImageToJson(this);

  @override
  List<Object?> get props => [url];
}

@JsonSerializable()
class ArticleRedacteur extends Equatable {
  final String email;

  const ArticleRedacteur({
    required this.email,
  });

  factory ArticleRedacteur.fromJson(Map<String, dynamic> json) => _$ArticleRedacteurFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleRedacteurToJson(this);

  @override
  List<Object?> get props => [email];
}

@JsonSerializable()
class ArticlesResponse extends Equatable {
  final List<Article> data;
  final ArticlesMeta? meta;

  const ArticlesResponse({
    required this.data,
    this.meta,
  });

  factory ArticlesResponse.fromJson(Map<String, dynamic> json) => _$ArticlesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ArticlesResponseToJson(this);

  @override
  List<Object?> get props => [data, meta];
}

@JsonSerializable()
class ArticlesMeta extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ArticlesMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ArticlesMeta.fromJson(Map<String, dynamic> json) => _$ArticlesMetaFromJson(json);
  Map<String, dynamic> toJson() => _$ArticlesMetaToJson(this);

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}