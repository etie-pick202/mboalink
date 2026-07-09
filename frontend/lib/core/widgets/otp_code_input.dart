import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";

/// Saisie de code OTP à N chiffres, fidèle au style de la maquette (cases
/// carrées, bordure fine, case active soulignée en vert). Un seul champ de
/// saisie invisible capte le clavier/collage ; l'affichage se fait via des
/// cases stylées séparées, plus fiable qu'un focus par case individuelle.
class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.autofocus = true,
    super.key,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange(String value) {
    widget.onChanged(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final char = index < value.text.length
                      ? value.text[index]
                      : "";
                  final isActive = index == value.text.length;
                  return Container(
                    width: 46,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.border,
                        width: isActive ? 2 : 1.5,
                      ),
                    ),
                    child: Text(char, style: AppTypography.headlineLarge),
                  );
                },
              );
            }),
          ),
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: _handleChange,
              decoration: const InputDecoration(counterText: ""),
            ),
          ),
        ],
      ),
    );
  }
}
