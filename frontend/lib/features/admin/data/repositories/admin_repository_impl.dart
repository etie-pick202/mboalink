import "../../../grossiste/data/models/document_verification_model.dart";
import "../../domain/entities/avis_moderation.dart";
import "../../domain/entities/dashboard_resume.dart";
import "../../domain/entities/revenu_mensuel.dart";
import "../../domain/entities/validation_fiche.dart";
import "../../domain/repositories/admin_repository.dart";
import "../datasources/admin_remote_datasource.dart";

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._datasource);

  final AdminRemoteDatasource _datasource;

  @override
  Future<DashboardResume> dashboardResume() async {
    final json = await _datasource.dashboardResume();
    return DashboardResume(
      totalUtilisateurs: json["totalUtilisateurs"] as int? ?? 0,
      totalGrossistes: json["totalGrossistes"] as int? ?? 0,
      totalUtilisateursClients: json["totalUtilisateursClients"] as int? ?? 0,
      validationsEnAttente: json["validationsEnAttente"] as int? ?? 0,
      avisSignales: json["avisSignales"] as int? ?? 0,
      deverrouillagesCoordonnees:
          json["deverrouillagesCoordonnees"] as int? ?? 0,
      demandesReinitialisationNote:
          json["demandesReinitialisationNote"] as int? ?? 0,
    );
  }

  @override
  Future<List<ValidationFiche>> validationsEnAttente() async {
    final list = await _datasource.validationsEnAttente();
    return list.map((json) {
      final docs = (json["documents"] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map((d) => DocumentVerificationModel.fromJson(d).toEntity())
          .toList();
      return ValidationFiche(
        id: json["id"] as String,
        nomEntreprise: json["nomEntreprise"] as String? ?? "",
        secteurActivite: json["secteurActivite"] as String?,
        ville: json["ville"] as String?,
        quartier: json["quartier"] as String?,
        statutVerification: json["statutVerification"] as String? ?? "",
        creeLe: DateTime.parse(json["creeLe"] as String),
        documents: docs,
      );
    }).toList();
  }

  @override
  Future<void> approuverDocument(String documentId, {String? commentaire}) =>
      _datasource.approuverDocument(documentId, commentaire: commentaire);

  @override
  Future<void> rejeterDocument(String documentId, {String? commentaire}) =>
      _datasource.rejeterDocument(documentId, commentaire: commentaire);

  @override
  Future<void> validerFiche(String ficheId) =>
      _datasource.validerFiche(ficheId);

  @override
  Future<void> rejeterFiche(String ficheId) =>
      _datasource.rejeterFiche(ficheId);

  @override
  Future<List<AvisModeration>> avisAModerer() async {
    final list = await _datasource.avisAModerer();
    return list
        .map(
          (json) => AvisModeration(
            id: json["id"] as String,
            ficheGrossisteId: json["ficheGrossisteId"] as String,
            ficheGrossisteName: json["ficheGrossisteName"] as String? ?? "",
            utilisateurNom: json["utilisateurNom"] as String? ?? "",
            note: json["note"] as int? ?? 0,
            commentaire: json["commentaire"] as String?,
            transactionVerifiee: json["transactionVerifiee"] as bool? ?? false,
            creeLe: DateTime.parse(json["creeLe"] as String),
          ),
        )
        .toList();
  }

  @override
  Future<void> conserverAvis(String notationId) =>
      _datasource.conserverAvis(notationId);

  @override
  Future<void> supprimerAvis(String notationId) =>
      _datasource.supprimerAvis(notationId);

  @override
  Future<List<RevenuMensuel>> revenusDerniers4Mois() async {
    final list = await _datasource.revenusDerniers4Mois();
    return list
        .map(
          (json) => RevenuMensuel(
            mois: json["mois"] as String? ?? "",
            numeroMois: json["numeroMois"] as int? ?? 0,
            total: (json["total"] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }
}
