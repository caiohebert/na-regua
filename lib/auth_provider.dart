import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

const supabaseAuthRedirectUri = 'na-regua://auth-callback';

String supabaseRedirectUri() {
  // Web must use an http(s) origin so the PKCE verifier lives in the same
  // browser storage that completes the callback.
  if (kIsWeb) return '${Uri.base.origin}/';
  return supabaseAuthRedirectUri;
}

final sessionProvider = StreamProvider.autoDispose<Session?>((ref) async* {
  final auth = Supabase.instance.client.auth;
  yield auth.currentSession;
  await for (final state in auth.onAuthStateChange) {
    yield state.session;
  }
});

@riverpod
Stream<AuthState> authState(Ref ref) {
  final supabase = Supabase.instance.client;
  return supabase.auth.onAuthStateChange;
}

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<void> build() {}

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    String? fullName,
  }) {
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: supabaseRedirectUri(),
      data: fullName == null || fullName.trim().isEmpty
          ? null
          : {'full_name': fullName.trim()},
    );
  }

  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) {
    return Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? supabaseRedirectUri(),
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: supabaseRedirectUri(),
        queryParams: {
          'prompt': 'select_account',
        },
      );
    } catch (e) {
      debugPrint('Error signing in with Google (Supabase): $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
