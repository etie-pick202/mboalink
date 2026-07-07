import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/widgets/diagonal_placeholder.dart";
import "../../../../core/widgets/primary_button.dart";
import "../widgets/onboarding_dots.dart";
import "../widgets/onboarding_slide.dart";

/// Écran 02 · Onboarding — conforme à la maquette MboaLink.
/// Carrousel de 3 slides, bouton "Passer" pour aller direct à la
/// Connexion/Inscription, bouton "Suivant" devient "Commencer" sur la
/// dernière slide. Chaque slide est scrollable pour rester utilisable
/// sur les petits écrans (exigence de responsivité totale).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboardingSlides.length - 1;

  void _goToLogin() => context.go(AppRoutes.login);

  void _next() {
    if (_isLast) {
      _goToLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isCompactHeight = size.height < 640;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 6,
                    ),
                    child: GestureDetector(
                      onTap: _goToLogin,
                      child: Text(
                        "Passer · Skip",
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingSlides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _SlideContent(
                      slide: onboardingSlides[i],
                      compact: isCompactHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 34),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OnboardingDots(
                          count: onboardingSlides.length,
                          activeIndex: _index,
                        ),
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: _isLast ? "Commencer · Start" : "Suivant · Next",
                        trailingIcon: Symbols.arrow_forward,
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide, required this.compact});

  final OnboardingSlide slide;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 8, 26, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DiagonalPlaceholder(
            icon: slide.icon,
            illustrationCaption: slide.illustrationCaption,
            height: compact ? 170 : 262,
          ),
          SizedBox(height: compact ? 18 : 30),
          Text(
            slide.titleFr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: compact ? 21 : 25,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            slide.subtitleEn,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.bodyFr,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
