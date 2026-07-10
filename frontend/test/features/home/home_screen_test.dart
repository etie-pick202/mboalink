import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/home/domain/entities/contact_debloque.dart";
import "package:mboalink/features/home/domain/entities/fiche_publique.dart";
import "package:mboalink/features/home/domain/entities/grossiste_resume.dart";
import "package:mboalink/features/home/domain/repositories/recherche_repository.dart";
import "package:mboalink/features/home/presentation/providers/home_providers.dart";
import "package:mboalink/features/home/presentation/screens/home_screen.dart";
import "package:mboalink/features/home/presentation/screens/client_recherche_screen.dart";
import "package:mboalink/features/home/presentation/screens/client_debloques_screen.dart";
import "package:mboalink/features/home/presentation/screens/client_profil_screen.dart";

const _demoResume = GrossisteResume(
  id: "f1",
  nomEntreprise: "Ets Tchana & Fils",
  secteurActivite: "Alimentation",
  ville: "Douala",
  quartier: "Mboppi",
  certifie: true,
);

class _FakeRechercheRepository implements RechercheRepository {
  @override
  Future<PageResultat<GrossisteResume>> filActualite({
    double? latitude,
    double? longitude,
    int page = 0,
    int taille = 10,
  }) async => const PageResultat(
    resultats: [_demoResume],
    totalElements: 1,
    page: 0,
    dernierePage: true,
  );

  @override
  Future<PageResultat<GrossisteResume>> rechercherGrossistes({
    String? motCle,
    String? ville,
    String? categorie,
    double? prixMin,
    double? prixMax,
    bool? certifie,
    bool? certifiePremium,
    String tri = "NOTE_DESC",
    int page = 0,
    int taille = 20,
  }) async => const PageResultat(
    resultats: [_demoResume],
    totalElements: 1,
    page: 0,
    dernierePage: true,
  );

  @override
  Future<List<String>> listerVilles() async => const ["Douala"];

  @override
  Future<List<String>> listerSecteurs() async => const ["Alimentation"];

  @override
  Future<List<String>> listerCategories() async => const ["Alimentation"];

  @override
  Future<FichePublique> consulterFiche(String ficheId) =>
      throw UnimplementedError();

  @override
  Future<bool> estDeverrouille(String ficheId) async => false;

  @override
  Future<CoordonneesDeverrouillees> deverrouiller({
    required String ficheId,
    required String transactionId,
    required double montantPaye,
  }) => throw UnimplementedError();

  @override
  Future<void> enregistrerVueFiche(String ficheId) async {}

  @override
  Future<bool> estFavori(String ficheId) async => false;

  @override
  Future<void> ajouterFavori(String ficheId) async {}

  @override
  Future<void> retirerFavori(String ficheId) async {}

  @override
  Future<List<GrossisteResume>> mesFavoris() async => const [];

  @override
  Future<List<ContactDebloque>> mesDeverrouillages() async => const [];
}

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
    return ProviderScope(
      overrides: [
        rechercheRepositoryProvider.overrideWithValue(
          _FakeRechercheRepository(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: buildRouter(),
      ),
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
