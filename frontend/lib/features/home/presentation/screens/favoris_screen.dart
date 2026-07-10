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
import "../../domain/entities/grossiste_resume.dart";
import "../providers/home_providers.dart";

/// Écran "Favoris" — grossistes marqués favoris (GET /favoris), accessible
/// depuis le profil client.
class FavorisScreen extends ConsumerWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorisAsync = ref.watch(mesFavorisProvider);

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
                    "Favoris",
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
              child: favorisAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (error, _) => AppErrorView(
                  error: error,
                  fallbackMessage: "Impossible de charger vos favoris.",
                  onRetry: () => ref.invalidate(mesFavorisProvider),
                ),
                data: (favoris) => favoris.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Symbols.bookmark_border,
                                size: 42,
                                color: AppColors.textFaint,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Aucun favori pour l'instant.",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Ajoutez des grossistes depuis leur fiche.",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textFaint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                        itemCount: favoris.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            _FavoriTile(resume: favoris[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriTile extends StatelessWidget {
  const _FavoriTile({required this.resume});

  final GrossisteResume resume;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push("${AppRoutes.fichePublique}/${resume.id}"),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    resume.logoUrl != null &&
                        resume.logoUrl!.isNotEmpty &&
                        !resume.logoUrl!.startsWith("mock://")
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          resume.logoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Symbols.storefront,
                        size: 24,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            resume.nomEntreprise,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (resume.certifie) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Symbols.verified,
                            size: 14,
                            color: Color(0xFF1D9BF0),
                          ),
                        ],
                        if (resume.certifiePremium) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Symbols.workspace_premium,
                            size: 14,
                            fill: 1,
                            color: AppColors.accent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        resume.secteurActivite,
                        resume.ville,
                      ].whereType<String>().join(" · "),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Symbols.favorite,
                size: 18,
                fill: 1,
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
