import "../entities/document_verification.dart";
import "../entities/fiche_grossiste.dart";
import "../entities/fiche_statistiques.dart";
import "../entities/produit_grossite.dart";

abstract class GrossisteRepository {
  /// Fiche du grossiste connecté, ou null si aucune fiche n'a encore été
  /// créée (nouveau compte, wizard "Créer ma fiche" jamais complété).
  Future<FicheGrossiste?> maFiche({String? emailCompte});

  /// Crée la fiche du grossiste connecté (volet 1 du wizard).
  Future<FicheGrossiste> creerFiche(Map<String, dynamic> donnees);

  Future<FicheGrossiste> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  });

  /// Envoie un document de vérification (RCCM, CNI…) : upload réel vers
  /// Supabase Storage via URL signée, puis confirmation côté backend.
  Future<DocumentVerification> uploaderDocument({
    required String ficheId,
    required String typeDocument,
    required String extension,
    required List<int> bytes,
  });

  Future<List<DocumentVerification>> listerDocuments(String ficheId);

  /// Upload réel du logo/photo de profil vers Supabase Storage, puis
  /// écrit l'URL finale sur FicheGrossiste.logoUrl (PATCH .../logo).
  Future<FicheGrossiste> uploaderLogo({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  });

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

  Future<void> supprimerProduit({
    required String ficheId,
    required String produitId,
  });

  /// Upload une photo produit vers Supabase Storage et renvoie son URL
  /// publique finale (à inclure dans ajouterProduit/modifierProduit).
  Future<String> uploaderPhotoProduit({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  });

  Future<FicheStatistiques> consulterStatistiques(String ficheId);
}
