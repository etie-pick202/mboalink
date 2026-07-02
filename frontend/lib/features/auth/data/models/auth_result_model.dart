import "../../domain/entities/auth_session.dart";
import "../../domain/entities/user_role.dart";

/// Reflet brut du JSON AuthResponseDto du backend. Les tokens sont nuls
/// juste après l'inscription (compte pas encore vérifié) — hasTokens
/// permet de distinguer les deux cas sans lever d'exception par erreur.
class AuthResultModel {
  const AuthResultModel({
    required this.utilisateurId,
    required this.role,
    required this.emailVerifie,
    required this.telephoneVerifie,
    this.accessToken,
    this.refreshToken,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.message,
  });

  final String? accessToken;
  final String? refreshToken;
  final String utilisateurId;
  final String role;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final bool emailVerifie;
  final bool telephoneVerifie;
  final String? message;

  bool get hasTokens => accessToken != null && refreshToken != null;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      accessToken: json["accessToken"] as String?,
      refreshToken: json["refreshToken"] as String?,
      utilisateurId: json["utilisateurId"] as String,
      role: json["role"] as String,
      nom: json["nom"] as String?,
      prenom: json["prenom"] as String?,
      email: json["email"] as String?,
      telephone: json["telephone"] as String?,
      emailVerifie: json["emailVerifie"] as bool? ?? false,
      telephoneVerifie: json["telephoneVerifie"] as bool? ?? false,
      message: json["message"] as String?,
    );
  }

  AuthSession toSession() {
    assert(hasTokens, "toSession() appelé sans accessToken/refreshToken.");
    return AuthSession(
      accessToken: accessToken!,
      refreshToken: refreshToken!,
      userId: utilisateurId,
      role: UserRole.fromApi(role),
      emailVerifie: emailVerifie,
      telephoneVerifie: telephoneVerifie,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
    );
  }
}
