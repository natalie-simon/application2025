import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/articles/domain/models/article.dart';
import 'article_card.dart';

class ArticleSlider extends StatelessWidget {
  final List<Article> articles;
  final String title;
  final ArticleCardType cardType;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback? onSeeAll;
  final Function(Article)? onArticleTap;

  const ArticleSlider({
    super.key,
    required this.articles,
    required this.title,
    this.cardType = ArticleCardType.medium,
    this.cardWidth = 280,
    this.cardHeight = 320,
    this.onSeeAll,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header avec titre et bouton "Voir tout"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (onSeeAll != null)
                TextButton.icon(
                  onPressed: onSeeAll,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                  label: const Text('Voir tout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Slider horizontal
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  right: index < articles.length - 1 ? 16 : 0,
                ),
                child: ArticleCard(
                  article: article,
                  type: cardType,
                  onTap: () => onArticleTap?.call(article),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ArticleGrid extends StatelessWidget {
  final List<Article> articles;
  final String title;
  final int crossAxisCount;
  final double childAspectRatio;
  final VoidCallback? onSeeAll;
  final Function(Article)? onArticleTap;

  const ArticleGrid({
    super.key,
    required this.articles,
    required this.title,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.onSeeAll,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (onSeeAll != null)
                TextButton.icon(
                  onPressed: onSeeAll,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                  label: const Text('Voir tout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Grille d'articles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleCard(
                article: article,
                type: ArticleCardType.medium,
                onTap: () => onArticleTap?.call(article),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget pour article en vedette (hero)
class FeaturedArticle extends StatelessWidget {
  final Article article;
  final Function(Article)? onTap;

  const FeaturedArticle({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ArticleCard(
        article: article,
        type: ArticleCardType.large,
        onTap: () => onTap?.call(article),
      ),
    );
  }
}

// Widget pour liste compacte d'articles
class ArticleCompactList extends StatelessWidget {
  final List<Article> articles;
  final String title;
  final VoidCallback? onSeeAll;
  final Function(Article)? onArticleTap;

  const ArticleCompactList({
    super.key,
    required this.articles,
    required this.title,
    this.onSeeAll,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('Voir tout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Liste compacte
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: articles.map((article) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ArticleCard(
                article: article,
                type: ArticleCardType.compact,
                onTap: () => onArticleTap?.call(article),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}