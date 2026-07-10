enum TypeNotification {
  nouveauGrossiste,
  baissePrix,
  recuPaiement,
  favoriCertifie,
  autre;

  static TypeNotification fromApi(String value) {
    switch (value) {
      case "NOUVEAU_GROSSISTE":
        return TypeNotification.nouveauGrossiste;
      case "BAISSE_PRIX":
        return TypeNotification.baissePrix;
      case "RECU_PAIEMENT":
        return TypeNotification.recuPaiement;
      case "FAVORI_CERTIFIE":
        return TypeNotification.favoriCertifie;
      default:
        return TypeNotification.autre;
    }
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.titre,
    this.message,
    this.referenceId,
    required this.lu,
    required this.creeLe,
  });

  final String id;
  final TypeNotification type;
  final String titre;
  final String? message;
  final String? referenceId;
  final bool lu;
  final DateTime creeLe;
}
