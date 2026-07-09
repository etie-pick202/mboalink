import "package:go_router/go_router.dart";

import "../constants/app_routes.dart";
import "../widgets/placeholder_screen.dart";
import "../../features/auth/domain/entities/registration_draft.dart";
import "../../features/auth/presentation/screens/splash_screen.dart";
import "../../features/auth/presentation/screens/onboarding_screen.dart";
import "../../features/auth/presentation/screens/login_register_screen.dart";
import "../../features/auth/presentation/screens/account_type_choice_screen.dart";
import "../../features/auth/presentation/screens/otp_screen.dart";
import "../../features/auth/presentation/screens/consent_screen.dart";
import "../../features/home/presentation/screens/home_screen.dart";
import "../../features/home/presentation/screens/client_recherche_screen.dart";
import "../../features/home/presentation/screens/client_debloques_screen.dart";
import "../../features/home/presentation/screens/client_profil_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_dashboard_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_boutique_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_fiche_preview_screen.dart";
import "../../features/grossiste/presentation/screens/grossiste_profil_screen.dart";
import "../../features/grossiste/presentation/screens/fiche_step1_screen.dart";
import "../../features/grossiste/presentation/screens/fiche_step2_screen.dart";

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
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

    // ── Client ────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.clientRecherche,
      builder: (context, state) => const ClientRechercheScreen(),
    ),
    GoRoute(
      path: AppRoutes.clientDebloques,
      builder: (context, state) => const ClientDeblocagesScreen(),
    ),
    GoRoute(
      path: AppRoutes.clientProfil,
      builder: (context, state) => const ClientProfilScreen(),
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
      path: AppRoutes.grossisteFicheReadonly,
      builder: (context, state) =>
          const PlaceholderScreen(title: "Ma fiche (lecture seule)"),
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
  ],
);
