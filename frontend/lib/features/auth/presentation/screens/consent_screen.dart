import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/primary_button.dart";
import "../providers/auth_providers.dart";

/// Écran 05 · Consentement données — conforme à la maquette MboaLink.
/// Enregistre le choix de personnalisation via PUT /consentements —
/// les conditions générales sont toujours acceptées (obligatoires pour
/// utiliser l'app), seule la personnalisation (tracking/notifications/
/// marketing) varie selon le bouton choisi.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({required this.isGrossiste, super.key});

  final bool isGrossiste;

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _isSubmitting = false;

  Future<void> _continueTo(
    BuildContext context, {
    required bool accepte,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(consentementRepositoryProvider)
          .mettreAJour(
            trackingAccepte: accepte,
            notificationsAcceptees: accepte,
            marketingAccepte: accepte,
            conditionsAcceptees: true,
            versionConditions: "1.0",
          );
    } on AppException catch (_) {
      // Le consentement pourra être ajusté plus tard depuis le profil —
      // on ne bloque pas l'accès à l'app si l'enregistrement échoue.
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    if (!context.mounted) return;
    context.go(
      widget.isGrossiste ? AppRoutes.grossisteDashboard : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Symbols.shield_person,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Votre expérience, personnalisée",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Personalise your experience",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Pour vous recommander les meilleurs grossistes, nous utilisons :",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  const _ConsentItem(
                    icon: Symbols.location_on,
                    title: "Position géographique",
                    subtitle: "Grossistes proches de vous",
                  ),
                  const SizedBox(height: 12),
                  const _ConsentItem(
                    icon: Symbols.interests,
                    title: "Catégories consultées",
                    subtitle: "Vos centres d'intérêt",
                  ),
                  const SizedBox(height: 12),
                  const _ConsentItem(
                    icon: Symbols.history,
                    title: "Historique de recherche",
                    subtitle: "Modifiable à tout moment",
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Symbols.lock,
                          size: 17,
                          color: AppColors.textFaint,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            "Données jamais revendues. Supprimables depuis votre profil. "
                            "Conforme à la loi camerounaise.",
                            style: AppTypography.caption.copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: "Accepter & continuer",
                    isLoading: _isSubmitting,
                    onPressed: () => _continueTo(context, accepte: true),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _continueTo(context, accepte: false),
                      child: Text(
                        "Continuer sans personnalisation",
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
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

class _ConsentItem extends StatelessWidget {
  const _ConsentItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(subtitle, style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}
