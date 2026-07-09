/// Statut de vérification d'un document soumis, tel que défini dans
/// l'entité backend DocumentVerification (EN_ATTENTE | APPROUVE | REJETE).
enum DocumentStatut {
  enAttente,
  approuve,
  rejete;

  static DocumentStatut fromApi(String value) {
    switch (value.toUpperCase()) {
      case "APPROUVE":
        return DocumentStatut.approuve;
      case "REJETE":
        return DocumentStatut.rejete;
      default:
        return DocumentStatut.enAttente;
    }
  }
}
