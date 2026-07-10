/// Reçu de paiement — reflet de RecuResponseDTO.
class Recu {
  const Recu({
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
}
