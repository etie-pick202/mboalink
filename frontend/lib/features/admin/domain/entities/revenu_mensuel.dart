/// Revenu total d'un mois donné — reflet de RevenuMensuelDTO.
class RevenuMensuel {
  const RevenuMensuel({
    required this.mois,
    required this.numeroMois,
    required this.total,
  });

  final String mois;
  final int numeroMois;
  final double total;
}
