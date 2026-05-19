/// Supabase connection config. Supplied at build/run time so no secret is
/// committed:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://YOURPROJECT.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// The URL defaults to the known project; the anon (publishable) key has
/// no safe default and must be provided.

library;

class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://musrkpxcsiytpyrjcnqn.supabase.co',
  );

  // Supabase ANON / publishable key. Safe to ship in the client — security
  // is enforced by Row-Level Security, not key secrecy. (Never put the
  // SERVICE key here.) Still overridable via --dart-define.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11c3JrcHhjc2l5dHB5cmpjbnFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5MjI1OTYsImV4cCI6MjA5NDQ5ODU5Nn0.rAGTYLhRP2RXX2LrWrttXHVvUofC7l320w65SVSKhKM',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
