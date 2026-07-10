import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../domain/entities/avis_moderation.dart";
import "../providers/admin_providers.dart";
import "../widgets/admin_nav_bar.dart";

/// Écran 30 · Modération des avis — avis à modérer (note < 3),
/// conserver ou supprimer.
class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avisAsync = ref.watch(avisAModererProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Modération des avis",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "Avis notés en dessous de 3 étoiles",
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: avisAsync.when(
                    loading: () => const Center(child: AppLoader()),
                    error: (error, _) => AppErrorView(
                      error: error,
                      fallbackMessage: "Impossible de charger les avis.",
                      onRetry: () => ref.invalidate(avisAModererProvider),
                    ),
                    data: (liste) => liste.isEmpty
                        ? Center(
                            child: Text(
                              "Aucun avis à modérer pour l'instant.",
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                            itemCount: liste.length,
                            itemBuilder: (ctx, i) =>
                                _ModerationCard(avis: liste[i]),
                          ),
                  ),
                ),
                const AdminNavBar(activeIndex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModerationCard extends ConsumerStatefulWidget {
  const _ModerationCard({required this.avis});

  final AvisModeration avis;

  @override
  ConsumerState<_ModerationCard> createState() => _ModerationCardState();
}

class _ModerationCardState extends ConsumerState<_ModerationCard> {
  bool _isSubmitting = false;

  Future<void> _conserver() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminRepositoryProvider).conserverAvis(widget.avis.id);
      ref.invalidate(avisAModererProvider);
      ref.invalidate(dashboardResumeProvider);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _supprimer() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer cet avis ?"),
        content: const Text(
          "L'avis sera définitivement supprimé de la fiche du grossiste.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminRepositoryProvider).supprimerAvis(widget.avis.id);
      ref.invalidate(avisAModererProvider);
      ref.invalidate(dashboardResumeProvider);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.avis;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "NOTE ${a.note}/5",
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "sur ${a.ficheGrossisteName}",
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.successBg,
                child: Text(
                  a.utilisateurNom.isNotEmpty
                      ? a.utilisateurNom[0].toUpperCase()
                      : "?",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.utilisateurNom,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Symbols.star,
                        size: 11,
                        fill: 1,
                        color: i < a.note ? AppColors.accent : AppColors.border,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (a.commentaire != null && a.commentaire!.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              "« ${a.commentaire} »",
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _conserver,
                    icon: const Icon(Symbols.check, size: 16),
                    label: const Text("Conserver"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _supprimer,
                    icon: const Icon(Symbols.delete, size: 16),
                    label: const Text("Supprimer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
