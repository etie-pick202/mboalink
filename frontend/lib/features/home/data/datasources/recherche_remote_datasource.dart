import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";
import "../models/fiche_publique_model.dart";
import "../models/grossiste_resume_model.dart";

class PageJson<T> {
  const PageJson({
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

/// Endpoints publics de recherche (/api/v1/search/**) et de consultation
/// de fiche (/api/v1/grossistes/**), tous confirmés existants côté
/// backend (domaine développé pour Personne 3).
class RechercheRemoteDatasource {
  const RechercheRemoteDatasource(this._dio);

  final Dio _dio;

  Future<PageJson<GrossisteResumeModel>> filActualite({
    double? latitude,
    double? longitude,
    int page = 0,
    int taille = 10,
  }) async {
    final json = await _get("/search/fil-actualite", {
      "latitudeUtilisateur": ?latitude,
      "longitudeUtilisateur": ?longitude,
      "page": page,
      "taille": taille,
    });
    return _toPage(json, GrossisteResumeModel.fromJson);
  }

  Future<PageJson<GrossisteResumeModel>> rechercherGrossistes({
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
    final json = await _get("/search/grossistes", {
      if (motCle != null && motCle.isNotEmpty) "motCle": motCle,
      "ville": ?ville,
      "categorie": ?categorie,
      "prixMin": ?prixMin,
      "prixMax": ?prixMax,
      "certifie": ?certifie,
      "certifiePremium": ?certifiePremium,
      "tri": tri,
      "page": page,
      "taille": taille,
    });
    return _toPage(json, GrossisteResumeModel.fromJson);
  }

  Future<List<String>> listerVilles() => _getStringList("/search/villes");

  Future<List<String>> listerSecteurs() => _getStringList("/search/secteurs");

  Future<List<String>> listerCategories() async {
    final list = await _getListRaw("/search/categories");
    return list
        .cast<Map<String, dynamic>>()
        .map((c) => c["nom"] as String)
        .toList();
  }

  Future<FichePubliqueModel> consulterFiche(String ficheId) async {
    final json = await _get("/grossistes/$ficheId", const {});
    return FichePubliqueModel.fromJson(json);
  }

  Future<bool> estDeverrouille(String ficheId) async {
    final json = await _get("/grossistes/$ficheId/deverrouille", const {});
    return json["deverrouille"] as bool? ?? false;
  }

  Future<Map<String, dynamic>> deverrouiller({
    required String ficheId,
    required String transactionId,
    required double montantPaye,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        "/grossistes/$ficheId/deverrouiller",
        data: {"transactionId": transactionId, "montantPaye": montantPaye},
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> enregistrerVueFiche(String ficheId) async {
    try {
      await _dio.post<void>(
        "/comportement/evenement",
        data: {"typeAction": "VUE_FICHE", "valeur": ficheId},
      );
    } on DioException {
      // Best-effort — le score de popularité n'est pas critique pour
      // l'affichage de la fiche.
    }
  }

  Future<bool> estFavori(String ficheId) async {
    final json = await _get("/favoris/$ficheId/statut", const {});
    return json["estFavori"] as bool? ?? false;
  }

  Future<void> ajouterFavori(String ficheId) async {
    try {
      await _dio.post<void>("/favoris/$ficheId");
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> retirerFavori(String ficheId) async {
    try {
      await _dio.delete<void>("/favoris/$ficheId");
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<List<GrossisteResumeModel>> mesFavoris() async {
    final list = await _getListRaw("/favoris");
    return list
        .cast<Map<String, dynamic>>()
        .map(GrossisteResumeModel.fromJson)
        .toList();
  }

  Future<List<Map<String, dynamic>>> mesDeverrouillages() async {
    final list = await _getListRaw("/grossistes/mes-deverrouillages");
    return list.cast<Map<String, dynamic>>();
  }

  PageJson<T> _toPage<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final resultats = (json["resultats"] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    return PageJson(
      resultats: resultats,
      totalElements: json["totalElements"] as int? ?? resultats.length,
      page: json["page"] as int? ?? 0,
      dernierePage: json["dernierePage"] as bool? ?? true,
    );
  }

  Future<List<String>> _getStringList(String path) async {
    final list = await _getListRaw(path);
    return list.cast<String>();
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query.isEmpty ? null : query,
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<List<dynamic>> _getListRaw(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      return response.data ?? const [];
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  AppException _toAppException(DioException e) {
    final body = e.response?.data;
    final statusCode = e.response?.statusCode;
    if (body is Map<String, dynamic> && body["message"] is String) {
      return AppException(body["message"] as String, statusCode: statusCode);
    }
    return AppException(
      "Une erreur est survenue lors de la communication avec le serveur.",
      statusCode: statusCode,
    );
  }
}
