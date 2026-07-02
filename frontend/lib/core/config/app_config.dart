/// Point de bascule unique entre données mock et vrai backend.
///
/// Usage :
///   flutter run
///     → mock (par défaut)
///   flutter run --dart-define=USE_MOCK=false
///     → backend local (émulateur Android, 10.0.2.2 = alias de localhost)
///   flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://mboalink.onrender.com/api/v1
///     → backend réel déployé sur Render
class AppConfig {
  AppConfig._();

  static const bool useMockData = bool.fromEnvironment(
    "USE_MOCK",
    defaultValue: true,
  );

  /// 10.0.2.2 = alias de "localhost" de la machine hôte depuis l'émulateur
  /// Android. Passer API_BASE_URL en --dart-define pour cibler un autre
  /// backend (ex: l'instance Render de production).
  static const String apiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://10.0.2.2:8080/api/v1",
  );

  /// URL du backend déployé, pour référence rapide (copier dans la commande
  /// --dart-define=API_BASE_URL=... ci-dessus).
  static const String productionApiBaseUrl =
      "https://mboalink.onrender.com/api/v1";
}
