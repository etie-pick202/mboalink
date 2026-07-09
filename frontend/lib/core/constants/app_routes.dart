class AppRoutes {
  AppRoutes._();

  // Auth
  static const splash = "/splash";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const otp = "/otp";
  static const consent = "/consent";

  // Client
  static const home = "/home";
  static const clientRecherche = "/recherche";
  static const clientDebloques = "/debloques";
  static const clientProfil = "/profil";

  // Grossiste
  static const grossisteDashboard = "/grossiste/dashboard";
  static const grossisteOnboarding = "/grossiste/creer-ma-fiche";
  static const grossisteFicheStep2 = "/grossiste/creer-ma-fiche/documents";
  // ⚠️ grossisteFicheStep3 supprimé — le paiement se fait depuis l'onglet
  // Profil APRÈS validation des documents par l'équipe MboaLink.
  static const grossisteFicheReadonly = "/grossiste/fiche/lecture";
  static const grossisteBoutique = "/grossiste/boutique";
  static const grossisteFichePreview = "/grossiste/fiche/apercu";
  static const grossisteProfil = "/grossiste/profil";
}
