import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../domain/entities/consentement.dart";
import "../providers/auth_providers.dart";

/// Écran 20 · Confidentialité & données — gestion des préférences
/// enregistrées via GET/PUT /api/v1/consentements. Accessible depuis le
/// profil, quel que soit le rôle (Client ou Grossiste).
class ConfidentialiteScreen extends ConsumerWidget {
  const ConfidentialiteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentementAsync = ref.watch(consentementProvider);

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
                    "Confidentialité",
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
              child: consentementAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (error, _) => AppErrorView(
                  error: error,
                  fallbackMessage: "Impossible de charger vos préférences.",
                  onRetry: () => ref.invalidate(consentementProvider),
                ),
                data: (consentement) =>
                    _ConfidentialiteBody(consentement: consentement),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidentialiteBody extends ConsumerStatefulWidget {
  const _ConfidentialiteBody({required this.consentement});

  final Consentement consentement;

  @override
  ConsumerState<_ConfidentialiteBody> createState() =>
      _ConfidentialiteBodyState();
}

class _ConfidentialiteBodyState extends ConsumerState<_ConfidentialiteBody> {
  late Consentement _consentement;
  String? _errorField;

  @override
  void initState() {
    super.initState();
    _consentement = widget.consentement;
  }

  Future<void> _toggle({required String field, required bool value}) async {
    final previous = _consentement;
    setState(() {
      _errorField = null;
      _consentement = switch (field) {
        "tracking" => _consentement.copyWith(trackingAccepte: value),
        "notifications" => _consentement.copyWith(
          notificationsAcceptees: value,
        ),
        _ => _consentement.copyWith(marketingAccepte: value),
      };
    });

    try {
      final updated = await ref
          .read(consentementRepositoryProvider)
          .mettreAJour(
            trackingAccepte: field == "tracking" ? value : null,
            notificationsAcceptees: field == "notifications" ? value : null,
            marketingAccepte: field == "marketing" ? value : null,
          );
      if (mounted) setState(() => _consentement = updated);
    } on AppException catch (_) {
      // Échec réseau : on annule visuellement le changement.
      if (mounted) {
        setState(() {
          _consentement = previous;
          _errorField = field;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gérez les données utilisées pour personnaliser vos "
                "recommandations.",
                style: AppTypography.bodySmall.copyWith(height: 1.5),
              ),
              const SizedBox(height: 14),
              const _BiometricSecurityCard(),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _ToggleTile(
                      icon: Symbols.location_on,
                      title: "Position & personnalisation",
                      subtitle: "Grossistes à proximité, suggestions",
                      value: _consentement.trackingAccepte,
                      onChanged: (v) => _toggle(field: "tracking", value: v),
                      showDivider: true,
                    ),
                    _ToggleTile(
                      icon: Symbols.notifications,
                      title: "Notifications",
                      subtitle: "Alertes nouveaux grossistes, prix",
                      value: _consentement.notificationsAcceptees,
                      onChanged: (v) =>
                          _toggle(field: "notifications", value: v),
                      showDivider: true,
                    ),
                    _ToggleTile(
                      icon: Symbols.campaign,
                      title: "Communications marketing",
                      subtitle: "Offres et actualités MboaLink",
                      value: _consentement.marketingAccepte,
                      onChanged: (v) => _toggle(field: "marketing", value: v),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              if (_errorField != null) ...[
                const SizedBox(height: 10),
                Text(
                  "Échec de la mise à jour. Réessayez.",
                  style: AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Symbols.verified_user,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      "Données utilisées en interne uniquement, jamais "
                      "revendues.",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textFaint,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Verrouillage biométrique — protège la reprise de session et les
/// actions sensibles (changement de mot de passe, bascule de rôle…).
/// Masqué si l'appareil ne possède aucun capteur compatible.
class _BiometricSecurityCard extends ConsumerWidget {
  const _BiometricSecurityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(biometricAvailableProvider);

    return availableAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (available) {
        if (!available) return const SizedBox.shrink();

        final enabledAsync = ref.watch(biometricLockEnabledProvider);
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _ToggleTile(
            icon: Symbols.fingerprint,
            title: "Verrouillage biométrique",
            subtitle:
                "Confirme votre identité pour reprendre votre "
                "session et modifier vos données sensibles",
            value: enabledAsync.value ?? true,
            showDivider: false,
            onChanged: enabledAsync.isLoading
                ? (_) {}
                : (v) => setBiometricLockEnabled(ref, v),
          ),
        );
      },
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.background))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
