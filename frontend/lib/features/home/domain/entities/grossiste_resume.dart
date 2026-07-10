/// Résumé d'un grossiste tel qu'affiché dans une liste (recherche ou fil
/// d'actualité) — reflet de GrossisteSearchResultDto / FilActualiteItemDto.
class GrossisteResume {
  const GrossisteResume({
    required this.id,
    required this.nomEntreprise,
    this.secteurActivite,
    this.ville,
    this.quartier,
    this.logoUrl,
    this.noteMoyenne,
    this.nombreAvis,
    this.certifie = false,
    this.certifiePremium = false,
    this.distanceKm,
    this.raisonRecommandation,
  });

  final String id;
  final String nomEntreprise;
  final String? secteurActivite;
  final String? ville;
  final String? quartier;
  final String? logoUrl;
  final double? noteMoyenne;
  final int? nombreAvis;
  final bool certifie;
  final bool certifiePremium;
  final double? distanceKm;

  /// Renseigné uniquement pour les éléments du fil d'actualité.
  final String? raisonRecommandation;
}
