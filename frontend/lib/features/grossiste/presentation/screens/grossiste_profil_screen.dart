import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../domain/entities/grossiste_dashboard_status.dart";
import "../providers/grossiste_providers.dart";
import "grossiste_nav_bar.dart";

/// Onglet "Profil" (index 3) du tableau de bord Grossiste.
///
/// En état [enAttenteAbonnement] : affiche uniquement le paiement
/// d'abonnement (obligatoire pour accéder au dashboard complet) +
/// la déconnexion. Aucune autre option n'est disponible à ce stade.
///
/// En état [validee] : affiche en plus tous les paramètres du compte.
class GrossisteProfilScreen extends ConsumerStatefulWidget {
  const GrossisteProfilScreen({super.key});

  @override
  ConsumerState<GrossisteProfilScreen> createState() =>
      _GrossisteProfilScreenState();
}

class _GrossisteProfilScreenState extends ConsumerState<GrossisteProfilScreen> {
  int _selectedPlan = 0;
  bool _isPaying = false;

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  Future<void> _payer(String ficheId) async {
    setState(() => _isPaying = true);
    try {
      await ref.read(grossisteRepositoryProvider).payerAbonnement(ficheId);
      ref.invalidate(maFicheProvider);
      if (!mounted) return;
      // Retour au dashboard — maintenant en état "validée"
      context.go(AppRoutes.grossisteDashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur lors du paiement : $e")));
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  Future<void> _logout() async {
    try {
      await ref.read(authRepositoryProvider).deconnecter("");
    } catch (_) {}
    await ref.read(sessionStorageProvider).clear();
    ref.read(currentSessionProvider.notifier).state = null;
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final ficheAsync = ref.watch(maFicheProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return ficheAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text("Erreur de chargement"))),
      data: (fiche) {
        final isPaymentRequired =
            fiche.dashboardStatus ==
            GrossisteDashboardStatus.enAttenteAbonnement;

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
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mon profil",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Carte entreprise
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.successBg,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Symbols.storefront,
                                      size: 25,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fiche.nomEntreprise ??
                                              "Mon entreprise",
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (fiche.emailProfessionnel != null)
                                          Text(
                                            fiche.emailProfessionnel!,
                                            style: AppTypography.caption,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Bloc abonnement ──────────────────────────
                            if (isPaymentRequired) ...[
                              // Bandeau important — paiement obligatoire
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: AppColors.warningBg,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Symbols.info,
                                      size: 17,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Vos documents ont été validés. Choisissez un plan et activez votre abonnement "
                                        "pour publier votre fiche dans l'annuaire MboaLink.",
                                        style: AppTypography.bodySmall.copyWith(
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            Text(
                              "Mon abonnement",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isPaymentRequired) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Plan actif",
                                                style: GoogleFonts.manrope(
                                                  fontSize: 11,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.65),
                                                ),
                                              ),
                                              Text(
                                                "Pro · 15 000 F/mois",
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            "Actif",
                                            style: GoogleFonts.manrope(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Expire le 12 juillet 2026",
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Divider(color: Colors.white24),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Renouveler ou changer de plan",
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ] else ...[
                                    Text(
                                      "Choisissez votre plan",
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],

                                  // Plan Mensuel
                                  _PlanTile(
                                    label: "Mensuel",
                                    detail: "Sans engagement",
                                    price: "2 000 F",
                                    unit: "/ mois",
                                    isSelected: _selectedPlan == 0,
                                    onTap: () =>
                                        setState(() => _selectedPlan = 0),
                                  ),
                                  const SizedBox(height: 8),

                                  // Plan Annuel
                                  _PlanTile(
                                    label: "Annuel",
                                    detail: "20 000 F / an",
                                    price: "1 666 F",
                                    unit: "/ mois",
                                    badge: "-2 MOIS",
                                    isSelected: _selectedPlan == 1,
                                    onTap: () =>
                                        setState(() => _selectedPlan = 1),
                                  ),
                                  const SizedBox(height: 14),

                                  // Bouton payer
                                  Material(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _isPaying
                                          ? null
                                          : () => _payer(fiche.id),
                                      child: SizedBox(
                                        height: 48,
                                        child: Center(
                                          child: _isPaying
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                )
                                              : Text(
                                                  _selectedPlan == 0
                                                      ? "Payer via Mobile Money · 2 000 F/mois"
                                                      : "Payer via Mobile Money · 20 000 F/an",
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Paramètres — masqués si en attente de paiement
                            if (!isPaymentRequired) ...[
                              Text(
                                "Paramètres",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _SettingsTile(
                                icon: Symbols.visibility,
                                label: "Prévisualiser ma fiche",
                                onTap: () =>
                                    _comingSoon("Prévisualiser ma fiche"),
                              ),
                              _SettingsTile(
                                icon: Symbols.swap_horiz,
                                label: "Basculer en compte Client",
                                onTap: () =>
                                    _comingSoon("Basculer en compte Client"),
                              ),
                              _SettingsTile(
                                icon: Symbols.support_agent,
                                label: "Contacter le service client",
                                onTap: () => _comingSoon("Service client"),
                              ),
                              _SettingsTile(
                                icon: Symbols.shield_person,
                                label: "Confidentialité & données",
                                onTap: () => _comingSoon("Confidentialité"),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Déconnexion — toujours visible
                            _SettingsTile(
                              icon: Symbols.logout,
                              label: "Se déconnecter",
                              onTap: _logout,
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Navbar : réduite si en attente de paiement
                    if (isPaymentRequired)
                      _PaymentOnlyNavBar()
                    else
                      const GrossisteNavBar(activeIndex: 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Navbar minimale dans l'écran Profil quand l'abonnement n'est pas payé.
class _PaymentOnlyNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.background)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DisabledNavItem(icon: Symbols.dashboard, label: "Dashboard"),
          _DisabledNavItem(icon: Symbols.storefront, label: "Boutique"),
          _DisabledNavItem(icon: Symbols.badge, label: "Fiche"),
          _ActiveNavItem(icon: Symbols.person, label: "Profil"),
        ],
      ),
    );
  }
}

class _DisabledNavItem extends StatelessWidget {
  const _DisabledNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 23, color: AppColors.textFaint),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveNavItem extends StatelessWidget {
  const _ActiveNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 23, color: AppColors.primary, fill: 1),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.label,
    required this.detail,
    required this.price,
    required this.unit,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String detail;
  final String price;
  final String unit;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    detail,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Material(
      color: isDestructive ? AppColors.errorBg : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 18,
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.5)
                    : AppColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
