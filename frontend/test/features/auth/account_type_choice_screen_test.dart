import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/services/session_storage.dart";
import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/auth/domain/entities/auth_session.dart";
import "package:mboalink/features/auth/domain/entities/registration_draft.dart";
import "package:mboalink/features/auth/domain/entities/registration_result.dart";
import "package:mboalink/features/auth/domain/repositories/auth_repository.dart";
import "package:mboalink/features/auth/presentation/providers/auth_providers.dart";
import "package:mboalink/features/auth/presentation/screens/account_type_choice_screen.dart";

/// Fake repository — inscrire retourne RegistrationResult (pas AuthSession)
/// conformément au contrat backend POST /auth/inscription.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
  }) async =>
      const RegistrationResult(utilisateurId: "uid-test", emailVerifie: false);

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  }) => throw UnimplementedError();

  @override
  Future<void> renvoyerOtp({required String cible, required String type}) =>
      throw UnimplementedError();

  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) => throw UnimplementedError();

  @override
  Future<AuthSession> rafraichir(String refreshToken) =>
      throw UnimplementedError();

  @override
  Future<void> deconnecter(String refreshToken) => throw UnimplementedError();

  @override
  Future<void> motDePasseOublie(String identifiant) =>
      throw UnimplementedError();

  @override
  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) => throw UnimplementedError();
}

class _NoSessionStorage implements SessionStorage {
  @override
  Future<void> save(AuthSession session) async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> clear() async {}
}

final _draft = RegistrationDraft(
  nom: "Tchana",
  prenom: "Paul",
  email: "paul@test.cm",
  telephone: null,
  motDePasse: "Pass@2026",
);

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => AccountTypeChoiceScreen(draft: _draft),
        ),
        GoRoute(
          path: "/otp",
          builder: (context, state) => const Scaffold(body: Text("OTP Screen")),
        ),
      ],
    );
  }

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        sessionStorageProvider.overrideWithValue(_NoSessionStorage()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: buildRouter(),
      ),
    );
  }

  testWidgets("affiche les 2 cartes de type de compte", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Client · Utilisateur"), findsOneWidget);
    expect(find.text("Grossiste"), findsOneWidget);
    expect(find.text("Continuer"), findsOneWidget);
  });

  testWidgets("sélectionner Client active la carte correspondante", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Client · Utilisateur"));
    await tester.pumpAndSettle();

    expect(find.text("Continuer"), findsOneWidget);
  });

  testWidgets(
    "sélectionner Grossiste active la carte et montre badge abonnement",
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Grossiste"));
      await tester.pumpAndSettle();

      expect(find.text("Abonnement requis"), findsOneWidget);
    },
  );

  testWidgets("choisir Client et taper Continuer navigue vers OTP", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Client · Utilisateur"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Continuer"));
    await tester.pumpAndSettle();

    expect(find.text("OTP Screen"), findsOneWidget);
  });

  testWidgets("choisir Grossiste et taper Continuer navigue vers OTP", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Grossiste"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Continuer"));
    await tester.pumpAndSettle();

    expect(find.text("OTP Screen"), findsOneWidget);
  });
}
