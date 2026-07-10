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
import "../../../payment/domain/entities/paiement_params.dart";
import "../../../payment/domain/entities/transaction_paiement.dart";
import "../../domain/entities/fiche_publique.dart";
import "../providers/home_providers.dart";

/// Écran 10 · Fiche grossiste (vue publique) — GET /grossistes/{ficheId}.
/// Les coordonnées (téléphone/email) restent masquées tant que la fiche
/// n'est pas déverrouillée (GET .../deverrouille). Prix dynamique — varie
/// avec la popularité de la fiche (plancher 5000 FCFA, voir PopulariteService).
class FichePubliqueScreen extends ConsumerStatefulWidget {
  const FichePubliqueScreen({required this.ficheId, super.key});

  final String ficheId;

  @override
  ConsumerState<FichePubliqueScreen> createState() =>
      _FichePubliqueScreenState();
}

class _FichePubliqueScreenState extends ConsumerState<FichePubliqueScreen> {
  @override
  void initState() {
    super.initState();
    // Best-effort — alimente le score de popularité côté backend.
    ref.read(rechercheRepositoryProvider).enregistrerVueFiche(widget.ficheId);
  }

  @override
  Widget build(BuildContext context) {
    final ficheId = widget.ficheId;
    final ficheAsync = ref.watch(fichePubliqueProvider(ficheId));
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

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
                  Expanded(
                    child: Text(
                      "Fiche grossiste",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _FavoriButton(ficheId: ficheId),
                ],
              ),
            ),
            Expanded(
              child: ficheAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (error, _) => AppErrorView(
                  error: error,
                  fallbackMessage: "Impossible de charger cette fiche.",
                  onRetry: () => ref.invalidate(fichePubliqueProvider(ficheId)),
                ),
                data: (fiche) => Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 480 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 66,
                                height: 66,
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child:
                                    fiche.logoUrl != null &&
                                        fiche.logoUrl!.isNotEmpty &&
                                        !fiche.logoUrl!.startsWith("mock://")
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          fiche.logoUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Symbols.storefront,
                                        size: 30,
                                        color: AppColors.primary,
                                      ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            fiche.nomEntreprise,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (fiche.certifie) ...[
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Symbols.verified,
                                            size: 16,
                                            color: Color(0xFF1D9BF0),
                                          ),
                                        ],
                                        if (fiche.certifiePremium) ...[
                                          const SizedBox(width: 5),
                                          Icon(
                                            Symbols.workspace_premium,
                                            size: 16,
                                            fill: 1,
                                            color: AppColors.accent,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      [
                                        fiche.secteurActivite,
                                        fiche.quartier ?? fiche.ville,
                                      ].whereType<String>().join(" · "),
                                      style: AppTypography.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        final deverrouille =
                                            ref
                                                .read(
                                                  estDeverrouilleProvider(
                                                    ficheId,
                                                  ),
                                                )
                                                .value ??
                                            false;
                                        context.push(
                                          AppRoutes.avis,
                                          extra: {
                                            "ficheId": ficheId,
                                            "nomEntreprise":
                                                fiche.nomEntreprise,
                                            "dejaDeverrouille": deverrouille,
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Symbols.star,
                                            size: 14,
                                            color: AppColors.accent,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            fiche.noteMoyenne?.toStringAsFixed(
                                                  1,
                                                ) ??
                                                "—",
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            " (${fiche.nombreAvis ?? 0} avis)",
                                            style: AppTypography.caption,
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Symbols.chevron_right,
                                            size: 14,
                                            color: AppColors.textFaint,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (fiche.description != null &&
                              fiche.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              fiche.description!,
                              style: AppTypography.bodySmall.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          _CoordonneesCard(ficheId: ficheId, fiche: fiche),
                          if (fiche.produits.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              "Produits",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final p in fiche.produits) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child:
                                          p.imageUrl != null &&
                                              p.imageUrl!.isNotEmpty &&
                                              !p.imageUrl!.startsWith("mock://")
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              child: Image.network(
                                                p.imageUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Symbols.inventory_2,
                                              size: 20,
                                              color: AppColors.textMuted,
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.nom,
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          if (p.uniteMesure != null)
                                            Text(
                                              p.uniteMesure!,
                                              style: AppTypography.caption,
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (p.prixUnitaire != null)
                                      Text(
                                        "${p.prixUnitaire!.toStringAsFixed(0)} F",
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriButton extends ConsumerWidget {
  const _FavoriButton({required this.ficheId});

  final String ficheId;

  Future<void> _toggle(WidgetRef ref, bool estFavoriActuel) async {
    final repo = ref.read(rechercheRepositoryProvider);
    if (estFavoriActuel) {
      await repo.retirerFavori(ficheId);
    } else {
      await repo.ajouterFavori(ficheId);
    }
    ref.invalidate(estFavoriProvider(ficheId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriAsync = ref.watch(estFavoriProvider(ficheId));

    return favoriAsync.when(
      loading: () => const SizedBox(width: 23, height: 23),
      error: (_, _) => const SizedBox(width: 23, height: 23),
      data: (estFavori) => GestureDetector(
        onTap: () => _toggle(ref, estFavori),
        child: Icon(
          estFavori ? Symbols.favorite : Symbols.favorite_border,
          size: 23,
          fill: estFavori ? 1 : 0,
          color: estFavori ? AppColors.error : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _CoordonneesCard extends ConsumerWidget {
  const _CoordonneesCard({required this.ficheId, required this.fiche});

  final String ficheId;
  final FichePublique fiche;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deverrouilleAsync = ref.watch(estDeverrouilleProvider(ficheId));

    return deverrouilleAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: AppLoader(size: 18),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (deverrouille) {
        if (!deverrouille) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Symbols.lock,
                      size: 18,
                      color: AppColors.textFaint,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Coordonnées verrouillées",
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Déverrouillez le téléphone et l'email professionnels de "
                  "ce grossiste — valable 24 h.",
                  style: AppTypography.bodySmall.copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.paiementChoix,
                    extra: PaiementParams(
                      type: TypeTransaction.deverrouillageCoordonnees,
                      montant: fiche.prixDeverrouillageActuel,
                      description: "Accès fiche · ${fiche.nomEntreprise}",
                      ficheGrossisteId: ficheId,
                      nomGrossiste: fiche.nomEntreprise,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        "Déverrouiller · ${fiche.prixDeverrouillageActuel.toStringAsFixed(0)} F",
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Symbols.lock_open,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Coordonnées débloquées",
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Le téléphone et l'email de ce grossiste restent visibles "
                "pendant 24 h à partir du déverrouillage.",
                style: AppTypography.bodySmall.copyWith(height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
