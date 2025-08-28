import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../features/articles/domain/models/article.dart';

class ArticleCarousel extends StatefulWidget {
  final List<Article> articles;
  final Duration autoPlayDuration;
  final double height;
  final Function(Article)? onArticleTap;

  const ArticleCarousel({
    super.key,
    required this.articles,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.height = 300,
    this.onArticleTap,
  });

  @override
  State<ArticleCarousel> createState() => _ArticleCarouselState();
}

class _ArticleCarouselState extends State<ArticleCarousel> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.articles.length <= 1) return;
    
    _timer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (_currentIndex < widget.articles.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _timer.cancel();
  }

  void _restartAutoPlay() {
    _stopAutoPlay();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actualités ASSBT',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              // Indicateur de progression
              if (widget.articles.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.articles.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Carousel des articles
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Redémarrer le timer quand l'utilisateur change de page manuellement
              _restartAutoPlay();
            },
            itemCount: widget.articles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildArticleCard(widget.articles[index]),
              );
            },
          ),
        ),
        
        // Indicateurs de points
        if (widget.articles.length > 1) ...[
          const SizedBox(height: 8),
          _buildPageIndicators(),
        ],
        
        // Contrôles de lecture/pause
        if (widget.articles.length > 1) ...[
          const SizedBox(height: 4),
          _buildPlaybackControls(),
        ],
      ],
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () => widget.onArticleTap?.call(article),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'article
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: article.mainImageUrl != null
                    ? Image.network(
                        article.mainImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.article,
                              color: AppColors.primary,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.article,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                ),
              ),
            ),
            
            // Contenu de l'article
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(article.statut).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(article.statut),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(article.statut),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Titre
                    Expanded(
                      child: Text(
                        article.titre,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Contenu (sans HTML)
                    Text(
                      _cleanHtmlContent(article.contenu),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.articles.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index 
                  ? AppColors.primary 
                  : AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (_currentIndex > 0) {
                setState(() {
                  _currentIndex--;
                });
                _pageController.animateToPage(
                  _currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                _restartAutoPlay();
              }
            },
            icon: const Icon(Icons.skip_previous),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: () {
              if (_timer.isActive) {
                _stopAutoPlay();
              } else {
                _startAutoPlay();
              }
              setState(() {});
            },
            icon: Icon(_timer.isActive ? Icons.pause : Icons.play_arrow),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: () {
              if (_currentIndex < widget.articles.length - 1) {
                setState(() {
                  _currentIndex++;
                });
                _pageController.animateToPage(
                  _currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                _restartAutoPlay();
              }
            },
            icon: const Icon(Icons.skip_next),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statut) {
    if (statut == null) return AppColors.grey500;
    switch (statut.toUpperCase()) {
      case 'PUBLIE':
        return AppColors.success;
      case 'BROUILLON':
        return AppColors.warning;
      case 'CORBEILLE':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _getStatusText(String? statut) {
    if (statut == null) return 'Article';
    switch (statut.toUpperCase()) {
      case 'PUBLIE':
        return 'Publié';
      case 'BROUILLON':
        return 'Brouillon';
      case 'CORBEILLE':
        return 'Archivé';
      default:
        return statut;
    }
  }

  String _cleanHtmlContent(String htmlContent) {
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}