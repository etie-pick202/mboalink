/// Données collectées à l'écran Inscription, transmises à l'écran
/// "Choix du type de compte" (revue de changement) qui les complètera
/// (rôle + photo si Grossiste) avant l'appel réel à /auth/inscription.
class RegistrationDraft {
  const RegistrationDraft({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    this.telephone,
  });

  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String? telephone;
}
