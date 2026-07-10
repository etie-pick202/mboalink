import "../entities/auth_session.dart";
import "../entities/registration_result.dart";

abstract class AuthRepository {
  /// POST /auth/inscription
  /// Crée le compte. Renvoie utilisateurId + emailVerifie (pas de tokens).
  /// [telephone] optionnel — s'il est fourni, permet ensuite de choisir
  /// l'OTP par SMS plutôt que par email (voir OtpScreen).
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
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

  /// POST /auth/devenir-grossiste — bascule le compte connecté (rôle
  /// UTILISATEUR) en GROSSISTE et renvoie une session avec des tokens à
  /// jour (le rôle étant encodé dans le JWT).
  Future<AuthSession> devenirGrossiste();

  /// POST /auth/redevenir-utilisateur — bascule le compte connecté (rôle
  /// GROSSISTE) en UTILISATEUR sans supprimer la fiche existante.
  Future<AuthSession> redevenirUtilisateur();

  /// PUT /profil — modifie nom/prénom du compte connecté.
  Future<void> modifierProfil({required String nom, required String prenom});

  /// PUT /auth/mot-de-passe — change le mot de passe du compte connecté.
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  });
}
