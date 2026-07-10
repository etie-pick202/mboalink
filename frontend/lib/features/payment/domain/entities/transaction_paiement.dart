enum TypeTransaction {
  deverrouillageCoordonnees,
  abonnement,
  reinitialisationNote,
  certificationPremium;

  String get apiValue => switch (this) {
    TypeTransaction.deverrouillageCoordonnees => "DEVERROUILLAGE_COORDONNEES",
    TypeTransaction.abonnement => "ABONNEMENT",
    TypeTransaction.reinitialisationNote => "REINITIALISATION_NOTE",
    TypeTransaction.certificationPremium => "CERTIFICATION_PREMIUM",
  };
}

enum OperateurMobileMoney {
  mtnMomo,
  orangeMoney;

  String get apiValue => switch (this) {
    OperateurMobileMoney.mtnMomo => "MTN_MOMO",
    OperateurMobileMoney.orangeMoney => "ORANGE_MONEY",
  };

  String get label => switch (this) {
    OperateurMobileMoney.mtnMomo => "MTN Mobile Money",
    OperateurMobileMoney.orangeMoney => "Orange Money",
  };
}

enum StatutTransaction {
  enAttente,
  succes,
  echec,
  rembourse;

  static StatutTransaction fromApi(String value) {
    switch (value.toUpperCase()) {
      case "SUCCES":
        return StatutTransaction.succes;
      case "ECHEC":
        return StatutTransaction.echec;
      case "REMBOURSE":
        return StatutTransaction.rembourse;
      default:
        return StatutTransaction.enAttente;
    }
  }
}

/// Transaction de paiement Mobile Money (Campay) — reflet de
/// TransactionResponseDTO. Sert à la fois au déverrouillage de
/// coordonnées (client) et à l'abonnement (grossiste).
class TransactionPaiement {
  const TransactionPaiement({
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
  final StatutTransaction statut;
  final String? messageStatut;

  /// Renseignés uniquement à l'initiation (réponse de POST /transactions).
  final String? instruction;
  final String? ussdCode;
}
