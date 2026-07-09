/// Produit vendu par un grossiste — reflet du modèle backend
/// ProduitGrossiste (géré dans l'onglet "Boutique" du tableau de bord
/// Grossiste après validation de la fiche).
class ProduitGrossiste {
  const ProduitGrossiste({
    required this.id,
    required this.ficheGrossisteId,
    required this.nom,
    this.description,
    this.categorie,
    this.prixUnitaire,
    this.quantiteMinimale,
    this.uniteMesure,
    this.imageUrl,
    required this.estDisponible,
  });

  final String id;
  final String ficheGrossisteId;
  final String nom;
  final String? description;
  final String? categorie;
  final double? prixUnitaire;
  final double? quantiteMinimale;
  final String? uniteMesure;
  final String? imageUrl;
  final bool estDisponible;
}
