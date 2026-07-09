import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../widgets/client_nav_bar.dart";

/// Onglet "Débloqués" (index 2) — liste des grossistes dont le client
/// a payé pour voir les coordonnées (MoMo / OM, conforme à la revue).
/// Données statiques en Workflow A ; flux réel branché en Workflow B
/// (endpoint GET /utilisateurs/me/deverrouillages).
class ClientDeblocagesScreen extends StatelessWidget {
  const ClientDeblocagesScreen({super.key});

  static const _mockDebloques = [
    (
      nom: "Ets Tchana & Fils",
      secteur: "Alimentation · Douala",
      tel: "+237 699 112 233",
      date: "3 juin 2026",
    ),
    (
      nom: "Kana Distribution",
      secteur: "Cosmétique · Yaoundé",
      tel: "+237 677 001 122",
      date: "18 mai 2026",
    ),
  ];

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Contacts débloqués",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${_mockDebloques.length}",
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _mockDebloques.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Symbols.lock_open,
                                size: 42,
                                color: AppColors.textFaint,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Aucun contact débloqué",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  "Déverrouillez les coordonnées d'un grossiste via son profil (MoMo ou Orange Money).",
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          itemCount: _mockDebloques.length,
                          itemBuilder: (ctx, i) {
                            final d = _mockDebloques[i];
                            return _DebloqueTile(
                              nom: d.nom,
                              secteur: d.secteur,
                              tel: d.tel,
                              date: d.date,
                            );
                          },
                        ),
                      ),
                const ClientNavBar(activeIndex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebloqueTile extends StatelessWidget {
  const _DebloqueTile({
    required this.nom,
    required this.secteur,
    required this.tel,
    required this.date,
  });

  final String nom;
  final String secteur;
  final String tel;
  final String date;

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Symbols.storefront,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(secteur, style: AppTypography.caption),
                  ],
                ),
              ),
              Text("le $date", style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ContactBtn(
                  icon: Symbols.call,
                  label: tel,
                  color: AppColors.primary,
                  onTap: () => _comingSoon(context, "Appel"),
                ),
              ),
              const SizedBox(width: 8),
              _ContactBtn(
                icon: Icons.message,
                label: "WhatsApp",
                color: const Color(0xFF25D366),
                onTap: () => _comingSoon(context, "WhatsApp"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
