import "../entities/document_verification.dart";
import "../entities/fiche_grossiste.dart";
import "../entities/produit_grossite.dart";

abstract class GrossisteRepository {
  Future<FicheGrossiste> maFiche({String? emailCompte});

  Future<FicheGrossiste> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  });

  Future<DocumentVerification> ajouterDocument({
    required String ficheId,
    required String typeDocument,
    required String urlDocument,
  });

  Future<List<DocumentVerification>> listerDocuments(String ficheId);

  Future<ProduitGrossiste> ajouterProduit({
    required String ficheId,
    required Map<String, dynamic> donnees,
  });

  Future<ProduitGrossiste> modifierProduit({
    required String ficheId,
    required String produitId,
    required Map<String, dynamic> donnees,
  });

  Future<List<ProduitGrossiste>> listerProduits(String ficheId);

  /// Active l'abonnement après paiement Mobile Money.
  /// TODO(backend): brancher sur le vrai endpoint de paiement une fois
  /// le domaine Paiements développé côté backend.
  Future<FicheGrossiste> payerAbonnement(String ficheId);
}
