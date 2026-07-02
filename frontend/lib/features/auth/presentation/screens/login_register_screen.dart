import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/utils/phone_formatter.dart";
import "../../../../core/utils/validators.dart";
import "../../../../core/widgets/app_logo.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../domain/entities/registration_draft.dart";
import "../providers/auth_providers.dart";
import "../widgets/phone_field.dart";
import "../widgets/segmented_tabs.dart";

/// Écran 03 · Connexion / Inscription — conforme au style de la maquette
/// MboaLink. L'email est l'identifiant unique de connexion ; le téléphone
/// n'est collecté qu'à l'inscription, en tant que donnée facultative.
class LoginRegisterScreen extends ConsumerStatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  ConsumerState<LoginRegisterScreen> createState() =>
      _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  int _activeTab = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _registerFormKey = GlobalKey<FormState>();
  final _registerNom = TextEditingController();
  final _registerPrenom = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPhone = TextEditingController();
  final _registerPassword = TextEditingController();

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerNom.dispose();
    _registerPrenom.dispose();
    _registerEmail.dispose();
    _registerPhone.dispose();
    _registerPassword.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .connecter(
            identifiant: _loginEmail.text.trim(),
            motDePasse: _loginPassword.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _submitRegister() {
    if (!_registerFormKey.currentState!.validate()) return;

    final phoneRaw = _registerPhone.text.trim();

    final draft = RegistrationDraft(
      nom: _registerNom.text.trim(),
      prenom: _registerPrenom.text.trim(),
      email: _registerEmail.text.trim(),
      telephone: phoneRaw.isEmpty
          ? null
          : PhoneFormatter.toE164Cameroon(phoneRaw),
      motDePasse: _registerPassword.text,
    );

    context.push(AppRoutes.accountTypeChoice, extra: draft);
  }

  void _showComingSoon(String feature) {
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
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 42),
                      const SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
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
                  const SizedBox(height: 22),
                  Text(
                    _activeTab == 0
                        ? "Bon retour \u{1F44B}"
                        : "Créer un compte",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _activeTab == 0
                        ? "Connectez-vous pour continuer · Sign in"
                        : "Rejoignez le réseau MboaLink · Sign up",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  SegmentedTabs(
                    labels: const ["Connexion", "Inscription"],
                    activeIndex: _activeTab,
                    onChanged: (index) => setState(() {
                      _activeTab = index;
                      _errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
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
                    const SizedBox(height: 14),
                  ],
                  _activeTab == 0
                      ? _LoginForm(
                          formKey: _loginFormKey,
                          emailController: _loginEmail,
                          passwordController: _loginPassword,
                          isSubmitting: _isSubmitting,
                          onSubmit: _submitLogin,
                          onForgotPassword: () =>
                              _showComingSoon("Mot de passe oublié"),
                        )
                      : _RegisterForm(
                          formKey: _registerFormKey,
                          nomController: _registerNom,
                          prenomController: _registerPrenom,
                          emailController: _registerEmail,
                          phoneController: _registerPhone,
                          passwordController: _registerPassword,
                          onSubmit: _submitRegister,
                        ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("ou · or", style: AppTypography.caption),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: "Google",
                          letter: "G",
                          letterColor: const Color(0xFFEA4335),
                          onTap: () => _showComingSoon("Connexion Google"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          label: "Facebook",
                          letter: "f",
                          letterColor: const Color(0xFF1877F2),
                          onTap: () => _showComingSoon("Connexion Facebook"),
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: "Email",
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: "Mot de passe · Password",
            controller: passwordController,
            obscureText: true,
            validator: (value) => Validators.required(
              value,
              message: "Le mot de passe est obligatoire.",
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                "Mot de passe oublié ?",
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          PrimaryButton(
            label: "Se connecter · Sign in",
            isLoading: isSubmitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nomController,
    required this.prenomController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: "Nom",
                  controller: nomController,
                  validator: (value) => Validators.required(
                    value,
                    message: "Le nom est obligatoire.",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  label: "Prénom",
                  controller: prenomController,
                  validator: (value) => Validators.required(
                    value,
                    message: "Le prénom est obligatoire.",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: "Email",
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          PhoneField(
            controller: phoneController,
            validator: Validators.phoneOptional,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: "Mot de passe · Password",
            controller: passwordController,
            obscureText: true,
            validator: Validators.strongPassword,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: "Créer mon compte",
            trailingIcon: Symbols.arrow_forward,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.letter,
    required this.letterColor,
    required this.onTap,
  });

  final String label;
  final String letter;
  final Color letterColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                letter,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: letterColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
