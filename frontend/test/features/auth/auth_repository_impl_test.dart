import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:mboalink/features/auth/data/datasources/auth_datasource.dart";
import "package:mboalink/features/auth/data/models/auth_result_model.dart";
import "package:mboalink/features/auth/data/models/message_response_model.dart";
import "package:mboalink/features/auth/data/repositories/auth_repository_impl.dart";
import "package:mboalink/features/auth/domain/entities/user_role.dart";

class _MockAuthDatasource extends Mock implements AuthDatasource {}

void main() {
  late _MockAuthDatasource datasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    datasource = _MockAuthDatasource();
    repository = AuthRepositoryImpl(datasource);
  });

  group("inscrire", () {
    test("retourne la cible email et le message du backend", () async {
      when(
        () => datasource.inscrire(
          nom: any(named: "nom"),
          prenom: any(named: "prenom"),
          email: any(named: "email"),
          telephone: any(named: "telephone"),
          motDePasse: any(named: "motDePasse"),
          role: any(named: "role"),
        ),
      ).thenAnswer(
        (_) async => const AuthResultModel(
          utilisateurId: "id-1",
          role: "UTILISATEUR",
          emailVerifie: false,
          telephoneVerifie: false,
          message:
              "Compte créé. Vérifiez votre email pour activer votre compte.",
        ),
      );

      final result = await repository.inscrire(
        nom: "Mayack",
        prenom: "Etienne",
        email: "etienne@test.cm",
        motDePasse: "MboaLink@2026",
        role: "UTILISATEUR",
      );

      expect(result.cible, "etienne@test.cm");
      expect(result.message, contains("Vérifiez votre email"));
    });
  });

  group("connecter", () {
    test("convertit la réponse en AuthSession avec le bon rôle", () async {
      when(
        () => datasource.connecter(
          identifiant: any(named: "identifiant"),
          motDePasse: any(named: "motDePasse"),
        ),
      ).thenAnswer(
        (_) async => const AuthResultModel(
          accessToken: "access-1",
          refreshToken: "refresh-1",
          utilisateurId: "id-1",
          role: "GROSSISTE",
          emailVerifie: true,
          telephoneVerifie: false,
        ),
      );

      final session = await repository.connecter(
        identifiant: "etienne@test.cm",
        motDePasse: "MboaLink@2026",
      );

      expect(session.accessToken, "access-1");
      expect(session.role, UserRole.grossiste);
    });
  });

  group("motDePasseOublie", () {
    test("retourne le message de confirmation", () async {
      when(
        () =>
            datasource.motDePasseOublie(identifiant: any(named: "identifiant")),
      ).thenAnswer(
        (_) async => const MessageResponseModel(
          statut: "success",
          message: "Un code de réinitialisation vous a été envoyé.",
        ),
      );

      final message = await repository.motDePasseOublie("etienne@test.cm");

      expect(message, "Un code de réinitialisation vous a été envoyé.");
    });
  });
}
