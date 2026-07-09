import "../../domain/entities/document_verification.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../../domain/entities/produit_grossite.dart";
import "../../domain/repositories/grossiste_repository.dart";
import "../datasources/grossiste_datasource.dart";
import "../datasources/grossiste_mock_datasource.dart";

class GrossisteRepositoryImpl implements GrossisteRepository {
  const GrossisteRepositoryImpl(this._datasource);

  final GrossisteDatasource _datasource;

  @override
  Future<FicheGrossiste> maFiche({String? emailCompte}) async {
    final model = await _datasource.maFiche(emailCompte: emailCompte);
    return model.toEntity();
  }

  @override
  Future<FicheGrossiste> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  }) async {
    final model = await _datasource.mettreAJourFiche(
      ficheId: ficheId,
      donnees: donnees,
    );
    return model.toEntity();
  }

  @override
  Future<DocumentVerification> ajouterDocument({
    required String ficheId,
    required String typeDocument,
    required String urlDocument,
  }) async {
    final model = await _datasource.ajouterDocument(
      ficheId: ficheId,
      typeDocument: typeDocument,
      urlDocument: urlDocument,
    );
    return model.toEntity();
  }

  @override
  Future<List<DocumentVerification>> listerDocuments(String ficheId) async {
    final models = await _datasource.listerDocuments(ficheId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProduitGrossiste> ajouterProduit({
    required String ficheId,
    required Map<String, dynamic> donnees,
  }) async {
    final model = await _datasource.ajouterProduit(
      ficheId: ficheId,
      donnees: donnees,
    );
    return model.toEntity();
  }

  @override
  Future<ProduitGrossiste> modifierProduit({
    required String ficheId,
    required String produitId,
    required Map<String, dynamic> donnees,
  }) async {
    final model = await _datasource.modifierProduit(
      ficheId: ficheId,
      produitId: produitId,
      donnees: donnees,
    );
    return model.toEntity();
  }

  @override
  Future<List<ProduitGrossiste>> listerProduits(String ficheId) async {
    final models = await _datasource.listerProduits(ficheId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FicheGrossiste> payerAbonnement(String ficheId) async {
    // Promotion de type Dart — plus besoin de cast explicite.
    // TODO(backend): brancher sur le vrai endpoint de paiement une fois
    // le domaine Paiements développé côté backend.
    final datasource = _datasource;
    if (datasource is GrossisteMockDatasource) {
      final model = await datasource.payerAbonnement(ficheId);
      return model.toEntity();
    }
    throw UnimplementedError(
      "payerAbonnement non encore implémenté côté remote.",
    );
  }
}
