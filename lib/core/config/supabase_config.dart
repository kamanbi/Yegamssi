import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    final url = AppConfig.supabaseUrl;
    final anonKey = AppConfig.supabaseAnonKey;

    // .env에 값이 없으면 초기화 건너뜀 (Phase 1 개발 시)
    if (url.isEmpty || anonKey.isEmpty) return;

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
