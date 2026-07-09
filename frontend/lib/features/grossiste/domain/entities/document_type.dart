/// Types de documents attendus pour la vérification d'une fiche
/// grossiste — repris tels quels de la maquette (écran 22).
/// TODO(backend): aligner ces valeurs avec celles réellement acceptées
/// par l'API une fois la route de création/documents stabilisée côté
/// backend (divergence actuelle entre le commentaire de l'entité
/// DocumentVerification et les exemples testés dans Postman).
enum DocumentType {
  rccm,
  cni,
  photoLocal;

  String get apiValue => switch (this) {
    DocumentType.rccm => "RCCM",
    DocumentType.cni => "CNI",
    DocumentType.photoLocal => "photolocal",
  };

  String get label => switch (this) {
    DocumentType.rccm => "Registre de commerce",
    DocumentType.cni => "Pièce d'identité (CNI)",
    DocumentType.photoLocal => "Photo du local / boutique",
  };

  static DocumentType fromApi(String value) {
    switch (value.toUpperCase()) {
      case "RCCM":
        return DocumentType.rccm;
      case "CNI":
        return DocumentType.cni;
      default:
        return DocumentType.photoLocal;
    }
  }
}
