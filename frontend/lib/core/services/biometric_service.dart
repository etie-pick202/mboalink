import "package:local_auth/local_auth.dart";

/// Authentification biométrique (empreinte / Face ID) pour déverrouiller
/// une session déjà existante, sans redemander le mot de passe à chaque
/// lancement.
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

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: "Confirmez votre identité pour accéder à MboaLink",
      );
    } catch (_) {
      return false;
    }
  }
}
