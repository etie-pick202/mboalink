import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/utils/category_icons.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../domain/entities/grossiste_resume.dart";
import "../providers/home_providers.dart";
import "../widgets/client_nav_bar.dart";

/// Écran 06 · Accueil Client — conforme à la maquette MboaLink.
/// Navbar Client réelle (Accueil | Recherche | Débloqués | Profil).
/// Fil d'actualité et catégories branchés sur GET /search/fil-actualite
/// et GET /search/categories.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final filAsync = ref.watch(filActualiteProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final prenom = ref.watch(currentSessionProvider)?.prenom;

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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (prenom != null && prenom.isNotEmpty)
                                      ? "Bonjour, $prenom"
                                      : "Bonjour",
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: 2),
                                GestureDetector(
                                  onTap: () => _comingSoon(
                                    context,
                                    "Changer de localisation",
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Symbols.location_on,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Douala · Mboppi",
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Icon(
                                        Symbols.expand_more,
                                        size: 16,
                                        color: AppColors.textFaint,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.push(AppRoutes.notifications),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Symbols.notifications,
                                      size: 22,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if ((ref.watch(nonLuesCountProvider).value ??
                                          0) >
                                      0)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.surfaceAlt,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Barre recherche
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.clientRecherche),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Symbols.search,
                                  size: 20,
                                  color: AppColors.textFaint,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  "Produit, grossiste, catégorie…",
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textFaint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Catégories
                        SizedBox(
                          height: 78,
                          child: categoriesAsync.when(
                            loading: () =>
                                const Center(child: AppLoader(size: 20)),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (categories) => ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (ctx, i) => _CategoryChip(
                                icon: categoryIcon(categories[i]),
                                label: categories[i],
                                bg: AppColors.successBg,
                                fg: AppColors.primary,
                                onTap: () => context.push(
                                  AppRoutes.clientRecherche,
                                  extra: categories[i],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Fil personnalisé
                        Row(
                          children: [
                            const Icon(
                              Symbols.auto_awesome,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Pour vous · à proximité",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        filAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: AppLoader()),
                          ),
                          error: (error, _) => AppErrorView(
                            error: error,
                            fallbackMessage:
                                "Impossible de charger le fil d'actualité.",
                            onRetry: () => ref.invalidate(filActualiteProvider),
                          ),
                          data: (fil) => fil.resultats.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Text(
                                    "Aucune recommandation pour l'instant.",
                                    style: AppTypography.bodySmall,
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (final g in fil.resultats) ...[
                                      _WholesalerCard(
                                        resume: g,
                                        onTap: () => context.push(
                                          "${AppRoutes.fichePublique}/${g.id}",
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const ClientNavBar(activeIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: fg, size: 24),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WholesalerCard extends StatelessWidget {
  const _WholesalerCard({required this.resume, required this.onTap});

  final GrossisteResume resume;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child:
                    resume.logoUrl != null &&
                        resume.logoUrl!.isNotEmpty &&
                        !resume.logoUrl!.startsWith("mock://")
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          resume.logoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Symbols.storefront,
                        size: 26,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            resume.nomEntreprise,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (resume.certifie) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Symbols.verified,
                            size: 15,
                            color: Color(0xFF1D9BF0),
                          ),
                        ],
                        if (resume.certifiePremium) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Symbols.workspace_premium,
                            size: 15,
                            fill: 1,
                            color: AppColors.accent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      [
                        resume.secteurActivite,
                        resume.quartier ?? resume.ville,
                      ].whereType<String>().join(" · "),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Symbols.star,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          resume.noteMoyenne?.toStringAsFixed(1) ?? "—",
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (resume.distanceKm != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${resume.distanceKm!.toStringAsFixed(1)} km",
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
