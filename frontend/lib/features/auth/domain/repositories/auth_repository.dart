import "../entities/auth_session.dart";
import "../entities/registration_result.dart";

/// Contrat métier de l'authentification, indépendant de Dio/HTTP/mock.
abstract class AuthRepository {
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String motDePasse,
    required String role,
  });

  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
  });

  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  });

  Future<AuthSession> rafraichir(String refreshToken);

  Future<void> deconnecter(String refreshToken);

  Future<String> motDePasseOublie(String identifiant);

  Future<String> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  });

  Future<String> renvoyerOtp({required String cible, required String type});
}
