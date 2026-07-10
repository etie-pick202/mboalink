import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../constants/app_routes.dart";
import "../theme/app_colors.dart";
import "../theme/app_typography.dart";
import "primary_button.dart";

/// Page affichée quand go_router ne trouve aucune route correspondante
/// (lien profond invalide, faute de frappe dans une navigation…). Sans
/// ce `errorBuilder`, Flutter affiche son écran d'erreur rouge par
/// défaut, hors charte et illisible pour l'utilisateur final.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
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
                    Symbols.search_off,
                    size: 32,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Page introuvable",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Cette page n'existe pas ou plus.",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: "Retour à l'accueil",
                  onPressed: () => context.go(AppRoutes.splash),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
