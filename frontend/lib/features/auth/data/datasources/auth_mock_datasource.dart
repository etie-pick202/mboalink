import "dart:math";

import "../../../../core/errors/app_exception.dart";
import "../../domain/entities/auth_session.dart";
import "../../domain/entities/registration_result.dart";
import "../../domain/entities/user_role.dart";
import "auth_datasource.dart";

/// Simule le comportement du backend Auth — utilisé quand USE_MOCK=true.
/// Les comptes démo sont pré-seedés ; les nouveaux comptes créés via
/// le formulaire d'inscription survivent le temps de la session.
class AuthMockDatasource implements AuthDatasource {
  static const _delay = Duration(milliseconds: 700);
  static const _otpValide = "123456";

  final Map<String, _MockAccount> _accounts = {
    "demo.client@mboalink.cm": _MockAccount(
      id: "mock-user-demo-client",
      nom: "Kamdem",
      prenom: "Alice",
      motDePasse: "Mboa@2026",
      role: "UTILISATEUR",
      email: "demo.client@mboalink.cm",
      emailVerifie: true,
    ),
    "demo.grossiste@mboalink.cm": _MockAccount(
      id: "mock-user-demo-grossiste",
      nom: "Tchana",
      prenom: "Paul",
      motDePasse: "Mboa@2026",
      role: "GROSSISTE",
      email: "demo.grossiste@mboalink.cm",
      emailVerifie: true,
    ),
    "demo.grossiste.attente@mboalink.cm": _MockAccount(
      id: "mock-user-demo-grossiste-attente",
      nom: "Kana",
      prenom: "Serge",
      motDePasse: "Mboa@2026",
      role: "GROSSISTE",
      email: "demo.grossiste.attente@mboalink.cm",
      emailVerifie: true,
    ),
    "demo.grossiste.rejete@mboalink.cm": _MockAccount(
      id: "mock-user-demo-grossiste-rejete",
      nom: "Sané",
      prenom: "Bella",
      motDePasse: "Mboa@2026",
      role: "GROSSISTE",
      email: "demo.grossiste.rejete@mboalink.cm",
      emailVerifie: true,
    ),
    "demo.grossiste.abonnement@mboalink.cm": _MockAccount(
      id: "mock-user-demo-grossiste-abonnement",
      nom: "Essomba",
      prenom: "Bruno",
      motDePasse: "Mboa@2026",
      role: "GROSSISTE",
      email: "demo.grossiste.abonnement@mboalink.cm",
      emailVerifie: true,
    ),
    "demo.grossiste.valide@mboalink.cm": _MockAccount(
      id: "mock-user-demo-grossiste-valide",
      nom: "Tchana",
      prenom: "Georges",
      motDePasse: "Mboa@2026",
      role: "GROSSISTE",
      email: "demo.grossiste.valide@mboalink.cm",
      emailVerifie: true,
    ),
    "demo.grossiste.suspendu@mboalink.cm": _MockAccount(
      id: "mock-user-demo-grossiste-suspendu",
      nom: "Mballa",
      prenom: "Rachel",
      motDePasse: "Mboa@2026",
      role: "GROSSISTE",
      email: "demo.grossiste.suspendu@mboalink.cm",
      emailVerifie: true,
    ),
    // Compte admin — non inscriptible via l'app, nommé par un admin existant
    "admin@mboalink.cm": _MockAccount(
      id: "mock-user-admin",
      nom: "MboaLink",
      prenom: "Admin",
      motDePasse: "Admin@2026",
      role: "ADMIN",
      email: "admin@mboalink.cm",
      emailVerifie: true,
    ),
  };

  int _seq = 0;

  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
  }) async {
    await Future.delayed(_delay);
    if (_accounts.containsKey(email)) {
      throw const AppException(
        "Un compte existe déjà avec cet email.",
        statusCode: 409,
      );
    }
    // Seuls UTILISATEUR et GROSSISTE peuvent s'inscrire via l'app.
    if (!UserRole.fromApi(role).isInscriptible) {
      throw const AppException(
        "Rôle non autorisé à l'inscription.",
        statusCode: 403,
      );
    }
    final id = "mock-user-${++_seq}";
    _accounts[email] = _MockAccount(
      id: id,
      nom: nom,
      prenom: prenom,
      motDePasse: motDePasse,
      role: role,
      email: email,
    );
    return RegistrationResult(utilisateurId: id, emailVerifie: false);
  }

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  }) async {
    await Future.delayed(_delay);
    if (code != _otpValide) {
      throw const AppException("Code OTP invalide ou expiré.", statusCode: 401);
    }
    final account = _accounts[cible];
    if (account == null) {
      throw const AppException("Compte introuvable.", statusCode: 404);
    }
    account.emailVerifie = true;
    return _buildSession(account, roleOverride: role);
  }

  @override
  Future<void> renvoyerOtp({
    required String cible,
    required String type,
  }) async {
    await Future.delayed(_delay);
    if (!_accounts.containsKey(cible)) {
      throw const AppException("Compte introuvable.", statusCode: 404);
    }
  }

  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) async {
    await Future.delayed(_delay);
    final account = _accounts[identifiant];
    if (account == null) {
      throw const AppException("Identifiants incorrects.", statusCode: 401);
    }
    if (account.motDePasse != motDePasse) {
      throw const AppException("Identifiants incorrects.", statusCode: 401);
    }
    if (!account.emailVerifie) {
      throw const AppException(
        "Votre email n'est pas encore vérifié.",
        statusCode: 403,
      );
    }
    return _buildSession(account);
  }

  @override
  Future<AuthSession> rafraichir(String refreshToken) async {
    await Future.delayed(_delay);
    return AuthSession(
      accessToken: "mock-access-${Random().nextInt(99999)}",
      refreshToken: "mock-refresh-${Random().nextInt(99999)}",
      role: UserRole.utilisateur,
      emailVerifie: true,
    );
  }

  @override
  Future<void> deconnecter(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> motDePasseOublie(String identifiant) async {
    await Future.delayed(_delay);
    if (!_accounts.containsKey(identifiant)) {
      throw const AppException("Compte introuvable.", statusCode: 404);
    }
  }

  @override
  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(_delay);
    if (codeOtp != _otpValide) {
      throw const AppException("Code OTP invalide ou expiré.", statusCode: 401);
    }
    final account = _accounts[cible];
    if (account == null) {
      throw const AppException("Compte introuvable.", statusCode: 404);
    }
    account.motDePasse = nouveauMotDePasse;
  }

  @override
  Future<AuthSession> devenirGrossiste() async {
    await Future.delayed(_delay);
    // Mode mock — aucune session courante à retrouver ici, on simule
    // simplement la bascule de rôle sur un compte factice.
    final account = _MockAccount(
      id: "mock-user-devenu-grossiste",
      nom: "Compte",
      prenom: "Bascule",
      motDePasse: "",
      role: "GROSSISTE",
      email: "bascule@mboalink.cm",
      emailVerifie: true,
    );
    return _buildSession(account);
  }

  @override
  Future<void> modifierProfil({
    required String nom,
    required String prenom,
  }) async {
    await Future.delayed(_delay);
  }

  @override
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    await Future.delayed(_delay);
    final account = _accounts.values.firstWhere(
      (a) => a.motDePasse == ancienMotDePasse,
      orElse: () => _MockAccount(
        id: "",
        nom: "",
        prenom: "",
        motDePasse: "",
        role: "",
        email: "",
      ),
    );
    if (account.id.isEmpty) {
      throw const AppException(
        "Mot de passe actuel incorrect.",
        statusCode: 401,
      );
    }
    account.motDePasse = nouveauMotDePasse;
  }

  @override
  Future<AuthSession> redevenirUtilisateur() async {
    await Future.delayed(_delay);
    final account = _MockAccount(
      id: "mock-user-redevenu-client",
      nom: "Compte",
      prenom: "Bascule",
      motDePasse: "",
      role: "UTILISATEUR",
      email: "bascule@mboalink.cm",
      emailVerifie: true,
    );
    return _buildSession(account);
  }

  AuthSession _buildSession(_MockAccount account, {String? roleOverride}) {
    final role = UserRole.fromApi(roleOverride ?? account.role);
    return AuthSession(
      accessToken: "mock-access-${account.id}",
      refreshToken: "mock-refresh-${account.id}",
      role: role,
      emailVerifie: account.emailVerifie,
      userId: account.id,
      nom: account.nom,
      prenom: account.prenom,
      email: account.email,
    );
  }
}

/// Compte en mémoire pour le mode mock.
/// Utilise des champs simples — pas de getter/setter inutile.
class _MockAccount {
  _MockAccount({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.motDePasse,
    required this.role,
    required this.email,
    this.emailVerifie = false,
  });

  final String id;
  final String nom;
  final String prenom;
  // Champ mutable directement — pas de getter/setter redondant.
  String motDePasse;
  final String role;
  final String email;
  bool emailVerifie;
}
