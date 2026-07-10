import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:material_symbols_icons/symbols.dart";

import "../../../../core/constants/app_routes.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_typography.dart";
import "../../domain/entities/notification_item.dart";
import "../providers/home_providers.dart";

/// Écran 21 · Notifications & alertes.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(mesNotificationsProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Symbols.arrow_back,
                          size: 23,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Notifications",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(notificationRepositoryProvider)
                              .marquerToutesCommeLues();
                          ref.invalidate(mesNotificationsProvider);
                          ref.invalidate(nonLuesCountProvider);
                        },
                        child: const Text("Tout marquer lu"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: notifications.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: Text(
                        "Impossible de charger vos notifications.",
                        style: AppTypography.bodySmall,
                      ),
                    ),
                    data: (liste) => liste.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Symbols.notifications_off,
                                  size: 42,
                                  color: AppColors.textFaint,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Aucune notification pour l'instant",
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _GroupedList(notifications: liste),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.notifications});

  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenant = DateTime.now();
    final aujourdhui = <NotificationItem>[];
    final cetteSemaine = <NotificationItem>[];
    final plusAncien = <NotificationItem>[];

    for (final n in notifications) {
      final diff = maintenant.difference(n.creeLe);
      if (diff.inHours < 24 && n.creeLe.day == maintenant.day) {
        aujourdhui.add(n);
      } else if (diff.inDays < 7) {
        cetteSemaine.add(n);
      } else {
        plusAncien.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      children: [
        if (aujourdhui.isNotEmpty) ...[
          _SectionLabel("AUJOURD'HUI"),
          for (final n in aujourdhui) _NotificationTile(notification: n),
        ],
        if (cetteSemaine.isNotEmpty) ...[
          _SectionLabel("CETTE SEMAINE"),
          for (final n in cetteSemaine) _NotificationTile(notification: n),
        ],
        if (plusAncien.isNotEmpty) ...[
          _SectionLabel("PLUS ANCIEN"),
          for (final n in plusAncien) _NotificationTile(notification: n),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9, top: 7),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final NotificationItem notification;

  (IconData, Color, Color) get _style => switch (notification.type) {
    TypeNotification.nouveauGrossiste => (
      Symbols.auto_awesome,
      AppColors.primary,
      AppColors.successBg,
    ),
    TypeNotification.baissePrix => (
      Symbols.sell,
      const Color(0xFFC79A16),
      const Color(0xFFFDF3D6),
    ),
    TypeNotification.recuPaiement => (
      Symbols.receipt_long,
      AppColors.primary,
      AppColors.successBg,
    ),
    TypeNotification.favoriCertifie => (
      Symbols.workspace_premium,
      const Color(0xFFC79A16),
      const Color(0xFFFDF3D6),
    ),
    TypeNotification.autre => (
      Symbols.notifications,
      AppColors.textMuted,
      AppColors.background,
    ),
  };

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return "il y a ${diff.inDays} j";
    if (diff.inHours >= 1) return "il y a ${diff.inHours}h";
    if (diff.inMinutes >= 1) return "il y a ${diff.inMinutes} min";
    return "à l'instant";
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    if (!notification.lu) {
      await ref
          .read(notificationRepositoryProvider)
          .marquerCommeLue(notification.id);
      ref.invalidate(mesNotificationsProvider);
      ref.invalidate(nonLuesCountProvider);
    }
    if (!context.mounted || notification.referenceId == null) return;
    switch (notification.type) {
      case TypeNotification.nouveauGrossiste:
      case TypeNotification.favoriCertifie:
      case TypeNotification.baissePrix:
        context.push("${AppRoutes.fichePublique}/${notification.referenceId}");
      case TypeNotification.recuPaiement:
        context.push(AppRoutes.recus);
      case TypeNotification.autre:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (icon, iconColor, iconBg) = _style;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onTap(context, ref),
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!notification.lu)
                Padding(
                  padding: const EdgeInsets.only(top: 18, right: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.titre,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    if (notification.message != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        "${notification.message} · ${_formatDate(notification.creeLe)}",
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
