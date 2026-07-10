import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";

/// Endpoints /api/v1/notations (domaine "Avis & évaluations") — enveloppe
/// {success, message, data} comme le reste du domaine paiement.
class AvisRemoteDatasource {
  const AvisRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> listerAvis(String ficheGrossisteId) async {
    final json = await _get("/notations/grossiste/$ficheGrossisteId");
    final list = json["data"] as List<dynamic>? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> breakdown(String ficheGrossisteId) async {
    final json = await _get("/notations/grossiste/$ficheGrossisteId/breakdown");
    return json["data"] as Map<String, dynamic>? ?? const {};
  }

  Future<Map<String, dynamic>> publierAvis({
    required String ficheGrossisteId,
    required int note,
    String? commentaire,
    String? referenceTransaction,
  }) async {
    final json = await _post("/notations", {
      "ficheGrossisteId": ficheGrossisteId,
      "note": note,
      if (commentaire != null && commentaire.isNotEmpty)
        "commentaire": commentaire,
      "transactionVerifiee": referenceTransaction != null,
      if (referenceTransaction != null)
        "referenceTransaction": referenceTransaction,
    });
    if (json["success"] != true) {
      throw AppException(
        json["message"] as String? ?? "Échec de la publication de l'avis.",
      );
    }
    return json["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _get(String path) =>
      _handle(() => _dio.get<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.post<Map<String, dynamic>>(path, data: data));

  Future<Map<String, dynamic>> _handle(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? const {};
    } on DioException catch (e) {
      final body = e.response?.data;
      final statusCode = e.response?.statusCode;
      if (body is Map<String, dynamic> && body["message"] is String) {
        throw AppException(body["message"] as String, statusCode: statusCode);
      }
      throw AppException(
        "Une erreur est survenue lors de la communication avec le serveur.",
        statusCode: statusCode,
      );
    }
  }
}
