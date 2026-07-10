import "../../domain/entities/notification_item.dart";
import "../../domain/repositories/notification_repository.dart";
import "../datasources/notification_remote_datasource.dart";

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._datasource);

  final NotificationRemoteDatasource _datasource;

  @override
  Future<List<NotificationItem>> mesNotifications() async {
    final list = await _datasource.mesNotifications();
    return list
        .map(
          (json) => NotificationItem(
            id: json["id"] as String,
            type: TypeNotification.fromApi(json["type"] as String? ?? ""),
            titre: json["titre"] as String? ?? "",
            message: json["message"] as String?,
            referenceId: json["referenceId"] as String?,
            lu: json["lu"] as bool? ?? false,
            creeLe: DateTime.parse(json["creeLe"] as String),
          ),
        )
        .toList();
  }

  @override
  Future<int> compterNonLues() => _datasource.compterNonLues();

  @override
  Future<void> marquerCommeLue(String notificationId) =>
      _datasource.marquerCommeLue(notificationId);

  @override
  Future<void> marquerToutesCommeLues() => _datasource.marquerToutesCommeLues();
}
