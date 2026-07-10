import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/config/app_config.dart";
import "../../../../core/network/dio_client.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../data/datasources/grossiste_datasource.dart";
import "../../data/datasources/grossiste_mock_datasource.dart";
import "../../data/datasources/grossiste_remote_datasource.dart";
import "../../data/repositories/grossiste_repository_impl.dart";
import "../../domain/entities/document_verification.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../../domain/entities/fiche_statistiques.dart";
import "../../domain/entities/fiche_verification_statut.dart";
import "../../domain/entities/grossiste_dashboard_widget.dart";
import "../../domain/entities/produit_grossite.dart";
import "../../domain/repositories/grossiste_repository.dart";

final grossisteDatasourceProvider = Provider<GrossisteDatasource>((ref) {
  if (AppConfig.useMockData) {
    return GrossisteMockDatasource();
  }
  return GrossisteRemoteDatasource(buildDioClient(withAuth: true));
});

final grossisteRepositoryProvider = Provider<GrossisteRepository>((ref) {
  return GrossisteRepositoryImpl(ref.watch(grossisteDatasourceProvider));
});

/// Fiche du grossiste connecté. Le mock sélectionne le bon scénario de
/// démonstration selon l'email de la session active — permet de tester
/// tous les statuts (vide, en attente, rejetée, validée, suspendue) en
/// se connectant simplement avec des comptes démo différents.
///
/// `null` (pas encore de fiche créée) est traduit en fiche "vide" ici,
/// pour que le reste de l'UI (dashboard, wizard) n'ait qu'un seul cas à
/// gérer : `estVide == true` → état nonSoumise / formulaire vierge.
final maFicheProvider = FutureProvider.autoDispose<FicheGrossiste>((ref) async {
  final session = ref.watch(currentSessionProvider);
  final fiche = await ref
      .watch(grossisteRepositoryProvider)
      .maFiche(emailCompte: session?.email);
  return fiche ??
      const FicheGrossiste(
        id: "",
        statutVerification: FicheVerificationStatut.enAttente,
      );
});

final ficheDocumentsProvider = FutureProvider.family
    .autoDispose<List<DocumentVerification>, String>((ref, ficheId) {
      return ref.watch(grossisteRepositoryProvider).listerDocuments(ficheId);
    });

final ficheProduits = FutureProvider.family
    .autoDispose<List<ProduitGrossiste>, String>((ref, ficheId) {
      return ref.watch(grossisteRepositoryProvider).listerProduits(ficheId);
    });

final ficheStatistiquesProvider = FutureProvider.family
    .autoDispose<FicheStatistiques, String>((ref, ficheId) {
      return ref
          .watch(grossisteRepositoryProvider)
          .consulterStatistiques(ficheId);
    });

/// Widgets choisis par le grossiste pour son dashboard — tous activés
/// par défaut.
final grossisteEnabledWidgetsProvider =
    FutureProvider.autoDispose<Set<GrossisteDashboardWidget>>((ref) async {
      final stored = await ref
          .watch(dashboardWidgetPreferencesStorageProvider)
          .read(GrossisteDashboardWidget.dashboardId);
      if (stored == null) return GrossisteDashboardWidget.all;
      return GrossisteDashboardWidget.values
          .where((w) => stored.contains(w.name))
          .toSet();
    });

Future<void> saveGrossisteEnabledWidgets(
  WidgetRef ref,
  Set<GrossisteDashboardWidget> widgets,
) async {
  await ref
      .read(dashboardWidgetPreferencesStorageProvider)
      .write(
        GrossisteDashboardWidget.dashboardId,
        widgets.map((w) => w.name).toSet(),
      );
  ref.invalidate(grossisteEnabledWidgetsProvider);
}
