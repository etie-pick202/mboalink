import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:url_launcher/url_launcher.dart";

import "../theme/app_colors.dart";
import "../theme/app_typography.dart";

const String supportEmail = "support@mboalink.cm";
const String supportTelephone = "+237699000000";

/// Bandeau "Nous contacter" — conforme à la maquette (écran 23). Ouvre
/// l'app mail ou WhatsApp vers le support MboaLink.
Future<void> showContactSupportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nous contacter",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Notre équipe vous répond généralement sous 24h.",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            _SupportOption(
              icon: Symbols.mail,
              label: supportEmail,
              sublabel: "Par email",
              color: AppColors.primary,
              onTap: () async {
                Navigator.pop(ctx);
                await launchUrl(Uri(scheme: "mailto", path: supportEmail));
              },
            ),
            const SizedBox(height: 10),
            _SupportOption(
              icon: Icons.message,
              label: "WhatsApp",
              sublabel: supportTelephone,
              color: const Color(0xFF25D366),
              onTap: () async {
                Navigator.pop(ctx);
                final numero = supportTelephone.replaceAll(
                  RegExp(r"[^0-9]"),
                  "",
                );
                await launchUrl(
                  Uri.parse("https://wa.me/$numero"),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _SupportOption extends StatelessWidget {
  const _SupportOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(sublabel, style: AppTypography.caption),
                  ],
                ),
              ),
              const Icon(
                Symbols.chevron_right,
                size: 19,
                color: AppColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
