import "fiche_verification_statut.dart";

/// Fiche professionnelle du grossiste.
/// [aAbonnementActif] : null = inconnu (vieux backend), false = pas d'abonnement,
/// true = abonnement actif.
/// TODO(backend): confirmer avec Aurelie que ce champ est bien renvoyé
/// par GET /grossistes/me — peut aussi venir d'un endpoint séparé.
class FicheGrossiste {
  const FicheGrossiste({
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
  });

  final String id;
  final FicheVerificationStatut statutVerification;

  /// Indique si le grossiste a un abonnement actif et payé. Distingue
  /// l'état "documents validés sans abonnement" (enAttenteAbonnement) de
  /// l'état "validé complet" (validee).
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

  /// Fiche vide = champs obligatoires du volet 1 non renseignés.
  bool get estVide =>
      (nomEntreprise == null || nomEntreprise!.trim().isEmpty) &&
      (secteurActivite == null || secteurActivite!.trim().isEmpty) &&
      (ville == null || ville!.trim().isEmpty);
}
