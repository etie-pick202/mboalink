import "../../domain/entities/auth_session.dart";
import "../../domain/entities/registration_result.dart";

abstract class AuthDatasource {
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
  });

  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  });

  Future<void> renvoyerOtp({required String cible, required String type});

  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  });

  Future<AuthSession> rafraichir(String refreshToken);

  Future<void> deconnecter(String refreshToken);

  Future<void> motDePasseOublie(String identifiant);

  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  });

  /// POST /auth/devenir-grossiste — bascule le compte connecté en
  /// GROSSISTE et renvoie une session avec des tokens à jour.
  Future<AuthSession> devenirGrossiste();

  /// POST /auth/redevenir-utilisateur — bascule le compte connecté en
  /// UTILISATEUR et renvoie une session avec des tokens à jour.
  Future<AuthSession> redevenirUtilisateur();

  /// PUT /profil — modifie nom/prénom du compte connecté.
  Future<void> modifierProfil({required String nom, required String prenom});

  /// PUT /auth/mot-de-passe — change le mot de passe du compte connecté.
  /// Révoque les sessions actives côté backend (l'appelant doit
  /// déconnecter et rediriger vers l'écran de connexion après succès).
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  });
}
