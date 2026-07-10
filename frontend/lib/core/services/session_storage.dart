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
    try {
      await _storage.write(key: _key, value: jsonEncode(json));
    } catch (_) {
      // Un échec d'écriture (Keystore/Keychain indisponible) ne doit pas
      // empêcher l'utilisateur de continuer sur la session déjà active en
      // mémoire (currentSessionProvider) — il devra simplement se
      // reconnecter au prochain lancement plutôt que de rester bloqué
      // maintenant sur l'écran de connexion.
    }
  }

  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
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
      // Entrée illisible (JSON corrompu, ou déchiffrement Keystore/Keychain
      // impossible après une réinstallation avec une autre clé de
      // signature) — on efface l'entrée invalide et on traite comme
      // "pas de session" plutôt que de laisser l'exception remonter et
      // bloquer l'appelant indéfiniment.
      try {
        await _storage.delete(key: _key);
      } catch (_) {}
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Une suppression qui échoue ne doit jamais bloquer une déconnexion
      // en cours — la prochaine lecture retombera de toute façon sur
      // "pas de session" si l'entrée est irrécupérable (voir read()).
    }
  }
}
