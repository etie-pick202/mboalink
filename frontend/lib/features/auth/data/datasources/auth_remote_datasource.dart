import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";
import "../../../../core/network/api_endpoints.dart";
import "../models/auth_result_model.dart";
import "../models/message_response_model.dart";
import "auth_datasource.dart";

/// Implémentation réelle — appelle le backend Spring Boot Auth (déjà
/// développé et testé via Postman, endpoints /api/v1/auth/**).
class AuthRemoteDatasource implements AuthDatasource {
  const AuthRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<AuthResultModel> inscrire({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    required String motDePasse,
    required String role,
  }) {
    return _post(ApiEndpoints.inscription, {
      "nom": nom,
      "prenom": prenom,
      "email": ?email,
      "telephone": ?telephone,
      "motDePasse": motDePasse,
      "role": role,
    }).then(AuthResultModel.fromJson);
  }

  @override
  Future<AuthResultModel> verifierOtp({
    required String cible,
    required String code,
    required String type,
  }) {
    return _post(ApiEndpoints.verifierOtp, {
      "cible": cible,
      "code": code,
      "type": type,
    }).then(AuthResultModel.fromJson);
  }

  @override
  Future<AuthResultModel> connecter({
    required String identifiant,
    required String motDePasse,
  }) {
    return _post(ApiEndpoints.connexion, {
      "identifiant": identifiant,
      "motDePasse": motDePasse,
    }).then(AuthResultModel.fromJson);
  }

  @override
  Future<AuthResultModel> rafraichir({required String refreshToken}) {
    return _post(ApiEndpoints.refresh, {
      "refreshToken": refreshToken,
    }).then(AuthResultModel.fromJson);
  }

  @override
  Future<MessageResponseModel> deconnecter({required String refreshToken}) {
    return _post(ApiEndpoints.logout, {
      "refreshToken": refreshToken,
    }).then(MessageResponseModel.fromJson);
  }

  @override
  Future<MessageResponseModel> motDePasseOublie({required String identifiant}) {
    return _post(ApiEndpoints.motDePasseOublie, {
      "identifiant": identifiant,
    }).then(MessageResponseModel.fromJson);
  }

  @override
  Future<MessageResponseModel> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) {
    return _post(ApiEndpoints.reinitialiserMotDePasse, {
      "cible": cible,
      "codeOtp": codeOtp,
      "nouveauMotDePasse": nouveauMotDePasse,
    }).then(MessageResponseModel.fromJson);
  }

  @override
  Future<MessageResponseModel> renvoyerOtp({
    required String cible,
    required String type,
  }) {
    return _post(ApiEndpoints.renvoyerOtp, {
      "cible": cible,
      "type": type,
    }).then(MessageResponseModel.fromJson);
  }

  /// POST générique + conversion des erreurs Dio en AppException avec le
  /// message métier renvoyé par le backend (format
  /// { erreur, message, statut, timestamp }).
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? const {};
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body["message"] is String) {
        throw AppException(
          body["message"] as String,
          statusCode: e.response?.statusCode,
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const AppException(
          "Connexion au serveur impossible. Vérifiez votre réseau.",
        );
      }
      throw const AppException("Une erreur inattendue est survenue.");
    }
  }
}
