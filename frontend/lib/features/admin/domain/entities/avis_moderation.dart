/// Avis à modérer (note < 3) — reflet de NotationResponseDTO tel
/// qu'exposé par GET /admin/avis-signales.
class AvisModeration {
  const AvisModeration({
    required this.id,
    required this.ficheGrossisteId,
    required this.ficheGrossisteName,
    required this.utilisateurNom,
    required this.note,
    this.commentaire,
    required this.transactionVerifiee,
    required this.creeLe,
  });

  final String id;
  final String ficheGrossisteId;
  final String ficheGrossisteName;
  final String utilisateurNom;
  final int note;
  final String? commentaire;
  final bool transactionVerifiee;
  final DateTime creeLe;
}
