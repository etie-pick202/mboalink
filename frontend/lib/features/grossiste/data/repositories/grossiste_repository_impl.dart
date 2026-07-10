import "../../domain/entities/document_verification.dart";
import "../../domain/entities/fiche_grossiste.dart";
import "../../domain/entities/fiche_statistiques.dart";
import "../../domain/entities/produit_grossite.dart";
import "../../domain/repositories/grossiste_repository.dart";
import "../datasources/grossiste_datasource.dart";

class GrossisteRepositoryImpl implements GrossisteRepository {
  const GrossisteRepositoryImpl(this._datasource);

  final GrossisteDatasource _datasource;

  @override
  Future<FicheGrossiste?> maFiche({String? emailCompte}) async {
    final model = await _datasource.maFiche(emailCompte: emailCompte);
    return model?.toEntity();
  }

  @override
  Future<FicheGrossiste> creerFiche(Map<String, dynamic> donnees) async {
    final model = await _datasource.creerFiche(donnees);
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
  Future<DocumentVerification> uploaderDocument({
    required String ficheId,
    required String typeDocument,
    required String extension,
    required List<int> bytes,
  }) async {
    final model = await _datasource.uploaderDocument(
      ficheId: ficheId,
      typeDocument: typeDocument,
      extension: extension,
      bytes: bytes,
    );
    return model.toEntity();
  }

  @override
  Future<List<DocumentVerification>> listerDocuments(String ficheId) async {
    final models = await _datasource.listerDocuments(ficheId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FicheGrossiste> uploaderLogo({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  }) async {
    final model = await _datasource.uploaderLogo(
      ficheId: ficheId,
      extension: extension,
      bytes: bytes,
    );
    return model.toEntity();
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
  Future<void> supprimerProduit({
    required String ficheId,
    required String produitId,
  }) => _datasource.supprimerProduit(ficheId: ficheId, produitId: produitId);

  @override
  Future<String> uploaderPhotoProduit({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  }) => _datasource.uploaderPhotoProduit(
    ficheId: ficheId,
    extension: extension,
    bytes: bytes,
  );

  @override
  Future<FicheStatistiques> consulterStatistiques(String ficheId) async {
    final json = await _datasource.consulterStatistiques(ficheId);
    return FicheStatistiques(
      vuesMoisEnCours: json["vuesMoisEnCours"] as int? ?? 0,
      contactsDebloques: json["contactsDebloques"] as int? ?? 0,
      vuesParJour:
          (json["vuesParJour"] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          List.filled(7, 0),
    );
  }
}
