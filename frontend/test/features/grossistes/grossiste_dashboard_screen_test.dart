import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";

import "package:mboalink/core/theme/app_theme.dart";
import "package:mboalink/features/grossiste/domain/entities/document_statut.dart";
import "package:mboalink/features/grossiste/domain/entities/document_type.dart";
import "package:mboalink/features/grossiste/domain/entities/document_verification.dart";
import "package:mboalink/features/grossiste/domain/entities/fiche_grossiste.dart";
import "package:mboalink/features/grossiste/domain/entities/fiche_statistiques.dart";
import "package:mboalink/features/grossiste/domain/entities/fiche_verification_statut.dart";
import "package:mboalink/features/grossiste/presentation/providers/grossiste_providers.dart";
import "package:mboalink/features/grossiste/presentation/screens/grossiste_dashboard_screen.dart";
import "package:mboalink/features/payment/domain/entities/abonnement.dart";
import "package:mboalink/features/payment/presentation/providers/payment_providers.dart";

/// Tests du tableau de bord grossiste — 6 états couverts :
///   1. nonSoumise          → fiche vide, bouton "Créer ma fiche"
///   2. enAttente           → fiche soumise, en vérification
///   3. rejetee             → document(s) refusé(s) avec commentaire admin
///   4. enAttenteAbonnement → docs validés, abonnement non payé
///   5. validee             → dashboard complet (stats + navbar)
///   6. suspendue           → fiche suspendue
void main() {
  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const GrossisteDashboardScreen(),
        ),
        GoRoute(
          path: "/grossiste/creer-ma-fiche",
          builder: (context, state) =>
              const Scaffold(body: Text("Créer ma fiche")),
        ),
        GoRoute(
          path: "/grossiste/fiche/lecture",
          builder: (context, state) =>
              const Scaffold(body: Text("Lecture fiche")),
        ),
        GoRoute(
          path: "/grossiste/boutique",
          builder: (context, state) => const Scaffold(body: Text("Boutique")),
        ),
        GoRoute(
          path: "/grossiste/fiche/apercu",
          builder: (context, state) =>
              const Scaffold(body: Text("Aperçu fiche")),
        ),
        GoRoute(
          path: "/grossiste/profil",
          builder: (context, state) => const Scaffold(body: Text("Profil")),
        ),
        GoRoute(
          path: "/login",
          builder: (context, state) => const Scaffold(body: Text("Login")),
        ),
      ],
    );
  }

  // ── 1. État nonSoumise ────────────────────────────────────────────────────

  testWidgets("état nonSoumise : bandeau orange + bouton Créer ma fiche", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith((ref) async => null),
          maFicheProvider.overrideWith(
            (ref) async => const FicheGrossiste(
              id: "f1",
              statutVerification: FicheVerificationStatut.enAttente,
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Compte en attente de vérification"), findsOneWidget);
    expect(find.text("Créer ma fiche"), findsOneWidget);
    expect(find.text("Vues ce mois"), findsOneWidget);
    expect(find.text("Contacts débloqués"), findsOneWidget);
  });

  // ── 2. État enAttente ─────────────────────────────────────────────────────

  testWidgets("état enAttente : bandeau vérification + bouton Lire ma fiche", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith((ref) async => null),
          maFicheProvider.overrideWith(
            (ref) async => const FicheGrossiste(
              id: "f1",
              statutVerification: FicheVerificationStatut.enAttente,
              nomEntreprise: "Kana Distribution",
              secteurActivite: "Cosmétique",
              ville: "Yaoundé",
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Fiche en attente de vérification"), findsOneWidget);
    expect(find.text("Lire ma fiche"), findsOneWidget);
  });

  // ── 3. État rejetee ───────────────────────────────────────────────────────

  testWidgets(
    "état rejetee : titre rouge + commentaire admin du document rejeté",
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monAbonnementProvider.overrideWith((ref) async => null),
            maFicheProvider.overrideWith(
              (ref) async => const FicheGrossiste(
                id: "f1",
                statutVerification: FicheVerificationStatut.rejete,
                nomEntreprise: "Sané Cosmetics",
                secteurActivite: "Cosmétique",
                ville: "Douala",
              ),
            ),
            ficheDocumentsProvider("f1").overrideWith(
              (ref) async => const [
                DocumentVerification(
                  id: "d1",
                  type: DocumentType.cni,
                  urlDocument: "mock://cni.jpg",
                  statut: DocumentStatut.rejete,
                  commentaireAdmin:
                      "Photo floue, le numéro de CNI est illisible.",
                ),
              ],
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: buildRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Fiche rejetée"), findsOneWidget);
      expect(
        find.text("Photo floue, le numéro de CNI est illisible."),
        findsOneWidget,
      );
      expect(find.text("Corriger ma fiche"), findsOneWidget);
    },
  );

  testWidgets("état rejetee sans documents : ne plante pas", (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith((ref) async => null),
          maFicheProvider.overrideWith(
            (ref) async => const FicheGrossiste(
              id: "f1",
              statutVerification: FicheVerificationStatut.rejete,
              nomEntreprise: "Test",
              secteurActivite: "Test",
              ville: "Douala",
            ),
          ),
          ficheDocumentsProvider("f1").overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Fiche rejetée"), findsOneWidget);
  });

  // ── 4. État enAttenteAbonnement ───────────────────────────────────────────

  testWidgets(
    "état enAttenteAbonnement : bandeau vert 'Documents validés' + bouton abonnement",
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monAbonnementProvider.overrideWith((ref) async => null),
            maFicheProvider.overrideWith(
              (ref) async => const FicheGrossiste(
                id: "f1",
                statutVerification: FicheVerificationStatut.verifie,
                aAbonnementActif: false,
                nomEntreprise: "Essomba Négoce",
                secteurActivite: "Alimentation",
                ville: "Bafoussam",
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: buildRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Documents validés !"), findsOneWidget);
      expect(find.text("Activer mon abonnement"), findsOneWidget);
      expect(find.textContaining("La boutique"), findsOneWidget);
    },
  );

  testWidgets("état enAttenteAbonnement : les 4 onglets navbar visibles", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith((ref) async => null),
          maFicheProvider.overrideWith(
            (ref) async => const FicheGrossiste(
              id: "f1",
              statutVerification: FicheVerificationStatut.verifie,
              aAbonnementActif: false,
              nomEntreprise: "Essomba Négoce",
              secteurActivite: "Alimentation",
              ville: "Bafoussam",
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Dashboard"), findsOneWidget);
    expect(find.text("Boutique"), findsOneWidget);
    expect(find.text("Fiche"), findsOneWidget);
    expect(find.text("Profil"), findsOneWidget);
  });

  testWidgets(
    "état enAttenteAbonnement : tap 'Activer mon abonnement' navigue vers Profil",
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monAbonnementProvider.overrideWith((ref) async => null),
            maFicheProvider.overrideWith(
              (ref) async => const FicheGrossiste(
                id: "f1",
                statutVerification: FicheVerificationStatut.verifie,
                aAbonnementActif: false,
                nomEntreprise: "Essomba Négoce",
                secteurActivite: "Alimentation",
                ville: "Bafoussam",
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: buildRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Activer mon abonnement"));
      await tester.pumpAndSettle();

      expect(find.text("Profil"), findsWidgets);
    },
  );

  // ── 5. État validee ───────────────────────────────────────────────────────

  testWidgets("état validee : stats + graphique + navbar complète 4 onglets", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith(
            (ref) async => Abonnement(
              id: "a1",
              typeAbonnement: "MENSUEL",
              montant: 15000,
              dateDebut: DateTime(2026, 6, 12),
              dateFin: DateTime(2026, 7, 12),
              statut: StatutAbonnement.actif,
              renouvellementAuto: false,
            ),
          ),
          maFicheProvider.overrideWith(
            (ref) async => const FicheGrossiste(
              id: "f1",
              statutVerification: FicheVerificationStatut.verifie,
              aAbonnementActif: true,
              nomEntreprise: "Ets Tchana & Fils",
              secteurActivite: "Alimentation",
              ville: "Douala",
            ),
          ),
          ficheStatistiquesProvider.overrideWith(
            (ref, ficheId) async => const FicheStatistiques(
              vuesMoisEnCours: 2412,
              contactsDebloques: 86,
              vuesParJour: [4, 9, 6, 12, 8, 15, 18],
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("2412"), findsOneWidget);
    expect(find.text("86"), findsOneWidget);
    expect(find.text("Plan mensuel · 15000 F"), findsOneWidget);
    expect(find.text("Vues · 7 derniers jours"), findsOneWidget);
    expect(find.text("Dashboard"), findsOneWidget);
    expect(find.text("Boutique"), findsOneWidget);
    expect(find.text("Fiche"), findsOneWidget);
    expect(find.text("Profil"), findsOneWidget);
  });

  // ── 6. État suspendue ─────────────────────────────────────────────────────

  testWidgets(
    "état suspendue : écran rouge + message suspension + bouton support",
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monAbonnementProvider.overrideWith((ref) async => null),
            maFicheProvider.overrideWith(
              (ref) async => const FicheGrossiste(
                id: "f1",
                statutVerification: FicheVerificationStatut.suspendu,
                nomEntreprise: "Mballa Textiles",
                secteurActivite: "Textile",
                ville: "Douala",
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: buildRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Fiche suspendue"), findsOneWidget);
      expect(find.textContaining("abonnement"), findsOneWidget);
      expect(find.text("Contacter le support"), findsOneWidget);
    },
  );

  // ── Chargement ────────────────────────────────────────────────────────────

  testWidgets("état loading : spinner affiché", (tester) async {
    // Completer sans timer — le tearDown le résout proprement pour éviter
    // "A Timer is still pending" au moment de la destruction du widget tree.
    final completer = Completer<FicheGrossiste>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(
          const FicheGrossiste(
            id: "f1",
            statutVerification: FicheVerificationStatut.enAttente,
          ),
        );
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith((ref) async => null),
          maFicheProvider.overrideWith((ref) => completer.future),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Erreur ────────────────────────────────────────────────────────────────

  testWidgets("état erreur : message + bouton Réessayer", (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monAbonnementProvider.overrideWith((ref) async => null),
          maFicheProvider.overrideWith(
            (ref) async => throw Exception("Connexion impossible"),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Réessayer"), findsOneWidget);
  });
}
