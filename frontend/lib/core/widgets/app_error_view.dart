import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

import "../errors/app_exception.dart";
import "../theme/app_colors.dart";
import "../theme/app_typography.dart";
import "primary_button.dart";

/// État d'erreur standard — icône, message (issu de l'[AppException] si
/// possible, sinon [fallbackMessage]) et bouton "Réessayer" optionnel.
///
/// Centralise ce qui était dupliqué (et incohérent) dans chaque écran
/// consommant un `AsyncValue` : certains affichaient un bouton "Réessayer",
/// d'autres non, aucun n'avait d'icône.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.error,
    this.fallbackMessage = "Une erreur est survenue. Réessayez.",
    this.onRetry,
    super.key,
  });

  final Object error;
  final String fallbackMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppException
        ? (error as AppException).message
        : fallbackMessage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Symbols.error,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              PrimaryButton(label: "Réessayer", onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
