import "package:flutter/material.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";
import "app_loader.dart";

/// Bouton d'action principal MboaLink : fond vert, ombre colorée,
/// coins arrondis 15px — conforme aux CTA de la maquette.
/// Gère nativement l'état de chargement (utile pendant les appels API).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.height = 54,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: isDisabled
            ? AppColors.primary.withValues(alpha: 0.5)
            : AppColors.primary,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isDisabled ? null : onPressed,
          child: Center(
            child: isLoading
                ? const AppLoader(size: 20, color: Colors.white)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: AppTypography.button),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(trailingIcon, size: 20, color: Colors.white),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
