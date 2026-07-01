import 'package:flutter/material.dart';

/// Palette de couleurs MboaLink, extraite directement de la maquette.
class AppColors {
  AppColors._();

  // Couleurs de marque
  static const Color primary = Color(0xFF0A7D4D);      // Vert principal
  static const Color primaryDark = Color(0xFF064D30);  // Vert foncé (dégradés, headers)
  static const Color accent = Color(0xFFF4C430);       // Or/Jaune (badges, accents)

  // Texte
  static const Color textPrimary = Color(0xFF14201A);  // Texte principal
  static const Color textSecondary = Color(0xFF5B6B62);// Texte secondaire
  static const Color textMuted = Color(0xFF6B7770);    // Texte atténué
  static const Color textFaint = Color(0xFF8B948C);    // Texte très atténué (placeholders, métadonnées)

  // Surfaces
  static const Color background = Color(0xFFECEEEA);   // Fond général de l'app
  static const Color surface = Color(0xFFFFFFFF);       // Cartes, fonds blancs
  static const Color surfaceAlt = Color(0xFFF7F8F6);    // Fond alternatif (headers d'écran)
  static const Color border = Color(0xFFE1E6E1);        // Bordures standard
  static const Color borderLight = Color(0xFFE9ECE8);   // Bordures fines (cartes)

  // États
  static const Color error = Color(0xFFE23B3B);
  static const Color success = Color(0xFF0A7D4D);
  static const Color warning = Color(0xFFC79A16);

  // Fonds teintés (chips, badges, états)
  static const Color successBg = Color(0xFFF3FAF6);
  static const Color successBorder = Color(0xFFCFE7D9);
  static const Color warningBg = Color(0xFFFDF3D6);
  static const Color errorBg = Color(0xFFFBEAEA);
}
