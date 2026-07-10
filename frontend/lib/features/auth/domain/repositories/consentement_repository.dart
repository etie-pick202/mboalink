import "../entities/consentement.dart";

abstract class ConsentementRepository {
  Future<Consentement> consulter();

  Future<Consentement> mettreAJour({
    bool? trackingAccepte,
    bool? notificationsAcceptees,
    bool? marketingAccepte,
    bool? conditionsAcceptees,
    String? versionConditions,
  });
}
