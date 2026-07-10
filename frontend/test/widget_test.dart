import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

import "package:mboalink/app.dart";
import "package:mboalink/core/services/biometric_service.dart";
import "package:mboalink/core/services/session_storage.dart";
import "package:mboalink/features/auth/domain/entities/auth_session.dart";
import "package:mboalink/features/auth/presentation/providers/auth_providers.dart";
import "package:mboalink/features/auth/presentation/screens/onboarding_screen.dart";
import "package:mboalink/features/auth/presentation/screens/splash_screen.dart";

class _NoSessionStorage implements SessionStorage {
  @override
  Future<void> save(AuthSession session) async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> clear() async {}
}

class _NoBiometrics implements BiometricService {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<bool> authenticate() async => false;

  @override
  Future<bool> authenticateBiometricOnly({required String reason}) async =>
      false;

  @override
  Future<bool> authenticateWithDeviceFallback({required String reason}) async =>
      false;

  @override
  Future<BiometricKind> preferredKind() async => BiometricKind.unavailable;
}

void main() {
  testWidgets(
    "Splash affiche le bouton Démarrer puis navigue vers l'onboarding (aucune session)",
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionStorageProvider.overrideWithValue(_NoSessionStorage()),
            biometricServiceProvider.overrideWithValue(_NoBiometrics()),
          ],
          child: const MboaLinkApp(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text("Démarrer · Start"), findsOneWidget);

      await tester.tap(find.text("Démarrer · Start"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(OnboardingScreen), findsOneWidget);
    },
  );
}
