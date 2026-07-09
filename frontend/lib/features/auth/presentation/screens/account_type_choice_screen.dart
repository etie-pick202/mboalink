import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_logo.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../domain/entities/registration_draft.dart";
import "../../domain/entities/user_role.dart";
import "../providers/auth_providers.dart";

/// Écran de choix du type de compte (Client / Grossiste) — ajouté
/// conformément à la revue de changement (point 1).
///
/// Appelle POST /auth/inscription avec le role choisi, puis navigue
/// vers l'écran OTP pour vérification email.
class AccountTypeChoiceScreen extends ConsumerStatefulWidget {
  const AccountTypeChoiceScreen({required this.draft, super.key});

  final RegistrationDraft draft;

  @override
  ConsumerState<AccountTypeChoiceScreen> createState() =>
      _AccountTypeChoiceScreenState();
}

class _AccountTypeChoiceScreenState
    extends ConsumerState<AccountTypeChoiceScreen> {
  UserRole? _selectedRole;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (_selectedRole == null) {
      setState(() => _errorMessage = "Veuillez choisir un type de compte.");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // POST /auth/inscription — telephone non envoyé (non supporté backend).
      await ref
          .read(authRepositoryProvider)
          .inscrire(
            nom: widget.draft.nom,
            prenom: widget.draft.prenom,
            email: widget.draft.email,
            motDePasse: widget.draft.motDePasse,
            role: _selectedRole!.toApi,
          );

      if (!mounted) return;

      context.push(
        AppRoutes.otp,
        extra: {
          "cible": widget.draft.email,
          "isGrossiste": _selectedRole == UserRole.grossiste,
        },
      );
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 38),
                      const SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          children: const [
                            TextSpan(text: "MboaLink"),
                            TextSpan(
                              text: ".",
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Quel type de compte\nvoulez-vous créer ?",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Bienvenue, ${widget.draft.prenom} !",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 24),

                  // Carte Client
                  _AccountTypeCard(
                    icon: Symbols.person,
                    title: "Client · Utilisateur",
                    description:
                        "Recherchez des grossistes, débloquez leurs coordonnées.",
                    isSelected: _selectedRole == UserRole.utilisateur,
                    onTap: () =>
                        setState(() => _selectedRole = UserRole.utilisateur),
                  ),
                  const SizedBox(height: 12),

                  // Carte Grossiste
                  _AccountTypeCard(
                    icon: Symbols.storefront,
                    title: "Grossiste",
                    description:
                        "Créez votre fiche professionnelle et soyez visible dans l'annuaire.",
                    badge: "Abonnement requis",
                    isSelected: _selectedRole == UserRole.grossiste,
                    onTap: () =>
                        setState(() => _selectedRole = UserRole.grossiste),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: "Continuer",
                    trailingIcon: Symbols.arrow_forward,
                    isLoading: _isSubmitting,
                    onPressed: _selectedRole != null ? _submit : null,
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

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.successBg : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Après — Flexible sur le titre, le badge reste à sa taille naturelle
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Symbols.check_circle
                    : Symbols.radio_button_unchecked,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
