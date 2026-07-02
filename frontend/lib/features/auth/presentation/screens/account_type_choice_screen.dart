import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../domain/entities/account_type.dart";
import "../../domain/entities/registration_draft.dart";
import "../providers/auth_providers.dart";
import "../widgets/account_type_card.dart";

/// Écran "Choix du type de compte" — ajouté par la revue de changement,
/// absent de la maquette d'origine. Style visuel aligné sur le design
/// system de l'app pour rester cohérent avec le reste du parcours.
///
/// Appelle réellement /auth/inscription une fois le type choisi : le
/// compte de base (email, mot de passe, rôle) est identique pour les deux
/// profils. Les documents spécifiques au Grossiste (RCCM, CNI, photo
/// boutique) sont soumis plus tard, via l'assistant "Créer ma fiche"
/// (écran 22 de la maquette), après vérification OTP et consentement.
class AccountTypeChoiceScreen extends ConsumerStatefulWidget {
  const AccountTypeChoiceScreen({required this.draft, super.key});

  final RegistrationDraft draft;

  @override
  ConsumerState<AccountTypeChoiceScreen> createState() =>
      _AccountTypeChoiceScreenState();
}

class _AccountTypeChoiceScreenState
    extends ConsumerState<AccountTypeChoiceScreen> {
  AccountType? _selected;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _continue() async {
    final type = _selected;
    if (type == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final draft = widget.draft;
      final result = await ref
          .read(authRepositoryProvider)
          .inscrire(
            nom: draft.nom,
            prenom: draft.prenom,
            email: draft.email,
            telephone: draft.telephone,
            motDePasse: draft.motDePasse,
            role: type.apiRole,
          );

      if (!mounted) return;
      context.push(
        AppRoutes.otp,
        extra: {
          "cible": result.cible,
          "isGrossiste": type == AccountType.grossiste,
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
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 4, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quel type de compte souhaitez-vous créer ?",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "What type of account would you like to create?",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  AccountTypeCard(
                    icon: Symbols.person,
                    title: "Client",
                    subtitle:
                        "Je recherche des grossistes et fournisseurs près de chez moi.",
                    isSelected: _selected == AccountType.client,
                    onTap: () => setState(() => _selected = AccountType.client),
                  ),
                  const SizedBox(height: 12),
                  AccountTypeCard(
                    icon: Symbols.storefront,
                    title: "Grossiste",
                    subtitle:
                        "Je vends en gros et je veux être visible sur MboaLink.",
                    isSelected: _selected == AccountType.grossiste,
                    onTap: () =>
                        setState(() => _selected = AccountType.grossiste),
                  ),
                  if (_selected == AccountType.grossiste) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Symbols.info,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Un compte Grossiste nécessite une vérification d'identité "
                              "(documents) et un abonnement mensuel avant la mise en ligne "
                              "de votre fiche. On vous guide juste après.",
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    onPressed: _selected == null ? null : _continue,
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
