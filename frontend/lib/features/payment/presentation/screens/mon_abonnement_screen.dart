import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../domain/entities/abonnement.dart";
import "../../domain/entities/paiement_params.dart";
import "../../domain/entities/recu.dart";
import "../../domain/entities/transaction_paiement.dart";
import "../providers/payment_providers.dart";

/// Écran 26 · Abonnement grossiste — plan actif, renouvellement,
/// historique des paiements, suspension. GET /abonnements/my, /recus/user/recent.
class MonAbonnementScreen extends ConsumerWidget {
  const MonAbonnementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnementAsync = ref.watch(monAbonnementProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
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
                    "Mon abonnement",
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
              child: abonnementAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (error, _) => AppErrorView(
                  error: error,
                  fallbackMessage: "Impossible de charger votre abonnement.",
                  onRetry: () => ref.invalidate(monAbonnementProvider),
                ),
                data: (abonnement) => abonnement == null
                    ? Center(
                        child: Text(
                          "Aucun abonnement pour l'instant.",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : _AbonnementBody(abonnement: abonnement),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbonnementBody extends ConsumerStatefulWidget {
  const _AbonnementBody({required this.abonnement});

  final Abonnement abonnement;

  @override
  ConsumerState<_AbonnementBody> createState() => _AbonnementBodyState();
}

class _AbonnementBodyState extends ConsumerState<_AbonnementBody> {
  bool _isSuspending = false;

  Future<void> _suspendre() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Suspendre l'abonnement ?"),
        content: const Text(
          "Votre fiche ne sera plus visible dans l'annuaire tant que "
          "l'abonnement n'est pas réactivé.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Suspendre",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _isSuspending = true);
    try {
      await ref.read(paymentRepositoryProvider).suspendreAbonnement();
      ref.invalidate(monAbonnementProvider);
    } finally {
      if (mounted) setState(() => _isSuspending = false);
    }
  }

  void _renouveler() {
    final abonnement = widget.abonnement;
    context.push(
      AppRoutes.paiementChoix,
      extra: PaiementParams(
        type: TypeTransaction.abonnement,
        montant: abonnement.montant,
        description: "Renouvellement abonnement grossiste",
        typeAbonnement: abonnement.typeAbonnement,
        abonnementExistant: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final abonnement = widget.abonnement;
    final recusAsync = ref.watch(mesRecusProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      abonnement.typeAbonnement == "ANNUEL"
                          ? "Plan Annuel"
                          : "Plan Mensuel",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _StatutBadge(statut: abonnement.statut),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${abonnement.montant.toStringAsFixed(0)} F",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      abonnement.typeAbonnement == "ANNUEL"
                          ? " / an"
                          : " / mois",
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                if (abonnement.statut == StatutAbonnement.actif) ...[
                  const SizedBox(height: 10),
                  Text(
                    "Expire le ${_formatDate(abonnement.dateFin)}"
                    "${abonnement.joursRestants != null ? " · ${abonnement.joursRestants} j restants" : ""}",
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (abonnement.statut != StatutAbonnement.actif)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Symbols.info, size: 17, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Votre abonnement n'est plus actif. Renouvelez-le pour "
                      "que votre fiche reste visible dans l'annuaire.",
                      style: AppTypography.bodySmall.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _renouveler,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    "Renouveler maintenant",
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          if (abonnement.statut != StatutAbonnement.actif) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: _renouveler,
                  child: Center(
                    child: Text(
                      "Renouveler mon abonnement",
                      style: AppTypography.button,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            "HISTORIQUE DES PAIEMENTS",
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 9),
          recusAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: AppLoader(size: 18),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (recus) => recus.isEmpty
                ? Text(
                    "Aucun paiement enregistré.",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      children: [
                        for (final r in recus.take(5)) _RecuRow(recu: r),
                      ],
                    ),
                  ),
          ),
          if (abonnement.statut == StatutAbonnement.actif) ...[
            const SizedBox(height: 22),
            Center(
              child: TextButton(
                onPressed: _isSuspending ? null : _suspendre,
                child: Text(
                  "Suspendre l'abonnement",
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const mois = [
      "jan",
      "fév",
      "mar",
      "avr",
      "mai",
      "juin",
      "juil",
      "août",
      "sep",
      "oct",
      "nov",
      "déc",
    ];
    return "${date.day} ${mois[date.month - 1]} ${date.year}";
  }
}

class _StatutBadge extends StatelessWidget {
  const _StatutBadge({required this.statut});

  final StatutAbonnement statut;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (statut) {
      StatutAbonnement.actif => (
        "ACTIF",
        AppColors.primary,
        AppColors.successBg,
      ),
      StatutAbonnement.suspendu => (
        "SUSPENDU",
        AppColors.error,
        AppColors.errorBg,
      ),
      StatutAbonnement.annule => (
        "ANNULÉ",
        AppColors.textFaint,
        AppColors.surfaceAlt,
      ),
      StatutAbonnement.expire => (
        "EXPIRÉ",
        AppColors.warning,
        AppColors.warningBg,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _RecuRow extends StatelessWidget {
  const _RecuRow({required this.recu});

  final Recu recu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.background)),
      ),
      child: Row(
        children: [
          const Icon(Symbols.receipt, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${recu.creeLe.day}/${recu.creeLe.month}/${recu.creeLe.year}"
              "${recu.operateur != null ? " · ${recu.operateur}" : ""}",
              style: AppTypography.caption,
            ),
          ),
          Text(
            "${recu.montantTotal.toStringAsFixed(0)} F",
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
