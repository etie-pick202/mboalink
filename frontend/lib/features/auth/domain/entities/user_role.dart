/// Rôles utilisateur MboaLink — aligné avec les valeurs backend.
///
/// 3 rôles existants :
///   UTILISATEUR — client standard, peut s'inscrire librement
///   GROSSISTE   — professionnel abonné, peut s'inscrire librement
///   ADMIN       — équipe MboaLink, NE peut PAS s'inscrire via l'app ;
///                 un admin existant peut promouvoir un utilisateur
///                 au rang d'admin depuis le back-office.
enum UserRole {
  utilisateur,
  grossiste,
  admin;

  String get toApi => switch (this) {
    UserRole.utilisateur => "UTILISATEUR",
    UserRole.grossiste => "GROSSISTE",
    UserRole.admin => "ADMIN",
  };

  static UserRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case "GROSSISTE":
        return UserRole.grossiste;
      case "ADMIN":
        return UserRole.admin;
      default:
        return UserRole.utilisateur;
    }
  }

  /// Indique si ce rôle donne accès à l'espace Admin (back-office).
  bool get isAdmin => this == UserRole.admin;

  /// Indique si ce rôle peut être choisi lors de l'inscription dans l'app.
  bool get isInscriptible =>
      this == UserRole.utilisateur || this == UserRole.grossiste;
}
