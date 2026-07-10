import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";
import "../models/consentement_model.dart";

/// GET/PUT /api/v1/consentements — endpoints protégés, identifient
/// l'utilisateur via le token Bearer (aucun id à passer en paramètre).
class ConsentementRemoteDatasource {
  const ConsentementRemoteDatasource(this._dio);

  final Dio _dio;

  Future<ConsentementModel> consulter() async {
    final json = await _get("/consentements");
    return ConsentementModel.fromJson(json);
  }

  Future<ConsentementModel> mettreAJour(Map<String, dynamic> donnees) async {
    final json = await _put("/consentements", donnees);
    return ConsentementModel.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(String path) =>
      _handle(() => _dio.get<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.put<Map<String, dynamic>>(path, data: data));

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
