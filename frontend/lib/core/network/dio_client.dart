import "package:dio/dio.dart";

import "../config/app_config.dart";

/// Instance Dio configurée pour l'API MboaLink. Les intercepteurs
/// d'authentification (injection JWT, refresh automatique) seront ajoutés
/// une fois le stockage de session en place.
///
/// Timeouts volontairement généreux (30s) : le backend est hébergé sur
/// Render en offre gratuite, qui met le service en veille après
/// inactivité — le réveil (cold start) peut prendre jusqu'à ~50s sur la
/// première requête.
Dio buildDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {"Content-Type": "application/json"},
    ),
  );
}
