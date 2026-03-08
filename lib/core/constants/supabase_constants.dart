/// Supabase project credentials.
/// TODO: Replace with your actual Supabase project URL and anon key.
/// These are safe to commit (anon key is public-facing), but for
/// production consider using --dart-define or flutter_dotenv.
class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://vwyeasxwrwejlxyydjnf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3eWVhc3h3cndlamx4eXlkam5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3NzUzNjcsImV4cCI6MjA4ODM1MTM2N30.RDT4e1bWChAMYLz8GK83D_OoWIWhRkgrNo19GYVwCxQ';

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
