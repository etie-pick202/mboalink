import "package:flutter_test/flutter_test.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:mboalink/app.dart";
import "package:mboalink/features/auth/presentation/screens/splash_screen.dart";
import "package:mboalink/features/auth/presentation/screens/onboarding_screen.dart";

void main() {
  testWidgets("Splash screen shows then navigates to onboarding", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MboaLinkApp()));

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
