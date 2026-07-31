/// Supabase project credentials.
/// The publishable key is safe to commit because it is public-facing, but for
/// production consider using --dart-define or flutter_dotenv.
class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://yffrxorputpzlumsgxlv.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable__LEh6F6qwZbIxdYJ59ZiGg_IzPsV7lp';

  // ── Table names ──────────────────────────────────────────────────────────
  static const String profilesTable = 'profiles';
  static const String fieldsTable = 'fields';
  static const String cropsTable = 'crops';
  static const String fieldCropsTable = 'field_crops';
  static const String chemicalsTable = 'chemicals';
  static const String sprayPlansTable = 'spray_plans';
  static const String sprayPlanChemicalsTable = 'spray_plan_chemicals';
  static const String dangerNotificationsTable = 'danger_notifications';
  static const String cropDusterServicesTable = 'crop_duster_services';

  // ── Realtime channel names ────────────────────────────────────────────────
  static const String fieldUpdatesChannel = 'field-updates';
  static const String notificationsChannel = 'notifications';

  // ── Storage bucket names ──────────────────────────────────────────────────
  static const String profileAvatarsBucket = 'avatars';

  // ── Edge function names ───────────────────────────────────────────────────
  static const String sendNotificationFunction = 'send_notification';
  static const String contactCropDusterFunction = 'contact_crop_duster';
}
