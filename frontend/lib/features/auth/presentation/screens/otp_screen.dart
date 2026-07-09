import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/otp_code_input.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../domain/entities/user_role.dart";
import "../providers/auth_providers.dart";

/// Écran 04 · Vérification OTP — conforme à la maquette MboaLink.
/// Code à 6 chiffres aligné avec le backend.
/// Le role est passé explicitement car la réponse backend /auth/verifier-otp
/// ne le contient pas — on utilise isGrossiste du contexte d'inscription.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.cible, required this.isGrossiste, super.key});

  final String cible;
  final bool isGrossiste;

  static const _codeLength = 6;
  static const _resendDelay = Duration(seconds: 60);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = "";
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  Timer? _timer;
  Duration _remaining = OtpScreen._resendDelay;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _remaining = OtpScreen._resendDelay;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  String get _remainingLabel {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, "0")}";
  }

  Future<void> _verify(String code) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final role = widget.isGrossiste
          ? UserRole.grossiste.toApi
          : UserRole.utilisateur.toApi;

      final session = await ref
          .read(authRepositoryProvider)
          .verifierOtp(
            cible: widget.cible,
            code: code,
            type: "INSCRIPTION_EMAIL",
            role: role,
          );
      ref.read(currentSessionProvider.notifier).state = session;
      await ref.read(sessionStorageProvider).save(session);
      if (!mounted) return;
      context.go(
        AppRoutes.consent,
        extra: {"isGrossiste": session.role == UserRole.grossiste},
      );
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .renvoyerOtp(cible: widget.cible, type: "INSCRIPTION_EMAIL");
      _startCountdown();
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final canResend = _remaining == Duration.zero;

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
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Symbols.sms,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    "Vérification · Verify",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textMuted,
                        height: 1.55,
                      ),
                      children: [
                        const TextSpan(
                          text: "Entrez le code à 6 chiffres envoyé à\n",
                        ),
                        TextSpan(
                          text: widget.cible,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  OtpCodeInput(
                    length: OtpScreen._codeLength,
                    onChanged: (value) => setState(() => _code = value),
                    onCompleted: _verify,
                  ),
                  const SizedBox(height: 22),
                  if (_errorMessage != null)
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
                    )
                  else
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Icon(
                          Symbols.schedule,
                          size: 17,
                          color: AppColors.textFaint,
                        ),
                        Text(
                          canResend
                              ? "Vous pouvez renvoyer le code"
                              : "Renvoyer le code dans",
                          style: AppTypography.bodySmall,
                        ),
                        if (!canResend)
                          Text(
                            _remainingLabel,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _isResending ? null : _resend,
                            child: Text(
                              _isResending ? "Envoi..." : "Renvoyer",
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: "Vérifier · Verify",
                    isLoading: _isVerifying,
                    onPressed: _code.length == OtpScreen._codeLength
                        ? () => _verify(_code)
                        : null,
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
