/// Préférences de confidentialité de l'utilisateur connecté — alignées
/// avec l'entité backend Consentement (GET/PUT /api/v1/consentements).
class Consentement {
  const Consentement({
    required this.trackingAccepte,
    required this.notificationsAcceptees,
    required this.marketingAccepte,
    required this.conditionsAcceptees,
    this.versionConditions,
  });

  final bool trackingAccepte;
  final bool notificationsAcceptees;
  final bool marketingAccepte;
  final bool conditionsAcceptees;
  final String? versionConditions;

  Consentement copyWith({
    bool? trackingAccepte,
    bool? notificationsAcceptees,
    bool? marketingAccepte,
    bool? conditionsAcceptees,
  }) {
    return Consentement(
      trackingAccepte: trackingAccepte ?? this.trackingAccepte,
      notificationsAcceptees:
          notificationsAcceptees ?? this.notificationsAcceptees,
      marketingAccepte: marketingAccepte ?? this.marketingAccepte,
      conditionsAcceptees: conditionsAcceptees ?? this.conditionsAcceptees,
      versionConditions: versionConditions,
    );
  }
}
