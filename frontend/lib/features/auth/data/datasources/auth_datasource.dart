import "../../domain/entities/auth_session.dart";
import "../../domain/entities/registration_result.dart";

abstract class AuthDatasource {
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
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
}
