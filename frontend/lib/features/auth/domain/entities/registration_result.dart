/// Résultat d'une inscription : pas de session tant que l'OTP n'est pas
/// vérifié, mais on garde la cible (email/téléphone) pour préremplir
/// l'écran de vérification OTP suivant.
class RegistrationResult {
  const RegistrationResult({
    required this.utilisateurId,
    required this.cible,
    required this.message,
  });

  final String utilisateurId;
  final String cible;
  final String message;
}
