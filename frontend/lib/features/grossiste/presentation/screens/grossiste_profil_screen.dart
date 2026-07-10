import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/contact_support_sheet.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../../auth/presentation/screens/biometric_prompt_screen.dart";
import "../../../payment/domain/entities/abonnement.dart";
import "../../../payment/domain/entities/paiement_params.dart";
import "../../../payment/domain/entities/plan.dart";
import "../../../payment/domain/entities/transaction_paiement.dart";
import "../../../payment/presentation/providers/payment_providers.dart";
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
  String? _selectedPlanId;
  bool _isBasculingRole = false;

  Future<void> _basculerEnClient() async {
    if (_isBasculingRole) return;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Basculer en compte Client ?"),
        content: const Text(
          "Vous passerez à l'expérience Client. Votre fiche grossiste et vos "
          "produits restent intacts — vous pourrez redevenir grossiste "
          "à tout moment.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    final identiteConfirmee = await requireBiometricConfirmation(
      context,
      ref,
      reason: "Confirmez votre identité pour basculer en compte Client.",
    );
    if (!identiteConfirmee || !mounted) return;

    setState(() => _isBasculingRole = true);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .redevenirUtilisateur();
      await ref.read(sessionStorageProvider).save(session);
      ref.read(currentSessionProvider.notifier).state = session;
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Une erreur est survenue. Réessayez.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isBasculingRole = false);
    }
  }

  void _payer(Plan plan) {
    context.push(
      AppRoutes.paiementChoix,
      extra: PaiementParams(
        type: TypeTransaction.abonnement,
        montant: plan.prix,
        description: "Abonnement grossiste MboaLink · ${plan.nom}",
        typeAbonnement: plan.periodicite,
      ),
    );
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

  String _formatDate(DateTime date) {
    const mois = [
      "jan",
      "fév",
      "mar",
      "avr",
      "mai",
      "juin",
      "juil",
      "août",
      "sep",
      "oct",
      "nov",
      "déc",
    ];
    return "${date.day} ${mois[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final ficheAsync = ref.watch(maFicheProvider);
    final abonnementAsync = ref.watch(monAbonnementProvider);
    final plansAsync = ref.watch(plansGrossisteProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return ficheAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text("Erreur de chargement"))),
      data: (fiche) {
        final abonnementActif =
            abonnementAsync.value?.statut == StatutAbonnement.actif;
        final isPaymentRequired =
            fiche.dashboardStatus(abonnementActif: abonnementActif) ==
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
                                    child:
                                        fiche.logoUrl != null &&
                                            fiche.logoUrl!.isNotEmpty &&
                                            !fiche.logoUrl!.startsWith(
                                              "mock://",
                                            )
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Image.network(
                                              fiche.logoUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
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
                                  if (!isPaymentRequired &&
                                      abonnementAsync.value != null) ...[
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
                                                "${abonnementAsync.value!.typeAbonnement == "ANNUEL" ? "Annuel" : "Mensuel"} · "
                                                "${abonnementAsync.value!.montant.toStringAsFixed(0)} F",
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
                                      "Expire le "
                                      "${_formatDate(abonnementAsync.value!.dateFin)}",
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
                                    GestureDetector(
                                      onTap: () => context.push(
                                        AppRoutes.grossisteMonAbonnement,
                                      ),
                                      child: Text(
                                        "Renouveler ou changer de plan",
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
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
                                    plansAsync.when(
                                      loading: () => const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      error: (_, _) => Text(
                                        "Impossible de charger les plans.",
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      data: (plans) => Column(
                                        children: [
                                          for (final plan in plans) ...[
                                            _PlanTile(
                                              label: plan.nom,
                                              detail:
                                                  plan.periodicite == "ANNUEL"
                                                  ? "${plan.prix.toStringAsFixed(0)} F / an"
                                                  : "Sans engagement",
                                              price:
                                                  "${(plan.periodicite == "ANNUEL" ? plan.prix / 12 : plan.prix).toStringAsFixed(0)} F",
                                              unit: "/ mois",
                                              badge:
                                                  plan.periodicite == "ANNUEL"
                                                  ? "-2 MOIS"
                                                  : null,
                                              isSelected:
                                                  (_selectedPlanId ??
                                                      plans.first.id) ==
                                                  plan.id,
                                              onTap: () => setState(
                                                () => _selectedPlanId = plan.id,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Bouton payer
                                    plansAsync.maybeWhen(
                                      data: (plans) {
                                        if (plans.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        final plan = plans.firstWhere(
                                          (p) => p.id == _selectedPlanId,
                                          orElse: () => plans.first,
                                        );
                                        return Material(
                                          color: AppColors.accent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () => _payer(plan),
                                            child: SizedBox(
                                              height: 48,
                                              child: Center(
                                                child: Text(
                                                  "Payer via Mobile Money · "
                                                  "${plan.prix.toStringAsFixed(0)} F",
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
                                        );
                                      },
                                      orElse: () => const SizedBox.shrink(),
                                    ),
                                  ],
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
                                icon: Symbols.edit,
                                label: "Modifier mes informations",
                                onTap: () => context.push(
                                  AppRoutes.grossisteEditerFiche,
                                ),
                              ),
                              _SettingsTile(
                                icon: Symbols.visibility,
                                label: "Prévisualiser ma fiche",
                                onTap: () => context.push(
                                  AppRoutes.grossisteFichePreview,
                                ),
                              ),
                              _SettingsTile(
                                icon: Symbols.swap_horiz,
                                label: "Basculer en compte Client",
                                onTap: _basculerEnClient,
                              ),
                              _SettingsTile(
                                icon: Symbols.support_agent,
                                label: "Contacter le service client",
                                onTap: () => showContactSupportSheet(context),
                              ),
                              _SettingsTile(
                                icon: Symbols.shield_person,
                                label: "Confidentialité & données",
                                onTap: () =>
                                    context.push(AppRoutes.confidentialite),
                              ),
                              _SettingsTile(
                                icon: Symbols.password,
                                label: "Changer mon mot de passe",
                                onTap: () =>
                                    context.push(AppRoutes.changerMotDePasse),
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
