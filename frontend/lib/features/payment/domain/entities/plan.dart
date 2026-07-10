/// Plan d'abonnement disponible — catalogue backend (GET /plans?role=X),
/// remplace les prix qui étaient codés en dur côté app.
class Plan {
  const Plan({
    required this.id,
    required this.nom,
    required this.prix,
    required this.periodicite,
    this.avantages = const [],
  });

  final String id;
  final String nom;
  final double prix;

  /// MENSUEL | TRIMESTRIEL | ANNUEL
  final String periodicite;
  final List<String> avantages;
}
