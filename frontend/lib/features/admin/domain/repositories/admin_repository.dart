import "../entities/avis_moderation.dart";
import "../entities/dashboard_resume.dart";
import "../entities/revenu_mensuel.dart";
import "../entities/validation_fiche.dart";

abstract class AdminRepository {
  Future<DashboardResume> dashboardResume();

  Future<List<ValidationFiche>> validationsEnAttente();

  Future<void> approuverDocument(String documentId, {String? commentaire});

  Future<void> rejeterDocument(String documentId, {String? commentaire});

  Future<void> validerFiche(String ficheId);

  Future<void> rejeterFiche(String ficheId);

  /// Avis à modérer (note < 3) — GET /admin/avis-signales.
  Future<List<AvisModeration>> avisAModerer();

  Future<void> conserverAvis(String notationId);

  Future<void> supprimerAvis(String notationId);

  Future<List<RevenuMensuel>> revenusDerniers4Mois();
}
