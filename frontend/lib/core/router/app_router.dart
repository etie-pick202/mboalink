import "package:go_router/go_router.dart";

import "../constants/app_routes.dart";
import "../widgets/placeholder_screen.dart";
import "../../features/auth/presentation/screens/splash_screen.dart";
import "../../features/auth/presentation/screens/onboarding_screen.dart";
import "../../features/auth/presentation/screens/login_register_screen.dart";

/// Router racine. Les routes se remplissent au fur et à mesure des
/// workflows ; les écrans pas encore développés utilisent PlaceholderScreen.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
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
          const PlaceholderScreen(title: "Choix du type de compte"),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) =>
          const PlaceholderScreen(title: "04 · Vérification OTP"),
    ),
    GoRoute(
      path: AppRoutes.consent,
      builder: (context, state) =>
          const PlaceholderScreen(title: "05 · Consentement données"),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) =>
          const PlaceholderScreen(title: "06 · Accueil"),
    ),
  ],
);
