import 'package:supabase/supabase.dart';

import 'supabase_config.dart';

SupabaseClient createSupabaseClient() {
  if (!SupabaseConfig.isConfigured) {
    throw StateError('Supabase URL and publishable key are not configured.');
  }
  return SupabaseClient(SupabaseConfig.url, SupabaseConfig.publishableKey);
}
