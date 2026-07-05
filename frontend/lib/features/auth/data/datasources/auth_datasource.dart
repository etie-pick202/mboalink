import "../models/auth_result_model.dart";
import "../models/message_response_model.dart";

/// Contrat commun mock/remote — la couche repository ne connaît que cette
/// interface, jamais l'implémentation concrète.
abstract class AuthDatasource {
  Future<AuthResultModel> inscrire({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String motDePasse,
    required String role,
  });

  Future<AuthResultModel> verifierOtp({
    required String cible,
    required String code,
    required String type,
  });

  Future<AuthResultModel> connecter({
    required String identifiant,
    required String motDePasse,
  });

  Future<AuthResultModel> rafraichir({required String refreshToken});

  Future<MessageResponseModel> deconnecter({required String refreshToken});

  Future<MessageResponseModel> motDePasseOublie({required String identifiant});

  Future<MessageResponseModel> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  });

  Future<MessageResponseModel> renvoyerOtp({
    required String cible,
    required String type,
  });
}
