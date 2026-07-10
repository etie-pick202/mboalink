import "package:go_router/go_router.dart";

import "../constants/app_routes.dart";
import "../widgets/not_found_screen.dart";
import "../../features/auth/domain/entities/registration_draft.dart";
import "../../features/auth/presentation/screens/splash_screen.dart";
import "../../features/auth/presentation/screens/onboarding_screen.dart";
import "../../features/auth/presentation/screens/login_register_screen.dart";
import "../../features/auth/presentation/screens/account_type_choice_screen.dart";
import "../../features/auth/presentation/screens/otp_screen.dart";
import "../../features/auth/presentation/screens/consent_screen.dart";
import "../../features/auth/presentation/screens/confidentialite_screen.dart";
import "../../features/auth/presentation/screens/changer_mot_de_passe_screen.dart";
import "../../features/home/presentation/screens/home_screen.dart";
import "../../features/home/presentation/screens/client_recherche_screen.dart";
import "../../features/home/presentation/screens/client_debloques_screen.dart";
import "../../features/home/presentation/screens/client_profil_screen.dart";
import "../../features/home/presentation/screens/fiche_publique_screen.dart";
import "../../features/home/presentation/screens/coordonnees_debloquees_screen.dart";
import "../../features/home/presentation/screens/favoris_screen.dart";
import "../../features/home/presentation/screens/devenir_grossiste_screen.dart";
import "../../features/home/presentation/screens/avis_screen.dart";
import "../../features/home/presentation/screens/laisser_avis_screen.dart";
import "../../features/home/presentation/screens/notifications_screen.dart";
import "../../features/home/domain/entities/fiche_publique.dart";
import "../../features/payment/domain/entities/paiement_params.dart";
import "../../features/payment/domain/entities/transaction_paiement.dart";
import "../../features/payment/presentation/screens/paiement_choix_screen.dart";
import "../../features/payment/presentation/screens/paiement_confirmation_screen.dart";
import "../../features/payment/presentation/screens/recus_screen.dart";
import "../../features/payment/presentation/screens/mon_abonnement_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_dashboard_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_boutique_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_fiche_preview_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_profil_screen.dart";
import "../../features/grossiste/presentation/screens/fiche_step1_screen.dart";
import "../../features/grossiste/presentation/screens/fiche_step2_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_fiche_en_attente_screen.dart";
import "../../features/grossiste/presentation/screens/certification_screen.dart";
import "../../features/admin/presentation/screens/admin_dashboard_screen.dart";
import "../../features/admin/presentation/screens/admin_validations_screen.dart";
import "../../features/admin/presentation/screens/admin_moderation_screen.dart";
import "../../features/admin/presentation/screens/admin_revenus_screen.dart";

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    // ── Auth ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginRegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountTypeChoice,
      builder: (context, state) =>
          AccountTypeChoiceScreen(draft: state.extra as RegistrationDraft),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OtpScreen(
          cible: extra["cible"] as String,
          isGrossiste: extra["isGrossiste"] as bool,
          telephone: extra["telephone"] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.consent,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ConsentScreen(isGrossiste: extra["isGrossiste"] as bool);
      },
    ),
    GoRoute(
      path: AppRoutes.confidentialite,
      builder: (context, state) => const ConfidentialiteScreen(),
    ),
    GoRoute(
      path: AppRoutes.changerMotDePasse,
      builder: (context, state) => const ChangerMotDePasseScreen(),
    ),

    // ── Client ────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.clientRecherche,
      builder: (context, state) =>
          ClientRechercheScreen(categorieInitiale: state.extra as String?),
    ),
    GoRoute(
      path: AppRoutes.clientDebloques,
      builder: (context, state) => const ClientDeblocagesScreen(),
    ),
    GoRoute(
      path: AppRoutes.clientProfil,
      builder: (context, state) => const ClientProfilScreen(),
    ),
    GoRoute(
      path: "${AppRoutes.fichePublique}/:ficheId",
      builder: (context, state) =>
          FichePubliqueScreen(ficheId: state.pathParameters["ficheId"]!),
    ),
    GoRoute(
      path: AppRoutes.recus,
      builder: (context, state) => const RecusScreen(),
    ),
    GoRoute(
      path: AppRoutes.favoris,
      builder: (context, state) => const FavorisScreen(),
    ),
    GoRoute(
      path: AppRoutes.devenirGrossiste,
      builder: (context, state) => const DevenirGrossisteScreen(),
    ),
    GoRoute(
      path: AppRoutes.avis,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AvisScreen(
          ficheId: extra["ficheId"] as String,
          nomEntreprise: extra["nomEntreprise"] as String,
          dejaDeverrouille: extra["dejaDeverrouille"] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.laisserAvis,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LaisserAvisScreen(
          ficheId: extra["ficheId"] as String,
          nomEntreprise: extra["nomEntreprise"] as String,
          referenceTransaction: extra["referenceTransaction"] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ── Paiement (commun Client/Grossiste) ──────────────────────────────────
    GoRoute(
      path: AppRoutes.paiementChoix,
      builder: (context, state) =>
          PaiementChoixScreen(params: state.extra as PaiementParams),
    ),
    GoRoute(
      path: AppRoutes.paiementConfirmation,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PaiementConfirmationScreen(
          transaction: extra["transaction"] as TransactionPaiement,
          params: extra["params"] as PaiementParams,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.coordonneesDebloquees,
      builder: (context, state) => CoordonneesDebloqueesScreen(
        coordonnees: state.extra as CoordonneesDeverrouillees,
      ),
    ),

    // ── Grossiste ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.grossisteDashboard,
      builder: (context, state) => const GrossisteDashboardScreen(),
    ),

    // Wizard "Créer ma fiche" — 2 volets uniquement (step3 supprimé).
    // Le paiement de l'abonnement se fait depuis l'onglet Profil
    // après validation des documents par l'équipe MboaLink.
    GoRoute(
      path: AppRoutes.grossisteOnboarding,
      builder: (context, state) => const GrossisteFicheStep1Screen(),
    ),
    GoRoute(
      path: AppRoutes.grossisteFicheStep2,
      builder: (context, state) =>
          GrossisteFicheStep2Screen(ficheId: state.extra as String),
    ),
    GoRoute(
      path: AppRoutes.grossisteEditerFiche,
      builder: (context, state) =>
          const GrossisteFicheStep1Screen(modeEdition: true),
    ),

    GoRoute(
      path: AppRoutes.grossisteFicheReadonly,
      builder: (context, state) => const GrossisteFicheEnAttenteScreen(),
    ),
    GoRoute(
      path: AppRoutes.grossisteBoutique,
      builder: (context, state) => const GrossisteBoutiqueScreen(),
    ),
    GoRoute(
      path: AppRoutes.grossisteFichePreview,
      builder: (context, state) => const GrossisteFichePreviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.grossisteProfil,
      builder: (context, state) => const GrossisteProfilScreen(),
    ),
    GoRoute(
      path: AppRoutes.grossisteMonAbonnement,
      builder: (context, state) => const MonAbonnementScreen(),
    ),
    GoRoute(
      path: AppRoutes.grossisteCertification,
      builder: (context, state) => const CertificationScreen(),
    ),

    // ── Admin ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminValidations,
      builder: (context, state) => const AdminValidationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminModeration,
      builder: (context, state) => const AdminModerationScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminRevenus,
      builder: (context, state) => const AdminRevenusScreen(),
    ),
  ],
);
