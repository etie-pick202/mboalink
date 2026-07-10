import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/network/dio_client.dart";
import "../../data/datasources/payment_remote_datasource.dart";
import "../../data/repositories/payment_repository_impl.dart";
import "../../domain/entities/abonnement.dart";
import "../../domain/entities/plan.dart";
import "../../domain/entities/recu.dart";
import "../../domain/repositories/payment_repository.dart";

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    PaymentRemoteDatasource(buildDioClient(withAuth: true)),
  );
});

/// Abonnement du grossiste connecté, ou null s'il n'en a jamais eu.
final monAbonnementProvider = FutureProvider.autoDispose<Abonnement?>((ref) {
  return ref.watch(paymentRepositoryProvider).monAbonnement();
});

final mesRecusProvider = FutureProvider.autoDispose<List<Recu>>((ref) {
  return ref.watch(paymentRepositoryProvider).mesRecus();
});

/// Plans d'abonnement disponibles pour les grossistes (GET /plans?role=GROSSISTE).
final plansGrossisteProvider = FutureProvider.autoDispose<List<Plan>>((ref) {
  return ref.watch(paymentRepositoryProvider).listerPlans("GROSSISTE");
});

/// true si cette fiche a déjà utilisé sa réinitialisation de note unique.
final aDejaReinitialiseNoteProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, ficheGrossisteId) {
      return ref
          .watch(paymentRepositoryProvider)
          .aDejaReinitialiseNote(ficheGrossisteId);
    });
