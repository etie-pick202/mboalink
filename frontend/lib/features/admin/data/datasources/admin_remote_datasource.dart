import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";

/// Endpoints /api/v1/admin/** — JSON brut (pas d'enveloppe {success,data}),
/// réservés au rôle ADMIN (voir SecurityConfig).
class AdminRemoteDatasource {
  const AdminRemoteDatasource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> dashboardResume() => _get("/admin/dashboard");

  Future<List<Map<String, dynamic>>> validationsEnAttente() async {
    final list = await _getList("/admin/validations");
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> approuverDocument(String documentId, {String? commentaire}) =>
      _patch("/admin/validations/documents/$documentId/approuver", {
        "commentaireAdmin": ?commentaire,
      });

  Future<void> rejeterDocument(String documentId, {String? commentaire}) =>
      _patch("/admin/validations/documents/$documentId/rejeter", {
        "commentaireAdmin": ?commentaire,
      });

  Future<void> validerFiche(String ficheId) =>
      _patch("/admin/validations/$ficheId/valider", const {});

  Future<void> rejeterFiche(String ficheId) =>
      _patch("/admin/validations/$ficheId/rejeter", const {});

  Future<List<Map<String, dynamic>>> avisAModerer() async {
    final list = await _getList("/admin/avis-signales");
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> conserverAvis(String notationId) =>
      _patch("/admin/avis-signales/$notationId/conserver", const {});

  Future<void> supprimerAvis(String notationId) =>
      _patch("/admin/avis-signales/$notationId/supprimer", const {});

  Future<List<Map<String, dynamic>>> revenusDerniers4Mois() async {
    final list = await _getList("/admin/dashboard/revenus");
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _get(String path) =>
      _handle(() => _dio.get<Map<String, dynamic>>(path));

  Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await _dio.get<List<dynamic>>(path);
      return response.data ?? const [];
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> _patch(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.patch<Map<String, dynamic>>(path, data: data));

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
