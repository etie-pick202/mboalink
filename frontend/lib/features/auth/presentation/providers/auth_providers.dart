import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../../../../core/config/app_config.dart";
import "../../../../core/network/dio_client.dart";
import "../../../../core/services/biometric_preference_storage.dart";
import "../../../../core/services/biometric_service.dart";
import "../../../../core/services/dashboard_widget_preferences_storage.dart";
import "../../../../core/services/session_storage.dart";
import "../../data/datasources/auth_datasource.dart";
import "../../data/datasources/auth_mock_datasource.dart";
import "../../data/datasources/auth_remote_datasource.dart";
import "../../data/datasources/consentement_remote_datasource.dart";
import "../../data/repositories/auth_repository_impl.dart";
import "../../data/repositories/consentement_repository_impl.dart";
import "../../domain/entities/auth_session.dart";
import "../../domain/entities/consentement.dart";
import "../../domain/repositories/auth_repository.dart";
import "../../domain/repositories/consentement_repository.dart";

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  if (AppConfig.useMockData) {
    return AuthMockDatasource();
  }
  // La plupart des routes /auth sont publiques (le serveur ignore un
  // header Authorization absent/inutile), mais devenir-grossiste,
  // redevenir-utilisateur et mot-de-passe exigent une session active —
  // le token doit donc être injecté.
  return AuthRemoteDatasource(buildDioClient(withAuth: true));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

/// Session en mémoire, active pendant la durée de vie de l'app.
/// Persistée sur disque via SessionStorage.
final currentSessionProvider = StateProvider<AuthSession?>((ref) => null);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(ref.watch(secureStorageProvider)),
);

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

/// Le capteur biométrique est-il disponible sur cet appareil ?
final biometricAvailableProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(biometricServiceProvider).isAvailable,
);

final biometricPreferenceStorageProvider = Provider<BiometricPreferenceStorage>(
  (ref) => BiometricPreferenceStorage(ref.watch(secureStorageProvider)),
);

/// Verrouillage biométrique activé pour cet appareil. Par défaut activé
/// dès qu'un capteur est disponible — l'utilisateur peut le désactiver
/// depuis Confidentialité & données.
final biometricLockEnabledProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final stored = await ref.watch(biometricPreferenceStorageProvider).read();
  if (stored != null) return stored;
  return ref.watch(biometricServiceProvider).isAvailable;
});

Future<void> setBiometricLockEnabled(WidgetRef ref, bool enabled) async {
  await ref.read(biometricPreferenceStorageProvider).write(enabled);
  ref.invalidate(biometricLockEnabledProvider);
}

/// Préférences locales "widgets affichés sur mon dashboard" — communes à
/// l'espace Admin et à l'espace Grossiste.
final dashboardWidgetPreferencesStorageProvider =
    Provider<DashboardWidgetPreferencesStorage>(
      (ref) =>
          DashboardWidgetPreferencesStorage(ref.watch(secureStorageProvider)),
    );

final consentementRepositoryProvider = Provider<ConsentementRepository>((ref) {
  return ConsentementRepositoryImpl(
    ConsentementRemoteDatasource(buildDioClient(withAuth: true)),
  );
});

/// Préférences de confidentialité de l'utilisateur connecté.
final consentementProvider = FutureProvider.autoDispose<Consentement>((ref) {
  return ref.watch(consentementRepositoryProvider).consulter();
});
