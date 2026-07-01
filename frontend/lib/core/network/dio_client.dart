import "package:dio/dio.dart";

import "../config/app_config.dart";

/// Instance Dio configurée pour l'API MboaLink. Les intercepteurs
/// d'authentification (injection JWT, refresh automatique) seront ajoutés
/// une fois le stockage de session en place.
Dio buildDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {"Content-Type": "application/json"},
    ),
  );
}
