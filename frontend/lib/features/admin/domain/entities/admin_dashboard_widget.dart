import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Widgets disponibles sur le dashboard admin — l'admin choisit lesquels
/// afficher (préférence locale, voir DashboardWidgetPreferencesStorage).
enum AdminDashboardWidget {
  statsUtilisateurs,
  revenueTrend,
  repartitionRoles,
  queues;

  static const dashboardId = "admin";

  static Set<AdminDashboardWidget> get all =>
      AdminDashboardWidget.values.toSet();

  String get label => switch (this) {
    AdminDashboardWidget.statsUtilisateurs => "Totaux utilisateurs",
    AdminDashboardWidget.revenueTrend => "Courbe des revenus",
    AdminDashboardWidget.repartitionRoles => "Répartition clients/grossistes",
    AdminDashboardWidget.queues => "Files d'attente",
  };

  String get description => switch (this) {
    AdminDashboardWidget.statsUtilisateurs =>
      "Nombre d'utilisateurs et de grossistes",
    AdminDashboardWidget.revenueTrend => "Évolution sur les 4 derniers mois",
    AdminDashboardWidget.repartitionRoles => "Part des clients vs grossistes",
    AdminDashboardWidget.queues => "Validations, avis signalés, réinit. note",
  };

  IconData get icon => switch (this) {
    AdminDashboardWidget.statsUtilisateurs => Symbols.groups,
    AdminDashboardWidget.revenueTrend => Symbols.trending_up,
    AdminDashboardWidget.repartitionRoles => Symbols.pie_chart,
    AdminDashboardWidget.queues => Symbols.pending_actions,
  };
}
