import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/primary_button.dart";

/// Volet 3/3 de l'assistant "Créer ma fiche" — paiement de l'abonnement,
/// exigence explicite de la revue de changement. Aucun endpoint de
/// paiement confirmé côté backend à ce jour (domaine Paiements pas
/// encore branché) : le paiement est entièrement simulé ici.
class GrossisteFicheStep3Screen extends StatefulWidget {
  const GrossisteFicheStep3Screen({required this.ficheId, super.key});

  final String ficheId;

  @override
  State<GrossisteFicheStep3Screen> createState() =>
      _GrossisteFicheStep3ScreenState();
}

class _GrossisteFicheStep3ScreenState extends State<GrossisteFicheStep3Screen> {
  int _selectedPlan = 1;
  bool _isPaying = false;

  static const _plans = [
    (
      label: "Standard",
      price: "8 000 F/mois",
      perk: "Fiche visible + 1 catégorie",
    ),
    (
      label: "Pro",
      price: "15 000 F/mois",
      perk: "Fiche mise en avant + 3 catégories",
    ),
    (
      label: "Premium",
      price: "25 000 F/mois",
      perk: "Fiche certifiée + catégories illimitées",
    ),
  ];

  Future<void> _pay() async {
    setState(() => _isPaying = true);
    // TODO(backend): brancher le vrai paiement Mobile Money (domaine
    // Paiements, pas encore développé) — simulation pour l'instant.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.go(AppRoutes.grossisteDashboard);
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
                        "Créer ma fiche",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "3/3",
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Choisissez votre abonnement",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Nécessaire pour publier votre fiche dans l'annuaire MboaLink.",
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 18),
                        for (var i = 0; i < _plans.length; i++) ...[
                          _PlanTile(
                            label: _plans[i].label,
                            price: _plans[i].price,
                            perk: _plans[i].perk,
                            isSelected: _selectedPlan == i,
                            onTap: () => setState(() => _selectedPlan = i),
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Symbols.info,
                                size: 17,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Votre fiche reste en attente de validation par notre équipe même "
                                  "après paiement — l'abonnement active la visibilité dès l'approbation.",
                                  style: AppTypography.bodySmall.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        PrimaryButton(
                          label: "Payer via Mobile Money",
                          trailingIcon: Symbols.arrow_forward,
                          isLoading: _isPaying,
                          onPressed: _pay,
                        ),
                      ],
                    ),
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

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.label,
    required this.price,
    required this.perk,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String price;
  final String perk;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.successBg : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(perk, style: AppTypography.caption),
                  ],
                ),
              ),
              Text(
                price,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Symbols.check_circle
                    : Symbols.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textFaint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
