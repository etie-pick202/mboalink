import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Widgets disponibles sur le dashboard grossiste — le grossiste choisit
/// lesquels afficher (préférence locale, voir
/// DashboardWidgetPreferencesStorage). L'abonnement et les actions
/// rapides restent toujours visibles (informations critiques).
enum GrossisteDashboardWidget {
  statsVues,
  vuesChart,
  maNote,
  mesProduits;

  static const dashboardId = "grossiste";

  static Set<GrossisteDashboardWidget> get all =>
      GrossisteDashboardWidget.values.toSet();

  String get label => switch (this) {
    GrossisteDashboardWidget.statsVues => "Vues et contacts débloqués",
    GrossisteDashboardWidget.vuesChart => "Courbe des vues (7 jours)",
    GrossisteDashboardWidget.maNote => "Ma note",
    GrossisteDashboardWidget.mesProduits => "Mes produits",
  };

  String get description => switch (this) {
    GrossisteDashboardWidget.statsVues =>
      "Nombre de vues ce mois et de contacts débloqués",
    GrossisteDashboardWidget.vuesChart => "Évolution des vues sur 7 jours",
    GrossisteDashboardWidget.maNote => "Note moyenne et nombre d'avis",
    GrossisteDashboardWidget.mesProduits => "Nombre de produits en boutique",
  };

  IconData get icon => switch (this) {
    GrossisteDashboardWidget.statsVues => Symbols.query_stats,
    GrossisteDashboardWidget.vuesChart => Symbols.trending_up,
    GrossisteDashboardWidget.maNote => Symbols.star,
    GrossisteDashboardWidget.mesProduits => Symbols.inventory_2,
  };
}
