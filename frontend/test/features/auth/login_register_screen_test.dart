import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/services/session_storage.dart";
import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/auth/domain/entities/auth_session.dart";
import "package:mboalink/features/auth/domain/entities/registration_draft.dart";
import "package:mboalink/features/auth/domain/entities/registration_result.dart";
import "package:mboalink/features/auth/domain/entities/user_role.dart";
import "package:mboalink/features/auth/domain/repositories/auth_repository.dart";
import "package:mboalink/features/auth/presentation/providers/auth_providers.dart";
import "package:mboalink/features/auth/presentation/screens/login_register_screen.dart";

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) async => const AuthSession(
    accessToken: "fake-tok",
    refreshToken: "fake-ref",
    role: UserRole.utilisateur,
    emailVerifie: true,
  );

  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
  }) async =>
      const RegistrationResult(utilisateurId: "fake-uid", emailVerifie: false);

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

  @override
  Future<AuthSession> devenirGrossiste() => throw UnimplementedError();

  @override
  Future<AuthSession> redevenirUtilisateur() => throw UnimplementedError();

  @override
  Future<void> modifierProfil({required String nom, required String prenom}) =>
      throw UnimplementedError();

  @override
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
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

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const LoginRegisterScreen(),
        ),
        GoRoute(
          path: "/home",
          builder: (context, state) =>
              const Scaffold(body: Text("Accueil Client")),
        ),
        GoRoute(
          path: "/grossiste/dashboard",
          builder: (context, state) =>
              const Scaffold(body: Text("Dashboard Grossiste")),
        ),
        GoRoute(
          path: "/inscription/type-compte",
          builder: (context, state) {
            final draft = state.extra as RegistrationDraft;
            return Scaffold(body: Text("Choix type — ${draft.email}"));
          },
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

  testWidgets("affiche les onglets Connexion et Inscription", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Connexion"), findsOneWidget);
    expect(find.text("Inscription"), findsOneWidget);
    expect(find.text("Se connecter · Sign in"), findsOneWidget);
  });

  testWidgets("connexion réussie navigue vers Accueil Client", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // AppTextField rend le label comme Text SÉPARÉ du TextField — on
    // utilise l'index pour identifier les champs, pas le label.
    // Onglet Connexion : TextField[0] = email, TextField[1] = mot de passe.
    await tester.enterText(
      find.byType(TextField).at(0),
      "fakeclient@mboalink.test",
    );
    await tester.enterText(find.byType(TextField).at(1), "FakePass@9999");
    await tester.tap(find.text("Se connecter · Sign in"));
    await tester.pumpAndSettle();

    expect(find.text("Accueil Client"), findsOneWidget);
  });

  testWidgets("basculer sur Inscription affiche le formulaire", (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Inscription"));
    await tester.pumpAndSettle();

    expect(find.text("Créer mon compte"), findsOneWidget);
    // Les labels sont des Text séparés — on les trouve normalement.
    expect(find.text("Nom"), findsOneWidget);
    expect(find.text("Prénom"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
  });

  testWidgets("inscription valide navigue vers choix type compte", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Inscription"));
    await tester.pumpAndSettle();

    // Onglet Inscription : [0]=Nom, [1]=Prénom, [2]=Email,
    // [3]=Téléphone (PhoneField, optionnel), [4]=Mot de passe.
    await tester.enterText(find.byType(TextField).at(0), "Fakenomtest");
    await tester.enterText(find.byType(TextField).at(1), "Fakeprenomtest");
    await tester.enterText(find.byType(TextField).at(2), "fake@mboalink.test");
    // Index 3 = téléphone optionnel, on le laisse vide
    await tester.enterText(find.byType(TextField).at(4), "FakePass@9999");

    // Le formulaire est plus long que l'écran de test (800×600) — on
    // scrolle jusqu'au bouton avant de tapper pour éviter l'erreur offset.
    await tester.ensureVisible(find.text("Créer mon compte"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Créer mon compte"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Choix type"), findsOneWidget);
  });

  testWidgets("Google et Facebook sont grisés (bientôt disponible)", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining("Google"), findsOneWidget);
    expect(find.textContaining("Facebook"), findsOneWidget);
    expect(find.textContaining("bientôt"), findsNWidgets(2));

    // Boutons désactivés — le tap ne doit provoquer aucune navigation ni erreur.
    await tester.tap(find.textContaining("Google"), warnIfMissed: false);
    await tester.tap(find.textContaining("Facebook"), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text("Se connecter · Sign in"), findsOneWidget);
  });
}
