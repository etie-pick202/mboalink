/// Reflet des réponses simples { statut, message } (mot de passe oublié,
/// reset, renvoi OTP, logout...).
class MessageResponseModel {
  const MessageResponseModel({required this.statut, required this.message});

  final String statut;
  final String message;

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      statut: json["statut"] as String? ?? "success",
      message: json["message"] as String? ?? "",
    );
  }
}
