import "transaction_paiement.dart";

/// Décrit l'intention derrière un paiement — ce qui doit se passer une
/// fois la transaction confirmée SUCCES. Passé de la page d'origine
/// (fiche publique, profil grossiste) jusqu'à l'écran de confirmation.
class PaiementParams {
  const PaiementParams({
    required this.type,
    required this.montant,
    required this.description,
    this.ficheGrossisteId,
    this.nomGrossiste,
    this.typeAbonnement,
    this.abonnementExistant = false,
  });

  final TypeTransaction type;
  final double montant;
  final String description;

  /// Requis pour TypeTransaction.deverrouillageCoordonnees.
  final String? ficheGrossisteId;
  final String? nomGrossiste;

  /// Requis pour TypeTransaction.abonnement — "MENSUEL" | "ANNUEL".
  final String? typeAbonnement;

  /// true si un abonnement existe déjà (même expiré/suspendu) → on
  /// renouvelle au lieu de créer, pour respecter la contrainte unique
  /// utilisateur↔abonnement côté backend.
  final bool abonnementExistant;
}
