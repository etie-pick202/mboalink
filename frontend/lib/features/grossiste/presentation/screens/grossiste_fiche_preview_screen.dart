import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../home/domain/entities/avis.dart";
import "../../../home/presentation/providers/home_providers.dart";
import "../../domain/entities/fiche_verification_statut.dart";
import "../../domain/entities/produit_grossite.dart";
import "../providers/grossiste_providers.dart";
import "grossiste_nav_bar.dart";

/// Onglet "Fiche" (index 2) du tableau de bord Grossiste — conforme à la
/// revue de changement : prévisualisation du profil tel qu'il est affiché
/// aux clients (photo, note, produits, avis). Contact masqué car payant.
class GrossisteFichePreviewScreen extends ConsumerWidget {
  const GrossisteFichePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficheAsync = ref.watch(maFicheProvider);
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
            child: ficheAsync.when(
              loading: () => const Center(child: AppLoader()),
              error: (error, _) => AppErrorView(
                error: error,
                fallbackMessage: "Impossible de charger votre fiche.",
                onRetry: () => ref.invalidate(maFicheProvider),
              ),
              data: (fiche) {
                final produitsAsync = ref.watch(ficheProduits(fiche.id));
                final avisAsync = ref.watch(avisListProvider(fiche.id));

                return Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          // Bannière
                          SliverToBoxAdapter(
                            child: Stack(
                              children: [
                                Container(
                                  height: 160,
                                  width: double.infinity,
                                  color: AppColors.successBg,
                                  child: Center(
                                    child:
                                        fiche.logoUrl != null &&
                                            fiche.logoUrl!.isNotEmpty &&
                                            !fiche.logoUrl!.startsWith(
                                              "mock://",
                                            )
                                        ? Image.network(
                                            fiche.logoUrl!,
                                            width: double.infinity,
                                            height: 160,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Symbols.storefront,
                                            size: 48,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      "Vue client — Aperçu",
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                // Nom + badge vérifié
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fiche.nomEntreprise ??
                                            "Nom de l'entreprise",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (fiche.statutVerification ==
                                        FicheVerificationStatut.verifie) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Symbols.verified,
                                        size: 18,
                                        color: Color(0xFF1D9BF0),
                                      ),
                                    ],
                                    if (fiche.certifiePremium) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Symbols.workspace_premium,
                                        size: 18,
                                        fill: 1,
                                        color: AppColors.accent,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (fiche.secteurActivite != null)
                                  Text(
                                    fiche.secteurActivite!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Note réelle (NotationService — mêmes données
                                // que la fiche publique vue par les clients).
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < (fiche.noteMoyenne ?? 0).round()
                                            ? Symbols.star
                                            : Symbols.star_border,
                                        size: 15,
                                        color: AppColors.accent,
                                        fill: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (fiche.noteMoyenne ?? 0).toStringAsFixed(
                                        1,
                                      ),
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "(${fiche.nombreAvis} avis)",
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                if (fiche.description != null) ...[
                                  Text(
                                    fiche.description!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textMuted,
                                      height: 1.55,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                const Divider(),
                                const SizedBox(height: 12),

                                // Localisation
                                if (fiche.ville != null) ...[
                                  _InfoRow(
                                    icon: Symbols.location_on,
                                    label: [
                                      fiche.adresseComplete,
                                      fiche.quartier,
                                      fiche.ville,
                                    ].whereType<String>().join(", "),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Contacts masqués — payant (MoMo/OM, conforme revue)
                                const _InfoRow(
                                  icon: Symbols.call,
                                  label:
                                      "Contact téléphonique — déverrouillage payant (MoMo / OM)",
                                  muted: true,
                                ),
                                const SizedBox(height: 8),
                                const _InfoRow(
                                  icon: Symbols.mail,
                                  label:
                                      "Email professionnel — déverrouillage payant",
                                  muted: true,
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),

                                // Produits
                                Text(
                                  "Produits disponibles",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                produitsAsync.when(
                                  data: (produits) {
                                    if (produits.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          "Aucun produit ajouté.",
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.textMuted,
                                              ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: produits
                                          .map(
                                            (p) =>
                                                _ProduitPreviewTile(produit: p),
                                          )
                                          .toList(),
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: AppLoader(size: 18),
                                  ),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 14),
                                const Divider(),
                                const SizedBox(height: 12),

                                // Avis — section enrichie (conforme revue de changement)
                                Text(
                                  "Avis clients",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                avisAsync.when(
                                  data: (avis) {
                                    if (avis.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          "Aucun avis pour l'instant.",
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.textMuted,
                                              ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: [
                                        for (final a in avis.take(5)) ...[
                                          _AvisTile(avis: a),
                                          const SizedBox(height: 8),
                                        ],
                                      ],
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: AppLoader(size: 18),
                                  ),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 24),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const GrossisteNavBar(activeIndex: 2),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.muted = false});

  final IconData icon;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: muted ? AppColors.textFaint : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: muted ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProduitPreviewTile extends StatelessWidget {
  const _ProduitPreviewTile({required this.produit});

  // Typage explicite — évite l'inférence dynamic et le warning unnecessary_underscores.
  final ProduitGrossiste produit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                produit.imageUrl != null &&
                    produit.imageUrl!.isNotEmpty &&
                    !produit.imageUrl!.startsWith("mock://")
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(produit.imageUrl!, fit: BoxFit.cover),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produit.nom,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (produit.categorie != null)
                  Text(produit.categorie!, style: AppTypography.caption),
              ],
            ),
          ),
          if (produit.prixUnitaire != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${produit.prixUnitaire!.toStringAsFixed(0)} F",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (produit.uniteMesure != null)
                  Text(
                    "/ ${produit.uniteMesure}",
                    style: AppTypography.caption,
                  ),
              ],
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
    return "à l'instant";
  }

  @override
  Widget build(BuildContext context) {
    final initiale = avis.utilisateurNom.isNotEmpty
        ? avis.utilisateurNom[0].toUpperCase()
        : "?";
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.successBg,
                child: Text(
                  initiale,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  avis.utilisateurNom,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(_formatDate(avis.creeLe), style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Symbols.star,
                size: 13,
                color: i < avis.note ? AppColors.accent : AppColors.border,
                fill: 1,
              ),
            ),
          ),
          if (avis.commentaire != null && avis.commentaire!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              avis.commentaire!,
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
