import "../entities/contact_debloque.dart";
import "../entities/fiche_publique.dart";
import "../entities/grossiste_resume.dart";

class PageResultat<T> {
  const PageResultat({
    required this.resultats,
    required this.totalElements,
    required this.page,
    required this.dernierePage,
  });

  final List<T> resultats;
  final int totalElements;
  final int page;
  final bool dernierePage;
}

abstract class RechercheRepository {
  Future<PageResultat<GrossisteResume>> filActualite({
    double? latitude,
    double? longitude,
    int page = 0,
    int taille = 10,
  });

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
  });

  Future<List<String>> listerVilles();

  Future<List<String>> listerSecteurs();

  Future<List<String>> listerCategories();

  Future<FichePublique> consulterFiche(String ficheId);

  Future<bool> estDeverrouille(String ficheId);

  /// Récupère les coordonnées (téléphone/email) après un paiement réussi
  /// (transactionId d'une transaction DEVERROUILLAGE_COORDONNEES SUCCES).
  /// Si déjà déverrouillé (< 24h), renvoie directement les coordonnées
  /// sans revalider la transaction.
  Future<CoordonneesDeverrouillees> deverrouiller({
    required String ficheId,
    required String transactionId,
    required double montantPaye,
  });

  /// Enregistre un événement "vue de fiche" (POST /comportement/evenement)
  /// — alimente le score de popularité côté backend. Best-effort : une
  /// erreur ici ne doit jamais bloquer l'affichage de la fiche.
  Future<void> enregistrerVueFiche(String ficheId);

  Future<bool> estFavori(String ficheId);

  Future<void> ajouterFavori(String ficheId);

  Future<void> retirerFavori(String ficheId);

  Future<List<GrossisteResume>> mesFavoris();

  /// Écran "Contacts débloqués" — historique des fiches déverrouillées
  /// par l'utilisateur, y compris hors fenêtre de validité 24h.
  Future<List<ContactDebloque>> mesDeverrouillages();
}
