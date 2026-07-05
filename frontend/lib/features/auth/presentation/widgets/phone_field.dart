import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";

/// Champ téléphone camerounais — indicatif +237 fixe, conforme au style
/// visuel de la maquette. Utilisé uniquement à l'inscription, en tant que
/// donnée secondaire facultative (l'email est l'identifiant principal).
class PhoneField extends StatelessWidget {
  const PhoneField({
    required this.controller,
    this.validator,
    this.label = "Téléphone (optionnel) · Phone",
    super.key,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Text(
                "\u{1F1E8}\u{1F1F2} +237",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: AppColors.border),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: "6 90 00 00 00",
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFaint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
