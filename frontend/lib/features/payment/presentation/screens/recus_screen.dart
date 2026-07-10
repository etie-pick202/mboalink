import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../domain/entities/recu.dart";
import "../providers/payment_providers.dart";

const _libellesType = {
  "ABONNEMENT": "Abonnement grossiste",
  "DEVERROUILLAGE_COORDONNEES": "Déverrouillage contact",
  "REINITIALISATION_NOTE": "Réinitialisation de note",
  "CERTIFICATION_PREMIUM": "Certification premium",
};

/// "Reçus & paiements" — historique des transactions réussies, commun
/// aux rôles Client et Grossiste (GET /recus/user/recent).
class RecusScreen extends ConsumerWidget {
  const RecusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recusAsync = ref.watch(mesRecusProvider);

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
                    "Reçus & paiements",
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
              child: recusAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (error, _) => AppErrorView(
                  error: error,
                  fallbackMessage: "Impossible de charger vos reçus.",
                  onRetry: () => ref.invalidate(mesRecusProvider),
                ),
                data: (recus) => recus.isEmpty
                    ? Center(
                        child: Text(
                          "Aucun paiement pour l'instant.",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                        itemCount: recus.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _RecuTile(recu: recus[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecuTile extends StatelessWidget {
  const _RecuTile({required this.recu});

  final Recu recu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Symbols.receipt,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _libellesType[recu.typeTransaction] ?? recu.typeTransaction,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "${_formatDate(recu.creeLe)} · ${recu.operateur ?? ""}",
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Text(
            "${recu.montantTotal.toStringAsFixed(0)} F",
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
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
