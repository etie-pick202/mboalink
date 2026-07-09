import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

import "../theme/app_colors.dart";

enum AppLogoVariant { solid, ghost }

/// Logo de marque MboaLink, réutilisable sur tous les écrans.
///
/// - [AppLogoVariant.ghost] : boîte translucide + bordure blanche, pour fonds
///   sombres/dégradés (ex: Splash).
/// - [AppLogoVariant.solid] : boîte dégradé vert plein, pour fonds clairs
///   (ex: en-tête de l'écran Connexion).
class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = 42,
    this.variant = AppLogoVariant.solid,
    this.showBadge = false,
    super.key,
  });

  final double size;
  final AppLogoVariant variant;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final isGhost = variant == AppLogoVariant.ghost;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isGhost
                  ? null
                  : const LinearGradient(
                      begin: Alignment(-0.5, -1),
                      end: Alignment(0.5, 1),
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
              color: isGhost ? Colors.white.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(size * 0.29),
              border: isGhost
                  ? Border.all(color: Colors.white.withValues(alpha: 0.25))
                  : null,
              boxShadow: isGhost
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: size * 0.33,
                        offset: Offset(0, size * 0.15),
                      ),
                    ],
            ),
            child: Center(
              child: Icon(Symbols.hub, size: size * 0.545, color: Colors.white),
            ),
          ),
          if (showBadge)
            Positioned(
              top: -size * 0.08,
              right: -size * 0.08,
              child: Container(
                width: size * 0.27,
                height: size * 0.27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  border: Border.all(
                    color: isGhost
                        ? AppColors.primaryDark
                        : AppColors.background,
                    width: size * 0.045,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
