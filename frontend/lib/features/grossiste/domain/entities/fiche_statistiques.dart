/// Statistiques réelles du dashboard grossiste — reflet de
/// FicheStatistiquesResponse (GET /grossistes/{ficheId}/statistiques).
class FicheStatistiques {
  const FicheStatistiques({
    required this.vuesMoisEnCours,
    required this.contactsDebloques,
    required this.vuesParJour,
  });

  final int vuesMoisEnCours;
  final int contactsDebloques;

  /// 7 valeurs, la plus ancienne en premier (J-6 → aujourd'hui).
  final List<int> vuesParJour;
}
