import "document_statut.dart";
import "document_type.dart";

/// Document de vérification rattaché à une fiche grossiste (RCCM, CNI,
/// photo du local). Le commentaire admin n'est renseigné que si le
/// document a été rejeté.
class DocumentVerification {
  const DocumentVerification({
    required this.id,
    required this.type,
    required this.urlDocument,
    required this.statut,
    this.commentaireAdmin,
  });

  final String id;
  final DocumentType type;
  final String urlDocument;
  final DocumentStatut statut;
  final String? commentaireAdmin;
}
