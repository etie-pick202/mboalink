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
import "../../domain/entities/produit_grossite.dart";
import "../../domain/repositories/grossiste_repository.dart";

final grossisteDatasourceProvider = Provider<GrossisteDatasource>((ref) {
  if (AppConfig.useMockData) {
    return GrossisteMockDatasource();
  }
  return GrossisteRemoteDatasource(buildDioClient());
});

final grossisteRepositoryProvider = Provider<GrossisteRepository>((ref) {
  return GrossisteRepositoryImpl(ref.watch(grossisteDatasourceProvider));
});

/// Fiche du grossiste connecté. Le mock sélectionne le bon scénario de
/// démonstration selon l'email de la session active — permet de tester
/// tous les statuts (vide, en attente, rejetée, validée, suspendue) en
/// se connectant simplement avec des comptes démo différents.
final maFicheProvider = FutureProvider.autoDispose<FicheGrossiste>((ref) {
  final session = ref.watch(currentSessionProvider);
  return ref
      .watch(grossisteRepositoryProvider)
      .maFiche(emailCompte: session?.email);
});

final ficheDocumentsProvider = FutureProvider.family
    .autoDispose<List<DocumentVerification>, String>((ref, ficheId) {
      return ref.watch(grossisteRepositoryProvider).listerDocuments(ficheId);
    });

final ficheProduits = FutureProvider.family
    .autoDispose<List<ProduitGrossiste>, String>((ref, ficheId) {
      return ref.watch(grossisteRepositoryProvider).listerProduits(ficheId);
    });
