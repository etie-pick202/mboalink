import "../../../grossiste/domain/entities/produit_grossite.dart";
import "../../domain/entities/fiche_publique.dart";

class FichePubliqueModel {
  const FichePubliqueModel({
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
  final double prixDeverrouillageActuel;
  final bool certifie;
  final bool certifiePremium;

  factory FichePubliqueModel.fromJson(Map<String, dynamic> json) {
    final produitsJson = json["produits"] as List<dynamic>? ?? const [];
    return FichePubliqueModel(
      id: json["id"] as String,
      nomEntreprise: json["nomEntreprise"] as String? ?? "",
      description: json["description"] as String?,
      secteurActivite: json["secteurActivite"] as String?,
      ville: json["ville"] as String?,
      quartier: json["quartier"] as String?,
      logoUrl: json["logoUrl"] as String?,
      noteMoyenne: (json["noteMoyenne"] as num?)?.toDouble(),
      nombreAvis: json["nombreAvis"] as int?,
      anneeCreation: json["anneeCreation"] as int?,
      // Plancher 5000 F si absent (fiche jamais recalculée) — cohérent
      // avec le défaut backend.
      prixDeverrouillageActuel:
          (json["prixDeverrouillageActuel"] as num?)?.toDouble() ?? 5000.0,
      certifie: json["statutVerification"] == "VERIFIE",
      certifiePremium: json["certifiePremium"] as bool? ?? false,
      produits: produitsJson
          .cast<Map<String, dynamic>>()
          .map(
            (p) => ProduitGrossiste(
              id: p["id"] as String,
              ficheGrossisteId: json["id"] as String,
              nom: p["nom"] as String? ?? "",
              description: p["description"] as String?,
              categorie: p["categorie"] as String?,
              prixUnitaire: (p["prixUnitaire"] as num?)?.toDouble(),
              quantiteMinimale: (p["quantiteMinimale"] as num?)?.toDouble(),
              uniteMesure: p["uniteMesure"] as String?,
              imageUrl: p["imageUrl"] as String?,
              estDisponible: p["estDisponible"] as bool? ?? true,
            ),
          )
          .toList(),
    );
  }

  FichePublique toEntity() {
    return FichePublique(
      id: id,
      nomEntreprise: nomEntreprise,
      description: description,
      secteurActivite: secteurActivite,
      ville: ville,
      quartier: quartier,
      logoUrl: logoUrl,
      noteMoyenne: noteMoyenne,
      nombreAvis: nombreAvis,
      anneeCreation: anneeCreation,
      produits: produits,
      prixDeverrouillageActuel: prixDeverrouillageActuel,
      certifie: certifie,
      certifiePremium: certifiePremium,
    );
  }
}
