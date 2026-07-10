/// Un contact grossiste déjà déverrouillé par l'utilisateur (écran
/// "Contacts débloqués") — reflet de DeverrouillageHistoriqueResponse.
class ContactDebloque {
  const ContactDebloque({
    required this.ficheGrossisteId,
    required this.nomEntreprise,
    this.secteurActivite,
    this.ville,
    this.logoUrl,
    this.telephoneProfessionnel,
    this.emailProfessionnel,
    required this.deverrouilleLe,
    required this.encoreValide,
    this.referenceTransaction,
  });

  final String ficheGrossisteId;
  final String nomEntreprise;
  final String? secteurActivite;
  final String? ville;
  final String? logoUrl;
  final String? telephoneProfessionnel;
  final String? emailProfessionnel;
  final DateTime deverrouilleLe;
  final bool encoreValide;
  final String? referenceTransaction;
}
