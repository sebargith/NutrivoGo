class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://teywdipydfvcgsymgqqh.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_V7KyMKFKepVN8viS17_Y8A_K9MPhJF7',
  );

  static bool get isConfigured =>
      url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;
}
