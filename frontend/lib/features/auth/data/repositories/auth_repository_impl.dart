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
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
  }) => _datasource.inscrire(
    nom: nom,
    prenom: prenom,
    email: email,
    motDePasse: motDePasse,
    role: role,
    telephone: telephone,
  );

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  }) =>
      _datasource.verifierOtp(cible: cible, code: code, type: type, role: role);

  @override
  Future<void> renvoyerOtp({required String cible, required String type}) =>
      _datasource.renvoyerOtp(cible: cible, type: type);

  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) => _datasource.connecter(identifiant: identifiant, motDePasse: motDePasse);

  @override
  Future<AuthSession> rafraichir(String refreshToken) =>
      _datasource.rafraichir(refreshToken);

  @override
  Future<void> deconnecter(String refreshToken) =>
      _datasource.deconnecter(refreshToken);

  @override
  Future<void> motDePasseOublie(String identifiant) =>
      _datasource.motDePasseOublie(identifiant);

  @override
  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) => _datasource.reinitialiserMotDePasse(
    cible: cible,
    codeOtp: codeOtp,
    nouveauMotDePasse: nouveauMotDePasse,
  );

  @override
  Future<AuthSession> devenirGrossiste() => _datasource.devenirGrossiste();

  @override
  Future<AuthSession> redevenirUtilisateur() =>
      _datasource.redevenirUtilisateur();

  @override
  Future<void> modifierProfil({required String nom, required String prenom}) =>
      _datasource.modifierProfil(nom: nom, prenom: prenom);

  @override
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) => _datasource.changerMotDePasse(
    ancienMotDePasse: ancienMotDePasse,
    nouveauMotDePasse: nouveauMotDePasse,
  );
}
