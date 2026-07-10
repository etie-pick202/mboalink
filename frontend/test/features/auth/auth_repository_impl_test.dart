import "package:flutter_test/flutter_test.dart";

import "package:mboalink/features/auth/data/datasources/auth_datasource.dart";
import "package:mboalink/features/auth/data/repositories/auth_repository_impl.dart";
import "package:mboalink/features/auth/domain/entities/auth_session.dart";
import "package:mboalink/features/auth/domain/entities/registration_result.dart";
import "package:mboalink/features/auth/domain/entities/user_role.dart";

class _FakeDatasource implements AuthDatasource {
  bool inscrireCalled = false;
  bool verifierOtpCalled = false;
  bool renvoyerOtpCalled = false;
  bool connecterCalled = false;
  bool rafraichirCalled = false;
  bool deconnecterCalled = false;
  bool motDePasseOublieCalled = false;
  bool reinitialiserCalled = false;
  bool devenirGrossisteCalled = false;

  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
  }) async {
    inscrireCalled = true;
    return const RegistrationResult(
      utilisateurId: "uid-test",
      emailVerifie: false,
    );
  }

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  }) async {
    verifierOtpCalled = true;
    return AuthSession(
      accessToken: "tok",
      refreshToken: "ref",
      role: UserRole.fromApi(role),
      emailVerifie: true,
    );
  }

  @override
  Future<void> renvoyerOtp({
    required String cible,
    required String type,
  }) async {
    renvoyerOtpCalled = true;
  }

  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) async {
    connecterCalled = true;
    return const AuthSession(
      accessToken: "tok",
      refreshToken: "ref",
      role: UserRole.utilisateur,
      emailVerifie: true,
    );
  }

  @override
  Future<AuthSession> rafraichir(String refreshToken) async {
    rafraichirCalled = true;
    return const AuthSession(
      accessToken: "new-tok",
      refreshToken: "new-ref",
      role: UserRole.utilisateur,
      emailVerifie: true,
    );
  }

  @override
  Future<void> deconnecter(String refreshToken) async {
    deconnecterCalled = true;
  }

  @override
  Future<void> motDePasseOublie(String identifiant) async {
    motDePasseOublieCalled = true;
  }

  @override
  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) async {
    reinitialiserCalled = true;
  }

  @override
  Future<AuthSession> devenirGrossiste() async {
    devenirGrossisteCalled = true;
    return const AuthSession(
      accessToken: "tok-grossiste",
      refreshToken: "ref-grossiste",
      role: UserRole.grossiste,
      emailVerifie: true,
    );
  }

  bool modifierProfilCalled = false;

  @override
  Future<void> modifierProfil({
    required String nom,
    required String prenom,
  }) async {
    modifierProfilCalled = true;
  }

  bool redevenirUtilisateurCalled = false;

  @override
  Future<AuthSession> redevenirUtilisateur() async {
    redevenirUtilisateurCalled = true;
    return const AuthSession(
      accessToken: "tok-client",
      refreshToken: "ref-client",
      role: UserRole.utilisateur,
      emailVerifie: true,
    );
  }

  bool changerMotDePasseCalled = false;

  @override
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    changerMotDePasseCalled = true;
  }
}

void main() {
  late _FakeDatasource datasource;
  late AuthRepositoryImpl repo;

  setUp(() {
    datasource = _FakeDatasource();
    repo = AuthRepositoryImpl(datasource);
  });

  test(
    "inscrire délègue au datasource et retourne RegistrationResult",
    () async {
      final result = await repo.inscrire(
        nom: "Tchana",
        prenom: "Paul",
        email: "paul@test.cm",
        motDePasse: "Pass@2026",
        role: "GROSSISTE",
      );

      expect(datasource.inscrireCalled, isTrue);
      expect(result.utilisateurId, equals("uid-test"));
      expect(result.emailVerifie, isFalse);
    },
  );

  test("verifierOtp délègue au datasource avec le role", () async {
    final session = await repo.verifierOtp(
      cible: "paul@test.cm",
      code: "123456",
      type: "INSCRIPTION_EMAIL",
      role: "GROSSISTE",
    );

    expect(datasource.verifierOtpCalled, isTrue);
    expect(session.role, equals(UserRole.grossiste));
    expect(session.emailVerifie, isTrue);
  });

  test("renvoyerOtp délègue au datasource", () async {
    await repo.renvoyerOtp(cible: "paul@test.cm", type: "INSCRIPTION_EMAIL");
    expect(datasource.renvoyerOtpCalled, isTrue);
  });

  test("connecter délègue au datasource", () async {
    final session = await repo.connecter(
      identifiant: "paul@test.cm",
      motDePasse: "Pass@2026",
    );

    expect(datasource.connecterCalled, isTrue);
    expect(session.accessToken, equals("tok"));
    expect(session.role, equals(UserRole.utilisateur));
  });

  test("rafraichir délègue au datasource", () async {
    final session = await repo.rafraichir("old-ref");

    expect(datasource.rafraichirCalled, isTrue);
    expect(session.accessToken, equals("new-tok"));
  });

  test("deconnecter délègue au datasource", () async {
    await repo.deconnecter("ref-token");
    expect(datasource.deconnecterCalled, isTrue);
  });

  test("motDePasseOublie délègue au datasource", () async {
    await repo.motDePasseOublie("paul@test.cm");
    expect(datasource.motDePasseOublieCalled, isTrue);
  });

  test("reinitialiserMotDePasse délègue au datasource", () async {
    await repo.reinitialiserMotDePasse(
      cible: "paul@test.cm",
      codeOtp: "123456",
      nouveauMotDePasse: "NewPass@2026",
    );
    expect(datasource.reinitialiserCalled, isTrue);
  });

  test("devenirGrossiste délègue au datasource", () async {
    final session = await repo.devenirGrossiste();
    expect(datasource.devenirGrossisteCalled, isTrue);
    expect(session.role, equals(UserRole.grossiste));
  });

  test("modifierProfil délègue au datasource", () async {
    await repo.modifierProfil(nom: "Tchana", prenom: "Paul");
    expect(datasource.modifierProfilCalled, isTrue);
  });

  test("redevenirUtilisateur délègue au datasource", () async {
    final session = await repo.redevenirUtilisateur();
    expect(datasource.redevenirUtilisateurCalled, isTrue);
    expect(session.role, equals(UserRole.utilisateur));
  });

  test("changerMotDePasse délègue au datasource", () async {
    await repo.changerMotDePasse(
      ancienMotDePasse: "OldPass@2026",
      nouveauMotDePasse: "NewPass@2026",
    );
    expect(datasource.changerMotDePasseCalled, isTrue);
  });
}
