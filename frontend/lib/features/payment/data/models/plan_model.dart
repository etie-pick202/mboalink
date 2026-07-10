import "../../domain/entities/plan.dart";

class PlanModel {
  const PlanModel({
    required this.id,
    required this.nom,
    required this.prix,
    required this.periodicite,
    this.avantages = const [],
  });

  final String id;
  final String nom;
  final double prix;
  final String periodicite;
  final List<String> avantages;

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json["id"] as String,
      nom: json["nom"] as String,
      prix: (json["prix"] as num).toDouble(),
      periodicite: json["periodicite"] as String,
      avantages: (json["avantages"] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  Plan toEntity() {
    return Plan(
      id: id,
      nom: nom,
      prix: prix,
      periodicite: periodicite,
      avantages: avantages,
    );
  }
}
