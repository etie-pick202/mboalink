import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../domain/entities/revenu_mensuel.dart";
import "../providers/admin_providers.dart";
import "../widgets/admin_nav_bar.dart";

/// Écran 31 · Revenus — total encaissé et répartition par mois sur les
/// 4 derniers mois (la partie "publicité" de la maquette n'existe pas
/// encore côté backend — volontairement absente ici).
class AdminRevenusScreen extends ConsumerWidget {
  const AdminRevenusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenusAsync = ref.watch(revenusDerniers4MoisProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        "Revenus",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: revenusAsync.when(
                    loading: () => const Center(child: AppLoader()),
                    error: (error, _) => AppErrorView(
                      error: error,
                      fallbackMessage: "Impossible de charger les revenus.",
                      onRetry: () =>
                          ref.invalidate(revenusDerniers4MoisProvider),
                    ),
                    data: (revenus) => _RevenusBody(revenus: revenus),
                  ),
                ),
                const AdminNavBar(activeIndex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RevenusBody extends StatelessWidget {
  const _RevenusBody({required this.revenus});

  final List<RevenuMensuel> revenus;

  @override
  Widget build(BuildContext context) {
    final total = revenus.fold<double>(0, (sum, r) => sum + r.total);
    final moisEnCours = revenus.isEmpty ? null : revenus.last;
    final max = revenus.isEmpty
        ? 1.0
        : revenus
              .map((r) => r.total)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, 1 << 30);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1F17),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total encaissé (4 derniers mois)",
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${total.toStringAsFixed(0)} F",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (moisEnCours != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${moisEnCours.mois} : ${moisEnCours.total.toStringAsFixed(0)} F",
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7EE0A8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "PAR MOIS",
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (revenus.isEmpty)
            Text(
              "Aucune donnée de revenu pour l'instant.",
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            )
          else
            for (final r in revenus) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r.mois,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${r.total.toStringAsFixed(0)} F",
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: r.total / max,
                        minHeight: 7,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
