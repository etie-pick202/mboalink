import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";
import "../models/document_verification_model.dart";
import "../models/fiche_grossiste_model.dart";
import "../models/produit_grossiste_model.dart";
import "grossiste_datasource.dart";

/// Implémentation réelle — endpoints confirmés via Postman + entités
/// backend (domaine grossiste, développé par Aurelie).
class GrossisteRemoteDatasource implements GrossisteDatasource {
  const GrossisteRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<FicheGrossisteModel> maFiche({String? emailCompte}) async {
    // emailCompte n'est utile qu'au mock (sélection de scénario) — le
    // backend identifie l'utilisateur via le token Bearer.
    // TODO(backend): endpoint à confirmer avec Aurelie. Hypothèse actuelle :
    // GET /grossistes/me — à ajuster dès que le vrai contrat est fixé
    // (alternative possible : ficheId renvoyé directement par
    // /auth/connexion ou /auth/verifier-otp pour les comptes GROSSISTE).
    final json = await _get("/grossistes/me");
    return FicheGrossisteModel.fromJson(json);
  }

  @override
  Future<FicheGrossisteModel> mettreAJourFiche({
    required String ficheId,
    required Map<String, dynamic> donnees,
  }) async {
    final json = await _put("/grossistes/$ficheId", donnees);
    return FicheGrossisteModel.fromJson(json);
  }

  @override
  Future<DocumentVerificationModel> ajouterDocument({
    required String ficheId,
    required String typeDocument,
    required String urlDocument,
  }) async {
    final json = await _post("/grossistes/$ficheId/documents", {
      "typeDocument": typeDocument,
      "urlDocument": urlDocument,
    });
    return DocumentVerificationModel.fromJson(json);
  }

  @override
  Future<List<DocumentVerificationModel>> listerDocuments(
    String ficheId,
  ) async {
    final list = await _getList("/grossistes/$ficheId/documents");
    return list
        .map(
          (e) => DocumentVerificationModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _get(String path) =>
      _handle(() => _dio.get<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.post<Map<String, dynamic>>(path, data: data));

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.put<Map<String, dynamic>>(path, data: data));

  Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      return response.data ?? const [];
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<Map<String, dynamic>> _handle(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Future<ProduitGrossisteModel> ajouterProduit({
    required String ficheId,
    required Map<String, dynamic> donnees,
  }) async {
    final json = await _post("/grossistes/$ficheId/produits", donnees);
    return ProduitGrossisteModel.fromJson(json);
  }

  @override
  Future<ProduitGrossisteModel> modifierProduit({
    required String ficheId,
    required String produitId,
    required Map<String, dynamic> donnees,
  }) async {
    final json = await _put(
      "/grossistes/$ficheId/produits/$produitId",
      donnees,
    );
    return ProduitGrossisteModel.fromJson(json);
  }

  @override
  Future<List<ProduitGrossisteModel>> listerProduits(String ficheId) async {
    final list = await _getList("/grossistes/$ficheId/produits");
    return list
        .map((e) => ProduitGrossisteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  AppException _toAppException(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic> && body["message"] is String) {
      return AppException(
        body["message"] as String,
        statusCode: e.response?.statusCode,
      );
    }
    return const AppException(
      "Une erreur est survenue lors de la communication avec le serveur.",
    );
  }
}
