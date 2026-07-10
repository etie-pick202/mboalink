import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../../core/widgets/contact_support_sheet.dart";
import "../providers/grossiste_providers.dart";

/// Écran 23 de la maquette · "Fiche en cours de vérification" — affiché
/// quand le grossiste tape "Lire ma fiche" sur le dashboard en attente.
/// Lecture seule : aucune action de modification ici, seul le wizard
/// "Créer ma fiche" (accessible depuis le dashboard) permet de corriger.
class GrossisteFicheEnAttenteScreen extends ConsumerWidget {
  const GrossisteFicheEnAttenteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficheAsync = ref.watch(maFicheProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: ficheAsync.when(
          loading: () => const Center(child: AppLoader()),
          error: (error, _) => AppErrorView(
            error: error,
            fallbackMessage: "Impossible de charger votre fiche.",
            onRetry: () => ref.invalidate(maFicheProvider),
          ),
          data: (fiche) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 480 : double.infinity,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(
                            Symbols.arrow_back,
                            size: 23,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Ma fiche",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                      child: Column(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Symbols.hourglass_top,
                              size: 42,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            "Fiche en cours de vérification",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "L'équipe MboaLink contrôle votre identité et la "
                            "légalité de votre activité. Délai habituel : "
                            "24 à 48 h.",
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _EtapeTile(
                                  icon: Symbols.check_circle,
                                  filled: true,
                                  iconColor: AppColors.primary,
                                  title: "Documents reçus",
                                  subtitle: "RCCM, CNI, photo du local",
                                  titleColor: AppColors.textPrimary,
                                  showDivider: true,
                                ),
                                _EtapeTile(
                                  icon: Symbols.pending,
                                  filled: false,
                                  iconColor: AppColors.warning,
                                  title: "Contrôle en cours",
                                  subtitle:
                                      "Vérification d'identité & légalité",
                                  titleColor: AppColors.textPrimary,
                                  showDivider: true,
                                ),
                                _EtapeTile(
                                  icon: Symbols.radio_button_unchecked,
                                  filled: false,
                                  iconColor: AppColors.textFaint,
                                  title: "Mise en ligne",
                                  subtitle: "Après validation",
                                  titleColor: AppColors.textFaint,
                                  showDivider: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                    child: GestureDetector(
                      onTap: () => showContactSupportSheet(context),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            "Nous contacter",
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EtapeTile extends StatelessWidget {
  const _EtapeTile({
    required this.icon,
    required this.filled,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.showDivider,
  });

  final IconData icon;
  final bool filled;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.background))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor, fill: filled ? 1 : 0),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
