import "../../domain/entities/abonnement.dart";

class AbonnementModel {
  const AbonnementModel({
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
  final String statut;
  final bool renouvellementAuto;
  final int? joursRestants;

  factory AbonnementModel.fromJson(Map<String, dynamic> json) {
    return AbonnementModel(
      id: json["id"] as String,
      typeAbonnement: json["typeAbonnement"] as String,
      montant: (json["montant"] as num).toDouble(),
      dateDebut: DateTime.parse(json["dateDebut"] as String),
      dateFin: DateTime.parse(json["dateFin"] as String),
      statut: json["statut"] as String,
      renouvellementAuto: json["renouvellementAuto"] as bool? ?? false,
      joursRestants: json["joursRestants"] as int?,
    );
  }

  Abonnement toEntity() {
    return Abonnement(
      id: id,
      typeAbonnement: typeAbonnement,
      montant: montant,
      dateDebut: dateDebut,
      dateFin: dateFin,
      statut: StatutAbonnement.fromApi(statut),
      renouvellementAuto: renouvellementAuto,
      joursRestants: joursRestants,
    );
  }
}
