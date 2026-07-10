import "../../domain/entities/fiche_grossiste.dart";
import "../../domain/entities/fiche_verification_statut.dart";

class FicheGrossisteModel {
  const FicheGrossisteModel({
    required this.id,
    required this.statutVerification,
    this.aAbonnementActif = false,
    this.nomEntreprise,
    this.description,
    this.secteurActivite,
    this.ville,
    this.quartier,
    this.adresseComplete,
    this.telephoneProfessionnel,
    this.emailProfessionnel,
    this.siteWeb,
    this.logoUrl,
    this.certifiePremium = false,
    this.noteMoyenne,
    this.nombreAvis = 0,
  });

  final String id;
  final String statutVerification;
  final bool aAbonnementActif;
  final String? nomEntreprise;
  final String? description;
  final String? secteurActivite;
  final String? ville;
  final String? quartier;
  final String? adresseComplete;
  final String? telephoneProfessionnel;
  final String? emailProfessionnel;
  final String? siteWeb;
  final String? logoUrl;
  final bool certifiePremium;
  final double? noteMoyenne;
  final int nombreAvis;

  factory FicheGrossisteModel.fromJson(Map<String, dynamic> json) {
    return FicheGrossisteModel(
      id: json["id"] as String,
      statutVerification:
          json["statutVerification"] as String? ??
          json["statut"] as String? ??
          "EN_ATTENTE",
      // TODO(backend): confirmer le nom du champ avec Aurelie.
      aAbonnementActif: json["aAbonnementActif"] as bool? ?? false,
      nomEntreprise: json["nomEntreprise"] as String?,
      description: json["description"] as String?,
      secteurActivite: json["secteurActivite"] as String?,
      ville: json["ville"] as String?,
      quartier: json["quartier"] as String?,
      adresseComplete: json["adresseComplete"] as String?,
      telephoneProfessionnel: json["telephoneProfessionnel"] as String?,
      emailProfessionnel: json["emailProfessionnel"] as String?,
      siteWeb: json["siteWeb"] as String?,
      logoUrl: json["logoUrl"] as String?,
      certifiePremium: json["certifiePremium"] as bool? ?? false,
      noteMoyenne: (json["noteMoyenne"] as num?)?.toDouble(),
      nombreAvis: json["nombreAvis"] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "nomEntreprise": nomEntreprise,
    "description": description,
    "secteurActivite": secteurActivite,
    "ville": ville,
    "quartier": quartier,
    "adresseComplete": adresseComplete,
    "telephoneProfessionnel": telephoneProfessionnel,
    "emailProfessionnel": emailProfessionnel,
    if (siteWeb != null) "siteWeb": siteWeb,
    if (logoUrl != null) "logoUrl": logoUrl,
  };

  FicheGrossiste toEntity() {
    return FicheGrossiste(
      id: id,
      statutVerification: FicheVerificationStatut.fromApi(statutVerification),
      aAbonnementActif: aAbonnementActif,
      nomEntreprise: nomEntreprise,
      description: description,
      secteurActivite: secteurActivite,
      ville: ville,
      quartier: quartier,
      adresseComplete: adresseComplete,
      telephoneProfessionnel: telephoneProfessionnel,
      emailProfessionnel: emailProfessionnel,
      siteWeb: siteWeb,
      logoUrl: logoUrl,
      certifiePremium: certifiePremium,
      noteMoyenne: noteMoyenne,
      nombreAvis: nombreAvis,
    );
  }
}
