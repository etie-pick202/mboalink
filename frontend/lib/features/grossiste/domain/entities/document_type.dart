/// Types de documents attendus pour la vérification d'une fiche
/// grossiste — repris tels quels de la maquette (écran 22).
/// Valeurs alignées avec DocumentVerification.typeDocument côté backend
/// (REGISTRE_COMMERCE | CNI | PHOTO_LOCAL | AUTRE).
enum DocumentType {
  rccm,
  cni,
  photoLocal;

  String get apiValue => switch (this) {
    DocumentType.rccm => "REGISTRE_COMMERCE",
    DocumentType.cni => "CNI",
    DocumentType.photoLocal => "PHOTO_LOCAL",
  };

  String get label => switch (this) {
    DocumentType.rccm => "Registre de commerce",
    DocumentType.cni => "Pièce d'identité (CNI)",
    DocumentType.photoLocal => "Photo du local / boutique",
  };

  static DocumentType fromApi(String value) {
    switch (value.toUpperCase()) {
      case "REGISTRE_COMMERCE":
      case "RCCM":
        return DocumentType.rccm;
      case "CNI":
        return DocumentType.cni;
      default:
        return DocumentType.photoLocal;
    }
  }
}
