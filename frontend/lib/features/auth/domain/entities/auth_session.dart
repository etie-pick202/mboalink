import "user_role.dart";

/// Session authentifiée — construite après vérification OTP ou connexion.
///
/// Les champs `userId`, `nom`, `prenom`, `email`, `telephone` sont
/// optionnels car l'endpoint /auth/connexion et /auth/verifier-otp
/// ne les retournent pas directement. Ils peuvent être enrichis via
/// GET /profil si besoin (écran Profil).
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.emailVerifie,
    this.telephoneVerifie = false,
    this.userId,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
  });

  final String accessToken;
  final String refreshToken;
  final UserRole role;
  final bool emailVerifie;
  final bool telephoneVerifie;

  // Champs optionnels — absents des réponses connexion/OTP, disponibles
  // via GET /profil.
  final String? userId;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
}
