import "../../domain/entities/grossiste_resume.dart";

class GrossisteResumeModel {
  const GrossisteResumeModel({
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
  final String? raisonRecommandation;

  factory GrossisteResumeModel.fromJson(Map<String, dynamic> json) {
    return GrossisteResumeModel(
      id: json["id"] as String,
      nomEntreprise: json["nomEntreprise"] as String? ?? "",
      secteurActivite: json["secteurActivite"] as String?,
      ville: json["ville"] as String?,
      quartier: json["quartier"] as String?,
      logoUrl: json["logoUrl"] as String?,
      noteMoyenne: (json["noteMoyenne"] as num?)?.toDouble(),
      nombreAvis: json["nombreAvis"] as int?,
      // Deux formes possibles selon la source : les DTO de recherche
      // exposent `certifie` directement ; la liste des favoris renvoie
      // une FicheResponse (champ `statutVerification`). On gère les deux.
      certifie:
          json["certifie"] as bool? ??
          (json["statutVerification"] == "VERIFIE"),
      certifiePremium: json["certifiePremium"] as bool? ?? false,
      distanceKm: (json["distanceKm"] as num?)?.toDouble(),
      raisonRecommandation: json["raisonRecommandation"] as String?,
    );
  }

  GrossisteResume toEntity() {
    return GrossisteResume(
      id: id,
      nomEntreprise: nomEntreprise,
      secteurActivite: secteurActivite,
      ville: ville,
      quartier: quartier,
      logoUrl: logoUrl,
      noteMoyenne: noteMoyenne,
      nombreAvis: nombreAvis,
      certifie: certifie,
      certifiePremium: certifiePremium,
      distanceKm: distanceKm,
      raisonRecommandation: raisonRecommandation,
    );
  }
}
