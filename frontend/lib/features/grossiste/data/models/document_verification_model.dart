import "../../domain/entities/document_statut.dart";
import "../../domain/entities/document_type.dart";
import "../../domain/entities/document_verification.dart";

class DocumentVerificationModel {
  const DocumentVerificationModel({
    required this.id,
    required this.typeDocument,
    required this.urlDocument,
    required this.statut,
    this.commentaireAdmin,
  });

  final String id;
  final String typeDocument;
  final String urlDocument;
  final String statut;
  final String? commentaireAdmin;

  factory DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationModel(
      id: json["id"] as String,
      typeDocument: json["typeDocument"] as String,
      urlDocument: json["urlDocument"] as String,
      // TODO(backend): "statut" absent de l'exemple de réponse Postman de
      // GET /grossistes/{ficheId}/documents (seulement dans l'entité) —
      // EN_ATTENTE par défaut en attendant confirmation.
      statut: json["statut"] as String? ?? "EN_ATTENTE",
      commentaireAdmin: json["commentaireAdmin"] as String?,
    );
  }

  DocumentVerification toEntity() {
    return DocumentVerification(
      id: id,
      type: DocumentType.fromApi(typeDocument),
      urlDocument: urlDocument,
      statut: DocumentStatut.fromApi(statut),
      commentaireAdmin: commentaireAdmin,
    );
  }
}
