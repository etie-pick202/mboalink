import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/primary_button.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../../domain/entities/produit_grossite.dart";
import "../providers/grossiste_providers.dart";
import "grossiste_nav_bar.dart";

/// Onglet "Boutique" (index 1) du tableau de bord Grossiste validé.
/// Conforme à la maquette : liste des produits avec actions glissables
/// (modifier, supprimer), bouton d'ajout, responsive.
class GrossisteBoutiqueScreen extends ConsumerWidget {
  const GrossisteBoutiqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ficheAsync = ref.watch(maFicheProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: ficheAsync.when(
          loading: () => const Center(child: AppLoader()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error is AppException
                    ? error.message
                    : "Impossible de charger votre fiche.",
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            ),
          ),
          data: (fiche) => _BoutiqueBody(fiche: fiche),
        ),
      ),
    );
  }
}

class _BoutiqueBody extends ConsumerWidget {
  const _BoutiqueBody({required this.fiche});

  final FicheGrossiste fiche;

  Future<void> _showAjoutDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ProduitDialog(ficheId: fiche.id),
    );
    ref.invalidate(ficheProduits(fiche.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final produitsAsync = ref.watch(ficheProduits(fiche.id));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 560 : double.infinity),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ma boutique",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    fiche.nomEntreprise ?? "",
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: produitsAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error is AppException
                              ? error.message
                              : "Impossible de charger les produits.",
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: "Réessayer",
                          onPressed: () =>
                              ref.invalidate(ficheProduits(fiche.id)),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (produits) => Column(
                  children: [
                    if (produits.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${produits.length} produit${produits.length > 1 ? "s" : ""}",
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "← Glisser pour modifier / supprimer",
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                    Expanded(
                      child: produits.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Symbols.inventory_2,
                                        size: 30,
                                        color: AppColors.textFaint,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      "Votre boutique est vide",
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Ajoutez vos premiers produits pour qu'ils apparaissent sur votre fiche.",
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodySmall.copyWith(
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: produits.length,
                              itemBuilder: (context, index) => _ProduitTile(
                                produit: produits[index],
                                ficheId: fiche.id,
                                onRefresh: () =>
                                    ref.invalidate(ficheProduits(fiche.id)),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: PrimaryButton(
                        label: "Ajouter un produit",
                        trailingIcon: Symbols.add,
                        onPressed: () => _showAjoutDialog(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const GrossisteNavBar(activeIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _ProduitTile extends ConsumerWidget {
  const _ProduitTile({
    required this.produit,
    required this.ficheId,
    required this.onRefresh,
  });

  final ProduitGrossiste produit;
  final String ficheId;
  final VoidCallback onRefresh;

  Future<void> _showModifierDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ProduitDialog(ficheId: ficheId, produit: produit),
    );
    ref.invalidate(ficheProduits(ficheId));
  }

  Future<void> _confirmerSuppression(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ce produit ?"),
        content: Text(
          "« ${produit.nom} » sera définitivement retiré de votre boutique.",
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
    if (confirmed == true) {
      // TODO(backend): brancher la suppression réelle — endpoint DELETE
      // /grossistes/{ficheId}/produits/{produitId} non encore confirmé.
      await Future.delayed(const Duration(milliseconds: 300));
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (ctx) => _showModifierDialog(context, ref),
              backgroundColor: const Color(0xFFFFF3CC),
              foregroundColor: const Color(0xFFC79A16),
              icon: Symbols.edit,
              label: "Modifier",
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(13),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (ctx) => _confirmerSuppression(context),
              backgroundColor: AppColors.errorBg,
              foregroundColor: AppColors.error,
              icon: Symbols.delete,
              label: "Supprimer",
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(13),
              ),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Symbols.inventory_2,
                  size: 24,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            produit.nom,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (produit.prixUnitaire != null)
                          Text(
                            "${produit.prixUnitaire!.toStringAsFixed(0)} F",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    if (produit.categorie != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        produit.categorie!,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    if (produit.description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        produit.description!,
                        style: AppTypography.caption.copyWith(height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (produit.quantiteMinimale != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        "Qté min : ${produit.quantiteMinimale!.toStringAsFixed(0)} ${produit.uniteMesure ?? ""}",
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProduitDialog extends ConsumerStatefulWidget {
  const _ProduitDialog({required this.ficheId, this.produit});

  final String ficheId;
  final ProduitGrossiste? produit;

  @override
  ConsumerState<_ProduitDialog> createState() => _ProduitDialogState();
}

class _ProduitDialogState extends ConsumerState<_ProduitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _description;
  late final TextEditingController _categorie;
  late final TextEditingController _prix;
  late final TextEditingController _quantiteMin;
  late final TextEditingController _unite;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEdit => widget.produit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produit;
    _nom = TextEditingController(text: p?.nom ?? "");
    _description = TextEditingController(text: p?.description ?? "");
    _categorie = TextEditingController(text: p?.categorie ?? "");
    _prix = TextEditingController(
      text: p?.prixUnitaire?.toStringAsFixed(0) ?? "",
    );
    _quantiteMin = TextEditingController(
      text: p?.quantiteMinimale?.toStringAsFixed(0) ?? "",
    );
    _unite = TextEditingController(text: p?.uniteMesure ?? "");
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _categorie.dispose();
    _prix.dispose();
    _quantiteMin.dispose();
    _unite.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final donnees = <String, dynamic>{
      "nom": _nom.text.trim(),
      "description": _description.text.trim(),
      "categorie": _categorie.text.trim(),
      if (_prix.text.trim().isNotEmpty)
        "prixUnitaire": double.tryParse(_prix.text.trim()),
      if (_quantiteMin.text.trim().isNotEmpty)
        "quantiteMinimale": double.tryParse(_quantiteMin.text.trim()),
      "uniteMesure": _unite.text.trim(),
      "estDisponible": true,
    };

    try {
      if (_isEdit) {
        await ref
            .read(grossisteRepositoryProvider)
            .modifierProduit(
              ficheId: widget.ficheId,
              produitId: widget.produit!.id,
              donnees: donnees,
            );
      } else {
        await ref
            .read(grossisteRepositoryProvider)
            .ajouterProduit(ficheId: widget.ficheId, donnees: donnees);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? "Modifier le produit" : "Ajouter un produit"),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: "Nom *",
              controller: _nom,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Le nom est obligatoire.";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(label: "Description", controller: _description),
            const SizedBox(height: 12),
            AppTextField(
              label: "Catégorie",
              controller: _categorie,
              hintText: "Ex : Vivres, Textile",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: "Prix (FCFA)",
                    controller: _prix,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return null;
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return "Nombre invalide.";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: "Qté min",
                    controller: _quantiteMin,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return null;
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return "Nombre invalide.";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: "Unité de mesure",
              controller: _unite,
              hintText: "kg, sac, pièce…",
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? "Enregistrer" : "Ajouter"),
        ),
      ],
    );
  }
}
