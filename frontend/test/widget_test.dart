import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:mboalink/app.dart";
import "package:mboalink/features/auth/presentation/screens/splash_screen.dart";

void main() {
  testWidgets("Splash screen shows then navigates to onboarding", (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MboaLinkApp()));

    expect(find.byType(SplashScreen), findsOneWidget);

    // Déclenche le Timer de navigation (2s) puis laisse la transition
    // de route se terminer (généreux pour couvrir toute plateforme).
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));

    // On vérifie l'arrivée sur le nouvel écran plutôt que la disparition
    // complète de l'ancien — plus robuste, indépendant du timing exact
    // de l'animation de transition.
    expect(find.text("02 · Onboarding"), findsOneWidget);
  });
}
