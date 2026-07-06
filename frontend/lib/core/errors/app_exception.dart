/// Exception métier unifiée : toute la couche data convertit ses erreurs
/// (réseau, backend, mock) vers ce type, pour que la présentation n'ait
/// jamais à connaître Dio ou le format d'erreur du backend.
class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
