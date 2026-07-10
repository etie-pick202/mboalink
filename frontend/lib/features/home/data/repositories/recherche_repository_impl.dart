import "../../domain/entities/contact_debloque.dart";
import "../../domain/entities/fiche_publique.dart";
import "../../domain/entities/grossiste_resume.dart";
import "../../domain/repositories/recherche_repository.dart";
import "../datasources/recherche_remote_datasource.dart";

class RechercheRepositoryImpl implements RechercheRepository {
  const RechercheRepositoryImpl(this._datasource);

  final RechercheRemoteDatasource _datasource;

  @override
  Future<PageResultat<GrossisteResume>> filActualite({
    double? latitude,
    double? longitude,
    int page = 0,
    int taille = 10,
  }) async {
    final result = await _datasource.filActualite(
      latitude: latitude,
      longitude: longitude,
      page: page,
      taille: taille,
    );
    return PageResultat(
      resultats: result.resultats.map((m) => m.toEntity()).toList(),
      totalElements: result.totalElements,
      page: result.page,
      dernierePage: result.dernierePage,
    );
  }

  @override
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
  }) async {
    final result = await _datasource.rechercherGrossistes(
      motCle: motCle,
      ville: ville,
      categorie: categorie,
      prixMin: prixMin,
      prixMax: prixMax,
      certifie: certifie,
      certifiePremium: certifiePremium,
      tri: tri,
      page: page,
      taille: taille,
    );
    return PageResultat(
      resultats: result.resultats.map((m) => m.toEntity()).toList(),
      totalElements: result.totalElements,
      page: result.page,
      dernierePage: result.dernierePage,
    );
  }

  @override
  Future<List<String>> listerVilles() => _datasource.listerVilles();

  @override
  Future<List<String>> listerSecteurs() => _datasource.listerSecteurs();

  @override
  Future<List<String>> listerCategories() => _datasource.listerCategories();

  @override
  Future<FichePublique> consulterFiche(String ficheId) async {
    final model = await _datasource.consulterFiche(ficheId);
    return model.toEntity();
  }

  @override
  Future<bool> estDeverrouille(String ficheId) =>
      _datasource.estDeverrouille(ficheId);

  @override
  Future<CoordonneesDeverrouillees> deverrouiller({
    required String ficheId,
    required String transactionId,
    required double montantPaye,
  }) async {
    final json = await _datasource.deverrouiller(
      ficheId: ficheId,
      transactionId: transactionId,
      montantPaye: montantPaye,
    );
    return CoordonneesDeverrouillees(
      nomEntreprise: json["nomEntreprise"] as String? ?? "",
      telephoneProfessionnel: json["telephoneProfessionnel"] as String?,
      emailProfessionnel: json["emailProfessionnel"] as String?,
    );
  }

  @override
  Future<void> enregistrerVueFiche(String ficheId) =>
      _datasource.enregistrerVueFiche(ficheId);

  @override
  Future<bool> estFavori(String ficheId) => _datasource.estFavori(ficheId);

  @override
  Future<void> ajouterFavori(String ficheId) =>
      _datasource.ajouterFavori(ficheId);

  @override
  Future<void> retirerFavori(String ficheId) =>
      _datasource.retirerFavori(ficheId);

  @override
  Future<List<GrossisteResume>> mesFavoris() async {
    final models = await _datasource.mesFavoris();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ContactDebloque>> mesDeverrouillages() async {
    final list = await _datasource.mesDeverrouillages();
    return list
        .map(
          (json) => ContactDebloque(
            ficheGrossisteId: json["ficheGrossisteId"] as String,
            nomEntreprise: json["nomEntreprise"] as String? ?? "",
            secteurActivite: json["secteurActivite"] as String?,
            ville: json["ville"] as String?,
            logoUrl: json["logoUrl"] as String?,
            telephoneProfessionnel: json["telephoneProfessionnel"] as String?,
            emailProfessionnel: json["emailProfessionnel"] as String?,
            deverrouilleLe: DateTime.parse(json["deverrouilleLe"] as String),
            encoreValide: json["encoreValide"] as bool? ?? false,
            referenceTransaction: json["referenceTransaction"] as String?,
          ),
        )
        .toList();
  }
}
