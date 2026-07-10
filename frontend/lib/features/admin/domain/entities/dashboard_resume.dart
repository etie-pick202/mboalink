/// Résumé du dashboard admin — reflet de DashboardResumeDTO.
class DashboardResume {
  const DashboardResume({
    required this.totalUtilisateurs,
    required this.totalGrossistes,
    required this.totalUtilisateursClients,
    required this.validationsEnAttente,
    required this.avisSignales,
    required this.deverrouillagesCoordonnees,
    required this.demandesReinitialisationNote,
  });

  final int totalUtilisateurs;
  final int totalGrossistes;
  final int totalUtilisateursClients;
  final int validationsEnAttente;
  final int avisSignales;
  final int deverrouillagesCoordonnees;
  final int demandesReinitialisationNote;
}
