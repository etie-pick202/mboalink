import "../../domain/entities/consentement.dart";

class ConsentementModel {
  const ConsentementModel({
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

  factory ConsentementModel.fromJson(Map<String, dynamic> json) {
    return ConsentementModel(
      trackingAccepte: json["trackingAccepte"] as bool? ?? false,
      notificationsAcceptees: json["notificationsAcceptees"] as bool? ?? false,
      marketingAccepte: json["marketingAccepte"] as bool? ?? false,
      conditionsAcceptees: json["conditionsAcceptees"] as bool? ?? false,
      versionConditions: json["versionConditions"] as String?,
    );
  }

  Consentement toEntity() {
    return Consentement(
      trackingAccepte: trackingAccepte,
      notificationsAcceptees: notificationsAcceptees,
      marketingAccepte: marketingAccepte,
      conditionsAcceptees: conditionsAcceptees,
      versionConditions: versionConditions,
    );
  }
}
