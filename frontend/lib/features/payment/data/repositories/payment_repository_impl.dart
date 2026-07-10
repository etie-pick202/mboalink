import "../../domain/entities/abonnement.dart";
import "../../domain/entities/plan.dart";
import "../../domain/entities/recu.dart";
import "../../domain/entities/transaction_paiement.dart";
import "../../domain/repositories/payment_repository.dart";
import "../datasources/payment_remote_datasource.dart";

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._datasource);

  final PaymentRemoteDatasource _datasource;

  @override
  Future<List<Plan>> listerPlans(String role) async {
    final models = await _datasource.listerPlans(role);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransactionPaiement> initierPaiement({
    required TypeTransaction type,
    required double montant,
    required OperateurMobileMoney operateur,
    required String numeroTelephone,
    required String description,
    String? ficheGrossisteId,
  }) async {
    final model = await _datasource.initierPaiement(
      typeTransaction: type.apiValue,
      montant: montant,
      operateur: operateur.apiValue,
      numeroTelephone: numeroTelephone,
      description: description,
      ficheGrossisteId: ficheGrossisteId,
    );
    return model.toEntity();
  }

  @override
  Future<StatutTransaction> verifierStatut(String transactionId) async {
    final statut = await _datasource.verifierStatut(transactionId);
    return StatutTransaction.fromApi(statut);
  }

  @override
  Future<Abonnement?> monAbonnement() async {
    final model = await _datasource.monAbonnement();
    return model?.toEntity();
  }

  @override
  Future<Abonnement> creerAbonnement({
    required String typeAbonnement,
    required double montant,
    required bool renouvellementAuto,
    required String transactionId,
  }) async {
    final model = await _datasource.creerAbonnement(
      typeAbonnement: typeAbonnement,
      montant: montant,
      renouvellementAuto: renouvellementAuto,
      transactionId: transactionId,
    );
    return model.toEntity();
  }

  @override
  Future<Abonnement> renouvelerAbonnement({
    required String transactionId,
  }) async {
    final model = await _datasource.renouvelerAbonnement(transactionId);
    return model.toEntity();
  }

  @override
  Future<void> suspendreAbonnement() => _datasource.suspendreAbonnement();

  @override
  Future<List<Recu>> mesRecus({int limit = 20}) async {
    final models = await _datasource.mesRecus(limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> reinitialiserNote({
    required String ficheGrossisteId,
    required String transactionId,
  }) => _datasource.reinitialiserNote(
    ficheGrossisteId: ficheGrossisteId,
    transactionId: transactionId,
  );

  @override
  Future<bool> aDejaReinitialiseNote(String ficheGrossisteId) =>
      _datasource.aDejaReinitialiseNote(ficheGrossisteId);

  @override
  Future<void> demanderCertification({
    required String ficheGrossisteId,
    required String transactionId,
  }) => _datasource.demanderCertification(
    ficheGrossisteId: ficheGrossisteId,
    transactionId: transactionId,
  );
}
