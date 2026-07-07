import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Contenu d'une slide d'onboarding.
class OnboardingSlide {
  const OnboardingSlide({
    required this.icon,
    required this.illustrationCaption,
    required this.titleFr,
    required this.subtitleEn,
    required this.bodyFr,
  });

  final IconData icon;
  final String illustrationCaption;
  final String titleFr;
  final String subtitleEn;
  final String bodyFr;
}

/// Les 3 slides de l'onboarding — la 1ère reprend le contenu exact de la
/// maquette (écran 02), les 2 suivantes prolongent la même trame visuelle
/// sur les autres piliers du cahier des charges.
const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    icon: Symbols.diversity_3,
    illustrationCaption: "illustration · réseau vérifié",
    titleFr: "Un réseau de grossistes vérifiés",
    subtitleEn: "A network of verified wholesalers",
    bodyFr:
        "Comparez les prix, vérifiez la fiabilité et contactez directement les fournisseurs près de chez vous.",
  ),
  OnboardingSlide(
    icon: Symbols.lock_open,
    illustrationCaption: "illustration · accès sécurisé",
    titleFr: "Débloquez les coordonnées en un instant",
    subtitleEn: "Unlock contacts in an instant",
    bodyFr:
        "Payez en toute sécurité via Mobile Money et accédez directement aux contacts des grossistes.",
  ),
  OnboardingSlide(
    icon: Symbols.reviews,
    illustrationCaption: "illustration · avis vérifiés",
    titleFr: "Des avis authentiques et vérifiés",
    subtitleEn: "Genuine, verified reviews",
    bodyFr:
        "Consultez les notes laissées par de vrais acheteurs pour choisir vos fournisseurs en confiance.",
  ),
];
