import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../../../core/theme/app_colors.dart";

/// Sélecteur à 2 segments (Connexion / Inscription), fidèle à la maquette :
/// piste grise arrondie, segment actif blanc avec ombre légère.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAEEE9),
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 38,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textFaint,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
