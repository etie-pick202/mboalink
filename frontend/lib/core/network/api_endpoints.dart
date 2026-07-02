/// Chemins des endpoints backend, relatifs à AppConfig.apiBaseUrl.
class ApiEndpoints {
  ApiEndpoints._();

  static const inscription = "/auth/inscription";
  static const verifierOtp = "/auth/verifier-otp";
  static const connexion = "/auth/connexion";
  static const refresh = "/auth/refresh";
  static const logout = "/auth/logout";
  static const motDePasseOublie = "/auth/mot-de-passe-oublie";
  static const reinitialiserMotDePasse = "/auth/reinitialiser-mot-de-passe";
  static const renvoyerOtp = "/auth/renvoyer-otp";
  static const compte = "/auth/compte";
}
