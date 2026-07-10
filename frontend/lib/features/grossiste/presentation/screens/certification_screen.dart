import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../payment/domain/entities/paiement_params.dart";
import "../../../payment/domain/entities/transaction_paiement.dart";
import "../../../payment/presentation/providers/payment_providers.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../providers/grossiste_providers.dart";

/// Écran 27 · Certification & réinitialisation de note — conforme à la
/// maquette : badge "Certification premium" (25000 F, paiement unique)
/// et "Réinitialisation de note" (10000 F, usage unique par grossiste).
class CertificationScreen extends ConsumerWidget {
  const CertificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fiche = ref.watch(maFicheProvider);
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
                        "Visibilité & réputation",
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
                  child: fiche.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: Text(
                        "Impossible de charger votre fiche.",
                        style: AppTypography.bodySmall,
                      ),
                    ),
                    data: (f) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CertificationCard(
                            certifie: f.certifiePremium,
                            onDemander: () => context.push(
                              AppRoutes.paiementChoix,
                              extra: PaiementParams(
                                type: TypeTransaction.certificationPremium,
                                montant: 25000,
                                description: "Certification premium",
                                ficheGrossisteId: f.id,
                                nomGrossiste: f.nomEntreprise,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "RÉINITIALISATION DE NOTE",
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 9),
                          _ReinitCard(fiche: f),
                        ],
                      ),
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

class _CertificationCard extends StatelessWidget {
  const _CertificationCard({required this.certifie, required this.onDemander});

  final bool certifie;
  final VoidCallback onDemander;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4C430), Color(0xFFE0A91C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Symbols.workspace_premium,
              size: 90,
              color: Colors.white.withValues(alpha: 0.18),
              fill: 1,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  certifie ? "ACTIF" : "OPTIONNEL",
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Certification premium",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Badge renforcé, meilleure visibilité dans les résultats et confiance accrue.",
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              if (!certifie)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "25 000 F",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "paiement unique",
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: Material(
                  color: certifie
                      ? Colors.white.withValues(alpha: 0.35)
                      : AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: certifie ? null : onDemander,
                    child: Center(
                      child: Text(
                        certifie ? "Fiche certifiée" : "Demander le badge",
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: certifie
                              ? AppColors.textPrimary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReinitCard extends ConsumerWidget {
  const _ReinitCard({required this.fiche});

  final FicheGrossiste fiche;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dejaUtilise = ref.watch(aDejaReinitialiseNoteProvider(fiche.id));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Symbols.restart_alt,
                  size: 21,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Repartir de zéro",
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Note actuelle : ${fiche.noteMoyenne?.toStringAsFixed(1) ?? "—"} (${fiche.nombreAvis} avis)",
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            "Réinitialise votre note moyenne. Disponible une seule fois par grossiste.",
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          dejaUtilise.when(
            loading: () => const SizedBox(
              height: 38,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (utilise) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "10 000 F",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: utilise
                          ? null
                          : () => context.push(
                              AppRoutes.paiementChoix,
                              extra: PaiementParams(
                                type: TypeTransaction.reinitialisationNote,
                                montant: 10000,
                                description: "Réinitialisation de note",
                                ficheGrossisteId: fiche.id,
                                nomGrossiste: fiche.nomEntreprise,
                              ),
                            ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: utilise ? AppColors.border : AppColors.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            utilise ? "Déjà utilisé" : "Demander",
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: utilise
                                  ? AppColors.textMuted
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
