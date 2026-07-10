import "../../domain/entities/transaction_paiement.dart";

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.typeTransaction,
    required this.montant,
    required this.operateur,
    required this.statut,
    this.messageStatut,
    this.instruction,
    this.ussdCode,
  });

  final String id;
  final String typeTransaction;
  final double montant;
  final String operateur;
  final String statut;
  final String? messageStatut;
  final String? instruction;
  final String? ussdCode;

  /// Construit depuis la réponse de POST /transactions : {..., "transaction": {...}}.
  factory TransactionModel.fromCreationJson(Map<String, dynamic> json) {
    final transaction = json["transaction"] as Map<String, dynamic>;
    return TransactionModel(
      id: transaction["id"] as String,
      typeTransaction: transaction["typeTransaction"] as String,
      montant: (transaction["montant"] as num).toDouble(),
      operateur: transaction["operateur"] as String? ?? "",
      statut: transaction["statut"] as String? ?? "EN_ATTENTE",
      messageStatut: transaction["messageStatut"] as String?,
      instruction: json["instruction"] as String?,
      ussdCode: json["ussdCode"] as String?,
    );
  }

  TransactionPaiement toEntity() {
    return TransactionPaiement(
      id: id,
      typeTransaction: typeTransaction,
      montant: montant,
      operateur: operateur,
      statut: StatutTransaction.fromApi(statut),
      messageStatut: messageStatut,
      instruction: instruction,
      ussdCode: ussdCode,
    );
  }
}
