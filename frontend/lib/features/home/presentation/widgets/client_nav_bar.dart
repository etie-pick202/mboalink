import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";

/// Barre de navigation Client — 4 onglets conformes à la maquette :
/// Accueil (0) | Recherche (1) | Débloqués (2) | Profil (3).
class ClientNavBar extends StatelessWidget {
  const ClientNavBar({required this.activeIndex, super.key});

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
            icon: Symbols.home,
            label: "Accueil",
            isActive: activeIndex == 0,
            onTap: activeIndex == 0 ? () {} : () => context.go(AppRoutes.home),
          ),
          _NavItem(
            icon: Symbols.search,
            label: "Recherche",
            isActive: activeIndex == 1,
            onTap: activeIndex == 1
                ? () {}
                : () => context.go(AppRoutes.clientRecherche),
          ),
          _NavItem(
            icon: Symbols.lock_open,
            label: "Débloqués",
            isActive: activeIndex == 2,
            onTap: activeIndex == 2
                ? () {}
                : () => context.go(AppRoutes.clientDebloques),
          ),
          _NavItem(
            icon: Symbols.person,
            label: "Profil",
            isActive: activeIndex == 3,
            onTap: activeIndex == 3
                ? () {}
                : () => context.go(AppRoutes.clientProfil),
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
