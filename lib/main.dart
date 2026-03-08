import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/supabase_constants.dart';
import 'shared/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();
  // TODO: Register Hive adapters here once models are generated
  // Hive.registerAdapter(FieldAdapter());
  // Hive.registerAdapter(ChemicalAdapter());

  // Initialize local notifications (mobile only — no-op on web)
  await LocalNotificationService.initialize();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
    // realtimeClientOptions can be configured here for Realtime
  );

  runApp(
    // Wrap entire app in ProviderScope for Riverpod
    const ProviderScope(
      child: CropIdApp(),
    ),
  );
}
