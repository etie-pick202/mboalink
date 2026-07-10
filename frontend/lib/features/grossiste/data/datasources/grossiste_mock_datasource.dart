import "../../../../core/errors/app_exception.dart";
import "../models/document_verification_model.dart";
import "../models/fiche_grossiste_model.dart";
import "../models/produit_grossiste_model.dart";
import "grossiste_datasource.dart";

/// Implémentation mock — 6 scénarios de démonstration couvrant tous les
/// états possibles du tableau de bord Grossiste, y compris le nouvel état
/// "en attente d'abonnement" (documents validés, paiement non effectué).
class GrossisteMockDatasource implements GrossisteDatasource {
  static const _delay = Duration(milliseconds: 500);

  int _sequence = 0;

  final Map<String, FicheGrossisteModel> _fichesById = {
    "demo-fiche-vide": const FicheGrossisteModel(
      id: "demo-fiche-vide",
      statutVerification: "EN_ATTENTE",
      aAbonnementActif: false,
    ),
    "demo-fiche-attente": const FicheGrossisteModel(
      id: "demo-fiche-attente",
      statutVerification: "EN_ATTENTE",
      aAbonnementActif: false,
      nomEntreprise: "Kana Distribution",
      description: "Grossiste en produits d'hygiène et cosmétiques",
      secteurActivite: "Cosmétique",
      ville: "Yaoundé",
      quartier: "Mvog-Mbi",
      adresseComplete: "Carrefour Mvog-Mbi, immeuble bleu",
      telephoneProfessionnel: "+237677001122",
      emailProfessionnel: "contact@kana-distribution.cm",
      logoUrl: "mock://logo-kana.jpg",
    ),
    "demo-fiche-rejete": const FicheGrossisteModel(
      id: "demo-fiche-rejete",
      statutVerification: "REJETE",
      aAbonnementActif: false,
      nomEntreprise: "Sané Cosmetics",
      description: "Cosmétiques en gros",
      secteurActivite: "Cosmétique",
      ville: "Douala",
      quartier: "Akwa",
      adresseComplete: "Rue Joss, immeuble 4",
      telephoneProfessionnel: "+237655223344",
      emailProfessionnel: "sane@cosmetics.cm",
      logoUrl: "mock://logo-sane.jpg",
    ),
    // Nouveau scénario : documents validés par l'admin, abonnement pas
    // encore payé — seul l'onglet Profil (paiement) est accessible.
    "demo-fiche-abonnement": const FicheGrossisteModel(
      id: "demo-fiche-abonnement",
      statutVerification: "VERIFIE",
      aAbonnementActif: false,
      nomEntreprise: "Essomba Négoce",
      description: "Négoce alimentaire en gros — Bafoussam",
      secteurActivite: "Alimentation",
      ville: "Bafoussam",
      quartier: "Djeleng",
      adresseComplete: "Marché B, hangar 5",
      telephoneProfessionnel: "+237677334455",
      emailProfessionnel: "essomba@negoce.cm",
      logoUrl: "mock://logo-essomba.jpg",
    ),
    "demo-fiche-valide": const FicheGrossisteModel(
      id: "demo-fiche-valide",
      statutVerification: "VERIFIE",
      aAbonnementActif: true,
      nomEntreprise: "Ets Tchana & Fils",
      description:
          "Grossiste leader en vivres frais et produits locaux du marché de Mboppi.",
      secteurActivite: "Alimentation",
      ville: "Douala",
      quartier: "Mboppi",
      adresseComplete: "Marché Mboppi, hangar 12",
      telephoneProfessionnel: "+237699112233",
      emailProfessionnel: "tchana@ets.cm",
      logoUrl: "mock://logo-tchana.jpg",
    ),
    "demo-fiche-suspendu": const FicheGrossisteModel(
      id: "demo-fiche-suspendu",
      statutVerification: "SUSPENDU",
      aAbonnementActif: false,
      nomEntreprise: "Mballa Textiles",
      description: "Grossiste en tissus et prêt-à-porter",
      secteurActivite: "Textile",
      ville: "Douala",
      quartier: "New-Bell",
      adresseComplete: "Marché New-Bell, allée 3",
      telephoneProfessionnel: "+237690556677",
      emailProfessionnel: "mballa@textiles.cm",
      logoUrl: "mock://logo-mballa.jpg",
    ),
  };

  final Map<String, String> _ficheIdByEmail = {
    "demo.grossiste@mboalink.cm": "demo-fiche-vide",
    "demo.grossiste.attente@mboalink.cm": "demo-fiche-attente",
    "demo.grossiste.rejete@mboalink.cm": "demo-fiche-rejete",
    "demo.grossiste.abonnement@mboalink.cm": "demo-fiche-abonnement",
    "demo.grossiste.valide@mboalink.cm": "demo-fiche-valide",
    "demo.grossiste.suspendu@mboalink.cm": "demo-fiche-suspendu",
  };

  final Map<String, List<DocumentVerificationModel>> _documentsByFicheId = {
    "demo-fiche-rejete": const [
      DocumentVerificationModel(
        id: "doc-rejete-cni",
        typeDocument: "CNI",
        urlDocument: "mock://cni-sane.jpg",
        statut: "REJETE",
        commentaireAdmin:
            "Photo floue, le numéro de CNI est illisible. Merci de renvoyer une photo nette.",
      ),
      DocumentVerificationModel(
        id: "doc-rejete-rccm",
        typeDocument: "RCCM",
        urlDocument: "mock://rccm-sane.jpg",
        statut: "APPROUVE",
      ),
    ],
    "demo-fiche-abonnement": const [
      DocumentVerificationModel(
        id: "doc-abonnement-cni",
        typeDocument: "CNI",
        urlDocument: "mock://cni-essomba.jpg",
        statut: "APPROUVE",
      ),
      DocumentVerificationModel(
        id: "doc-abonnement-rccm",
        typeDocument: "RCCM",
        urlDocument: "mock://rccm-essomba.jpg",
        statut: "APPROUVE",
      ),
    ],
    "demo-fiche-valide": const [
      DocumentVerificationModel(
        id: "doc-valide-cni",
        typeDocument: "CNI",
        urlDocument: "mock://cni-tchana.jpg",
        statut: "APPROUVE",
      ),
      DocumentVerificationModel(
        id: "doc-valide-rccm",
        typeDocument: "RCCM",
        urlDocument: "mock://rccm-tchana.jpg",
        statut: "APPROUVE",
      ),
    ],
  };

  final Map<String, List<ProduitGrossisteModel>> _produitsByFicheId = {
    "demo-fiche-valide": [
      ProduitGrossisteModel(
        id: "pr-tchana-tomate",
        ficheGrossisteId: "demo-fiche-valide",
        nom: "Tomate fraîche",
        description: "Tomates grappes, cagettes de 3 kg",
        categorie: "Fruits et légumes",
        prixUnitaire: 1200,
        quantiteMinimale: 5,
        uniteMesure: "cagette",
        estDisponible: true,
      ),
      ProduitGrossisteModel(
        id: "pr-tchana-oignon",
        ficheGrossisteId: "demo-fiche-valide",
        nom: "Oignon rouge",
        description: "Filet de 5 kg",
        categorie: "Fruits et légumes",
        prixUnitaire: 500,
        quantiteMinimale: 10,
        uniteMesure: "filet",
        estDisponible: true,
      ),
      ProduitGrossisteModel(
        id: "pr-tchana-riz",
        ficheGrossisteId: "demo-fiche-valide",
        nom: "Riz basmati",
        description: "Sacs de 25 kg",
        categorie: "Alimentation de base",
        prixUnitaire: 15500,
        quantiteMinimale: 1,
        uniteMesure: "sac",
        estDisponible: true,
      ),
    ],
  };

  @override
  Future<FicheGrossisteModel?> maFiche({String? emailCompte}) async {
    await Future.delayed(_delay);
    final ficheId = _ficheIdByEmail[emailCompte];
    if (ficheId != null) return _fichesById[ficheId]!;
    final newId = "fiche-auto-${++_sequence}";
    final fiche = FicheGrossisteModel(
      id: newId,
      statutVerification: "EN_ATTENTE",
    );
    _fichesById[newId] = fiche;
    if (emailCompte != null) _ficheIdByEmail[emailCompte] = newId;
    return fiche;
  }

  @override
  Future<FicheGrossisteModel> creerFiche(Map<String, dynamic> donnees) async {
    await Future.delayed(_delay);
    final newId = "fiche-auto-${++_sequence}";
    final fiche = FicheGrossisteModel(
      id: newId,
      statutVerification: "EN_ATTENTE",
      nomEntreprise: donnees["nomEntreprise"] as String?,
      description: donnees["description"] as String?,
      secteurActivite: donnees["secteurActivite"] as String?,
      ville: donnees["ville"] as String?,
      quartier: donnees["quartier"] as String?,
      adresseComplete: donnees["adresseComplete"] as String?,
      telephoneProfessionnel: donnees["telephoneProfessionnel"] as String?,
      emailProfessionnel: donnees["emailProfessionnel"] as String?,
      siteWeb: donnees["siteWeb"] as String?,
      logoUrl: donnees["logoUrl"] as String?,
    );
    _fichesById[newId] = fiche;
    return fiche;
  }

  @override
  Future<FicheGrossisteModel> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  }) async {
    await Future.delayed(_delay);
    final current = _fichesById[ficheId];
    final updated = FicheGrossisteModel(
      id: ficheId,
      statutVerification: current?.statutVerification ?? "EN_ATTENTE",
      aAbonnementActif: current?.aAbonnementActif ?? false,
      nomEntreprise:
          donnees["nomEntreprise"] as String? ?? current?.nomEntreprise,
      description: donnees["description"] as String? ?? current?.description,
      secteurActivite:
          donnees["secteurActivite"] as String? ?? current?.secteurActivite,
      ville: donnees["ville"] as String? ?? current?.ville,
      quartier: donnees["quartier"] as String? ?? current?.quartier,
      adresseComplete:
          donnees["adresseComplete"] as String? ?? current?.adresseComplete,
      telephoneProfessionnel:
          donnees["telephoneProfessionnel"] as String? ??
          current?.telephoneProfessionnel,
      emailProfessionnel:
          donnees["emailProfessionnel"] as String? ??
          current?.emailProfessionnel,
      siteWeb: donnees["siteWeb"] as String? ?? current?.siteWeb,
      logoUrl: donnees["logoUrl"] as String? ?? current?.logoUrl,
    );
    _fichesById[ficheId] = updated;
    return updated;
  }

  @override
  Future<DocumentVerificationModel> uploaderDocument({
    required String ficheId,
    required String typeDocument,
    required String extension,
    required List<int> bytes,
  }) async {
    await Future.delayed(_delay);

    // Reflète le comportement backend : une fiche rejetée qui reçoit un
    // nouveau document repasse en attente.
    final current = _fichesById[ficheId];
    if (current != null && current.statutVerification == "REJETE") {
      _fichesById[ficheId] = FicheGrossisteModel(
        id: current.id,
        statutVerification: "EN_ATTENTE",
        aAbonnementActif: current.aAbonnementActif,
        nomEntreprise: current.nomEntreprise,
        description: current.description,
        secteurActivite: current.secteurActivite,
        ville: current.ville,
        quartier: current.quartier,
        adresseComplete: current.adresseComplete,
        telephoneProfessionnel: current.telephoneProfessionnel,
        emailProfessionnel: current.emailProfessionnel,
        siteWeb: current.siteWeb,
        logoUrl: current.logoUrl,
      );
    }

    final doc = DocumentVerificationModel(
      id: "doc-${++_sequence}",
      typeDocument: typeDocument,
      urlDocument: "mock://document-${bytes.length}-bytes.$extension",
      statut: "EN_ATTENTE",
    );
    // Upsert par type — un document déjà soumis pour ce type est remplacé
    // plutôt que dupliqué (mêmes règles que le backend réel).
    final documents = _documentsByFicheId.putIfAbsent(ficheId, () => []);
    documents.removeWhere((d) => d.typeDocument == typeDocument);
    documents.add(doc);
    return doc;
  }

  @override
  Future<List<DocumentVerificationModel>> listerDocuments(
    String ficheId,
  ) async {
    await Future.delayed(_delay);
    return List.unmodifiable(_documentsByFicheId[ficheId] ?? const []);
  }

  @override
  Future<FicheGrossisteModel> uploaderLogo({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  }) async {
    await Future.delayed(_delay);
    final current = _fichesById[ficheId];
    if (current == null) {
      throw const AppException("Fiche introuvable.", statusCode: 404);
    }
    final updated = FicheGrossisteModel(
      id: current.id,
      statutVerification: current.statutVerification,
      aAbonnementActif: current.aAbonnementActif,
      nomEntreprise: current.nomEntreprise,
      description: current.description,
      secteurActivite: current.secteurActivite,
      ville: current.ville,
      quartier: current.quartier,
      adresseComplete: current.adresseComplete,
      telephoneProfessionnel: current.telephoneProfessionnel,
      emailProfessionnel: current.emailProfessionnel,
      siteWeb: current.siteWeb,
      logoUrl: "mock://logo-${bytes.length}-bytes.$extension",
      certifiePremium: current.certifiePremium,
      noteMoyenne: current.noteMoyenne,
      nombreAvis: current.nombreAvis,
    );
    _fichesById[ficheId] = updated;
    return updated;
  }

  @override
  Future<ProduitGrossisteModel> ajouterProduit({
    required String ficheId,
    required Map<String, dynamic> donnees,
  }) async {
    await Future.delayed(_delay);
    final produit = ProduitGrossisteModel(
      id: "produit-${++_sequence}",
      ficheGrossisteId: ficheId,
      nom: donnees["nom"] as String,
      description: donnees["description"] as String?,
      categorie: donnees["categorie"] as String?,
      prixUnitaire: donnees["prixUnitaire"] as double?,
      quantiteMinimale: donnees["quantiteMinimale"] as double?,
      uniteMesure: donnees["uniteMesure"] as String?,
      imageUrl: donnees["imageUrl"] as String?,
      estDisponible: donnees["estDisponible"] as bool? ?? true,
    );
    _produitsByFicheId.putIfAbsent(ficheId, () => []).add(produit);
    return produit;
  }

  @override
  Future<ProduitGrossisteModel> modifierProduit({
    required String ficheId,
    required String produitId,
    required Map<String, dynamic> donnees,
  }) async {
    await Future.delayed(_delay);
    final index = _produitsByFicheId[ficheId]?.indexWhere(
      (p) => p.id == produitId,
    );
    if (index == null || index == -1) throw Exception("Produit non trouvé");
    final current = _produitsByFicheId[ficheId]![index];
    final updated = ProduitGrossisteModel(
      id: current.id,
      ficheGrossisteId: current.ficheGrossisteId,
      nom: donnees["nom"] as String? ?? current.nom,
      description: donnees["description"] as String? ?? current.description,
      categorie: donnees["categorie"] as String? ?? current.categorie,
      prixUnitaire: donnees["prixUnitaire"] as double? ?? current.prixUnitaire,
      quantiteMinimale:
          donnees["quantiteMinimale"] as double? ?? current.quantiteMinimale,
      uniteMesure: donnees["uniteMesure"] as String? ?? current.uniteMesure,
      imageUrl: donnees["imageUrl"] as String? ?? current.imageUrl,
      estDisponible: donnees["estDisponible"] as bool? ?? current.estDisponible,
    );
    _produitsByFicheId[ficheId]![index] = updated;
    return updated;
  }

  @override
  Future<List<ProduitGrossisteModel>> listerProduits(String ficheId) async {
    await Future.delayed(_delay);
    return List.unmodifiable(_produitsByFicheId[ficheId] ?? []);
  }

  @override
  Future<String> uploaderPhotoProduit({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  }) async {
    await Future.delayed(_delay);
    return "mock://produit-${bytes.length}-bytes.$extension";
  }

  @override
  Future<void> supprimerProduit({
    required String ficheId,
    required String produitId,
  }) async {
    await Future.delayed(_delay);
    _produitsByFicheId[ficheId]?.removeWhere((p) => p.id == produitId);
  }

  @override
  Future<Map<String, dynamic>> consulterStatistiques(String ficheId) async {
    await Future.delayed(_delay);
    return {
      "vuesMoisEnCours": 214,
      "contactsDebloques": 12,
      "vuesParJour": [4, 9, 6, 12, 8, 15, 18],
    };
  }
}
