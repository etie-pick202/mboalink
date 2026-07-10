import "../../../grossiste/domain/entities/produit_grossite.dart";

/// Détail public d'une fiche grossiste — reflet de FicheResponse.
/// Ne contient JAMAIS le téléphone/email professionnel : ces champs sont
/// payants et n'arrivent que via [CoordonneesDeverrouillees] après
/// déverrouillage.
class FichePublique {
  const FichePublique({
    required this.id,
    required this.nomEntreprise,
    this.description,
    this.secteurActivite,
    this.ville,
    this.quartier,
    this.logoUrl,
    this.noteMoyenne,
    this.nombreAvis,
    this.anneeCreation,
    this.produits = const [],
    required this.prixDeverrouillageActuel,
    this.certifie = false,
    this.certifiePremium = false,
  });

  final String id;
  final String nomEntreprise;
  final String? description;
  final String? secteurActivite;
  final String? ville;
  final String? quartier;
  final String? logoUrl;
  final double? noteMoyenne;
  final int? nombreAvis;
  final int? anneeCreation;
  final List<ProduitGrossiste> produits;
  final bool certifie;
  final bool certifiePremium;

  /// Prix du déverrouillage des coordonnées — varie avec la popularité
  /// de la fiche (plancher 5000 FCFA).
  final double prixDeverrouillageActuel;
}

/// Coordonnées d'un grossiste, visibles uniquement après déverrouillage
/// (paiement). Reflet de CoordonneesResponse.
class CoordonneesDeverrouillees {
  const CoordonneesDeverrouillees({
    required this.nomEntreprise,
    this.telephoneProfessionnel,
    this.emailProfessionnel,
  });

  final String nomEntreprise;
  final String? telephoneProfessionnel;
  final String? emailProfessionnel;
}
