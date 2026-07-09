import "fiche_grossiste.dart";
import "fiche_verification_statut.dart";

/// État global affiché sur le tableau de bord — calculé côté app,
/// jamais stocké tel quel côté backend.
///
/// Flux complet :
///   nonSoumise → enAttente → rejetee → enAttente (correction)
///                         → enAttenteAbonnement → validee
///                         → suspendue
enum GrossisteDashboardStatus {
  nonSoumise,
  enAttente,
  rejetee,
  enAttenteAbonnement,
  suspendue,
  validee,
}

extension GrossisteDashboardStatusX on FicheGrossiste {
  GrossisteDashboardStatus get dashboardStatus {
    if (estVide) return GrossisteDashboardStatus.nonSoumise;
    switch (statutVerification) {
      case FicheVerificationStatut.verifie:
        // Documents validés par l'admin — si pas encore d'abonnement
        // actif, le grossiste doit payer avant d'accéder au dashboard
        // complet.
        return aAbonnementActif
            ? GrossisteDashboardStatus.validee
            : GrossisteDashboardStatus.enAttenteAbonnement;
      case FicheVerificationStatut.rejete:
        return GrossisteDashboardStatus.rejetee;
      case FicheVerificationStatut.suspendu:
        return GrossisteDashboardStatus.suspendue;
      case FicheVerificationStatut.enAttente:
        return GrossisteDashboardStatus.enAttente;
    }
  }
}
