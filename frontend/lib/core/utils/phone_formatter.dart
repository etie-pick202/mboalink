/// Construit le format attendu par le backend (+2376XXXXXXXX) à partir
/// d'un numéro local saisi par l'utilisateur (ex: "690000000" ou
/// "6 90 00 00 00").
class PhoneFormatter {
  PhoneFormatter._();

  static String toE164Cameroon(String local) {
    final digits = local.replaceAll(RegExp(r"\D"), "");
    return "+237$digits";
  }
}
