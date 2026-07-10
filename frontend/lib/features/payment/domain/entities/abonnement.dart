enum StatutAbonnement {
  actif,
  expire,
  suspendu,
  annule;

  static StatutAbonnement fromApi(String value) {
    switch (value.toUpperCase()) {
      case "ACTIF":
        return StatutAbonnement.actif;
      case "SUSPENDU":
        return StatutAbonnement.suspendu;
      case "ANNULE":
        return StatutAbonnement.annule;
      default:
        return StatutAbonnement.expire;
    }
  }
}

/// Abonnement de visibilité du grossiste — reflet de AbonnementResponseDTO.
class Abonnement {
  const Abonnement({
    required this.id,
    required this.typeAbonnement,
    required this.montant,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.renouvellementAuto,
    this.joursRestants,
  });

  final String id;
  final String typeAbonnement;
  final double montant;
  final DateTime dateDebut;
  final DateTime dateFin;
  final StatutAbonnement statut;
  final bool renouvellementAuto;
  final int? joursRestants;
}
