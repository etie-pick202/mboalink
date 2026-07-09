import "../entities/auth_session.dart";
import "../entities/registration_result.dart";

abstract class AuthRepository {
  /// POST /auth/inscription
  /// Crée le compte. Renvoie utilisateurId + emailVerifie (pas de tokens).
  /// telephone ignoré — non supporté par le backend v1.
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
  });

  /// POST /auth/verifier-otp
  /// Vérifie le code OTP. Renvoie accessToken + refreshToken.
  /// [role] : passé explicitement car la réponse backend ne le contient
  /// pas — on utilise le choix fait par l'utilisateur lors de l'inscription.
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  });

  /// POST /auth/renvoyer-otp
  Future<void> renvoyerOtp({required String cible, required String type});

  /// POST /auth/connexion
  /// body: { identifiant, motDePasse } → réponse: { accessToken, refreshToken, role }
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  });

  /// POST /auth/refresh
  /// body: { refreshToken }
  Future<AuthSession> rafraichir(String refreshToken);

  /// POST /auth/logout
  /// body: { refreshToken }
  Future<void> deconnecter(String refreshToken);

  /// POST /auth/mot-de-passe-oublie
  /// body: { identifiant }
  Future<void> motDePasseOublie(String identifiant);

  /// POST /auth/reinitialiser-mot-de-passe
  /// body: { cible, codeOtp, nouveauMotDePasse }
  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  });
}
