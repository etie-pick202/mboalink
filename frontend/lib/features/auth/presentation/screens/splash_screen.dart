import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/widgets/app_logo.dart";
import "../../domain/entities/user_role.dart";
import "../providers/auth_providers.dart";
import "../widgets/pulsing_dot.dart";

/// Écran 01 · Splash — bouton "Démarrer" (pas un loader automatique).
/// Au tap : vérifie une session persistée ; si trouvée, demande une
/// confirmation biométrique (si disponible sur l'appareil) avant de
/// reprendre directement sur l'accueil/dashboard, sinon direction
/// Onboarding.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isStarting = false;

  Future<void> _handleStart() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);

    final session = await ref.read(sessionStorageProvider).read();

    if (session == null) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      context.go(AppRoutes.onboarding);
      return;
    }

    final biometricsAvailable = await ref
        .read(biometricServiceProvider)
        .isAvailable;
    var authenticated = true;
    if (biometricsAvailable) {
      authenticated = await ref.read(biometricServiceProvider).authenticate();
    }

    if (!mounted) return;

    if (!authenticated) {
      context.go(AppRoutes.login);
      return;
    }

    ref.read(currentSessionProvider.notifier).state = session;
    context.go(
      session.role == UserRole.grossiste
          ? AppRoutes.grossisteDashboard
          : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = shortestSide >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.6, -1),
            end: Alignment(0.6, 1),
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 480 : double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppLogo(
                            size: isTablet ? 112 : 96,
                            variant: AppLogoVariant.ghost,
                            showBadge: true,
                          ),
                          const SizedBox(height: 22),
                          Text.rich(
                            TextSpan(
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: isTablet ? 46 : 38,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                              children: const [
                                TextSpan(text: "MboaLink"),
                                TextSpan(
                                  text: ".",
                                  style: TextStyle(color: AppColors.accent),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Trouvez les meilleurs grossistes du Cameroun",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Find Cameroon's best wholesalers",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 46),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isStarting
                      ? const Row(
                          key: ValueKey("loading"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PulsingDot(delay: Duration.zero),
                            SizedBox(width: 9),
                            PulsingDot(delay: Duration(milliseconds: 200)),
                            SizedBox(width: 9),
                            PulsingDot(delay: Duration(milliseconds: 400)),
                          ],
                        )
                      : GestureDetector(
                          key: const ValueKey("button"),
                          onTap: _handleStart,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Démarrer · Start",
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: AppColors.primaryDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
