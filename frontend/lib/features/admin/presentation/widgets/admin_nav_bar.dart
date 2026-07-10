import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";

/// Barre de navigation Admin — 4 onglets : Dashboard (0), Validations (1),
/// Modération (2), Revenus (3).
class AdminNavBar extends StatelessWidget {
  const AdminNavBar({required this.activeIndex, super.key});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.background)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Symbols.admin_panel_settings,
            label: "Dashboard",
            isActive: activeIndex == 0,
            onTap: activeIndex == 0
                ? () {}
                : () => context.go(AppRoutes.adminDashboard),
          ),
          _NavItem(
            icon: Symbols.fact_check,
            label: "Validations",
            isActive: activeIndex == 1,
            onTap: activeIndex == 1
                ? () {}
                : () => context.go(AppRoutes.adminValidations),
          ),
          _NavItem(
            icon: Symbols.reviews,
            label: "Modération",
            isActive: activeIndex == 2,
            onTap: activeIndex == 2
                ? () {}
                : () => context.go(AppRoutes.adminModeration),
          ),
          _NavItem(
            icon: Symbols.payments,
            label: "Revenus",
            isActive: activeIndex == 3,
            onTap: activeIndex == 3
                ? () {}
                : () => context.go(AppRoutes.adminRevenus),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textFaint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 23, color: color, fill: isActive ? 1 : 0),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
