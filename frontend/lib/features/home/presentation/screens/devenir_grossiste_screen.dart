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
import "../../../auth/presentation/providers/auth_providers.dart";

/// Bascule un compte Client (UTILISATEUR) en Grossiste — appelle
/// POST /auth/devenir-grossiste (le rôle change, de nouveaux tokens sont
/// émis), met à jour la session locale puis lance le wizard "Créer ma
/// fiche" déjà existant (qui exige ROLE_GROSSISTE côté backend).
class DevenirGrossisteScreen extends ConsumerStatefulWidget {
  const DevenirGrossisteScreen({super.key});

  @override
  ConsumerState<DevenirGrossisteScreen> createState() =>
      _DevenirGrossisteScreenState();
}

class _DevenirGrossisteScreenState
    extends ConsumerState<DevenirGrossisteScreen> {
  bool _isSubmitting = false;
  String? _erreur;

  Future<void> _confirmer() async {
    setState(() {
      _isSubmitting = true;
      _erreur = null;
    });
    try {
      final session = await ref.read(authRepositoryProvider).devenirGrossiste();
      await ref.read(sessionStorageProvider).save(session);
      ref.read(currentSessionProvider.notifier).state = session;
      if (!mounted) return;
      context.go(AppRoutes.grossisteOnboarding);
    } on AppException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                        "Devenir grossiste",
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Symbols.storefront,
                                  size: 26,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Passez du côté grossiste",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Votre compte devient un compte Grossiste : vous pourrez créer votre fiche, ajouter vos produits et être visible dans l'annuaire MboaLink dès validation de vos documents.",
                                style: AppTypography.bodySmall.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AvantageTile(
                          icon: Symbols.storefront,
                          texte: "Fiche visible dans l'annuaire des grossistes",
                        ),
                        const SizedBox(height: 8),
                        _AvantageTile(
                          icon: Symbols.inventory_2,
                          texte: "Produits et prix illimités",
                        ),
                        const SizedBox(height: 8),
                        _AvantageTile(
                          icon: Symbols.payments,
                          texte:
                              "Coordonnées monétisées — vous êtes rémunéré à chaque déverrouillage",
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Symbols.info,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Un abonnement grossiste est requis après validation de vos documents pour rendre votre fiche visible.",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_erreur != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _erreur!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 11, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: PrimaryButton(
                    label: "Devenir grossiste",
                    isLoading: _isSubmitting,
                    onPressed: _confirmer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvantageTile extends StatelessWidget {
  const _AvantageTile({required this.icon, required this.texte});

  final IconData icon;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texte,
            style: AppTypography.bodySmall.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}
