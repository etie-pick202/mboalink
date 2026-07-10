import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/network/dio_client.dart";
import "../../../auth/presentation/providers/auth_providers.dart";
import "../../data/datasources/admin_remote_datasource.dart";
import "../../data/repositories/admin_repository_impl.dart";
import "../../domain/entities/admin_dashboard_widget.dart";
import "../../domain/entities/avis_moderation.dart";
import "../../domain/entities/dashboard_resume.dart";
import "../../domain/entities/revenu_mensuel.dart";
import "../../domain/entities/validation_fiche.dart";
import "../../domain/repositories/admin_repository.dart";

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    AdminRemoteDatasource(buildDioClient(withAuth: true)),
  );
});

final dashboardResumeProvider = FutureProvider.autoDispose<DashboardResume>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).dashboardResume();
});

final validationsEnAttenteProvider =
    FutureProvider.autoDispose<List<ValidationFiche>>((ref) {
      return ref.watch(adminRepositoryProvider).validationsEnAttente();
    });

final avisAModererProvider = FutureProvider.autoDispose<List<AvisModeration>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).avisAModerer();
});

final revenusDerniers4MoisProvider =
    FutureProvider.autoDispose<List<RevenuMensuel>>((ref) {
      return ref.watch(adminRepositoryProvider).revenusDerniers4Mois();
    });

/// Widgets choisis par l'admin pour son dashboard — tous activés par défaut.
final adminEnabledWidgetsProvider =
    FutureProvider.autoDispose<Set<AdminDashboardWidget>>((ref) async {
      final stored = await ref
          .watch(dashboardWidgetPreferencesStorageProvider)
          .read(AdminDashboardWidget.dashboardId);
      if (stored == null) return AdminDashboardWidget.all;
      return AdminDashboardWidget.values
          .where((w) => stored.contains(w.name))
          .toSet();
    });

Future<void> saveAdminEnabledWidgets(
  WidgetRef ref,
  Set<AdminDashboardWidget> widgets,
) async {
  await ref
      .read(dashboardWidgetPreferencesStorageProvider)
      .write(
        AdminDashboardWidget.dashboardId,
        widgets.map((w) => w.name).toSet(),
      );
  ref.invalidate(adminEnabledWidgetsProvider);
}
