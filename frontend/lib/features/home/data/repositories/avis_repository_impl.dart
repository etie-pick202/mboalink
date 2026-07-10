import "../../domain/entities/avis.dart";
import "../../domain/repositories/avis_repository.dart";
import "../datasources/avis_remote_datasource.dart";

class AvisRepositoryImpl implements AvisRepository {
  const AvisRepositoryImpl(this._datasource);

  final AvisRemoteDatasource _datasource;

  @override
  Future<List<Avis>> listerAvis(String ficheGrossisteId) async {
    final list = await _datasource.listerAvis(ficheGrossisteId);
    return list.map(_avisFromJson).toList();
  }

  @override
  Future<AvisBreakdown> breakdown(String ficheGrossisteId) async {
    final json = await _datasource.breakdown(ficheGrossisteId);
    final cinq = json["fiveStars"] as int? ?? 0;
    final quatre = json["fourStars"] as int? ?? 0;
    final trois = json["threeStars"] as int? ?? 0;
    final deux = json["twoStars"] as int? ?? 0;
    final un = json["oneStar"] as int? ?? 0;
    final total = json["total"] as int? ?? (cinq + quatre + trois + deux + un);
    final somme = cinq * 5 + quatre * 4 + trois * 3 + deux * 2 + un;
    return AvisBreakdown(
      moyenne: total == 0 ? 0 : somme / total,
      total: total,
      cinq: cinq,
      quatre: quatre,
      trois: trois,
      deux: deux,
      un: un,
    );
  }

  @override
  Future<Avis> publierAvis({
    required String ficheGrossisteId,
    required int note,
    String? commentaire,
    String? referenceTransaction,
  }) async {
    final json = await _datasource.publierAvis(
      ficheGrossisteId: ficheGrossisteId,
      note: note,
      commentaire: commentaire,
      referenceTransaction: referenceTransaction,
    );
    return _avisFromJson(json);
  }

  Avis _avisFromJson(Map<String, dynamic> json) {
    return Avis(
      id: json["id"] as String,
      utilisateurNom: json["utilisateurNom"] as String? ?? "Utilisateur",
      note: json["note"] as int? ?? 0,
      commentaire: json["commentaire"] as String?,
      transactionVerifiee: json["transactionVerifiee"] as bool? ?? false,
      creeLe: DateTime.parse(json["creeLe"] as String),
    );
  }
}
