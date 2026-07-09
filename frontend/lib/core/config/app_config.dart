/// Configuration globale de l'application.
///
/// Pour cibler le backend déployé en mode réel :
///   flutter run --dart-define=USE_MOCK=false
///
/// Pour pointer sur un backend local :
///   flutter run --dart-define=USE_MOCK=false --dart-define=BASE_URL=http://10.0.2.2:8080/api/v1
class AppConfig {
  AppConfig._();

  /// true  → données simulées (défaut développement)
  /// false → appels réseau réels vers le backend Render
  static const bool useMockData = bool.fromEnvironment(
    "USE_MOCK",
    defaultValue: false,
  );

  /// URL de base de l'API — inclut le préfixe /api/v1 attendu par le backend.
  static const String baseUrl = String.fromEnvironment(
    "BASE_URL",
    defaultValue: "https://mboalink.onrender.com/api/v1",
  );
}
