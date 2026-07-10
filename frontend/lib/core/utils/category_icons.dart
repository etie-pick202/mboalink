import "package:flutter/widgets.dart";
import "package:material_symbols_icons/symbols.dart";

/// Associe une icône à un libellé de catégorie. Les catégories ne stockent
/// pas d'icône côté backend : on la dérive du nom, avec un repli sur une
/// icône générique (`Symbols.category`) pour toute catégorie inconnue.
///
/// La correspondance est insensible à la casse et aux accents, et se fait
/// par mots-clés — une catégorie « Mode & Vêtements » comme « vetements »
/// tombent toutes deux sur l'icône vêtements.
IconData categoryIcon(String? nom) {
  if (nom == null || nom.trim().isEmpty) return Symbols.category;
  final n = _normaliser(nom);

  // L'ordre compte : on teste du plus spécifique au plus générique.
  for (final entry in _rules) {
    for (final motCle in entry.motsCles) {
      if (n.contains(motCle)) return entry.icone;
    }
  }
  return Symbols.category;
}

class _Rule {
  const _Rule(this.motsCles, this.icone);
  final List<String> motsCles;
  final IconData icone;
}

const _rules = <_Rule>[
  _Rule(["aliment", "epicerie", "vivre", "provision"], Symbols.restaurant),
  _Rule(["agroaliment", "agro"], Symbols.agriculture),
  _Rule(["boisson", "buvette", "vin", "biere"], Symbols.local_bar),
  _Rule(["cosmetique", "beaute", "parfum"], Symbols.spa),
  _Rule([
    "electronique",
    "electro",
    "informatique",
    "ordinateur",
  ], Symbols.devices),
  _Rule(["telephon", "mobile", "gsm"], Symbols.smartphone),
  _Rule([
    "mode",
    "vetement",
    "habillement",
    "textile",
    "pret-a-porter",
  ], Symbols.checkroom),
  _Rule(["chaussure"], Symbols.footprint),
  _Rule(["quincaillerie", "outil", "outillage"], Symbols.hardware),
  _Rule([
    "materiaux",
    "construction",
    "batiment",
    "ciment",
  ], Symbols.foundation),
  _Rule(["menager", "maison", "electromenager"], Symbols.home_iot_device),
  _Rule(["papeterie", "bureautique", "bureau", "librairie"], Symbols.edit_note),
  _Rule([
    "sante",
    "pharmacie",
    "medical",
    "medicament",
  ], Symbols.medical_services),
  _Rule([
    "automobile",
    "auto",
    "piece",
    "vehicule",
    "moto",
  ], Symbols.directions_car),
  _Rule(["agriculture", "elevage", "ferme", "semence"], Symbols.agriculture),
  _Rule(["jouet", "enfant", "bebe", "puericulture"], Symbols.toys),
  _Rule(["meuble", "ameublement", "decoration", "deco"], Symbols.chair),
  _Rule(["bijou", "montre", "accessoire", "or", "joaillerie"], Symbols.diamond),
  _Rule(["sport", "fitness", "loisir"], Symbols.sports_soccer),
];

String _normaliser(String valeur) {
  final bas = valeur.toLowerCase().trim();
  const accents = {
    "à": "a",
    "â": "a",
    "ä": "a",
    "é": "e",
    "è": "e",
    "ê": "e",
    "ë": "e",
    "î": "i",
    "ï": "i",
    "ô": "o",
    "ö": "o",
    "ù": "u",
    "û": "u",
    "ü": "u",
    "ç": "c",
  };
  final buffer = StringBuffer();
  for (final rune in bas.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(accents[ch] ?? ch);
  }
  return buffer.toString();
}
