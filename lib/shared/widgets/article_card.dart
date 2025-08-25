import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/articles/domain/models/article.dart';
import 'assbt_card.dart';

enum ArticleCardType {
  large,  // Card principale avec image grande
  medium, // Card normale
  compact // Card compacte pour liste
}

class ArticleCard extends StatelessWidget {
  final Article article;
  final ArticleCardType type;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.type = ArticleCardType.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ArticleCardType.large:
        return _buildLargeCard(context);
      case ArticleCardType.medium:
        return _buildMediumCard(context);
      case ArticleCardType.compact:
        return _buildCompactCard(context);
    }
  }

  Widget _buildLargeCard(BuildContext context) {
    return AssbtCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          _buildImage(context, height: 180),
          const SizedBox(height: 16),
          
          // Titre
          Text(
            article.titre,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Contenu
          Text(
            _cleanHtmlContent(article.contenu),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Footer avec date et statut
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildMediumCard(BuildContext context) {
    return AssbtCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          _buildImage(context, height: 140),
          const SizedBox(height: 12),
          
          // Titre
          Text(
            article.titre,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Contenu
          Text(
            _cleanHtmlContent(article.contenu),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return AssbtCard(
      onTap: onTap,
      child: Row(
        children: [
          // Image miniature
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(context, height: 80, width: 80),
          ),
          const SizedBox(width: 12),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.titre,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _cleanHtmlContent(article.contenu),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildCompactFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, {required double height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: article.mainImageUrl != null
          ? Image.network(
              article.mainImageUrl!,
              width: width ?? double.infinity,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width ?? double.infinity,
                  height: height,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.article,
                    color: AppColors.primary,
                    size: height * 0.3,
                  ),
                );
              },
            )
          : Icon(
              Icons.article,
              color: AppColors.primary,
              size: height * 0.3,
            ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        
        // Date
        if (article.dateCreation != null) ...[
          Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.grey500,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(article.dateCreation),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ] else
          Text(
            'Récent',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
      ],
    );
  }

  Widget _buildCompactFooter(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
        const Spacer(),
        Text(
          article.dateCreation != null ? _formatDate(article.dateCreation) : 'Récent',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _cleanHtmlContent(String htmlContent) {
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  Color _getStatusColor() {
    switch (article.statut.toUpperCase()) {
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

  String _getStatusText() {
    switch (article.statut.toUpperCase()) {
      case 'PUBLIE':
        return 'Publié';
      case 'BROUILLON':
        return 'Brouillon';
      case 'CORBEILLE':
        return 'Archivé';
      default:
        return article.statut;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} mois';
    } else if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} sem.';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return 'Maintenant';
    }
  }
}