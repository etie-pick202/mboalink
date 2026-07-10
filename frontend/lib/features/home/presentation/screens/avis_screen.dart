import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../domain/entities/avis.dart";
import "../providers/home_providers.dart";

/// Écran 16 · Avis & évaluations — moyenne, répartition par étoile et
/// liste des avis visibles pour une fiche grossiste.
class AvisScreen extends ConsumerWidget {
  const AvisScreen({
    required this.ficheId,
    required this.nomEntreprise,
    this.dejaDeverrouille = false,
    super.key,
  });

  final String ficheId;
  final String nomEntreprise;
  final bool dejaDeverrouille;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(avisBreakdownProvider(ficheId));
    final avis = ref.watch(avisListProvider(ficheId));
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
                      Expanded(
                        child: Text(
                          breakdown.value != null
                              ? "Avis (${breakdown.value!.total})"
                              : "Avis",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (dejaDeverrouille)
                        TextButton(
                          onPressed: () => context.push(
                            AppRoutes.laisserAvis,
                            extra: {
                              "ficheId": ficheId,
                              "nomEntreprise": nomEntreprise,
                            },
                          ),
                          child: const Text("Laisser un avis"),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        breakdown.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (b) => _BreakdownCard(breakdown: b),
                        ),
                        const SizedBox(height: 14),
                        avis.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, _) => Text(
                            "Impossible de charger les avis.",
                            style: AppTypography.bodySmall,
                          ),
                          data: (liste) => liste.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Aucun avis pour l'instant.",
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (final a in liste) _AvisTile(avis: a),
                                  ],
                                ),
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

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.breakdown});

  final AvisBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final max = breakdown.max == 0 ? 1 : breakdown.max;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                breakdown.moyenne.toStringAsFixed(1),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Symbols.star,
                    size: 13,
                    fill: 1,
                    color: i < breakdown.moyenne.round()
                        ? AppColors.accent
                        : AppColors.borderLight,
                  ),
                ),
              ),
              Text("${breakdown.total} avis", style: AppTypography.caption),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _BarRow(label: "5", value: breakdown.cinq, max: max),
                _BarRow(label: "4", value: breakdown.quatre, max: max),
                _BarRow(label: "3", value: breakdown.trois, max: max),
                _BarRow(label: "2", value: breakdown.deux, max: max),
                _BarRow(label: "1", value: breakdown.un, max: max),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.label, required this.value, required this.max});

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 10,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value / max,
                minHeight: 5,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisTile extends StatelessWidget {
  const _AvisTile({required this.avis});

  final Avis avis;

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 7) return "il y a ${(diff.inDays / 7).floor()} sem";
    if (diff.inDays >= 1) return "il y a ${diff.inDays} j";
    if (diff.inHours >= 1) return "il y a ${diff.inHours} h";
    return "à l'instant";
  }

  @override
  Widget build(BuildContext context) {
    final initiale = avis.utilisateurNom.isNotEmpty
        ? avis.utilisateurNom[0].toUpperCase()
        : "?";
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
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
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.successBg,
                child: Text(
                  initiale,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          avis.utilisateurNom,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (avis.transactionVerifiee) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Symbols.verified,
                            size: 13,
                            fill: 1,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      "${avis.transactionVerifiee ? "Achat vérifié · " : ""}${_formatDate(avis.creeLe)}",
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Symbols.star,
                    size: 12,
                    fill: 1,
                    color: i < avis.note
                        ? AppColors.accent
                        : AppColors.borderLight,
                  ),
                ),
              ),
            ],
          ),
          if (avis.commentaire != null && avis.commentaire!.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              avis.commentaire!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
