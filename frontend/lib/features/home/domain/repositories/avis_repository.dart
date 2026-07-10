import "../entities/avis.dart";

abstract class AvisRepository {
  Future<List<Avis>> listerAvis(String ficheGrossisteId);

  Future<AvisBreakdown> breakdown(String ficheGrossisteId);

  Future<Avis> publierAvis({
    required String ficheGrossisteId,
    required int note,
    String? commentaire,
    String? referenceTransaction,
  });
}
