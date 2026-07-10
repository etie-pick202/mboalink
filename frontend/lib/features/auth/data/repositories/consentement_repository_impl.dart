import "../../domain/entities/consentement.dart";
import "../../domain/repositories/consentement_repository.dart";
import "../datasources/consentement_remote_datasource.dart";

class ConsentementRepositoryImpl implements ConsentementRepository {
  const ConsentementRepositoryImpl(this._datasource);

  final ConsentementRemoteDatasource _datasource;

  @override
  Future<Consentement> consulter() async {
    final model = await _datasource.consulter();
    return model.toEntity();
  }

  @override
  Future<Consentement> mettreAJour({
    bool? trackingAccepte,
    bool? notificationsAcceptees,
    bool? marketingAccepte,
    bool? conditionsAcceptees,
    String? versionConditions,
  }) async {
    final model = await _datasource.mettreAJour({
      "trackingAccepte": ?trackingAccepte,
      "notificationsAcceptees": ?notificationsAcceptees,
      "marketingAccepte": ?marketingAccepte,
      "conditionsAcceptees": ?conditionsAcceptees,
      "versionConditions": ?versionConditions,
    });
    return model.toEntity();
  }
}
