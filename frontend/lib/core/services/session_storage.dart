import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../../features/auth/domain/entities/auth_session.dart";
import "../../features/auth/domain/entities/user_role.dart";

/// Persiste la session (tokens + profil) chiffrée via le Keystore
/// Android / Keychain iOS — permet de rester connecté entre deux
/// lancements de l'app.
class SessionStorage {
  const SessionStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = "mboalink_session";

  Future<void> save(AuthSession session) async {
    final json = {
      "accessToken": session.accessToken,
      "refreshToken": session.refreshToken,
      "userId": session.userId,
      "role": session.role.toApi,
      "emailVerifie": session.emailVerifie,
      "telephoneVerifie": session.telephoneVerifie,
      "nom": session.nom,
      "prenom": session.prenom,
      "email": session.email,
      "telephone": session.telephone,
    };
    await _storage.write(key: _key, value: jsonEncode(json));
  }

  Future<AuthSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSession(
        accessToken: json["accessToken"] as String,
        refreshToken: json["refreshToken"] as String,
        userId: json["userId"] as String,
        role: UserRole.fromApi(json["role"] as String),
        emailVerifie: json["emailVerifie"] as bool? ?? false,
        telephoneVerifie: json["telephoneVerifie"] as bool? ?? false,
        nom: json["nom"] as String?,
        prenom: json["prenom"] as String?,
        email: json["email"] as String?,
        telephone: json["telephone"] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _key);
}
