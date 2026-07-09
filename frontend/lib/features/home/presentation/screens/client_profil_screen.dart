import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../widgets/client_nav_bar.dart";

/// Écran 18 · Profil Client — conforme à la maquette MboaLink et à la
/// revue de changement : Favoris, Reçus & paiements, Confidentialité,
/// Devenir grossiste, Déconnexion. Option "Télécharger ses données"
/// supprimée (revue). "Contacter le service client" ajouté (revue).
class ClientProfilScreen extends ConsumerStatefulWidget {
  const ClientProfilScreen({super.key});

  @override
  ConsumerState<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends ConsumerState<ClientProfilScreen> {
  bool _isLoggingOut = false;

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
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
    final session = ref.watch(currentSessionProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    final initiales = [
      if (session?.prenom?.isNotEmpty == true)
        session!.prenom![0].toUpperCase(),
      if (session?.nom?.isNotEmpty == true) session!.nom![0].toUpperCase(),
    ].join();

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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête profil — conforme maquette écran 18
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.successBg,
                                child: Text(
                                  initiales.isNotEmpty ? initiales : "?",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${session?.prenom ?? ""} ${session?.nom ?? ""}"
                                              .trim()
                                              .isEmpty
                                          ? "Mon compte"
                                          : "${session?.prenom ?? ""} ${session?.nom ?? ""}"
                                                .trim(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (session?.email != null)
                                      Text(
                                        session!.email!,
                                        style: AppTypography.caption,
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _comingSoon("Modifier mon profil"),
                                child: const Icon(
                                  Symbols.edit,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 1 — conforme maquette
                        _SectionCard(
                          children: [
                            _MenuTile(
                              icon: Symbols.bookmark,
                              label: "Favoris",
                              onTap: () => _comingSoon("Favoris"),
                            ),
                            _MenuTile(
                              icon: Symbols.receipt_long,
                              label: "Reçus & paiements",
                              onTap: () => _comingSoon("Reçus & paiements"),
                            ),
                            _MenuTile(
                              icon: Symbols.shield_person,
                              label: "Confidentialité & données",
                              onTap: () =>
                                  _comingSoon("Confidentialité & données"),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Section 2 — conforme maquette + revue
                        _SectionCard(
                          children: [
                            _MenuTile(
                              icon: Symbols.storefront,
                              label: "Devenir grossiste",
                              iconColor: AppColors.textMuted,
                              onTap: () => _comingSoon("Devenir grossiste"),
                            ),
                            _MenuTile(
                              icon: Symbols.swap_horiz,
                              label: "Basculer vers un compte Grossiste",
                              iconColor: AppColors.textMuted,
                              onTap: () =>
                                  _comingSoon("Bascule Client ↔ Grossiste"),
                            ),
                            _MenuTile(
                              icon: Symbols.support_agent,
                              label: "Contacter le service client",
                              iconColor: AppColors.textMuted,
                              onTap: () => _comingSoon("Service client"),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Déconnexion — conforme maquette
                        _SectionCard(
                          children: [
                            _MenuTile(
                              icon: Symbols.logout,
                              label: "Déconnexion",
                              iconColor: AppColors.error,
                              labelColor: AppColors.error,
                              isLast: true,
                              trailing: _isLoggingOut
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.error,
                                      ),
                                    )
                                  : null,
                              onTap: _isLoggingOut ? null : _logout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const ClientNavBar(activeIndex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.isLast = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isLast;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(13))
            : BorderRadius.zero,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: AppColors.background)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 21, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Symbols.chevron_right,
                    size: 19,
                    color:
                        labelColor?.withValues(alpha: 0.4) ??
                        AppColors.textFaint,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
