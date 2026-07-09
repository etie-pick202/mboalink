/// Type de compte choisi à l'inscription (revue de changement — écran
/// ajouté, absent de la maquette d'origine). Mappé sur le rôle backend.
enum AccountType {
  client,
  grossiste;

  String get apiRole => switch (this) {
    AccountType.client => "UTILISATEUR",
    AccountType.grossiste => "GROSSISTE",
  };
}
