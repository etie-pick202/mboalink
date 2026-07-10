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
  Future<FicheGrossisteModel?> maFiche({String? emailCompte}) async {
    // emailCompte n'est utile qu'au mock (sélection de scénario) — le
    // backend identifie l'utilisateur via le token Bearer.
    try {
      final json = await _get("/grossistes/me");
      return FicheGrossisteModel.fromJson(json);
    } on AppException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<FicheGrossisteModel> creerFiche(Map<String, dynamic> donnees) async {
    final json = await _post("/grossistes", donnees);
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
  Future<DocumentVerificationModel> uploaderDocument({
    required String ficheId,
    required String typeDocument,
    required String extension,
    required List<int> bytes,
  }) async {
    // 1. Demander une URL signée Supabase pour ce document.
    final uploadUrlJson = await _post(
      "/grossistes/$ficheId/documents/upload-url",
      {
        "typeDocument": typeDocument,
        "extension": extension,
        "contexte": "grossistes",
      },
    );
    final uploadUrl = uploadUrlJson["uploadUrl"] as String;
    final filePath = uploadUrlJson["filePath"] as String;

    // 2. Uploader le fichier directement vers Supabase — appel isolé, sans
    // le token Bearer MboaLink (inutile et non pertinent pour Supabase) ni
    // le Content-Type JSON par défaut du client partagé.
    try {
      await Dio().put<void>(
        uploadUrl,
        data: bytes,
        options: Options(contentType: _mimeType(extension)),
      );
    } on DioException catch (e) {
      throw AppException(
        "Échec de l'envoi du document. Vérifiez votre connexion et réessayez.",
        statusCode: e.response?.statusCode,
      );
    }

    // 3. Confirmer l'upload côté backend pour enregistrer le document.
    final json = await _post("/grossistes/$ficheId/documents/confirmer", {
      "filePath": filePath,
      "typeDocument": typeDocument,
    });
    return DocumentVerificationModel.fromJson(json);
  }

  @override
  Future<FicheGrossisteModel> uploaderLogo({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  }) async {
    // Réutilise le même endpoint "upload-url" que les documents de
    // vérification (générique sur typeDocument), avec typeDocument=LOGO.
    final uploadUrlJson = await _post(
      "/grossistes/$ficheId/documents/upload-url",
      {
        "typeDocument": "LOGO",
        "extension": extension,
        "contexte": "grossistes",
      },
    );
    final uploadUrl = uploadUrlJson["uploadUrl"] as String;
    final filePath = uploadUrlJson["filePath"] as String;

    try {
      await Dio().put<void>(
        uploadUrl,
        data: bytes,
        options: Options(contentType: _mimeType(extension)),
      );
    } on DioException catch (e) {
      throw AppException(
        "Échec de l'envoi de la photo. Vérifiez votre connexion et réessayez.",
        statusCode: e.response?.statusCode,
      );
    }

    // Confirme sur logoUrl (pas la table de vérification de documents).
    final json = await _patch("/grossistes/$ficheId/logo", {
      "filePath": filePath,
    });
    return FicheGrossisteModel.fromJson(json);
  }

  String _mimeType(String extension) {
    switch (extension.toLowerCase()) {
      case "png":
        return "image/png";
      case "pdf":
        return "application/pdf";
      case "jpg":
      case "jpeg":
      default:
        return "image/jpeg";
    }
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

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.patch<Map<String, dynamic>>(path, data: data));

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

  @override
  Future<void> supprimerProduit({
    required String ficheId,
    required String produitId,
  }) async {
    try {
      await _dio.delete<void>("/grossistes/$ficheId/produits/$produitId");
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Future<String> uploaderPhotoProduit({
    required String ficheId,
    required String extension,
    required List<int> bytes,
  }) async {
    final uploadUrlJson = await _post(
      "/grossistes/$ficheId/produits/upload-url",
      {"extension": extension},
    );
    final uploadUrl = uploadUrlJson["uploadUrl"] as String;
    final finalUrl = uploadUrlJson["finalUrl"] as String;

    try {
      await Dio().put<void>(
        uploadUrl,
        data: bytes,
        options: Options(contentType: _mimeType(extension)),
      );
    } on DioException catch (e) {
      throw AppException(
        "Échec de l'envoi de la photo. Vérifiez votre connexion et réessayez.",
        statusCode: e.response?.statusCode,
      );
    }

    return finalUrl;
  }

  @override
  Future<Map<String, dynamic>> consulterStatistiques(String ficheId) =>
      _get("/grossistes/$ficheId/statistiques");

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
