import "package:flutter/material.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";

/// Indicateur de chargement circulaire stylé à la marque MboaLink.
class AppLoader extends StatelessWidget {
  const AppLoader({this.size = 22, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size * 0.12,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );
  }
}

/// Voile de chargement plein écran (ex: pendant un appel API bloquant).
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoader(size: 28),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message!, style: AppTypography.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
