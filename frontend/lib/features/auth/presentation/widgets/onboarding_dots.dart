import "package:flutter/material.dart";

import "../../../../core/theme/app_colors.dart";

/// Indicateur de pagination : point actif en barre (24x7), inactifs en
/// cercle (7x7 gris) — exactement le style de la maquette.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    required this.count,
    required this.activeIndex,
    super.key,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 7),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFCDD6CF),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
