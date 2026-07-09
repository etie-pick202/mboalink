import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";

/// Champ de saisie MboaLink : libellé au-dessus, style conforme à la
/// maquette (fond blanc, bordure fine, coins arrondis). Gère le toggle
/// de visibilité pour les mots de passe.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefix,
    this.validator,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final bool enabled;
  final void Function(String)? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.fieldLabel),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefix,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Symbols.visibility_off : Symbols.visibility,
                      color: AppColors.textFaint,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
