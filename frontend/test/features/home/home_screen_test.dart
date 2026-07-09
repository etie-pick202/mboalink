import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/home/presentation/screens/home_screen.dart";
import "package:mboalink/features/home/presentation/screens/client_recherche_screen.dart";
import "package:mboalink/features/home/presentation/screens/client_debloques_screen.dart";
import "package:mboalink/features/home/presentation/screens/client_profil_screen.dart";

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(path: "/", builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: "/recherche",
          builder: (context, state) => const ClientRechercheScreen(),
        ),
        GoRoute(
          path: "/debloques",
          builder: (context, state) => const ClientDeblocagesScreen(),
        ),
        GoRoute(
          path: "/profil",
          builder: (context, state) => const ClientProfilScreen(),
        ),
      ],
    );
  }

  Widget buildApp() {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: buildRouter(),
    );
  }

  testWidgets("affiche le fil personnalisé et la barre de navigation", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Pour vous · à proximité"), findsOneWidget);
    expect(find.text("Ets Tchana & Fils"), findsOneWidget);
    expect(find.text("Accueil"), findsOneWidget);
    expect(find.text("Recherche"), findsOneWidget);
    expect(find.text("Débloqués"), findsOneWidget);
    expect(find.text("Profil"), findsOneWidget);
  });

  testWidgets("taper sur Recherche navigue vers l'écran Recherche", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Recherche"));
    await tester.pumpAndSettle();

    expect(find.byType(ClientRechercheScreen), findsOneWidget);
  });

  testWidgets("taper sur Débloqués navigue vers l'écran Débloqués", (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Débloqués"));
    await tester.pumpAndSettle();

    expect(find.byType(ClientDeblocagesScreen), findsOneWidget);
  });
}
