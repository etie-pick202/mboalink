import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/auth/presentation/screens/login_register_screen.dart";

void main() {
  Widget buildApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const LoginRegisterScreen(),
        ),
      ],
    );
    return ProviderScope(
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets("le tab Inscription révèle les champs Nom et Prénom", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Nom"), findsNothing);

    await tester.tap(find.text("Inscription"));
    await tester.pumpAndSettle();

    expect(find.text("Nom"), findsOneWidget);
    expect(find.text("Prénom"), findsOneWidget);
  });

  testWidgets("soumettre le formulaire de connexion vide affiche des erreurs", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Se connecter · Sign in"));
    await tester.pumpAndSettle();

    expect(find.textContaining("obligatoire"), findsWidgets);
  });
}
