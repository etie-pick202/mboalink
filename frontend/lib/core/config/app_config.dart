/// Point de bascule unique entre données mock et vrai backend.
///
/// Usage :
///   flutter run                                → mock (par défaut)
///   flutter run --dart-define=USE_MOCK=false   → vrai backend
class AppConfig {
  AppConfig._();

  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// 10.0.2.2 = alias de "localhost" de la machine hôte depuis l'émulateur Android.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );
}
