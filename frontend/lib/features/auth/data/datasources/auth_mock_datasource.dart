import "../../../../core/errors/app_exception.dart";
import "../models/auth_result_model.dart";
import "../models/message_response_model.dart";
import "auth_datasource.dart";

class _MockAccount {
  _MockAccount({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.motDePasse,
    required this.role,
    this.email,
    this.telephone,
  });

  final String id;
  final String nom;
  final String prenom;
  final String motDePasse;
  final String role;
  final String? email;
  final String? telephone;
  bool emailVerifie = false;
  bool telephoneVerifie = false;

  String get cible => email ?? telephone!;
}

/// Implémentation mock — aucune requête réseau, délai simulé, code OTP
/// fixe (aligné sur le mode MOCK du backend : 6 chiffres, "123456").
/// Permet de développer/tester tout le workflow d'auth sans avoir le
/// backend Spring lancé.
class AuthMockDatasource implements AuthDatasource {
  static const _mockOtp = "123456";
  static const _delay = Duration(milliseconds: 700);

  final Map<String, _MockAccount> _accounts = {};
  int _sequence = 0;

  @override
  Future<AuthResultModel> inscrire({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String motDePasse,
    required String role,
  }) async {
    await Future.delayed(_delay);
    _sequence++;
    final account = _MockAccount(
      id: "mock-user-$_sequence",
      nom: nom,
      prenom: prenom,
      motDePasse: motDePasse,
      role: role,
      email: email,
      telephone: telephone,
    );
    _accounts[account.cible] = account;

    return AuthResultModel(
      utilisateurId: account.id,
      role: role,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      emailVerifie: false,
      telephoneVerifie: false,
      message:
          "Compte créé. Vérifiez votre ${email != null ? "email" : "téléphone"} pour activer votre compte.",
    );
  }

  @override
  Future<AuthResultModel> verifierOtp({
    required String cible,
    required String code,
    required String type,
  }) async {
    await Future.delayed(_delay);
    if (code != _mockOtp) {
      throw const AppException("Code OTP invalide.");
    }

    final account = _accounts.putIfAbsent(
      cible,
      () => _MockAccount(
        id: "mock-user-guest",
        nom: "Utilisateur",
        prenom: "Test",
        motDePasse: "Mock@2026",
        role: "UTILISATEUR",
        email: cible.contains("@") ? cible : null,
        telephone: cible.contains("@") ? null : cible,
      ),
    );
    account.emailVerifie = account.email != null;
    account.telephoneVerifie = account.telephone != null;

    return _sessionResponse(
      account,
      message: "Compte activé avec succès. Bienvenue !",
    );
  }

  @override
  Future<AuthResultModel> connecter({
    required String identifiant,
    required String motDePasse,
  }) async {
    await Future.delayed(_delay);
    final account = _accounts[identifiant];
    if (account == null || account.motDePasse != motDePasse) {
      throw const AppException("Identifiants incorrects.");
    }
    return _sessionResponse(account, message: null);
  }

  @override
  Future<AuthResultModel> rafraichir({required String refreshToken}) async {
    await Future.delayed(_delay);
    return const AuthResultModel(
      accessToken: "mock-access-token-refreshed",
      refreshToken: "mock-refresh-token-refreshed",
      utilisateurId: "mock-user-current",
      role: "UTILISATEUR",
      emailVerifie: true,
      telephoneVerifie: false,
    );
  }

  @override
  Future<MessageResponseModel> deconnecter({
    required String refreshToken,
  }) async {
    await Future.delayed(_delay);
    return const MessageResponseModel(
      statut: "success",
      message: "Déconnexion réussie.",
    );
  }

  @override
  Future<MessageResponseModel> motDePasseOublie({
    required String identifiant,
  }) async {
    await Future.delayed(_delay);
    return const MessageResponseModel(
      statut: "success",
      message: "Un code de réinitialisation vous a été envoyé.",
    );
  }

  @override
  Future<MessageResponseModel> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(_delay);
    if (codeOtp != _mockOtp) {
      throw const AppException("Code OTP invalide.");
    }
    final account = _accounts[cible];
    if (account != null) {
      _accounts[cible] =
          _MockAccount(
              id: account.id,
              nom: account.nom,
              prenom: account.prenom,
              motDePasse: nouveauMotDePasse,
              role: account.role,
              email: account.email,
              telephone: account.telephone,
            )
            ..emailVerifie = account.emailVerifie
            ..telephoneVerifie = account.telephoneVerifie;
    }
    return const MessageResponseModel(
      statut: "success",
      message: "Mot de passe réinitialisé. Vous pouvez vous reconnecter.",
    );
  }

  @override
  Future<MessageResponseModel> renvoyerOtp({
    required String cible,
    required String type,
  }) async {
    await Future.delayed(_delay);
    return const MessageResponseModel(
      statut: "success",
      message: "Code OTP renvoyé.",
    );
  }

  AuthResultModel _sessionResponse(_MockAccount account, {String? message}) {
    return AuthResultModel(
      accessToken: "mock-access-token-${account.id}",
      refreshToken: "mock-refresh-token-${account.id}",
      utilisateurId: account.id,
      role: account.role,
      nom: account.nom,
      prenom: account.prenom,
      email: account.email,
      telephone: account.telephone,
      emailVerifie: account.emailVerifie,
      telephoneVerifie: account.telephoneVerifie,
      message: message,
    );
  }
}
