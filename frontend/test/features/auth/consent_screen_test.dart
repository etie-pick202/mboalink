import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/auth/domain/entities/consentement.dart";
import "package:mboalink/features/auth/domain/repositories/consentement_repository.dart";
import "package:mboalink/features/auth/presentation/providers/auth_providers.dart";
import "package:mboalink/features/auth/presentation/screens/consent_screen.dart";

class _FakeConsentementRepository implements ConsentementRepository {
  @override
  Future<Consentement> consulter() async => const Consentement(
    trackingAccepte: false,
    notificationsAcceptees: false,
    marketingAccepte: false,
    conditionsAcceptees: true,
  );

  @override
  Future<Consentement> mettreAJour({
    bool? trackingAccepte,
    bool? notificationsAcceptees,
    bool? marketingAccepte,
    bool? conditionsAcceptees,
    String? versionConditions,
  }) async => Consentement(
    trackingAccepte: trackingAccepte ?? false,
    notificationsAcceptees: notificationsAcceptees ?? false,
    marketingAccepte: marketingAccepte ?? false,
    conditionsAcceptees: conditionsAcceptees ?? true,
    versionConditions: versionConditions,
  );
}

void main() {
  GoRouter buildRouter({required bool isGrossiste}) {
    return GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => ConsentScreen(isGrossiste: isGrossiste),
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
      ],
    );
  }

  Widget buildApp({required bool isGrossiste}) {
    return ProviderScope(
      overrides: [
        consentementRepositoryProvider.overrideWithValue(
          _FakeConsentementRepository(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: buildRouter(isGrossiste: isGrossiste),
      ),
    );
  }

  testWidgets("Client : accepter navigue vers Accueil", (tester) async {
    await tester.pumpWidget(buildApp(isGrossiste: false));
    await tester.pumpAndSettle();

    final acceptButton = find.textContaining("Accepter");
    expect(acceptButton, findsOneWidget);

    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    expect(find.text("Accueil Client"), findsOneWidget);
  });

  testWidgets("Grossiste : accepter navigue vers Dashboard Grossiste", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(isGrossiste: true));
    await tester.pumpAndSettle();

    final acceptButton = find.textContaining("Accepter");
    expect(acceptButton, findsOneWidget);

    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    expect(find.text("Dashboard Grossiste"), findsOneWidget);
  });

  testWidgets("affiche les informations de consentement", (tester) async {
    await tester.pumpWidget(buildApp(isGrossiste: false));
    await tester.pumpAndSettle();

    // L'écran de consentement doit exister et être visible
    expect(find.byType(ConsentScreen), findsOneWidget);
  });
}
