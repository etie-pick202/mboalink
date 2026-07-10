import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";

class DashboardWidgetOption {
  const DashboardWidgetOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
}

/// Bottom sheet générique "Personnaliser mon dashboard" — une case à
/// cocher par widget disponible. Réutilisé par l'espace Admin et l'espace
/// Grossiste. Renvoie le nouvel ensemble de widgets choisis, ou null si
/// l'utilisateur annule.
Future<Set<String>?> showDashboardWidgetPickerSheet(
  BuildContext context, {
  required List<DashboardWidgetOption> options,
  required Set<String> selected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) =>
        _WidgetPickerSheet(options: options, initialSelected: selected),
  );
}

class _WidgetPickerSheet extends StatefulWidget {
  const _WidgetPickerSheet({
    required this.options,
    required this.initialSelected,
  });

  final List<DashboardWidgetOption> options;
  final Set<String> initialSelected;

  @override
  State<_WidgetPickerSheet> createState() => _WidgetPickerSheetState();
}

class _WidgetPickerSheetState extends State<_WidgetPickerSheet> {
  late final Set<String> _selected = {...widget.initialSelected};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Text(
              "Personnaliser mon dashboard",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "Choisissez les widgets à afficher.",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final option in widget.options)
                      _OptionTile(
                        option: option,
                        checked: _selected.contains(option.id),
                        onChanged: (v) => setState(() {
                          if (v) {
                            _selected.add(option.id);
                          } else {
                            _selected.remove(option.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.checked,
    required this.onChanged,
  });

  final DashboardWidgetOption option;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!checked),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: checked ? AppColors.successBg : AppColors.background,
            border: Border.all(
              color: checked ? AppColors.primary : AppColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 19,
                color: checked ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(option.description, style: AppTypography.caption),
                  ],
                ),
              ),
              Checkbox(
                value: checked,
                activeColor: AppColors.primary,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
