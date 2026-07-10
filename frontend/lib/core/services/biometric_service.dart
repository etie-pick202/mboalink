import "package:local_auth/local_auth.dart";

/// Type de capteur biométrique privilégié sur l'appareil — pilote
/// l'icône/le texte adaptatifs de [BiometricPromptScreen].
enum BiometricKind { face, fingerprint, iris, generic, unavailable }

/// Authentification biométrique (empreinte / Face ID / code de
/// l'appareil) — utilisée pour déverrouiller une session existante et
/// pour confirmer les actions sensibles (mot de passe, bascule de rôle,
/// suppression de compte…).
///
/// Le capteur biométrique lui-même reste piloté par l'OS (BiometricPrompt
/// Android / LocalAuthentication iOS) — Flutter ne peut pas et ne doit
/// pas ré-implémenter la capture d'empreinte/visage en dehors du système
/// d'exploitation, pour des raisons de sécurité. En revanche, tout
/// l'habillage — écran, messages, compteur d'essais, bascule vers le
/// code de l'appareil — est propre à l'app (voir BiometricPromptScreen).
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Détermine le type de capteur à mettre en avant dans l'UI (adaptatif).
  Future<BiometricKind> preferredKind() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      if (types.contains(BiometricType.fingerprint)) {
        return BiometricKind.fingerprint;
      }
      if (types.contains(BiometricType.iris)) return BiometricKind.iris;
      if (types.isNotEmpty) return BiometricKind.generic;
      return BiometricKind.unavailable;
    } catch (_) {
      return BiometricKind.unavailable;
    }
  }

  /// Capture biométrique stricte (empreinte/visage uniquement, pas de
  /// repli sur le code de l'appareil). Utilisé pour les premiers essais.
  Future<bool> authenticateBiometricOnly({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  /// Repli sur le code/schéma/mot de passe de l'appareil — proposé par
  /// notre écran après 2 échecs biométriques successifs.
  Future<bool> authenticateWithDeviceFallback({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  /// Conservé pour compatibilité — équivalent à [authenticateBiometricOnly]
  /// suivi d'un repli automatique sur le code de l'appareil.
  Future<bool> authenticate() => authenticateWithDeviceFallback(
    reason: "Confirmez votre identité pour accéder à MboaLink",
  );
}
