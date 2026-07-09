import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:image_picker/image_picker.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../domain/entities/document_statut.dart";
import "../../domain/entities/document_type.dart";
import "../../domain/entities/document_verification.dart";
import "../providers/grossiste_providers.dart";

/// Volet 2/2 de l'assistant "Créer ma fiche" — documents de vérification.
///
/// C'est le DERNIER volet du wizard. Une fois les documents soumis :
///   → dialogue de confirmation
///   → retour au dashboard en état "En attente de vérification"
///
/// Le paiement de l'abonnement n'est PAS demandé ici. Il intervient
/// uniquement après validation par l'équipe MboaLink, depuis l'onglet
/// "Profil" (état enAttenteAbonnement).
class GrossisteFicheStep2Screen extends ConsumerWidget {
  const GrossisteFicheStep2Screen({required this.ficheId, super.key});

  final String ficheId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(ficheDocumentsProvider(ficheId));

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: documentsAsync.when(
          loading: () => const Center(child: AppLoader()),
          error: (error, _) => Center(
            child: Text(
              error is AppException
                  ? error.message
                  : "Impossible de charger les documents.",
              style: AppTypography.bodyMedium,
            ),
          ),
          data: (documents) =>
              _Step2Body(ficheId: ficheId, existingDocuments: documents),
        ),
      ),
    );
  }
}

class _Step2Body extends ConsumerStatefulWidget {
  const _Step2Body({required this.ficheId, required this.existingDocuments});

  final String ficheId;
  final List<DocumentVerification> existingDocuments;

  @override
  ConsumerState<_Step2Body> createState() => _Step2BodyState();
}

class _Step2BodyState extends ConsumerState<_Step2Body> {
  final Map<DocumentType, XFile> _pickedFiles = {};
  bool _isSubmitting = false;
  String? _errorMessage;

  DocumentVerification? _existingFor(DocumentType type) {
    for (final doc in widget.existingDocuments) {
      if (doc.type == type) return doc;
    }
    return null;
  }

  bool get _canSubmit {
    final hasRccm =
        _pickedFiles.containsKey(DocumentType.rccm) ||
        _existingFor(DocumentType.rccm) != null;
    final hasCni =
        _pickedFiles.containsKey(DocumentType.cni) ||
        _existingFor(DocumentType.cni) != null;
    return hasRccm && hasCni;
  }

  Future<void> _pick(DocumentType type, {required ImageSource source}) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1600);
    if (file != null) setState(() => _pickedFiles[type] = file);
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(
        () => _errorMessage =
            "Le registre de commerce (RCCM) et la CNI sont obligatoires.",
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      for (final entry in _pickedFiles.entries) {
        // TODO(backend): urlDocument factice — remplacer par vraie URL d'upload.
        await ref
            .read(grossisteRepositoryProvider)
            .ajouterDocument(
              ficheId: widget.ficheId,
              typeDocument: entry.key.apiValue,
              urlDocument: entry.value.path,
            );
      }
      ref.invalidate(ficheDocumentsProvider(widget.ficheId));
      ref.invalidate(maFicheProvider);
      if (!mounted) return;
      _showConfirmationDialog();
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Symbols.check_circle,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Fiche soumise !",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Notre équipe va examiner vos documents sous 24 à 48 h. "
              "Vous serez notifié dès la validation.\n\n"
              "L'abonnement vous sera demandé uniquement après approbation de votre fiche.",
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                height: 1.55,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.grossisteDashboard);
            },
            child: Text(
              "Compris",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
        child: Column(
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Symbols.arrow_back,
                      size: 23,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Créer ma fiche",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Barre de progression 2/2
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "2/2",
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vérification d'identité",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Obligatoire pour tous les grossistes.",
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 10),

                    // Bandeau informatif — flux corrigé
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Symbols.info,
                            size: 17,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Une fois soumis, notre équipe vérifie vos documents sous 24 à 48 h. "
                              "L'abonnement sera demandé uniquement après validation de votre fiche.",
                              style: AppTypography.bodySmall.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _DocumentTile(
                      title: "Registre de commerce (RCCM)",
                      icon: Symbols.description,
                      existing: _existingFor(DocumentType.rccm),
                      picked: _pickedFiles[DocumentType.rccm],
                      onPick: () =>
                          _pick(DocumentType.rccm, source: ImageSource.gallery),
                    ),
                    const SizedBox(height: 14),
                    _DocumentTile(
                      title: "Pièce d'identité (CNI) — recto/verso",
                      icon: Symbols.badge,
                      existing: _existingFor(DocumentType.cni),
                      picked: _pickedFiles[DocumentType.cni],
                      onPick: () =>
                          _pick(DocumentType.cni, source: ImageSource.camera),
                    ),
                    const SizedBox(height: 14),
                    _DocumentTile(
                      title: "Photo du local / boutique (optionnel)",
                      icon: Symbols.storefront,
                      existing: _existingFor(DocumentType.photoLocal),
                      picked: _pickedFiles[DocumentType.photoLocal],
                      onPick: () => _pick(
                        DocumentType.photoLocal,
                        source: ImageSource.camera,
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),

                    PrimaryButton(
                      label: "Soumettre ma fiche",
                      trailingIcon: Symbols.send,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.title,
    required this.icon,
    required this.existing,
    required this.picked,
    required this.onPick,
  });

  final String title;
  final IconData icon;
  final DocumentVerification? existing;
  final XFile? picked;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final isApproved = existing?.statut == DocumentStatut.approuve;
    final isRejected = existing?.statut == DocumentStatut.rejete;
    final isPendingReview =
        existing?.statut == DocumentStatut.enAttente && picked == null;
    final hasNewPick = picked != null;

    var borderColor = AppColors.border;
    if (isApproved) borderColor = AppColors.primary;
    if (isRejected) borderColor = AppColors.error;
    if (hasNewPick) borderColor = AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: borderColor,
          width: isApproved || isRejected || hasNewPick ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isRejected ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isApproved)
                const Icon(
                  Symbols.check_circle,
                  size: 18,
                  color: AppColors.primary,
                ),
            ],
          ),
          if (isRejected && existing?.commentaireAdmin != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Symbols.error, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      existing!.commentaireAdmin!,
                      style: AppTypography.caption.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: isApproved ? null : onPick,
            child: _DottedContainer(
              isActive: hasNewPick || isApproved,
              child: SizedBox(
                height: 72,
                child: Center(
                  child: hasNewPick
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Symbols.check_circle,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Fichier sélectionné — tap pour changer",
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : isPendingReview
                      ? Text(
                          "En attente de vérification",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        )
                      : isApproved
                      ? Text(
                          "Document validé ✓",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Symbols.add_a_photo,
                              size: 22,
                              color: AppColors.textFaint,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isRejected
                                  ? "Renvoyer le document"
                                  : "Ajouter un document",
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedContainer extends StatelessWidget {
  const _DottedContainer({required this.child, this.isActive = false});

  final Widget child;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: isActive ? AppColors.primary : AppColors.border,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
