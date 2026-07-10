import "../../../grossiste/domain/entities/document_verification.dart";

/// Fiche grossiste en attente de validation admin — reflet de
/// ValidationFicheDTO (GET /admin/validations).
class ValidationFiche {
  const ValidationFiche({
    required this.id,
    required this.nomEntreprise,
    this.secteurActivite,
    this.ville,
    this.quartier,
    required this.statutVerification,
    required this.creeLe,
    this.documents = const [],
  });

  final String id;
  final String nomEntreprise;
  final String? secteurActivite;
  final String? ville;
  final String? quartier;
  final String statutVerification;
  final DateTime creeLe;
  final List<DocumentVerification> documents;
}
