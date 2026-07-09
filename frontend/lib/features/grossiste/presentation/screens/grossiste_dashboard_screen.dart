import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../domain/entities/document_statut.dart";
import "../../domain/entities/document_verification.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../../domain/entities/grossiste_dashboard_status.dart";
import "../providers/grossiste_providers.dart";
import "grossiste_nav_bar.dart";

/// Écran 24 · Tableau de bord grossiste.
///
/// 6 états possibles :
///   nonSoumise           → Fiche vide, bouton "Créer ma fiche"
///   enAttente            → Documents soumis, équipe en cours de vérification
///   rejetee              → Documents refusés avec motif par document
///   enAttenteAbonnement  → Documents validés, abonnement non payé
///                          → SEUL l'onglet Profil (paiement) est accessible
///   validee              → Abonnement actif, dashboard complet
///   suspendue            → Abonnement expiré ou fiche suspendue
class GrossisteDashboardScreen extends ConsumerWidget {
  const GrossisteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficheAsync = ref.watch(maFicheProvider);

    return ficheAsync.when(
      loading: () => const Scaffold(body: Center(child: AppLoader())),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.surfaceAlt,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is AppException
                      ? error.message
                      : "Impossible de charger votre fiche.",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: "Réessayer",
                  onPressed: () => ref.invalidate(maFicheProvider),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (fiche) {
        switch (fiche.dashboardStatus) {
          case GrossisteDashboardStatus.validee:
            return const _ValidatedDashboard();
          case GrossisteDashboardStatus.rejetee:
            return _RejectedDashboard(fiche: fiche);
          case GrossisteDashboardStatus.suspendue:
            return const _SuspendedDashboard();
          case GrossisteDashboardStatus.enAttenteAbonnement:
            return _PaymentRequiredDashboard(fiche: fiche);
          case GrossisteDashboardStatus.nonSoumise:
          case GrossisteDashboardStatus.enAttente:
            return _PendingDashboard(fiche: fiche);
        }
      },
    );
  }
}

// ── Bouton paramètres commun ──────────────────────────────────────────────────

class _SettingsMenuButton extends ConsumerWidget {
  const _SettingsMenuButton();

  void _openMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Symbols.logout, color: AppColors.error),
              title: Text(
                "Se déconnecter",
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  await ref.read(authRepositoryProvider).deconnecter("");
                } catch (_) {}
                await ref.read(sessionStorageProvider).clear();
                ref.read(currentSessionProvider.notifier).state = null;
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openMenu(context, ref),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Symbols.settings,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Coquille commune (états non validés) ─────────────────────────────────────

/// Header + bandeau + stats verrouillées + actions grisées.
/// Utilisée par les états nonSoumise, enAttente et rejetee.
class _LockedShell extends StatelessWidget {
  const _LockedShell({required this.banner});

  final Widget banner;

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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tableau de bord", style: AppTypography.caption),
                          const SizedBox(height: 2),
                          Text(
                            "Espace Grossiste",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const _SettingsMenuButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  banner,
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(
                        child: _LockedStatCard(
                          icon: Symbols.visibility,
                          label: "Vues ce mois",
                        ),
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: _LockedStatCard(
                          icon: Symbols.lock_open,
                          label: "Contacts débloqués",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Symbols.edit,
                          label: "Modifier fiche",
                          enabled: false,
                          onTap: () => _comingSoon(context, "Modifier fiche"),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _QuickAction(
                          icon: Symbols.workspace_premium,
                          label: "Certification",
                          enabled: false,
                          onTap: () => _comingSoon(context, "Certification"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── États ─────────────────────────────────────────────────────────────────────

class _PendingDashboard extends StatelessWidget {
  const _PendingDashboard({required this.fiche});

  final FicheGrossiste fiche;

  @override
  Widget build(BuildContext context) {
    final isPending =
        fiche.dashboardStatus == GrossisteDashboardStatus.enAttente;

    return _LockedShell(
      banner: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPending ? Symbols.hourglass_top : Symbols.hourglass_empty,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPending
                        ? "Fiche en attente de vérification"
                        : "Compte en attente de vérification",
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isPending
                  ? "Votre fiche a bien été soumise. Notre équipe la vérifie "
                        "sous 24 à 48 h — vous serez notifié dès la validation."
                  : "Complétez votre fiche (informations + documents) pour être "
                        "visible sur MboaLink.",
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: isPending ? "Lire ma fiche" : "Créer ma fiche",
              trailingIcon: isPending
                  ? Symbols.visibility
                  : Symbols.arrow_forward,
              onPressed: () => context.push(
                isPending
                    ? AppRoutes.grossisteFicheReadonly
                    : AppRoutes.grossisteOnboarding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedDashboard extends ConsumerWidget {
  const _RejectedDashboard({required this.fiche});

  final FicheGrossiste fiche;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(ficheDocumentsProvider(fiche.id));

    return _LockedShell(
      banner: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.error, size: 18, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Fiche rejetée",
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Notre équipe n'a pas pu valider votre fiche. Corrigez les "
              "points ci-dessous puis soumettez à nouveau.",
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            documentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AppLoader(size: 18),
              ),
              // Nommage correct des paramètres — évite le warning
              // unnecessary_underscores sur le second paramètre ignoré.
              error: (error, stackTrace) => Text(
                "Impossible de charger le détail.",
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
              data: (documents) {
                final rejected = documents
                    .where((d) => d.statut == DocumentStatut.rejete)
                    .toList();
                if (rejected.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final doc in rejected) ...[
                      _RejectedDocumentTile(document: doc),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            PrimaryButton(
              label: "Corriger ma fiche",
              trailingIcon: Symbols.arrow_forward,
              onPressed: () => context.push(AppRoutes.grossisteOnboarding),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedDocumentTile extends StatelessWidget {
  const _RejectedDocumentTile({required this.document});

  final DocumentVerification document;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.cancel, size: 16, color: AppColors.error),
              const SizedBox(width: 6),
              Text(
                document.type.label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (document.commentaireAdmin != null &&
              document.commentaireAdmin!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              document.commentaireAdmin!,
              style: AppTypography.caption.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

/// État "en attente d'abonnement" — documents validés par l'admin,
/// paiement non encore effectué. Seul l'onglet Profil est accessible.
class _PaymentRequiredDashboard extends ConsumerWidget {
  const _PaymentRequiredDashboard({required this.fiche});

  final FicheGrossiste fiche;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tableau de bord", style: AppTypography.caption),
                          const SizedBox(height: 2),
                          Text(
                            "Espace Grossiste",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const _SettingsMenuButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bandeau succès documents
                        Container(
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
                                    Symbols.verified,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Documents validés !",
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Félicitations — votre identité et vos documents ont "
                                "été vérifiés. Activez votre abonnement pour mettre "
                                "votre fiche en ligne et être visible dans l'annuaire.",
                                style: AppTypography.bodySmall.copyWith(
                                  height: 1.55,
                                ),
                              ),
                              const SizedBox(height: 14),
                              PrimaryButton(
                                label: "Activer mon abonnement",
                                trailingIcon: Symbols.arrow_forward,
                                onPressed: () =>
                                    context.push(AppRoutes.grossisteProfil),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(
                              child: _LockedStatCard(
                                icon: Symbols.visibility,
                                label: "Vues ce mois",
                              ),
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: _LockedStatCard(
                                icon: Symbols.lock_open,
                                label: "Contacts débloqués",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Symbols.lock,
                                size: 17,
                                color: AppColors.textFaint,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "La boutique, les statistiques et les autres "
                                  "fonctionnalités seront disponibles dès "
                                  "l'activation de votre abonnement.",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _PaymentRequiredNavBar(
                  onProfilTap: () => context.push(AppRoutes.grossisteProfil),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navbar réduite — état "en attente d'abonnement".
/// Dashboard, Boutique, Fiche grisés et non tappables. Profil seul actif.
class _PaymentRequiredNavBar extends StatelessWidget {
  const _PaymentRequiredNavBar({required this.onProfilTap});

  final VoidCallback onProfilTap;

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
          _ActiveNavItem(
            icon: Symbols.person,
            label: "Profil",
            onTap: onProfilTap,
          ),
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
  const _ActiveNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
    );
  }
}

class _SuspendedDashboard extends ConsumerWidget {
  const _SuspendedDashboard();

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceAlt,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: _SettingsMenuButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Symbols.block,
                    size: 32,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Fiche suspendue",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Votre fiche a été suspendue, probablement suite à l'expiration "
                  "de votre abonnement. Contactez le support pour la réactiver.",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: "Contacter le support",
                  onPressed: () => _comingSoon(context, "Contacter le support"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── État validé — dashboard complet ──────────────────────────────────────────

class _ValidatedDashboard extends StatelessWidget {
  const _ValidatedDashboard();

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tableau de bord",
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      "Ets Tchana & Fils",
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Symbols.verified,
                                      size: 15,
                                      color: Color(0xFF1D9BF0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const _SettingsMenuButton(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Abonnement actif · expire le 12 juil",
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "Plan Pro · 15 000 F/mois",
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _comingSoon(context, "Gestion abonnement"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    "Gérer",
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Symbols.visibility,
                                value: "2 412",
                                label: "Vues ce mois",
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _StatCard(
                                icon: Symbols.lock_open,
                                value: "86",
                                label: "Contacts débloqués",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Vues · 7 derniers jours",
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "+18%",
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 62,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: const [
                                    _Bar(
                                      heightFactor: 0.42,
                                      highlighted: false,
                                    ),
                                    SizedBox(width: 7),
                                    _Bar(
                                      heightFactor: 0.58,
                                      highlighted: false,
                                    ),
                                    SizedBox(width: 7),
                                    _Bar(
                                      heightFactor: 0.36,
                                      highlighted: false,
                                    ),
                                    SizedBox(width: 7),
                                    _Bar(heightFactor: 0.70, highlighted: true),
                                    SizedBox(width: 7),
                                    _Bar(
                                      heightFactor: 0.54,
                                      highlighted: false,
                                    ),
                                    SizedBox(width: 7),
                                    _Bar(heightFactor: 0.82, highlighted: true),
                                    SizedBox(width: 7),
                                    _Bar(heightFactor: 1.0, highlighted: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Symbols.edit,
                                label: "Modifier fiche",
                                enabled: true,
                                onTap: () =>
                                    context.push(AppRoutes.grossisteBoutique),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _QuickAction(
                                icon: Symbols.workspace_premium,
                                label: "Certification",
                                enabled: true,
                                onTap: () =>
                                    _comingSoon(context, "Certification"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const GrossisteNavBar(activeIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets partagés ──────────────────────────────────────────────────────────

class _LockedStatCard extends StatelessWidget {
  const _LockedStatCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 19, color: AppColors.textFaint),
              const Icon(Symbols.lock, size: 15, color: AppColors.textFaint),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "—",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textFaint,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : AppColors.textFaint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: enabled ? 1 : 0.6),
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.highlighted});

  final double heightFactor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: highlighted ? AppColors.primary : AppColors.successBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
