class AppConstants {
  AppConstants._();

  // ── Map defaults ─────────────────────────────────────────────────────────
  /// Default zoom level when the map first opens
  static const double defaultMapZoom = 14.0;

  /// Radius (in meters) to search for adjacent fields
  static const double adjacentFieldRadiusMeters = 500.0;

  /// OpenStreetMap tile URL template (no API key required)
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ── Hive box names ───────────────────────────────────────────────────────
  static const String fieldsBox = 'fields_box';
  static const String chemicalsBox = 'chemicals_box';
  static const String userPrefsBox = 'user_prefs_box';

  // ── Notification channel IDs ─────────────────────────────────────────────
  static const String dangerNotifChannelId = 'crop_danger_channel';
  static const String dangerNotifChannelName = 'Crop Danger Alerts';

  // ── Workflow status labels ───────────────────────────────────────────────
  static const String saveStateIdleLabel = 'Ready to save';
  static const String saveStateSavingLabel = 'Saving plan...';
  static const String saveStateSavedLabel = 'Plan saved';
  static const String saveStateFailedLabel = 'Save failed';
  static const String retryActionLabel = 'Retry';

  static const String alertStateUnreadLabel = 'Unread';
  static const String alertStateReviewedLabel = 'Reviewed';

  static const String contactStateReadyLabel = 'Ready to contact service';
  static const String contactStateUnavailableLabel =
      'Contact channel unavailable';

  // ── Privacy defaults ─────────────────────────────────────────────────────
  /// Whether a new farmer's field data is shared by default
  static const bool defaultFieldSharingEnabled = false;

  // ── App info ─────────────────────────────────────────────────────────────
  static const String appName = 'CropID';
  static const String supportEmail = 'support@cropid.app';
}
