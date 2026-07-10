import "../../domain/entities/recu.dart";

class RecuModel {
  const RecuModel({
    required this.id,
    required this.numeroRecu,
    required this.montantTotal,
    required this.typeTransaction,
    required this.operateur,
    required this.creeLe,
  });

  final String id;
  final String numeroRecu;
  final double montantTotal;
  final String typeTransaction;
  final String? operateur;
  final DateTime creeLe;

  factory RecuModel.fromJson(Map<String, dynamic> json) {
    return RecuModel(
      id: json["id"] as String,
      numeroRecu: json["numeroRecu"] as String,
      montantTotal: (json["montantTotal"] as num).toDouble(),
      typeTransaction: json["typeTransaction"] as String? ?? "",
      operateur: json["operateur"] as String?,
      creeLe: DateTime.parse(json["creeLe"] as String),
    );
  }

  Recu toEntity() {
    return Recu(
      id: id,
      numeroRecu: numeroRecu,
      montantTotal: montantTotal,
      typeTransaction: typeTransaction,
      operateur: operateur,
      creeLe: creeLe,
    );
  }
}
