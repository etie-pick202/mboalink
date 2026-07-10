import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

/// Persiste, par tableau de bord (ex: "admin", "grossiste"), la liste des
/// widgets que l'utilisateur a choisi d'afficher — permet de personnaliser
/// son dashboard sans backend dédié (préférence purement locale à l'appareil).
class DashboardWidgetPreferencesStorage {
  const DashboardWidgetPreferencesStorage(this._storage);

  final FlutterSecureStorage _storage;

  String _keyFor(String dashboardId) => "dashboard_widgets_$dashboardId";

  /// null = aucune préférence enregistrée (l'appelant doit utiliser ses
  /// widgets par défaut).
  Future<Set<String>?> read(String dashboardId) async {
    try {
      final raw = await _storage.read(key: _keyFor(dashboardId));
      if (raw == null) return null;
      return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String dashboardId, Set<String> widgetIds) async {
    try {
      await _storage.write(
        key: _keyFor(dashboardId),
        value: jsonEncode(widgetIds.toList()),
      );
    } catch (_) {}
  }
}
