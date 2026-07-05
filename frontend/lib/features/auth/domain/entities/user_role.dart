/// Les 3 rôles avec compte (VISITEUR n'a pas de compte, donc pas de
/// valeur ici — l'absence de session suffit à le représenter).
enum UserRole {
  utilisateur,
  grossiste,
  admin;

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

  String get toApi => switch (this) {
    UserRole.utilisateur => "UTILISATEUR",
    UserRole.grossiste => "GROSSISTE",
    UserRole.admin => "ADMIN",
  };
}
