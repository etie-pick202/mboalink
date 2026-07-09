import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../widgets/client_nav_bar.dart";

/// Écran 06 · Accueil Client — conforme à la maquette MboaLink.
/// Navbar Client réelle (Accueil | Recherche | Débloqués | Profil).
/// Le fil de recommandation réel (Workflow B) sera branché plus tard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  @override
  Widget build(BuildContext context) {
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
                                  "Bonjour 👋",
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
                                  _comingSoon(context, "Notifications"),
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
                          onTap: () => _comingSoon(context, "Recherche"),
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
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _CategoryChip(
                                icon: Symbols.rice_bowl,
                                label: "Vivres",
                                bg: AppColors.successBg,
                                fg: AppColors.primary,
                                onTap: () => _comingSoon(context, "Vivres"),
                              ),
                              _CategoryChip(
                                icon: Symbols.checkroom,
                                label: "Textile",
                                bg: AppColors.warningBg,
                                fg: AppColors.warning,
                                onTap: () => _comingSoon(context, "Textile"),
                              ),
                              _CategoryChip(
                                icon: Symbols.spa,
                                label: "Cosméto",
                                bg: AppColors.successBg,
                                fg: AppColors.primary,
                                onTap: () => _comingSoon(context, "Cosméto"),
                              ),
                              _CategoryChip(
                                icon: Symbols.devices,
                                label: "Électro",
                                bg: AppColors.warningBg,
                                fg: AppColors.warning,
                                onTap: () => _comingSoon(context, "Électro"),
                              ),
                              _CategoryChip(
                                icon: Symbols.build,
                                label: "Quincail.",
                                bg: AppColors.surfaceAlt,
                                fg: AppColors.textMuted,
                                onTap: () =>
                                    _comingSoon(context, "Quincaillerie"),
                              ),
                            ],
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
                        _WholesalerCard(
                          nom: "Ets Tchana & Fils",
                          verifie: true,
                          description: "Riz, huile, sucre · Mboppi",
                          note: "4.8",
                          distance: "1,2 km",
                          onTap: () => _comingSoon(context, "Fiche grossiste"),
                        ),
                        const SizedBox(height: 10),
                        _WholesalerCard(
                          nom: "Sané Cosmetics",
                          verifie: false,
                          description: "Cosmétiques en gros · Akwa",
                          note: "4.9",
                          distance: "2,6 km",
                          onTap: () => _comingSoon(context, "Fiche grossiste"),
                        ),
                        const SizedBox(height: 10),
                        _WholesalerCard(
                          nom: "Kana Distribution",
                          verifie: true,
                          description: "Hygiène & beauté · Mvog-Mbi",
                          note: "4.7",
                          distance: "3,1 km",
                          onTap: () => _comingSoon(context, "Fiche grossiste"),
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
  const _WholesalerCard({
    required this.nom,
    required this.verifie,
    required this.description,
    required this.note,
    required this.distance,
    required this.onTap,
  });

  final String nom;
  final bool verifie;
  final String description;
  final String note;
  final String distance;
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
                child: const Icon(
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
                            nom,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (verifie) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Symbols.verified,
                            size: 15,
                            color: Color(0xFF1D9BF0),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(description, style: AppTypography.caption),
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
                          note,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                            distance,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
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
