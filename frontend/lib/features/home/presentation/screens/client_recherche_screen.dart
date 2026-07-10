import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/errors/app_exception.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../../../core/widgets/app_error_view.dart";
import "../../../../core/widgets/app_loader.dart";
import "../../domain/entities/grossiste_resume.dart";
import "../../domain/repositories/recherche_repository.dart";
import "../providers/home_providers.dart";
import "../widgets/client_nav_bar.dart";

/// Écran 07 · Recherche — filtres ville/secteur et résultats paginés,
/// branchés sur GET /search/grossistes, /search/villes, /search/secteurs.
class ClientRechercheScreen extends ConsumerStatefulWidget {
  const ClientRechercheScreen({this.categorieInitiale, super.key});

  /// Pré-remplit le filtre secteur quand on arrive depuis une catégorie
  /// tapée sur l'accueil.
  final String? categorieInitiale;

  @override
  ConsumerState<ClientRechercheScreen> createState() =>
      _ClientRechercheScreenState();
}

class _ClientRechercheScreenState extends ConsumerState<ClientRechercheScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String _query = "";
  String? _ville;
  String? _secteur;

  // Filtres avancés (écran 08) — appliqués via le bottom sheet _FiltresSheet.
  RangeValues? _fourchettePrix;
  bool _verifiesUniquement = false;
  bool _certifiesUniquement = false;
  String _tri = "NOTE_DESC";

  PageResultat<GrossisteResume>? _page;
  bool _isLoading = true;
  Object? _error;

  int get _nombreFiltresActifs =>
      (_fourchettePrix != null ? 1 : 0) +
      (_verifiesUniquement ? 1 : 0) +
      (_certifiesUniquement ? 1 : 0) +
      (_tri != "NOTE_DESC" ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _secteur = widget.categorieInitiale;
    _rechercher();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _rechercher() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(rechercheRepositoryProvider)
          .rechercherGrossistes(
            motCle: _query.isEmpty ? null : _query,
            ville: _ville,
            categorie: _secteur,
            prixMin: _fourchettePrix?.start,
            prixMax: _fourchettePrix?.end,
            certifie: _verifiesUniquement ? true : null,
            certifiePremium: _certifiesUniquement ? true : null,
            tri: _tri,
          );
      if (mounted) setState(() => _page = page);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _rechercher);
  }

  Future<void> _ouvrirFiltres() async {
    final resultat = await showModalBottomSheet<_FiltresResultat>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _FiltresSheet(
        fourchetteInitiale: _fourchettePrix,
        verifiesInitial: _verifiesUniquement,
        certifiesInitial: _certifiesUniquement,
        triInitial: _tri,
      ),
    );
    if (resultat == null) return;
    setState(() {
      _fourchettePrix = resultat.fourchettePrix;
      _verifiesUniquement = resultat.verifies;
      _certifiesUniquement = resultat.certifies;
      _tri = resultat.tri;
    });
    _rechercher();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final villesAsync = ref.watch(villesProvider);
    final secteursAsync = ref.watch(secteursProvider);
    final results = _page?.resultats ?? const [];

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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recherche",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ctrl,
                        onChanged: _onQueryChanged,
                        decoration: InputDecoration(
                          hintText: "Grossiste, produit, catégorie…",
                          hintStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.textFaint,
                          ),
                          prefixIcon: const Icon(
                            Symbols.search,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    _onQueryChanged("");
                                  },
                                  child: const Icon(Symbols.close, size: 18),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _Dropdown(
                              hint: "Ville",
                              value: _ville,
                              items: villesAsync.value ?? const [],
                              onChanged: (v) {
                                setState(() => _ville = v);
                                _rechercher();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Dropdown(
                              hint: "Secteur",
                              value: _secteur,
                              items: secteursAsync.value ?? const [],
                              onChanged: (v) {
                                setState(() => _secteur = v);
                                _rechercher();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          _FiltresButton(
                            nombreActifs: _nombreFiltresActifs,
                            onTap: _ouvrirFiltres,
                          ),
                        ],
                      ),
                      if (_ville != null || _secteur != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: [
                            if (_ville != null)
                              _FilterChip(
                                label: _ville!,
                                onRemove: () {
                                  setState(() => _ville = null);
                                  _rechercher();
                                },
                              ),
                            if (_secteur != null)
                              _FilterChip(
                                label: _secteur!,
                                onRemove: () {
                                  setState(() => _secteur = null);
                                  _rechercher();
                                },
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (!_isLoading)
                        Text(
                          "${_page?.totalElements ?? 0} résultat"
                          "${(_page?.totalElements ?? 0) > 1 ? "s" : ""}",
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: AppLoader())
                      : _error != null
                      ? AppErrorView(
                          error: _error!,
                          fallbackMessage:
                              "Impossible de charger les résultats.",
                          onRetry: _rechercher,
                        )
                      : results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Symbols.search_off,
                                size: 42,
                                color: AppColors.textFaint,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Aucun résultat",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          itemCount: results.length,
                          itemBuilder: (ctx, i) {
                            final g = results[i];
                            return _ResultTile(
                              resume: g,
                              onTap: () => context.push(
                                "${AppRoutes.fichePublique}/${g.id}",
                              ),
                            );
                          },
                        ),
                ),
                const ClientNavBar(activeIndex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: items.contains(value) ? value : null,
        hint: Text(
          hint,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textFaint),
        ),
        underline: const SizedBox(),
        isExpanded: true,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text("Tout", style: AppTypography.bodySmall),
          ),
          ...items.map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, style: AppTypography.bodySmall),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Symbols.close,
              size: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.resume, required this.onTap});

  final GrossisteResume resume;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      resume.logoUrl != null &&
                          resume.logoUrl!.isNotEmpty &&
                          !resume.logoUrl!.startsWith("mock://")
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            resume.logoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Symbols.storefront,
                          size: 24,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              resume.nomEntreprise,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (resume.certifie) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Symbols.verified,
                              size: 14,
                              color: Color(0xFF1D9BF0),
                            ),
                          ],
                          if (resume.certifiePremium) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Symbols.workspace_premium,
                              size: 14,
                              fill: 1,
                              color: AppColors.accent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          resume.secteurActivite,
                          resume.ville,
                        ].whereType<String>().join(" · "),
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Symbols.star,
                            size: 13,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            resume.noteMoyenne?.toStringAsFixed(1) ?? "—",
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Symbols.chevron_right,
                  size: 18,
                  color: AppColors.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FiltresButton extends StatelessWidget {
  const _FiltresButton({required this.nombreActifs, required this.onTap});

  final int nombreActifs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actif = nombreActifs > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: actif ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: actif ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Symbols.tune,
                size: 20,
                color: actif ? Colors.white : AppColors.textMuted,
              ),
            ),
            if (actif)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$nombreActifs",
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FiltresResultat {
  const _FiltresResultat({
    required this.fourchettePrix,
    required this.verifies,
    required this.certifies,
    required this.tri,
  });

  final RangeValues? fourchettePrix;
  final bool verifies;
  final bool certifies;
  final String tri;
}

/// Écran 08 · Filtres avancés — fourchette de prix, "Vérifiés"/"Certifiés"
/// et tri, conforme à la maquette (bottom sheet plutôt que plein écran).
class _FiltresSheet extends StatefulWidget {
  const _FiltresSheet({
    required this.fourchetteInitiale,
    required this.verifiesInitial,
    required this.certifiesInitial,
    required this.triInitial,
  });

  final RangeValues? fourchetteInitiale;
  final bool verifiesInitial;
  final bool certifiesInitial;
  final String triInitial;

  @override
  State<_FiltresSheet> createState() => _FiltresSheetState();
}

class _FiltresSheetState extends State<_FiltresSheet> {
  static const _prixMin = 10000.0;
  static const _prixMax = 500000.0;

  late bool _filtrerParPrix = widget.fourchetteInitiale != null;
  late RangeValues _fourchette =
      widget.fourchetteInitiale ?? const RangeValues(_prixMin, _prixMax);
  late bool _verifies = widget.verifiesInitial;
  late bool _certifies = widget.certifiesInitial;
  late String _tri = widget.triInitial;

  static const _optionsTri = {
    "NOTE_DESC": "Note (décroissante)",
    "NOTE_ASC": "Note (croissante)",
    "PROXIMITE": "Proximité",
    "CERTIFICATION": "Certification",
    "NOM_ASC": "Nom (A→Z)",
    "NOM_DESC": "Nom (Z→A)",
  };

  void _reinitialiser() {
    setState(() {
      _filtrerParPrix = false;
      _fourchette = const RangeValues(_prixMin, _prixMax);
      _verifies = false;
      _certifies = false;
      _tri = "NOTE_DESC";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filtres",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _reinitialiser,
                  child: Text(
                    "Réinitialiser",
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "FOURCHETTE DE PRIX (FCFA)",
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                Switch(
                  value: _filtrerParPrix,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _filtrerParPrix = v),
                ),
              ],
            ),
            RangeSlider(
              values: _fourchette,
              min: _prixMin,
              max: _prixMax,
              divisions: 49,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.borderLight,
              labels: RangeLabels(
                _fourchette.start.toStringAsFixed(0),
                _fourchette.end.toStringAsFixed(0),
              ),
              onChanged: _filtrerParPrix
                  ? (v) => setState(() => _fourchette = v)
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fourchette.start.toStringAsFixed(0),
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _fourchette.end.toStringAsFixed(0),
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              "CONFIANCE",
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _ConfianceChip(
                    icon: Symbols.verified,
                    iconColor: const Color(0xFF1D9BF0),
                    label: "Vérifiés",
                    isSelected: _verifies,
                    onTap: () => setState(() => _verifies = !_verifies),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ConfianceChip(
                    icon: Symbols.workspace_premium,
                    iconColor: AppColors.accent,
                    label: "Certifiés",
                    isSelected: _certifies,
                    onTap: () => setState(() => _certifies = !_certifies),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              "TRIER PAR",
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _tri,
                isExpanded: true,
                underline: const SizedBox(),
                items: _optionsTri.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: AppTypography.bodySmall),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _tri = v);
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => Navigator.pop(
                    context,
                    _FiltresResultat(
                      fourchettePrix: _filtrerParPrix ? _fourchette : null,
                      verifies: _verifies,
                      certifies: _certifies,
                      tri: _tri,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Appliquer les filtres",
                      style: AppTypography.button,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfianceChip extends StatelessWidget {
  const _ConfianceChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successBg : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: iconColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
