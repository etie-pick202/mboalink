import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";

/// Endpoints /api/v1/notifications — pas d'enveloppe {success,data},
/// même convention que /grossistes/** et /search/**.
class NotificationRemoteDatasource {
  const NotificationRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> mesNotifications() async {
    try {
      final response = await _dio.get<List<dynamic>>("/notifications");
      return (response.data ?? const []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<int> compterNonLues() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        "/notifications/non-lues/compte",
      );
      return (response.data?["compte"] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> marquerCommeLue(String notificationId) async {
    try {
      await _dio.patch<void>("/notifications/$notificationId/lue");
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> marquerToutesCommeLues() async {
    try {
      await _dio.patch<void>("/notifications/lues");
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
