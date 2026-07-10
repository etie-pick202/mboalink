class Avis {
  const Avis({
    required this.id,
    required this.utilisateurNom,
    required this.note,
    this.commentaire,
    required this.transactionVerifiee,
    required this.creeLe,
  });

  final String id;
  final String utilisateurNom;
  final int note;
  final String? commentaire;
  final bool transactionVerifiee;
  final DateTime creeLe;
}

class AvisBreakdown {
  const AvisBreakdown({
    required this.moyenne,
    required this.total,
    required this.cinq,
    required this.quatre,
    required this.trois,
    required this.deux,
    required this.un,
  });

  final double moyenne;
  final int total;
  final int cinq;
  final int quatre;
  final int trois;
  final int deux;
  final int un;

  int get max =>
      [cinq, quatre, trois, deux, un].reduce((a, b) => a > b ? a : b);
}
