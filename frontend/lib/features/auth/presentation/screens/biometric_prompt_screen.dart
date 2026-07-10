import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/services/biometric_service.dart";
import "../providers/auth_providers.dart";

/// Écran biométrique propre à l'app — remplace la petite fenêtre native
/// du téléphone par une page plein écran, adaptative (Face ID / empreinte
/// / iris selon le capteur détecté) et interactive : compteur d'essais,
/// puis bascule automatique vers le code de l'appareil après 2 échecs.
///
/// La capture biométrique elle-même (le capteur) reste gérée par l'OS —
/// c'est une contrainte de sécurité du système, pas de l'app — mais tout
/// l'habillage, les messages et la logique de repli sont les nôtres.
///
/// Retourne `true` (via Navigator.pop) si l'utilisateur est authentifié,
/// `false` sinon (annulation ou choix du mot de passe).
class BiometricPromptScreen extends ConsumerStatefulWidget {
  const BiometricPromptScreen({
    super.key,
    this.reason = "Confirmez votre identité pour continuer.",
    this.allowPasswordFallback = true,
    this.passwordFallbackLabel = "Utiliser mon mot de passe MboaLink",
  });

  final String reason;
  final bool allowPasswordFallback;
  final String passwordFallbackLabel;

  @override
  ConsumerState<BiometricPromptScreen> createState() =>
      _BiometricPromptScreenState();
}

class _BiometricPromptScreenState extends ConsumerState<BiometricPromptScreen>
    with SingleTickerProviderStateMixin {
  static const _maxBiometricAttempts = 2;

  BiometricKind _kind = BiometricKind.generic;
  int _failedAttempts = 0;
  bool _isAuthenticating = false;
  String? _error;
  late final AnimationController _pulseController;

  bool get _useDeviceFallback => _failedAttempts >= _maxBiometricAttempts;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _loadKind();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadKind() async {
    final kind = await ref.read(biometricServiceProvider).preferredKind();
    if (mounted) setState(() => _kind = kind);
  }

  Future<void> _attempt() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    final service = ref.read(biometricServiceProvider);
    final success = _useDeviceFallback
        ? await service.authenticateWithDeviceFallback(reason: widget.reason)
        : await service.authenticateBiometricOnly(reason: widget.reason);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isAuthenticating = false;
      if (!_useDeviceFallback) {
        _failedAttempts++;
        _error = _failedAttempts >= _maxBiometricAttempts
            ? "Échecs répétés. Utilisez le code de votre appareil."
            : "Non reconnu. Essai $_failedAttempts/$_maxBiometricAttempts.";
      } else {
        _error = "Authentification annulée ou échouée.";
      }
    });
  }

  IconData get _icon => switch (_kind) {
    BiometricKind.face => Symbols.face,
    BiometricKind.fingerprint => Symbols.fingerprint,
    BiometricKind.iris => Symbols.visibility,
    BiometricKind.generic => Symbols.lock_person,
    BiometricKind.unavailable => Symbols.lock,
  };

  String get _title => _useDeviceFallback
      ? "Code de l'appareil"
      : switch (_kind) {
          BiometricKind.face => "Face ID",
          BiometricKind.fingerprint => "Empreinte digitale",
          BiometricKind.iris => "Scan de l'iris",
          BiometricKind.generic => "Authentification biométrique",
          BiometricKind.unavailable => "Authentification requise",
        };

  String get _instruction => _useDeviceFallback
      ? "Utilisez le code, schéma ou mot de passe de votre appareil."
      : switch (_kind) {
          BiometricKind.face => "Regardez votre écran pour continuer.",
          BiometricKind.fingerprint => "Posez votre doigt sur le capteur.",
          BiometricKind.iris => "Approchez votre œil du capteur.",
          _ => "Touchez le bouton pour confirmer votre identité.",
        };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Symbols.close, color: AppColors.textMuted),
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final t = _pulseController.value;
                  return SizedBox(
                    width: 176,
                    height: 176,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: (1 - t) * 0.25,
                          child: Container(
                            width: 176 * (0.75 + t * 0.25),
                            height: 176 * (0.75 + t * 0.25),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _error != null && !_isAuthenticating
                                ? AppColors.errorBg
                                : AppColors.successBg,
                          ),
                        ),
                        Icon(
                          _icon,
                          size: 56,
                          color: _error != null && !_isAuthenticating
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                _title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.reason,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _instruction,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textFaint,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _attempt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isAuthenticating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_useDeviceFallback ? Symbols.pin : _icon),
                  label: Text(
                    _useDeviceFallback
                        ? "Utiliser le code de l'appareil"
                        : "Scanner maintenant",
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (widget.allowPasswordFallback) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    widget.passwordFallbackLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ouvre l'écran biométrique (plein écran) et attend le résultat.
///
/// Si le verrouillage biométrique est indisponible sur l'appareil ou
/// désactivé par l'utilisateur (Confidentialité & données), l'action
/// est autorisée directement (`true`) — on ne bloque jamais l'utilisateur
/// avec une exigence qu'il ne peut pas satisfaire.
Future<bool> requireBiometricConfirmation(
  BuildContext context,
  WidgetRef ref, {
  String reason = "Confirmez votre identité pour continuer.",
  bool allowPasswordFallback = true,
  String passwordFallbackLabel = "Utiliser mon mot de passe MboaLink",
}) async {
  final available = await ref.read(biometricServiceProvider).isAvailable;
  final enabled = await ref.read(biometricLockEnabledProvider.future);
  if (!available || !enabled) return true;

  if (!context.mounted) return false;
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => BiometricPromptScreen(
        reason: reason,
        allowPasswordFallback: allowPasswordFallback,
        passwordFallbackLabel: passwordFallbackLabel,
      ),
      fullscreenDialog: true,
    ),
  );
  return result ?? false;
}
