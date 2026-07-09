import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../providers/auth_providers.dart";

/// Écran Profil minimal — pas encore conforme en détail à l'écran 18 de
/// la maquette (à enrichir plus tard), mais fonctionnel : sert de point
/// de sortie (déconnexion) pour boucler le parcours de test complet.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    // TODO(auth): passer le vrai refreshToken une fois la session persistée
    // (flutter_secure_storage) — pour l'instant, le mock/remote accepte un
    // token vide sans erreur bloquante côté logout.
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
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profil",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Paramètres et gestion de compte — à enrichir (écran 18/20 de la maquette).",
                style: AppTypography.bodySmall,
              ),
              const Spacer(),
              Material(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: _isLoggingOut ? null : _logout,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    child: _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Symbols.logout,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Se déconnecter",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
