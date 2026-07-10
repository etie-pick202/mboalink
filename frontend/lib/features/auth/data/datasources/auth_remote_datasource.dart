import "package:dio/dio.dart";

import "../../../../core/errors/app_exception.dart";
import "../../domain/entities/auth_session.dart";
import "../../domain/entities/registration_result.dart";
import "../../domain/entities/user_role.dart";
import "auth_datasource.dart";

/// Implémentation réelle des appels API Auth — alignée avec le contrat
/// Postman MboaLink Auth API (deploy_url = https://mboalink.onrender.com/api/v1).
class AuthRemoteDatasource implements AuthDatasource {
  const AuthRemoteDatasource(this._dio);

  final Dio _dio;

  // ── Inscription & OTP ──────────────────────────────────────────────────

  @override
  Future<RegistrationResult> inscrire({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String role,
    String? telephone,
  }) async {
    final response = await _post("/auth/inscription", {
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "motDePasse": motDePasse,
      "role": role,
      if (telephone != null && telephone.isNotEmpty) "telephone": telephone,
    });
    return RegistrationResult(
      utilisateurId: response["utilisateurId"] as String? ?? "",
      emailVerifie: response["emailVerifie"] as bool? ?? false,
    );
  }

  @override
  Future<AuthSession> verifierOtp({
    required String cible,
    required String code,
    required String type,
    required String role,
  }) async {
    final response = await _post("/auth/verifier-otp", {
      "cible": cible,
      "code": code,
      "type": type,
    });
    // Le backend ne retourne pas le role dans cette réponse — on utilise
    // le role passé en paramètre (choisi lors de l'inscription).
    final backendRole = response["role"] as String?;
    return AuthSession(
      accessToken: response["accessToken"] as String,
      refreshToken: response["refreshToken"] as String? ?? "",
      emailVerifie: response["emailVerifie"] as bool? ?? true,
      role: backendRole != null
          ? UserRole.fromApi(backendRole)
          : UserRole.fromApi(role),
      userId: response["utilisateurId"] as String?,
    );
  }

  @override
  Future<void> renvoyerOtp({
    required String cible,
    required String type,
  }) async {
    await _post("/auth/renvoyer-otp", {"cible": cible, "type": type});
  }

  // ── Connexion & Tokens ─────────────────────────────────────────────────

  @override
  Future<AuthSession> connecter({
    required String identifiant,
    required String motDePasse,
  }) async {
    // Clé "identifiant" (pas "email") — alignement avec le contrat backend.
    final response = await _post("/auth/connexion", {
      "identifiant": identifiant,
      "motDePasse": motDePasse,
    });
    return AuthSession(
      accessToken: response["accessToken"] as String,
      refreshToken: response["refreshToken"] as String? ?? "",
      role: UserRole.fromApi(response["role"] as String? ?? "UTILISATEUR"),
      emailVerifie: response["emailVerifie"] as bool? ?? true,
      userId: response["utilisateurId"] as String?,
      nom: response["nom"] as String?,
      prenom: response["prenom"] as String?,
      email: response["email"] as String?,
    );
  }

  @override
  Future<AuthSession> rafraichir(String refreshToken) async {
    // POST /auth/refresh — body: { refreshToken }
    final response = await _post("/auth/refresh", {
      "refreshToken": refreshToken,
    });
    return AuthSession(
      accessToken: response["accessToken"] as String,
      refreshToken: response["refreshToken"] as String? ?? "",
      role: UserRole.fromApi(response["role"] as String? ?? "UTILISATEUR"),
      emailVerifie: true,
    );
  }

  @override
  Future<void> deconnecter(String refreshToken) async {
    // POST /auth/logout — body: { refreshToken }
    await _post("/auth/logout", {"refreshToken": refreshToken});
  }

  // ── Mot de passe ───────────────────────────────────────────────────────

  @override
  Future<void> motDePasseOublie(String identifiant) async {
    await _post("/auth/mot-de-passe-oublie", {"identifiant": identifiant});
  }

  @override
  Future<void> reinitialiserMotDePasse({
    required String cible,
    required String codeOtp,
    required String nouveauMotDePasse,
  }) async {
    await _post("/auth/reinitialiser-mot-de-passe", {
      "cible": cible,
      "codeOtp": codeOtp,
      "nouveauMotDePasse": nouveauMotDePasse,
    });
  }

  @override
  Future<AuthSession> redevenirUtilisateur() async {
    final response = await _post("/auth/redevenir-utilisateur", const {});
    return AuthSession(
      accessToken: response["accessToken"] as String,
      refreshToken: response["refreshToken"] as String? ?? "",
      role: UserRole.fromApi(response["role"] as String? ?? "UTILISATEUR"),
      emailVerifie: response["emailVerifie"] as bool? ?? true,
      userId: response["utilisateurId"] as String?,
      nom: response["nom"] as String?,
      prenom: response["prenom"] as String?,
      email: response["email"] as String?,
    );
  }

  @override
  Future<void> modifierProfil({
    required String nom,
    required String prenom,
  }) async {
    try {
      await _dio.put<Map<String, dynamic>>(
        "/profil",
        data: {"nom": nom, "prenom": prenom},
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      await _dio.put<Map<String, dynamic>>(
        "/auth/mot-de-passe",
        data: {
          "ancienMotDePasse": ancienMotDePasse,
          "nouveauMotDePasse": nouveauMotDePasse,
        },
      );
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  @override
  Future<AuthSession> devenirGrossiste() async {
    final response = await _post("/auth/devenir-grossiste", const {});
    return AuthSession(
      accessToken: response["accessToken"] as String,
      refreshToken: response["refreshToken"] as String? ?? "",
      role: UserRole.fromApi(response["role"] as String? ?? "GROSSISTE"),
      emailVerifie: response["emailVerifie"] as bool? ?? true,
      userId: response["utilisateurId"] as String?,
      nom: response["nom"] as String?,
      prenom: response["prenom"] as String?,
      email: response["email"] as String?,
    );
  }

  // ── Helper ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _toAppException(e);
    }
  }

  AppException _toAppException(DioException e) {
    final body = e.response?.data;
    final statusCode = e.response?.statusCode;

    if (body is Map<String, dynamic>) {
      final message =
          body["message"] as String? ??
          body["erreur"] as String? ??
          body["error"] as String?;
      if (message != null) {
        return AppException(message, statusCode: statusCode);
      }
    }

    return switch (statusCode) {
      400 => const AppException(
        "Données invalides. Vérifiez vos informations.",
      ),
      401 => const AppException("Identifiants incorrects ou session expirée."),
      403 => const AppException("Accès refusé."),
      404 => const AppException("Compte introuvable."),
      409 => const AppException("Un compte existe déjà avec cet email."),
      _ => const AppException("Erreur de connexion au serveur. Réessayez."),
    };
  }
}
