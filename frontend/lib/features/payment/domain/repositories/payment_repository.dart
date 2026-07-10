import "../entities/abonnement.dart";
import "../entities/plan.dart";
import "../entities/recu.dart";
import "../entities/transaction_paiement.dart";

abstract class PaymentRepository {
  /// Plans disponibles pour un rôle donné ("GROSSISTE" | "UTILISATEUR").
  Future<List<Plan>> listerPlans(String role);

  /// Crée une transaction et initie le paiement Mobile Money auprès de
  /// Campay. Renvoie la transaction (statut EN_ATTENTE) accompagnée de
  /// l'instruction USSD à suivre sur le téléphone.
  Future<TransactionPaiement> initierPaiement({
    required TypeTransaction type,
    required double montant,
    required OperateurMobileMoney operateur,
    required String numeroTelephone,
    required String description,
    String? ficheGrossisteId,
  });

  /// Interroge Campay pour connaître le statut actuel d'une transaction —
  /// à appeler en boucle jusqu'à SUCCES ou ECHEC. Déclenche côté backend,
  /// dès que le statut passe à SUCCES, la génération du reçu et — pour un
  /// déverrouillage — l'enregistrement du déverrouillage lui-même.
  Future<StatutTransaction> verifierStatut(String transactionId);

  /// Abonnement du grossiste connecté, ou null s'il n'en a jamais eu.
  Future<Abonnement?> monAbonnement();

  /// Crée un nouvel abonnement après un paiement réussi (transactionId).
  Future<Abonnement> creerAbonnement({
    required String typeAbonnement,
    required double montant,
    required bool renouvellementAuto,
    required String transactionId,
  });

  /// Renouvelle l'abonnement existant (même type/montant que précédemment)
  /// après un nouveau paiement réussi.
  Future<Abonnement> renouvelerAbonnement({required String transactionId});

  Future<void> suspendreAbonnement();

  Future<List<Recu>> mesRecus({int limit = 20});

  /// Réinitialise la note moyenne d'une fiche après paiement réussi —
  /// usage unique par grossiste (contrainte backend).
  Future<void> reinitialiserNote({
    required String ficheGrossisteId,
    required String transactionId,
  });

  /// true si cette fiche a déjà utilisé sa réinitialisation de note.
  Future<bool> aDejaReinitialiseNote(String ficheGrossisteId);

  /// Active le badge "certification premium" après paiement réussi.
  Future<void> demanderCertification({
    required String ficheGrossisteId,
    required String transactionId,
  });
}
