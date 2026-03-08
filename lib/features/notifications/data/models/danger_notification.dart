import 'package:freezed_annotation/freezed_annotation.dart';

part 'danger_notification.freezed.dart';
part 'danger_notification.g.dart';

@freezed
class DangerNotification with _$DangerNotification {
  const factory DangerNotification({
    required String id,
    required String recipientFarmerId,
    required String senderFarmerId,
    required String sprayPlanId,
    required String affectedFieldId,
    String? affectedFieldName,
    String? senderFarmName,
    @Default([]) List<String> dangerousChemicalNames,
    DateTime? sprayScheduledDate,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _DangerNotification;

  factory DangerNotification.fromJson(Map<String, dynamic> json) =>
      _$DangerNotificationFromJson(json);
}
