import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/primary_button.dart";
import "../providers/home_providers.dart";

/// Écran 15 · Laisser un avis — conforme à la maquette : bandeau "Avis
/// autorisé" si l'utilisateur a débloqué ce contact, sélection d'étoiles,
/// commentaire libre.
class LaisserAvisScreen extends ConsumerStatefulWidget {
  const LaisserAvisScreen({
    required this.ficheId,
    required this.nomEntreprise,
    this.referenceTransaction,
    super.key,
  });

  final String ficheId;
  final String nomEntreprise;
  final String? referenceTransaction;

  @override
  ConsumerState<LaisserAvisScreen> createState() => _LaisserAvisScreenState();
}

class _LaisserAvisScreenState extends ConsumerState<LaisserAvisScreen> {
  int _note = 4;
  final _commentaire = TextEditingController();
  bool _isSubmitting = false;
  String? _erreur;

  static const _labels = {
    1: "Décevant",
    2: "Moyen",
    3: "Correct",
    4: "Très bien",
    5: "Excellent",
  };

  @override
  void dispose() {
    _commentaire.dispose();
    super.dispose();
  }

  Future<void> _publier() async {
    setState(() {
      _isSubmitting = true;
      _erreur = null;
    });
    try {
      await ref
          .read(avisRepositoryProvider)
          .publierAvis(
            ficheGrossisteId: widget.ficheId,
            note: _note,
            commentaire: _commentaire.text.trim(),
            referenceTransaction: widget.referenceTransaction,
          );
      ref.invalidate(avisListProvider(widget.ficheId));
      ref.invalidate(avisBreakdownProvider(widget.ficheId));
      // La note moyenne affichée sur la fiche publique doit refléter le
      // nouvel avis immédiatement (NotationService la recalcule côté serveur).
      ref.invalidate(fichePubliqueProvider(widget.ficheId));
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Avis publié. Merci !")));
    } on AppException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Symbols.close,
                      size: 23,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Votre avis",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.referenceTransaction != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Symbols.verified_user,
                              size: 18,
                              fill: 1,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Avis autorisé : vous avez débloqué ce contact",
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 22),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            widget.nomEntreprise,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Quelle note donnez-vous ?",
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final valeur = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _note = valeur),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.5,
                            ),
                            child: Icon(
                              Symbols.star,
                              size: 38,
                              fill: 1,
                              color: valeur <= _note
                                  ? AppColors.accent
                                  : AppColors.borderLight,
                            ),
                          ),
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        "${_labels[_note]} · $_note/5",
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "VOTRE COMMENTAIRE",
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentaire,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            "Décrivez votre expérience avec ce grossiste…",
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                            color: AppColors.borderLight,
                          ),
                        ),
                      ),
                    ),
                    if (_erreur != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _erreur!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 11, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: PrimaryButton(
                label: "Publier l'avis",
                isLoading: _isSubmitting,
                onPressed: _publier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
