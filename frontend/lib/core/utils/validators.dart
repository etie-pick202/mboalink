/// Règles de validation partagées, alignées (au mieux) sur celles du
/// backend Auth. Le serveur reste toujours la source de vérité finale ;
/// ces règles ne servent qu'à donner un retour immédiat à l'utilisateur.
class Validators {
  Validators._();

  static String? required(
    String? value, {
    String message = "Ce champ est obligatoire.",
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Exige : 8 caractères min., une majuscule, une minuscule, un chiffre
  /// et un caractère spécial — comme la politique de mot de passe backend.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Le mot de passe est obligatoire.";
    }
    final hasUpper = RegExp(r"[A-Z]").hasMatch(value);
    final hasLower = RegExp(r"[a-z]").hasMatch(value);
    final hasDigit = RegExp(r"\d").hasMatch(value);
    final hasSpecial = RegExp(r'[!@#%^&*(),.?":{}|<>_\-]').hasMatch(value);
    if (value.length < 8 ||
        !hasUpper ||
        !hasLower ||
        !hasDigit ||
        !hasSpecial) {
      return "8 caractères min., avec majuscule, minuscule, chiffre et symbole.";
    }
    return null;
  }

  /// Accepte un email ou un numéro camerounais local (6XXXXXXXX).
  static String? identifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Téléphone ou email obligatoire.";
    }
    final v = value.trim();
    if (v.contains("@")) {
      final emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
      if (!emailRegex.hasMatch(v)) {
        return "Email invalide.";
      }
      return null;
    }
    final phoneRegex = RegExp(r"^6\d{8}$");
    if (!phoneRegex.hasMatch(v.replaceAll(" ", ""))) {
      return "Numéro camerounais invalide (ex: 690000000).";
    }
    return null;
  }
}
