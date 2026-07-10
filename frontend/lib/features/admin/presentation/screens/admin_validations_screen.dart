import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../grossiste/domain/entities/document_statut.dart";
import "../../../grossiste/domain/entities/document_type.dart";
import "../../../grossiste/domain/entities/document_verification.dart";
import "../../domain/entities/validation_fiche.dart";
import "../providers/admin_providers.dart";
import "../widgets/admin_nav_bar.dart";

/// Écran 29 · Validation des grossistes — fiches en attente, documents
/// (approuver/rejeter individuellement), valider/rejeter la fiche entière.
class AdminValidationsScreen extends ConsumerWidget {
  const AdminValidationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validationsAsync = ref.watch(validationsEnAttenteProvider);
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        "Validations",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      validationsAsync.maybeWhen(
                        data: (list) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            "${list.length}",
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: validationsAsync.when(
                    loading: () => const Center(child: AppLoader()),
                    error: (error, _) => AppErrorView(
                      error: error,
                      fallbackMessage: "Impossible de charger les validations.",
                      onRetry: () =>
                          ref.invalidate(validationsEnAttenteProvider),
                    ),
                    data: (fiches) => fiches.isEmpty
                        ? Center(
                            child: Text(
                              "Aucune fiche en attente de validation.",
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            itemCount: fiches.length,
                            itemBuilder: (ctx, i) =>
                                _ValidationCard(fiche: fiches[i]),
                          ),
                  ),
                ),
                const AdminNavBar(activeIndex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ValidationCard extends ConsumerStatefulWidget {
  const _ValidationCard({required this.fiche});

  final ValidationFiche fiche;

  @override
  ConsumerState<_ValidationCard> createState() => _ValidationCardState();
}

class _ValidationCardState extends ConsumerState<_ValidationCard> {
  bool _isSubmitting = false;

  Future<void> _valider() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminRepositoryProvider).validerFiche(widget.fiche.id);
      ref.invalidate(validationsEnAttenteProvider);
      ref.invalidate(dashboardResumeProvider);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _rejeter() async {
    final commentaire = await _demanderCommentaire(
      "Motif du rejet de la fiche",
    );
    if (commentaire == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminRepositoryProvider).rejeterFiche(widget.fiche.id);
      ref.invalidate(validationsEnAttenteProvider);
      ref.invalidate(dashboardResumeProvider);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String?> _demanderCommentaire(String titre) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titre),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Expliquez brièvement la raison…",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _traiterDocument(
    DocumentVerification doc, {
    required bool approuver,
  }) async {
    String? commentaire;
    if (!approuver) {
      commentaire = await _demanderCommentaire("Motif du rejet du document");
      if (commentaire == null) return;
    }
    final repo = ref.read(adminRepositoryProvider);
    if (approuver) {
      await repo.approuverDocument(doc.id);
    } else {
      await repo.rejeterDocument(doc.id, commentaire: commentaire);
    }
    ref.invalidate(validationsEnAttenteProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _ouvrirDocument(DocumentVerification doc) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.type.label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.network(
                  doc.urlDocument,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 220,
                    color: AppColors.background,
                    child: const Icon(
                      Symbols.broken_image,
                      color: AppColors.textFaint,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _traiterDocument(doc, approuver: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text("Refuser"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _traiterDocument(doc, approuver: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Approuver"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fiche;
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Symbols.storefront,
                  size: 23,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.nomEntreprise,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      [
                        f.secteurActivite,
                        f.quartier ?? f.ville,
                      ].whereType<String>().join(" · "),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF3D6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "NOUVEAU",
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC79A16),
                  ),
                ),
              ),
            ],
          ),
          if (f.documents.isNotEmpty) ...[
            const SizedBox(height: 11),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final doc in f.documents)
                  _DocumentChip(doc: doc, onTap: () => _ouvrirDocument(doc)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _rejeter,
                    icon: const Icon(Symbols.close, size: 17),
                    label: const Text("Refuser"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _valider,
                    icon: const Icon(Symbols.check, size: 17),
                    label: const Text("Valider"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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

class _DocumentChip extends StatelessWidget {
  const _DocumentChip({required this.doc, required this.onTap});

  final DocumentVerification doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (doc.statut) {
      DocumentStatut.approuve => (
        Symbols.check_circle,
        AppColors.primary,
        AppColors.successBg,
      ),
      DocumentStatut.rejete => (
        Symbols.cancel,
        AppColors.error,
        AppColors.errorBg,
      ),
      DocumentStatut.enAttente => (
        Symbols.hourglass_top,
        const Color(0xFFC79A16),
        const Color(0xFFFDF3D6),
      ),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, fill: 1, color: color),
            const SizedBox(width: 5),
            Text(
              _shortLabel(doc.type),
              style: GoogleFonts.manrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortLabel(DocumentType type) => switch (type) {
    DocumentType.rccm => "RCCM",
    DocumentType.cni => "CNI",
    DocumentType.photoLocal => "Photo local",
  };
}
