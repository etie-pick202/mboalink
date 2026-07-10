import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:url_launcher/url_launcher.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../domain/entities/fiche_publique.dart";

/// Écran 14 · Coordonnées débloquées — affiché juste après un
/// déverrouillage réussi. Boutons Appeler/WhatsApp réels (url_launcher),
/// plus copie dans le presse-papiers sur chaque coordonnée.
class CoordonneesDebloqueesScreen extends StatelessWidget {
  const CoordonneesDebloqueesScreen({required this.coordonnees, super.key});

  final CoordonneesDeverrouillees coordonnees;

  void _copier(BuildContext context, String valeur, String label) {
    Clipboard.setData(ClipboardData(text: valeur));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$label copié.")));
  }

  Future<void> _appeler(BuildContext context, String telephone) async {
    final uri = Uri(scheme: "tel", path: telephone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir l'application téléphone."),
        ),
      );
    }
  }

  Future<void> _whatsapp(BuildContext context, String telephone) async {
    final numero = telephone.replaceAll(RegExp(r"[^0-9]"), "");
    final uri = Uri.parse("https://wa.me/$numero");
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir WhatsApp.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Symbols.check_circle,
                            size: 34,
                            color: AppColors.primary,
                            fill: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Contact débloqué !",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coordonnees.nomEntreprise,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (coordonnees.telephoneProfessionnel != null)
                          _CoordonneeTile(
                            icon: Symbols.call,
                            iconColor: AppColors.primary,
                            valeur: coordonnees.telephoneProfessionnel!,
                            label: "Téléphone",
                            onCopy: () => _copier(
                              context,
                              coordonnees.telephoneProfessionnel!,
                              "Numéro",
                            ),
                          ),
                        if (coordonnees.emailProfessionnel != null) ...[
                          const SizedBox(height: 10),
                          _CoordonneeTile(
                            icon: Symbols.mail,
                            iconColor: AppColors.primary,
                            valeur: coordonnees.emailProfessionnel!,
                            label: "Email",
                            onCopy: () => _copier(
                              context,
                              coordonnees.emailProfessionnel!,
                              "Email",
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      if (coordonnees.telephoneProfessionnel != null) ...[
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: Material(
                              color: const Color(0xFF25D366),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _whatsapp(
                                  context,
                                  coordonnees.telephoneProfessionnel!,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Symbols.chat,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      "WhatsApp",
                                      style: AppTypography.button,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _appeler(
                                  context,
                                  coordonnees.telephoneProfessionnel!,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Symbols.call,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      "Appeler",
                                      style: AppTypography.button,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.go(AppRoutes.clientDebloques),
                        child: Center(
                          child: Text(
                            "Voir mes contacts débloqués",
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoordonneeTile extends StatelessWidget {
  const _CoordonneeTile({
    required this.icon,
    required this.iconColor,
    required this.valeur,
    required this.label,
    required this.onCopy,
  });

  final IconData icon;
  final Color iconColor;
  final String valeur;
  final String label;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valeur,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label, style: AppTypography.caption),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: const Icon(
              Symbols.content_copy,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
