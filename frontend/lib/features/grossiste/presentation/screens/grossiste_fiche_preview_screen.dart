import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_loader.dart";
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
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error is AppException
                        ? error.message
                        : "Impossible de charger votre fiche.",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ),
              data: (fiche) {
                final produitsAsync = ref.watch(ficheProduits(fiche.id));

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
                                  child: const Center(
                                    child: Icon(
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
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Symbols.verified,
                                      size: 18,
                                      color: Color(0xFF1D9BF0),
                                    ),
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

                                // Note simulée (conforme revue — enrichissement social)
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < 4
                                            ? Symbols.star
                                            : Symbols.star_half,
                                        size: 15,
                                        color: AppColors.accent,
                                        fill: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "4.8",
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "(127 avis)",
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
                                const _AvisTile(
                                  auteur: "Alice K.",
                                  note: 5,
                                  commentaire:
                                      "Très réactif, produits toujours frais. Je recommande !",
                                  date: "il y a 3 jours",
                                ),
                                const SizedBox(height: 8),
                                const _AvisTile(
                                  auteur: "Jean-Marc T.",
                                  note: 4,
                                  commentaire:
                                      "Bon grossiste, prix compétitifs. Livraison rapide.",
                                  date: "il y a 1 semaine",
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
            child: const Icon(
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
  const _AvisTile({
    required this.auteur,
    required this.note,
    required this.commentaire,
    required this.date,
  });

  final String auteur;
  final int note;
  final String commentaire;
  final String date;

  @override
  Widget build(BuildContext context) {
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
                  auteur[0],
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
                  auteur,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(date, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Symbols.star,
                size: 13,
                color: i < note ? AppColors.accent : AppColors.border,
                fill: 1,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            commentaire,
            style: AppTypography.bodySmall.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
