import "../../domain/entities/auth_session.dart";
import "../../domain/entities/registration_result.dart";
import "../../domain/repositories/auth_repository.dart";
import "../datasources/auth_datasource.dart";

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String motDePasse,
    required String role,
  }) async {
    final result = await _datasource.inscrire(
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      motDePasse: motDePasse,
      role: role,
    );
    return RegistrationResult(
      utilisateurId: result.utilisateurId,
      cible: email ?? telephone!,
      message: result.message ?? "",
    );
  }

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
  }) async {
    final result = await _datasource.verifierOtp(
      cible: cible,
      code: code,
      type: type,
    );
    return result.toSession();
  }

  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) async {
    final result = await _datasource.connecter(
      identifiant: identifiant,
      motDePasse: motDePasse,
    );
    return result.toSession();
  }

  @override
  Future<AuthSession> rafraichir(String refreshToken) async {
    final result = await _datasource.rafraichir(refreshToken: refreshToken);
    return result.toSession();
  }

  @override
  Future<void> deconnecter(String refreshToken) {
    return _datasource.deconnecter(refreshToken: refreshToken);
  }

  @override
  Future<String> motDePasseOublie(String identifiant) async {
    final result = await _datasource.motDePasseOublie(identifiant: identifiant);
    return result.message;
  }

  @override
  Future<String> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) async {
    final result = await _datasource.reinitialiserMotDePasse(
      cible: cible,
      codeOtp: codeOtp,
      nouveauMotDePasse: nouveauMotDePasse,
    );
    return result.message;
  }

  @override
  Future<String> renvoyerOtp({
    required String cible,
    required String type,
  }) async {
    final result = await _datasource.renvoyerOtp(cible: cible, type: type);
    return result.message;
  }
}
