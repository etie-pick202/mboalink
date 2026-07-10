import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../../core/widgets/dashboard_widget_picker_sheet.dart";
import "../../../../core/widgets/mini_line_chart.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../domain/entities/admin_dashboard_widget.dart";
import "../../domain/entities/dashboard_resume.dart";
import "../../domain/entities/revenu_mensuel.dart";
import "../providers/admin_providers.dart";
import "../widgets/admin_nav_bar.dart";

/// Écran 28 · Dashboard admin — vue d'ensemble personnalisable : l'admin
/// choisit les widgets qu'il souhaite voir (bouton "tune" dans l'en-tête).
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _ouvrirPersonnalisation(
    BuildContext context,
    WidgetRef ref,
    Set<AdminDashboardWidget> actuels,
  ) async {
    final result = await showDashboardWidgetPickerSheet(
      context,
      options: [
        for (final w in AdminDashboardWidget.values)
          DashboardWidgetOption(
            id: w.name,
            label: w.label,
            description: w.description,
            icon: w.icon,
          ),
      ],
      selected: actuels.map((w) => w.name).toSet(),
    );
    if (result == null) return;
    final widgets = AdminDashboardWidget.values
        .where((w) => result.contains(w.name))
        .toSet();
    await saveAdminEnabledWidgets(ref, widgets);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeAsync = ref.watch(dashboardResumeProvider);
    final enabledAsync = ref.watch(adminEnabledWidgetsProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1F17),
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Console MboaLink",
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            "Vue d'ensemble",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _ouvrirPersonnalisation(
                              context,
                              ref,
                              enabledAsync.value ?? AdminDashboardWidget.all,
                            ),
                            child: Container(
                              width: 38,
                              height: 38,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Symbols.tune,
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                await ref
                                    .read(authRepositoryProvider)
                                    .deconnecter("");
                              } catch (_) {}
                              await ref.read(sessionStorageProvider).clear();
                              ref.read(currentSessionProvider.notifier).state =
                                  null;
                              if (context.mounted) {
                                context.go(AppRoutes.login);
                              }
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Symbols.logout,
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: resumeAsync.when(
                    loading: () =>
                        const Center(child: AppLoader(color: Colors.white)),
                    error: (error, _) => AppErrorView(
                      error: error,
                      fallbackMessage: "Impossible de charger le dashboard.",
                      onRetry: () => ref.invalidate(dashboardResumeProvider),
                    ),
                    data: (resume) {
                      final enabled =
                          enabledAsync.value ?? AdminDashboardWidget.all;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (enabled.contains(
                              AdminDashboardWidget.statsUtilisateurs,
                            )) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatTile(
                                      value: "${resume.totalUtilisateurs}",
                                      label: "Utilisateurs",
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: _StatTile(
                                      value: "${resume.totalGrossistes}",
                                      label: "Grossistes",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                            ],
                            if (enabled.contains(
                              AdminDashboardWidget.repartitionRoles,
                            )) ...[
                              _RepartitionRolesCard(resume: resume),
                              const SizedBox(height: 9),
                            ],
                            if (enabled.contains(
                              AdminDashboardWidget.revenueTrend,
                            )) ...[
                              const _RevenueTrendCard(),
                              const SizedBox(height: 9),
                            ],
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.adminRevenus),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF064D30),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Revenus — voir le détail",
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Symbols.chevron_right,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (enabled.contains(
                              AdminDashboardWidget.queues,
                            )) ...[
                              const SizedBox(height: 16),
                              _QueueTile(
                                icon: Symbols.pending_actions,
                                iconColor: AppColors.accent,
                                label: "Validations en attente",
                                count: resume.validationsEnAttente,
                                onTap: () =>
                                    context.go(AppRoutes.adminValidations),
                              ),
                              const SizedBox(height: 8),
                              _QueueTile(
                                icon: Symbols.flag,
                                iconColor: const Color(0xFFFF7A7A),
                                label: "Avis signalés",
                                count: resume.avisSignales,
                                badgeColor: AppColors.error,
                                onTap: () =>
                                    context.go(AppRoutes.adminModeration),
                              ),
                              const SizedBox(height: 8),
                              _QueueTile(
                                icon: Symbols.restart_alt,
                                iconColor: Colors.white,
                                label: "Demandes réinit. note",
                                count: resume.demandesReinitialisationNote,
                              ),
                              const SizedBox(height: 8),
                              _QueueTile(
                                icon: Symbols.lock_open,
                                iconColor: Colors.white,
                                label:
                                    "Déverrouillages (utilisateurs distincts)",
                                count: resume.deverrouillagesCoordonnees,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const AdminNavBar(activeIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RevenueTrendCard extends ConsumerWidget {
  const _RevenueTrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenusAsync = ref.watch(revenusDerniers4MoisProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Courbe des revenus · 4 derniers mois",
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          revenusAsync.when(
            loading: () => const SizedBox(
              height: 110,
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
            error: (_, _) => const SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  "Impossible de charger les revenus.",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ),
            data: (revenus) => _RevenueTrendChart(revenus: revenus),
          ),
        ],
      ),
    );
  }
}

class _RevenueTrendChart extends StatelessWidget {
  const _RevenueTrendChart({required this.revenus});

  final List<RevenuMensuel> revenus;

  @override
  Widget build(BuildContext context) {
    return MiniLineChart(
      values: revenus.map((r) => r.total).toList(),
      labels: revenus.map((r) => r.mois.substring(0, 3)).toList(),
      lineColor: AppColors.accent,
      emptyMessage: "Pas encore assez de données sur les revenus",
    );
  }
}

class _RepartitionRolesCard extends StatelessWidget {
  const _RepartitionRolesCard({required this.resume});

  final DashboardResume resume;

  @override
  Widget build(BuildContext context) {
    final clients = resume.totalUtilisateursClients;
    final grossistes = resume.totalGrossistes;
    final total = clients + grossistes;
    final partClients = total == 0 ? 0.0 : clients / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Répartition clients / grossistes",
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          if (total == 0)
            const Text(
              "Aucun utilisateur pour l'instant.",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 11,
                child: Row(
                  children: [
                    Expanded(
                      flex: (partClients * 1000).round().clamp(1, 999),
                      child: Container(color: AppColors.primary),
                    ),
                    Expanded(
                      flex: ((1 - partClients) * 1000).round().clamp(1, 999),
                      child: Container(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _LegendDot(color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  "Clients · $clients (${(partClients * 100).toStringAsFixed(0)}%)",
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 14),
                _LegendDot(color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  "Grossistes · $grossistes",
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
    this.badgeColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int count;
  final Color? badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                "$count",
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
