import "user_role.dart";

/// Session utilisateur authentifiée : tokens + informations de profil,
/// telles que retournées par connexion / vérification OTP / refresh.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    required this.emailVerifie,
    required this.telephoneVerifie,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final UserRole role;
  final bool emailVerifie;
  final bool telephoneVerifie;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
}
