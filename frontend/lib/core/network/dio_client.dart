import "package:dio/dio.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../config/app_config.dart";
import "../services/session_storage.dart";

/// Construit un client Dio configuré pour l'API MboaLink.
///
/// [withAuth] : si true, injecte automatiquement le Bearer token depuis le
/// stockage sécurisé avant chaque requête. À utiliser pour les endpoints
/// protégés (grossiste, profil, consentements…).
/// Pour les endpoints publics (auth), false suffit — le serveur ignore
/// un éventuel header Authorization sur les routes non protégées.
Dio buildDioClient({bool withAuth = false}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
  );

  if (withAuth) {
    dio.interceptors.add(_AuthInterceptor());
  }

  // Log basique en debug uniquement
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
    return true;
  }());

  return dio;
}

/// Interceptor qui lit le token depuis le stockage sécurisé et l'injecte
/// en header Authorization avant chaque requête protégée.
class _AuthInterceptor extends Interceptor {
  final _storage = SessionStorage(const FlutterSecureStorage());

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = await _storage.read();
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers["Authorization"] = "Bearer ${session.accessToken}";
    }
    handler.next(options);
  }
}
