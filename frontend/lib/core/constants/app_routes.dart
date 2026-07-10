class AppRoutes {
  AppRoutes._();

  // Auth
  static const splash = "/splash";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const otp = "/otp";
  static const consent = "/consent";
  static const confidentialite = "/confidentialite";
  static const changerMotDePasse = "/securite/mot-de-passe";

  // Client
  static const home = "/home";
  static const clientRecherche = "/recherche";
  static const clientDebloques = "/debloques";
  static const clientProfil = "/profil";
  static const fichePublique = "/fiche";
  static const favoris = "/favoris";
  static const devenirGrossiste = "/devenir-grossiste";
  static const avis = "/avis";
  static const laisserAvis = "/avis/laisser";
  static const notifications = "/notifications";

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
  static const grossisteMonAbonnement = "/grossiste/abonnement";
  static const grossisteCertification = "/grossiste/certification";
  static const grossisteEditerFiche = "/grossiste/fiche/modifier";

  // Paiement (commun Client/Grossiste)
  static const paiementChoix = "/paiement/choix";
  static const paiementConfirmation = "/paiement/confirmation";
  static const coordonneesDebloquees = "/paiement/coordonnees-debloquees";
  static const recus = "/recus";

  // Admin
  static const adminDashboard = "/admin/dashboard";
  static const adminValidations = "/admin/validations";
  static const adminModeration = "/admin/moderation";
  static const adminRevenus = "/admin/revenus";
}
