import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/config/app_config.dart";
import "../../../../core/network/dio_client.dart";
import "../../data/datasources/auth_datasource.dart";
import "../../data/datasources/auth_mock_datasource.dart";
import "../../data/datasources/auth_remote_datasource.dart";
import "../../data/repositories/auth_repository_impl.dart";
import "../../domain/repositories/auth_repository.dart";

/// Bascule automatiquement mock <-> remote selon AppConfig.useMockData —
/// le reste de l'app ne dépend que de authRepositoryProvider.
final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  if (AppConfig.useMockData) {
    return AuthMockDatasource();
  }
  return AuthRemoteDatasource(buildDioClient());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});
