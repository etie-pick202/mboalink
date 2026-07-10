import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:url_launcher/url_launcher.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../domain/entities/contact_debloque.dart";
import "../providers/home_providers.dart";
import "../widgets/client_nav_bar.dart";

/// Onglet "Débloqués" (index 2) — liste réelle des grossistes dont le
/// client a payé pour voir les coordonnées (GET /grossistes/mes-deverrouillages).
class ClientDeblocagesScreen extends ConsumerWidget {
  const ClientDeblocagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final contacts = ref.watch(mesDeverrouillagesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Contacts débloqués",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${contacts.value?.length ?? 0}",
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: contacts.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: Text(
                        "Impossible de charger vos contacts débloqués.",
                        style: AppTypography.bodySmall,
                      ),
                    ),
                    data: (liste) => liste.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Symbols.lock_open,
                                  size: 42,
                                  color: AppColors.textFaint,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Aucun contact débloqué",
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    "Déverrouillez les coordonnées d'un grossiste via son profil (MoMo ou Orange Money).",
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            itemCount: liste.length,
                            itemBuilder: (ctx, i) =>
                                _DebloqueTile(contact: liste[i]),
                          ),
                  ),
                ),
                const ClientNavBar(activeIndex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebloqueTile extends StatelessWidget {
  const _DebloqueTile({required this.contact});

  final ContactDebloque contact;

  Future<void> _appeler(BuildContext context) async {
    final tel = contact.telephoneProfessionnel;
    if (tel == null) return;
    final uri = Uri(scheme: "tel", path: tel);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir l'application téléphone."),
        ),
      );
    }
  }

  Future<void> _whatsapp(BuildContext context) async {
    final tel = contact.telephoneProfessionnel;
    if (tel == null) return;
    final numero = tel.replaceAll(RegExp(r"[^0-9]"), "");
    final uri = Uri.parse("https://wa.me/$numero");
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir WhatsApp.")),
      );
    }
  }

  String _formatDate(DateTime d) {
    const mois = [
      "janv.",
      "févr.",
      "mars",
      "avr.",
      "mai",
      "juin",
      "juil.",
      "août",
      "sept.",
      "oct.",
      "nov.",
      "déc.",
    ];
    return "${d.day} ${mois[d.month - 1]} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    contact.logoUrl != null &&
                        contact.logoUrl!.isNotEmpty &&
                        !contact.logoUrl!.startsWith("mock://")
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          contact.logoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Symbols.storefront,
                        size: 22,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.nomEntreprise,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      [
                        contact.secteurActivite,
                        contact.ville,
                      ].whereType<String>().join(" · "),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "le ${_formatDate(contact.deverrouilleLe)}",
                    style: AppTypography.caption,
                  ),
                  if (!contact.encoreValide)
                    Text(
                      "Expiré",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ContactBtn(
                  icon: Symbols.call,
                  label: contact.telephoneProfessionnel ?? "—",
                  color: AppColors.primary,
                  onTap: contact.telephoneProfessionnel == null
                      ? null
                      : () => _appeler(context),
                ),
              ),
              const SizedBox(width: 8),
              _ContactBtn(
                icon: Icons.message,
                label: "WhatsApp",
                color: const Color(0xFF25D366),
                onTap: contact.telephoneProfessionnel == null
                    ? null
                    : () => _whatsapp(context),
              ),
              const SizedBox(width: 8),
              _ContactBtn(
                icon: Symbols.star,
                label: "Avis",
                color: AppColors.accent,
                onTap: () => context.push(
                  AppRoutes.laisserAvis,
                  extra: {
                    "ficheId": contact.ficheGrossisteId,
                    "nomEntreprise": contact.nomEntreprise,
                    "referenceTransaction": contact.referenceTransaction,
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
