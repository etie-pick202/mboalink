/// Résultat de l'endpoint POST /auth/inscription.
///
/// Le backend ne renvoie PAS de tokens à l'inscription — il renvoie
/// uniquement l'identifiant du compte créé et l'état de vérification
/// de l'email. Les tokens sont obtenus après vérification OTP.
class RegistrationResult {
  const RegistrationResult({
    required this.utilisateurId,
    required this.emailVerifie,
  });

  /// Identifiant unique du compte créé côté backend.
  final String utilisateurId;

  /// Toujours false à l'inscription — devient true après OTP vérifié.
  final bool emailVerifie;
}
