import "dart:async";

import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/widgets/app_logo.dart";
import "../widgets/pulsing_dot.dart";

/// Écran 01 · Splash — conforme à la maquette MboaLink.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TODO(auth): vérifier une session existante (token stocké) avant de
    // rediriger — direct vers l'accueil si connecté, sinon onboarding.
    Timer(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
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
                padding: const EdgeInsets.only(bottom: 46),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    PulsingDot(delay: Duration.zero),
                    SizedBox(width: 9),
                    PulsingDot(delay: Duration(milliseconds: 200)),
                    SizedBox(width: 9),
                    PulsingDot(delay: Duration(milliseconds: 400)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
