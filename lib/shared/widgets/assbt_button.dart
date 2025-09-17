import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AssbtButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Widget? icon;
  final String? semanticLabel;
  final String? tooltip;

  const AssbtButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style,
    this.icon,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (icon != null) {
      button = ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        ) : icon!,
        label: Text(text),
        style: style,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(text),
      );
    }

    // Améliorer l'accessibilité avec Semantics et Tooltip
    Widget accessibleButton = Semantics(
      button: true,
      enabled: !isLoading && onPressed != null,
      label: semanticLabel ?? (isLoading ? '$text - Chargement en cours' : text),
      hint: isLoading ? 'Bouton désactivé pendant le chargement' : 'Appuyez pour ${text.toLowerCase()}',
      child: button,
    );

    // Ajouter un tooltip si fourni
    if (tooltip != null) {
      accessibleButton = Tooltip(
        message: tooltip!,
        child: accessibleButton,
      );
    }

    return accessibleButton;
  }
}