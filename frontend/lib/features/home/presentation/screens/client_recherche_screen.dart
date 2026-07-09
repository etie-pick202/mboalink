import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../widgets/client_nav_bar.dart";

/// Écran 07 · Recherche — conforme à la maquette : barre de recherche,
/// filtres ville / secteur, résultats paginés (statiques en Workflow A,
/// vrais endpoints en Workflow B).
class ClientRechercheScreen extends StatefulWidget {
  const ClientRechercheScreen({super.key});

  @override
  State<ClientRechercheScreen> createState() => _ClientRechercheScreenState();
}

class _ClientRechercheScreenState extends State<ClientRechercheScreen> {
  final _ctrl = TextEditingController();
  String _query = "";
  String? _ville;
  String? _secteur;

  static const _villes = [
    "Douala",
    "Yaoundé",
    "Bafoussam",
    "Garoua",
    "Bamenda",
  ];
  static const _secteurs = [
    "Alimentation",
    "Textile",
    "Cosmétique",
    "Matériaux",
    "Électronique",
    "Pharmacie",
  ];

  static const _all = [
    (
      nom: "Ets Tchana & Fils",
      secteur: "Alimentation",
      ville: "Douala",
      note: "4.8",
      verifie: true,
    ),
    (
      nom: "Sané Cosmetics",
      secteur: "Cosmétique",
      ville: "Douala",
      note: "4.6",
      verifie: false,
    ),
    (
      nom: "Kana Distribution",
      secteur: "Cosmétique",
      ville: "Yaoundé",
      note: "4.9",
      verifie: true,
    ),
    (
      nom: "Mballa Textiles",
      secteur: "Textile",
      ville: "Douala",
      note: "4.3",
      verifie: false,
    ),
    (
      nom: "SPS Matériaux",
      secteur: "Matériaux",
      ville: "Bafoussam",
      note: "4.1",
      verifie: false,
    ),
    (
      nom: "PharmaDist Cameroun",
      secteur: "Pharmacie",
      ville: "Yaoundé",
      note: "4.7",
      verifie: true,
    ),
  ];

  List<({String nom, String secteur, String ville, String note, bool verifie})>
  get _results => _all.where((g) {
    final matchQ =
        _query.isEmpty ||
        g.nom.toLowerCase().contains(_query.toLowerCase()) ||
        g.secteur.toLowerCase().contains(_query.toLowerCase());
    final matchV = _ville == null || g.ville == _ville;
    final matchS = _secteur == null || g.secteur == _secteur;
    return matchQ && matchV && matchS;
  }).toList();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature — bientôt disponible.")));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final results = _results;

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
                        onChanged: (v) => setState(() => _query = v),
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
                                    setState(() => _query = "");
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
                              items: _villes,
                              onChanged: (v) => setState(() => _ville = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Dropdown(
                              hint: "Secteur",
                              value: _secteur,
                              items: _secteurs,
                              onChanged: (v) => setState(() => _secteur = v),
                            ),
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
                                onRemove: () => setState(() => _ville = null),
                              ),
                            if (_secteur != null)
                              _FilterChip(
                                label: _secteur!,
                                onRemove: () => setState(() => _secteur = null),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        "${results.length} résultat${results.length > 1 ? "s" : ""}",
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                Expanded(
                  child: results.isEmpty
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
                              nom: g.nom,
                              secteur: g.secteur,
                              ville: g.ville,
                              note: g.note,
                              verifie: g.verifie,
                              onTap: () =>
                                  _comingSoon(context, "Fiche grossiste"),
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
        value: value,
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
  const _ResultTile({
    required this.nom,
    required this.secteur,
    required this.ville,
    required this.note,
    required this.verifie,
    required this.onTap,
  });

  final String nom;
  final String secteur;
  final String ville;
  final String note;
  final bool verifie;
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
                  child: const Icon(
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
                              nom,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (verifie) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Symbols.verified,
                              size: 14,
                              color: Color(0xFF1D9BF0),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text("$secteur · $ville", style: AppTypography.caption),
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
                            note,
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
