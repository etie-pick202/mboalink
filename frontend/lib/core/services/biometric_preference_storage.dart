import "package:flutter_secure_storage/flutter_secure_storage.dart";

/// Préférence locale "verrouillage biométrique activé" — indépendante par
/// appareil, pas de valeur par défaut stockée tant que l'utilisateur n'a
/// pas fait de choix explicite (voir biometricLockEnabledProvider pour la
/// valeur par défaut effective).
class BiometricPreferenceStorage {
  const BiometricPreferenceStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = "biometric_lock_enabled";

  Future<bool?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return raw == "true";
    } catch (_) {
      // Lecture impossible (Keystore/Keychain indisponible) — on retombe
      // sur la valeur par défaut plutôt que de bloquer l'appelant.
      return null;
    }
  }

  Future<void> write(bool enabled) async {
    try {
      await _storage.write(key: _key, value: enabled ? "true" : "false");
    } catch (_) {}
  }
}
