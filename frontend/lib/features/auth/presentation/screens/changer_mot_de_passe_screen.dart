import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/utils/validators.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../providers/auth_providers.dart";
import "biometric_prompt_screen.dart";

/// Écran "Changer mon mot de passe" — action sensible, protégée par une
/// confirmation biométrique avant même d'afficher le formulaire.
/// Le backend révoque toutes les sessions actives après succès : on
/// déconnecte donc l'utilisateur et le renvoie à l'écran de connexion.
class ChangerMotDePasseScreen extends ConsumerStatefulWidget {
  const ChangerMotDePasseScreen({super.key});

  @override
  ConsumerState<ChangerMotDePasseScreen> createState() =>
      _ChangerMotDePasseScreenState();
}

class _ChangerMotDePasseScreenState
    extends ConsumerState<ChangerMotDePasseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ancien = TextEditingController();
  final _nouveau = TextEditingController();
  final _confirmation = TextEditingController();
  bool _isSubmitting = false;
  bool _checkingBiometrics = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirmerIdentite());
  }

  @override
  void dispose() {
    _ancien.dispose();
    _nouveau.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _confirmerIdentite() async {
    final confirme = await requireBiometricConfirmation(
      context,
      ref,
      reason: "Confirmez votre identité pour changer votre mot de passe.",
    );
    if (!mounted) return;
    if (!confirme) {
      context.pop();
      return;
    }
    setState(() => _checkingBiometrics = false);
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
          .changerMotDePasse(
            ancienMotDePasse: _ancien.text,
            nouveauMotDePasse: _nouveau.text,
          );
      if (!mounted) return;
      await ref.read(sessionStorageProvider).clear();
      ref.read(currentSessionProvider.notifier).state = null;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mot de passe modifié. Reconnectez-vous avec le nouveau.",
          ),
        ),
      );
      context.go(AppRoutes.login);
    } on AppException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingBiometrics) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Symbols.arrow_back,
                      size: 23,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Changer mon mot de passe",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Choisissez un nouveau mot de passe robuste. "
                            "Vous devrez vous reconnecter ensuite.",
                            style: AppTypography.bodySmall.copyWith(
                              height: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            label: "Mot de passe actuel",
                            controller: _ancien,
                            obscureText: true,
                            validator: (v) => (v == null || v.isEmpty)
                                ? "Le mot de passe actuel est obligatoire."
                                : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: "Nouveau mot de passe",
                            controller: _nouveau,
                            obscureText: true,
                            validator: Validators.strongPassword,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: "Confirmer le nouveau mot de passe",
                            controller: _confirmation,
                            obscureText: true,
                            validator: (v) => v != _nouveau.text
                                ? "Les mots de passe ne correspondent pas."
                                : null,
                          ),
                          if (_erreur != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _erreur!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text("Enregistrer"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
