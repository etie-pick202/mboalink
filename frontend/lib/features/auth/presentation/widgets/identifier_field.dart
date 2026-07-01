import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../../../core/theme/app_colors.dart";
import "../../../../../../core/theme/app_typography.dart";

/// Champ identifiant unique — téléphone (par défaut, style maquette avec
/// indicatif Cameroun) ou email (détecté automatiquement dès qu'un "@"
/// est saisi). Couvre l'exigence du cahier des charges (email OU
/// téléphone) sans dénaturer le champ téléphone de la maquette.
class IdentifierField extends StatefulWidget {
  const IdentifierField({required this.controller, this.validator, super.key});

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<IdentifierField> createState() => _IdentifierFieldState();
}

class _IdentifierFieldState extends State<IdentifierField> {
  bool _isEmail = false;

  void _handleChange(String value) {
    final looksLikeEmail = value.contains("@");
    if (looksLikeEmail != _isEmail) {
      setState(() => _isEmail = looksLikeEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEmail ? "Email" : "Téléphone · Phone",
          style: AppTypography.fieldLabel,
        ),
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
              if (!_isEmail) ...[
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
              ],
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  onChanged: _handleChange,
                  validator: widget.validator,
                  keyboardType: _isEmail
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: _isEmail ? "vous@exemple.com" : "6 90 00 00 00",
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
