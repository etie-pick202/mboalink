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
///
/// Canal par défaut : email (déjà envoyé automatiquement par
/// POST /auth/inscription). Si un numéro de téléphone a été renseigné à
/// l'inscription, l'utilisateur peut choisir de recevoir le code par SMS
/// à la place — le renvoi cible alors le téléphone avec
/// type=INSCRIPTION_SMS, et toute vérification/renvoi suivant reste sur
/// ce canal jusqu'à ce qu'il en change à nouveau.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    required this.cible,
    required this.isGrossiste,
    this.telephone,
    super.key,
  });

  final String cible;
  final bool isGrossiste;

  /// Numéro enregistré à l'inscription, s'il y en a un — conditionne
  /// l'affichage du choix "Recevoir par SMS".
  final String? telephone;

  static const _codeLength = 6;
  static const _resendDelay = Duration(seconds: 60);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = "";
  bool _isVerifying = false;
  bool _isResending = false;
  bool _isSwitchingChannel = false;
  String? _errorMessage;

  /// Canal actif — commence sur l'email (déjà envoyé à l'inscription).
  late String _cibleActive = widget.cible;
  String _typeActif = "INSCRIPTION_EMAIL";

  Timer? _timer;
  Duration _remaining = OtpScreen._resendDelay;

  bool get _smsDisponible =>
      widget.telephone != null && widget.telephone!.isNotEmpty;
  bool get _surSms => _typeActif == "INSCRIPTION_SMS";

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
            cible: _cibleActive,
            code: code,
            type: _typeActif,
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
          .renvoyerOtp(cible: _cibleActive, type: _typeActif);
      _startCountdown();
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  /// Bascule le canal actif (email ↔ SMS) et déclenche immédiatement
  /// l'envoi d'un nouveau code sur ce canal.
  Future<void> _changerDeCanal() async {
    final nouvelleCible = _surSms ? widget.cible : widget.telephone!;
    final nouveauType = _surSms ? "INSCRIPTION_EMAIL" : "INSCRIPTION_SMS";

    setState(() {
      _isSwitchingChannel = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .renvoyerOtp(cible: nouvelleCible, type: nouveauType);
      setState(() {
        _cibleActive = nouvelleCible;
        _typeActif = nouveauType;
        _code = "";
      });
      _startCountdown();
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSwitchingChannel = false);
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
                    child: Icon(
                      _surSms ? Symbols.sms : Symbols.mail,
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
                        TextSpan(
                          text: _surSms
                              ? "Entrez le code à 6 chiffres envoyé par SMS au\n"
                              : "Entrez le code à 6 chiffres envoyé à\n",
                        ),
                        TextSpan(
                          text: _cibleActive,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_smsDisponible) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _isSwitchingChannel ? null : _changerDeCanal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _surSms ? Symbols.mail : Symbols.sms,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isSwitchingChannel
                                ? "Envoi en cours…"
                                : _surSms
                                ? "Recevoir par email à la place"
                                : "Recevoir par SMS à la place",
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  OtpCodeInput(
                    key: ValueKey(_cibleActive),
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
