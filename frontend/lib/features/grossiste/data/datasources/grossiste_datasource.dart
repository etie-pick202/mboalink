import "../models/document_verification_model.dart";
import "../models/fiche_grossiste_model.dart";
import "../models/produit_grossiste_model.dart";

abstract class GrossisteDatasource {
  /// Fiche du grossiste connecté, ou null si aucune fiche n'a encore été
  /// créée (nouveau compte, wizard "Créer ma fiche" jamais complété).
  Future<FicheGrossisteModel?> maFiche({String? emailCompte});

  /// Crée la fiche du grossiste connecté (volet 1 du wizard). POST /grossistes.
  Future<FicheGrossisteModel> creerFiche(Map<String, dynamic> donnees);

  Future<FicheGrossisteModel> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  });

  /// Envoie un document de vérification (RCCM, CNI…) : upload réel vers
  /// Supabase Storage via URL signée, puis confirmation côté backend.
  Future<DocumentVerificationModel> uploaderDocument({
    required String ficheId,
    required String typeDocument,
    required String extension,
    required List<int> bytes,
  });

  Future<List<DocumentVerificationModel>> listerDocuments(String ficheId);

  Future<FicheGrossisteModel> uploaderLogo({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  });

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

  Future<void> supprimerProduit({
    required String ficheId,
    required String produitId,
  });

  Future<String> uploaderPhotoProduit({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  });

  Future<Map<String, dynamic>> consulterStatistiques(String ficheId);
}
