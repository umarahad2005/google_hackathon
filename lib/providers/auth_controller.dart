/// Supabase email/password auth, exposed through Riverpod. The app's
/// identity for multi-tenancy comes from here — the Dio interceptor
/// attaches this session's JWT to every backend call.

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Emits on every sign-in / sign-out / token refresh.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// The signed-in user, or null. Rebuilds when [authStateProvider] ticks.
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

class AuthController extends AsyncNotifier<void> {
  @override
  void build() {}

  SupabaseClient get _client => ref.read(supabaseClientProvider);

  Future<bool> signIn(String email, String password) =>
      _run(() => _client.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          ));

  Future<bool> signUp(String email, String password) =>
      _run(() => _client.auth.signUp(
            email: email.trim(),
            password: password,
          ));

  Future<void> signOut() => _client.auth.signOut();

  String _friendly(String message) {
    final m = message.toLowerCase();
    if (m.contains('not confirmed')) {
      return 'Email not confirmed. Confirm it from your inbox, or have '
          'the admin turn off email confirmation in Supabase.';
    }
    if (m.contains('invalid login')) {
      return 'Incorrect email or password.';
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'That email is already registered — sign in instead.';
    }
    return message;
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading<void>();
    try {
      await action();
      state = const AsyncData<void>(null);
      return true;
    } on AuthException catch (e, st) {
      state = AsyncError<void>(_friendly(e.message), st);
      return false;
    } catch (e, st) {
      state = AsyncError<void>('Something went wrong. Please try again.', st);
      return false;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
