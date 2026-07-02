import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/auth/domain/entities/auth_session.dart";
import "package:mboalink/features/auth/domain/entities/registration_draft.dart";
import "package:mboalink/features/auth/domain/entities/registration_result.dart";
import "package:mboalink/features/auth/domain/repositories/auth_repository.dart";
import "package:mboalink/features/auth/presentation/providers/auth_providers.dart";
import "package:mboalink/features/auth/presentation/screens/account_type_choice_screen.dart";

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String motDePasse,
    required String role,
  }) async {
    return RegistrationResult(
      utilisateurId: "id-1",
      cible: email ?? telephone!,
      message: "ok",
    );
  }

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
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
  Future<String> motDePasseOublie(String identifiant) =>
      throw UnimplementedError();

  @override
  Future<String> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) => throw UnimplementedError();

  @override
  Future<String> renvoyerOtp({required String cible, required String type}) =>
      throw UnimplementedError();
}

void main() {
  const draft = RegistrationDraft(
    nom: "Mayack",
    prenom: "Etienne",
    email: "etienne@test.cm",
    motDePasse: "MboaLink@2026",
  );

  Widget buildApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => AccountTypeChoiceScreen(draft: draft),
        ),
        GoRoute(
          path: "/otp",
          builder: (context, state) => const Scaffold(body: Text("OTP")),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets(
    "le bouton Continuer reste bloqué tant qu'aucun type n'est choisi",
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Continuer"));
      await tester.pumpAndSettle();

      expect(
        find.text("Quel type de compte souhaitez-vous créer ?"),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    "sélectionner Grossiste affiche l'avertissement vérification/abonnement",
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Grossiste"));
      await tester.pumpAndSettle();

      expect(find.textContaining("vérification d'identité"), findsOneWidget);
    },
  );

  testWidgets(
    "choisir Client puis Continuer appelle inscrire() et navigue vers l'OTP",
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Client"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Continuer"));
      await tester.pumpAndSettle();

      expect(find.text("OTP"), findsOneWidget);
    },
  );
}
