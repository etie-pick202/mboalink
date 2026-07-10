import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/contact_support_sheet.dart";
import "../../../auth/domain/entities/auth_session.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../../auth/presentation/screens/biometric_prompt_screen.dart";
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

  Future<void> _modifierProfil(AuthSession? session) async {
    final confirme = await requireBiometricConfirmation(
      context,
      ref,
      reason: "Confirmez votre identité pour modifier votre profil.",
    );
    if (!confirme || !mounted) return;

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => _ModifierProfilDialog(
        nomInitial: session?.nom ?? "",
        prenomInitial: session?.prenom ?? "",
      ),
    );
    if (result == null || session == null) return;
    final (nom, prenom) = result;
    ref.read(currentSessionProvider.notifier).state = session.copyWith(
      nom: nom,
      prenom: prenom,
    );
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
                                onTap: () => _modifierProfil(session),
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
                              onTap: () => context.push(AppRoutes.favoris),
                            ),
                            _MenuTile(
                              icon: Symbols.receipt_long,
                              label: "Reçus & paiements",
                              onTap: () => context.push(AppRoutes.recus),
                            ),
                            _MenuTile(
                              icon: Symbols.shield_person,
                              label: "Confidentialité & données",
                              onTap: () =>
                                  context.push(AppRoutes.confidentialite),
                            ),
                            _MenuTile(
                              icon: Symbols.password,
                              label: "Changer mon mot de passe",
                              onTap: () =>
                                  context.push(AppRoutes.changerMotDePasse),
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
                              onTap: () =>
                                  context.push(AppRoutes.devenirGrossiste),
                            ),
                            _MenuTile(
                              icon: Symbols.support_agent,
                              label: "Contacter le service client",
                              iconColor: AppColors.textMuted,
                              onTap: () => showContactSupportSheet(context),
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

class _ModifierProfilDialog extends ConsumerStatefulWidget {
  const _ModifierProfilDialog({
    required this.nomInitial,
    required this.prenomInitial,
  });

  final String nomInitial;
  final String prenomInitial;

  @override
  ConsumerState<_ModifierProfilDialog> createState() =>
      _ModifierProfilDialogState();
}

class _ModifierProfilDialogState extends ConsumerState<_ModifierProfilDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nom = TextEditingController(text: widget.nomInitial);
  late final _prenom = TextEditingController(text: widget.prenomInitial);
  bool _isSubmitting = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _erreur = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .modifierProfil(nom: _nom.text.trim(), prenom: _prenom.text.trim());
      if (!mounted) return;
      Navigator.pop(context, (_nom.text.trim(), _prenom.text.trim()));
    } on AppException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier mon profil"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: "Prénom",
              controller: _prenom,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Le prénom est obligatoire."
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: "Nom",
              controller: _nom,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Le nom est obligatoire."
                  : null,
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 12),
              Text(
                _erreur!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Enregistrer"),
        ),
      ],
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
