import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "../../../../core/config/app_config.dart";
import "../../../../core/network/dio_client.dart";
import "../../../../core/services/biometric_service.dart";
import "../../../../core/services/session_storage.dart";
import "../../data/datasources/auth_datasource.dart";
import "../../data/datasources/auth_mock_datasource.dart";
import "../../data/datasources/auth_remote_datasource.dart";
import "../../data/repositories/auth_repository_impl.dart";
import "../../domain/entities/auth_session.dart";
import "../../domain/repositories/auth_repository.dart";

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  if (AppConfig.useMockData) {
    return AuthMockDatasource();
  }
  // Auth endpoints sont publics — pas besoin du token interceptor.
  return AuthRemoteDatasource(buildDioClient(withAuth: false));
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
