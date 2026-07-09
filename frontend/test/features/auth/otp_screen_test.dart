import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/services/session_storage.dart";
import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/auth/domain/entities/auth_session.dart";
import "package:mboalink/features/auth/domain/entities/registration_result.dart";
import "package:mboalink/features/auth/domain/entities/user_role.dart";
import "package:mboalink/features/auth/domain/repositories/auth_repository.dart";
import "package:mboalink/features/auth/presentation/providers/auth_providers.dart";
import "package:mboalink/features/auth/presentation/screens/otp_screen.dart";

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  }) async => AuthSession(
    accessToken: "fake-tok",
    refreshToken: "fake-ref",
    role: UserRole.fromApi(role),
    emailVerifie: true,
  );

  @override
  Future<void> renvoyerOtp({required String cible, required String type}) async {}

  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
  }) => throw UnimplementedError();

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

// Email clairement fictif — domaine .test (RFC 2606, jamais résolu en DNS)
const _testEmail = "fakeotp@mboalink.test";

void main() {
  GoRouter buildRouter({bool isGrossiste = false}) {
    return GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => OtpScreen(
            cible: _testEmail,
            isGrossiste: isGrossiste,
          ),
        ),
        GoRoute(
          path: "/consent",
          builder: (context, state) =>
          const Scaffold(body: Text("Consentement")),
        ),
      ],
    );
  }

  Widget buildApp({bool isGrossiste = false}) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        sessionStorageProvider.overrideWithValue(_NoSessionStorage()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: buildRouter(isGrossiste: isGrossiste),
      ),
    );
  }

  testWidgets("affiche le titre Vérification", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Vérification · Verify"), findsOneWidget);
  });

  testWidgets("affiche la cible email dans le corps", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // L'email est dans un TextSpan de Text.rich — textContaining
    // traverse les widgets RichText contrairement à find.text().
    expect(find.textContaining(_testEmail), findsOneWidget);
  });

  testWidgets("affiche le bouton Vérifier", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Vérifier · Verify"), findsOneWidget);
  });

  testWidgets("affiche le countdown de renvoi au démarrage", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining("Renvoyer le code dans"), findsOneWidget);
    expect(find.textContaining("1:0"), findsOneWidget);
  });

  testWidgets("sans code saisi — tapper Vérifier ne navigue pas", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Le bouton est présent mais inactif (onPressed null)
    // → tapper ne provoque aucune navigation
    await tester.tap(find.text("Vérifier · Verify"), warnIfMissed: false);
    await tester.pumpAndSettle();

    // On reste sur l'écran OTP
    expect(find.text("Vérification · Verify"), findsOneWidget);
    expect(find.text("Consentement"), findsNothing);
  });

  testWidgets("saisir le code complet navigue vers Consentement", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    final fieldCount = tester.widgetList(fields).length;

    if (fieldCount >= 6) {
      // OtpCodeInput avec 6 champs distincts — un digit par champ
      for (var i = 0; i < 6; i++) {
        await tester.tap(fields.at(i));
        await tester.pump();
        await tester.enterText(fields.at(i), (i + 1).toString());
        await tester.pump();
      }
    } else {
      // OtpCodeInput avec champ unique — code entier d'un coup
      await tester.tap(fields.first);
      await tester.pump();
      await tester.enterText(fields.first, "123456");
      await tester.pump();
    }

    await tester.pumpAndSettle();
    expect(find.text("Consentement"), findsOneWidget);
  });

  testWidgets("état initial stable — pas de spinner au démarrage", (tester) async {
    final completer = Completer<AuthSession>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(const AuthSession(
          accessToken: "fake-tok",
          refreshToken: "fake-ref",
          role: UserRole.utilisateur,
          emailVerifie: true,
        ));
      }
    });

    await tester.pumpWidget(buildApp());
    await tester.pump();

    // Au démarrage, pas de spinner — le spinner n'apparaît qu'après soumission
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("Vérification · Verify"), findsOneWidget);
  });
}