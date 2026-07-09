import "../../domain/entities/produit_grossite.dart";

class ProduitGrossisteModel {
  const ProduitGrossisteModel({
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

  factory ProduitGrossisteModel.fromJson(Map<String, dynamic> json) {
    return ProduitGrossisteModel(
      id: json["id"] as String,
      ficheGrossisteId: json["ficheGrossisteId"] as String,
      nom: json["nom"] as String,
      description: json["description"] as String?,
      categorie: json["categorie"] as String?,
      prixUnitaire: (json["prixUnitaire"] as num?)?.toDouble(),
      quantiteMinimale: (json["quantiteMinimale"] as num?)?.toDouble(),
      uniteMesure: json["uniteMesure"] as String?,
      imageUrl: json["imageUrl"] as String?,
      estDisponible: json["estDisponible"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      if (description != null) "description": description,
      if (categorie != null) "categorie": categorie,
      if (prixUnitaire != null) "prixUnitaire": prixUnitaire,
      if (quantiteMinimale != null) "quantiteMinimale": quantiteMinimale,
      if (uniteMesure != null) "uniteMesure": uniteMesure,
      if (imageUrl != null) "imageUrl": imageUrl,
      "estDisponible": estDisponible,
    };
  }

  ProduitGrossiste toEntity() {
    return ProduitGrossiste(
      id: id,
      ficheGrossisteId: ficheGrossisteId,
      nom: nom,
      description: description,
      categorie: categorie,
      prixUnitaire: prixUnitaire,
      quantiteMinimale: quantiteMinimale,
      uniteMesure: uniteMesure,
      imageUrl: imageUrl,
      estDisponible: estDisponible,
    );
  }
}
