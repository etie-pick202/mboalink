/// Statut de vérification de la fiche, tel que défini côté backend
/// (FicheGrossiste.statutVerification).
enum FicheVerificationStatut {
  enAttente,
  verifie,
  rejete,
  suspendu;

  static FicheVerificationStatut fromApi(String value) {
    switch (value.toUpperCase()) {
      case "VERIFIE":
        return FicheVerificationStatut.verifie;
      case "REJETE":
        return FicheVerificationStatut.rejete;
      case "SUSPENDU":
        return FicheVerificationStatut.suspendu;
      default:
        return FicheVerificationStatut.enAttente;
    }
  }
}
