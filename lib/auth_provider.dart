import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

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

  Future<void> signInWithGoogle() async {
    try {
      final supabaseAuth = Supabase.instance.client.auth;

      // Web uses OAuth redirect flow.
      if (kIsWeb) {
        debugPrint('Starting Google OAuth sign-in...');

        // Use externalApplication mode to force opening in a new tab/window
        // This avoids popup blockers and iframe issues
        final result = await supabaseAuth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? Uri.base.toString() : null,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );

        debugPrint('OAuth initiated: $result');
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        // Mobile uses native Google Sign-In, then exchanges token with Supabase.
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();

        final account = await googleSignIn.authenticate(
          scopeHint: const ['email', 'profile'],
        );

        final googleAuth = account.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw const AuthException('Missing Google idToken');
        }

        await supabaseAuth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
      } else {
        throw UnsupportedError('Google sign-in not supported on this platform');
      }
    } catch (e) {
      debugPrint('Error signing in with Google (Supabase): $e');
      rethrow;
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in with email/password: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
    } catch (e) {
      debugPrint('Error signing up with email/password: $e');
      rethrow;
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
