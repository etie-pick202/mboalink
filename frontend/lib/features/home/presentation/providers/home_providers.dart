import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/network/dio_client.dart";
import "../../data/datasources/avis_remote_datasource.dart";
import "../../data/datasources/notification_remote_datasource.dart";
import "../../data/datasources/recherche_remote_datasource.dart";
import "../../data/repositories/avis_repository_impl.dart";
import "../../data/repositories/notification_repository_impl.dart";
import "../../data/repositories/recherche_repository_impl.dart";
import "../../domain/entities/avis.dart";
import "../../domain/entities/contact_debloque.dart";
import "../../domain/entities/fiche_publique.dart";
import "../../domain/entities/grossiste_resume.dart";
import "../../domain/entities/notification_item.dart";
import "../../domain/repositories/avis_repository.dart";
import "../../domain/repositories/notification_repository.dart";
import "../../domain/repositories/recherche_repository.dart";

final rechercheRepositoryProvider = Provider<RechercheRepository>((ref) {
  return RechercheRepositoryImpl(
    RechercheRemoteDatasource(buildDioClient(withAuth: true)),
  );
});

/// Fil d'actualité personnalisé — première page, utilisée sur l'accueil.
final filActualiteProvider =
    FutureProvider.autoDispose<PageResultat<GrossisteResume>>((ref) {
      return ref.watch(rechercheRepositoryProvider).filActualite();
    });

final categoriesProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(rechercheRepositoryProvider).listerCategories();
});

final villesProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(rechercheRepositoryProvider).listerVilles();
});

final secteursProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(rechercheRepositoryProvider).listerSecteurs();
});

final fichePubliqueProvider = FutureProvider.autoDispose
    .family<FichePublique, String>((ref, ficheId) {
      return ref.watch(rechercheRepositoryProvider).consulterFiche(ficheId);
    });

final estDeverrouilleProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, ficheId) {
    return ref.watch(rechercheRepositoryProvider).estDeverrouille(ficheId);
  },
);

final estFavoriProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  ficheId,
) {
  return ref.watch(rechercheRepositoryProvider).estFavori(ficheId);
});

final mesFavorisProvider = FutureProvider.autoDispose<List<GrossisteResume>>((
  ref,
) {
  return ref.watch(rechercheRepositoryProvider).mesFavoris();
});

final mesDeverrouillagesProvider =
    FutureProvider.autoDispose<List<ContactDebloque>>((ref) {
      return ref.watch(rechercheRepositoryProvider).mesDeverrouillages();
    });

final avisRepositoryProvider = Provider<AvisRepository>((ref) {
  return AvisRepositoryImpl(
    AvisRemoteDatasource(buildDioClient(withAuth: true)),
  );
});

final avisListProvider = FutureProvider.autoDispose.family<List<Avis>, String>((
  ref,
  ficheId,
) {
  return ref.watch(avisRepositoryProvider).listerAvis(ficheId);
});

final avisBreakdownProvider = FutureProvider.autoDispose
    .family<AvisBreakdown, String>((ref, ficheId) {
      return ref.watch(avisRepositoryProvider).breakdown(ficheId);
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    NotificationRemoteDatasource(buildDioClient(withAuth: true)),
  );
});

final mesNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) {
      return ref.watch(notificationRepositoryProvider).mesNotifications();
    });

final nonLuesCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(notificationRepositoryProvider).compterNonLues();
});
