import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";
import "../models/abonnement_model.dart";
import "../models/plan_model.dart";
import "../models/recu_model.dart";
import "../models/transaction_model.dart";

/// Endpoints du domaine paiement (/api/v1/transactions, /abonnements,
/// /recus) — contrairement au reste du backend, ces contrôleurs renvoient
/// systématiquement une enveloppe {success, message, data}. Exception :
/// /plans, qui renvoie une liste brute (même convention que /search/**).
class PaymentRemoteDatasource {
  const PaymentRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<PlanModel>> listerPlans(String role) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        "/plans",
        queryParameters: {"role": role},
      );
      final list = response.data ?? const [];
      return list.cast<Map<String, dynamic>>().map(PlanModel.fromJson).toList();
    } on DioException catch (e) {
      final body = e.response?.data;
      final statusCode = e.response?.statusCode;
      if (body is Map<String, dynamic> && body["message"] is String) {
        throw AppException(body["message"] as String, statusCode: statusCode);
      }
      throw AppException(
        "Une erreur est survenue lors de la communication avec le serveur.",
        statusCode: statusCode,
      );
    }
  }

  Future<TransactionModel> initierPaiement({
    required String typeTransaction,
    required double montant,
    required String operateur,
    required String numeroTelephone,
    required String description,
    String? ficheGrossisteId,
  }) async {
    final json = await _post("/transactions", {
      "typeTransaction": typeTransaction,
      "montant": montant,
      "operateur": operateur,
      "numeroTelephonePaiement": numeroTelephone,
      "description": description,
      "ficheGrossisteId": ?ficheGrossisteId,
    });
    if (json["success"] != true) {
      throw AppException(
        json["message"] as String? ?? "Échec de l'initiation du paiement.",
      );
    }
    return TransactionModel.fromCreationJson(json);
  }

  Future<String> verifierStatut(String transactionId) async {
    final json = await _get("/transactions/$transactionId/status");
    return json["status"] as String? ?? "EN_ATTENTE";
  }

  Future<AbonnementModel?> monAbonnement() async {
    try {
      final json = await _get("/abonnements/my");
      return AbonnementModel.fromJson(json["data"] as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<AbonnementModel> creerAbonnement({
    required String typeAbonnement,
    required double montant,
    required bool renouvellementAuto,
    required String transactionId,
  }) async {
    final json = await _post("/abonnements?transactionId=$transactionId", {
      "typeAbonnement": typeAbonnement,
      "montant": montant,
      "renouvellementAuto": renouvellementAuto,
    });
    if (json["success"] != true) {
      throw AppException(
        json["message"] as String? ?? "Échec de la création de l'abonnement.",
      );
    }
    return AbonnementModel.fromJson(json["data"] as Map<String, dynamic>);
  }

  Future<AbonnementModel> renouvelerAbonnement(String transactionId) async {
    final json = await _post(
      "/abonnements/renew?transactionId=$transactionId",
      const {},
    );
    if (json["success"] != true) {
      throw AppException(
        json["message"] as String? ?? "Échec du renouvellement.",
      );
    }
    return AbonnementModel.fromJson(json["data"] as Map<String, dynamic>);
  }

  Future<void> suspendreAbonnement() async {
    await _post("/abonnements/suspend", const {});
  }

  Future<List<RecuModel>> mesRecus({int limit = 20}) async {
    final json = await _get("/recus/user/recent?limit=$limit");
    final list = json["data"] as List<dynamic>? ?? const [];
    return list.cast<Map<String, dynamic>>().map(RecuModel.fromJson).toList();
  }

  Future<void> reinitialiserNote({
    required String ficheGrossisteId,
    required String transactionId,
  }) async {
    final json = await _post("/reinitialisations-note", {
      "ficheGrossisteId": ficheGrossisteId,
      "transactionId": transactionId,
    });
    if (json["success"] != true) {
      throw AppException(
        json["message"] as String? ?? "Échec de la réinitialisation de note.",
      );
    }
  }

  Future<bool> aDejaReinitialiseNote(String ficheGrossisteId) async {
    final json = await _get("/reinitialisations-note/$ficheGrossisteId");
    final list = json["data"] as List<dynamic>? ?? const [];
    return list.isNotEmpty;
  }

  Future<void> demanderCertification({
    required String ficheGrossisteId,
    required String transactionId,
  }) async {
    final json = await _post("/certifications-premium", {
      "ficheGrossisteId": ficheGrossisteId,
      "transactionId": transactionId,
    });
    if (json["success"] != true) {
      throw AppException(
        json["message"] as String? ??
            "Échec de l'activation de la certification.",
      );
    }
  }

  Future<Map<String, dynamic>> _get(String path) =>
      _handle(() => _dio.get<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> data) =>
      _handle(() => _dio.post<Map<String, dynamic>>(path, data: data));

  Future<Map<String, dynamic>> _handle(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data ?? const {};
    } on DioException catch (e) {
      final body = e.response?.data;
      final statusCode = e.response?.statusCode;
      if (body is Map<String, dynamic> && body["message"] is String) {
        throw AppException(body["message"] as String, statusCode: statusCode);
      }
      throw AppException(
        "Une erreur est survenue lors de la communication avec le serveur.",
        statusCode: statusCode,
      );
    }
  }
}
