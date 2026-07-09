import "../models/document_verification_model.dart";
import "../models/fiche_grossiste_model.dart";
import "../models/produit_grossiste_model.dart";

abstract class GrossisteDatasource {
  Future<FicheGrossisteModel> maFiche({String? emailCompte});

  Future<FicheGrossisteModel> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  });

  Future<DocumentVerificationModel> ajouterDocument({
    required String ficheId,
    required String typeDocument,
    required String urlDocument,
  });

  Future<List<DocumentVerificationModel>> listerDocuments(String ficheId);

  Future<ProduitGrossisteModel> ajouterProduit({
    required String ficheId,
    required Map<String, dynamic> donnees,
  });

  Future<ProduitGrossisteModel> modifierProduit({
    required String ficheId,
    required String produitId,
    required Map<String, dynamic> donnees,
  });

  Future<List<ProduitGrossisteModel>> listerProduits(String ficheId);
}
