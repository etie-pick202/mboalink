import "../entities/notification_item.dart";

abstract class NotificationRepository {
  Future<List<NotificationItem>> mesNotifications();

  Future<int> compterNonLues();

  Future<void> marquerCommeLue(String notificationId);

  Future<void> marquerToutesCommeLues();
}
