import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:na_regua/auth_provider.dart';
import 'package:na_regua/app_theme.dart';
import 'package:na_regua/screens/welcome_screen.dart';
import 'package:na_regua/screens/main_scaffold.dart';
import 'package:na_regua/db/user_db.dart';

// Sample supbase_options.dart file:
//
// const Map<Symbol, dynamic> supabaseOptions = {
//   #url: 'https://qwerty.supabase.co',
//   #anonKey: '1234567890',
// };
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Na Régua',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const AuthenticationWrapper(),
      )
    ),
  );
}

class AuthenticationWrapper extends ConsumerStatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  ConsumerState<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends ConsumerState<AuthenticationWrapper> {
  ProviderSubscription<AsyncValue<AuthState>>? _authStateSub;

  void _createUserIfNeeded(Session session) {
    // Fire-and-forget: do not block UI rendering.
    unawaited(() async {
      try {
        final existing = await getUserFromSession();
        if (existing == null) {
          await insertUserFromSession();
        }
      } catch (e) {
        // Don’t crash the app; allow retry on next auth event.
        debugPrint('User upsert after auth failed: $e');
      }
    }());
  }

  @override
  void initState() {
    super.initState();

    _authStateSub = ref.listenManual(authStateProvider, (previous, next) {
      next.whenData((state) {
        final session = state.session;
        if (session == null) return;

        // Run after auth is actually finished (session is present). This covers:
        // - Web OAuth redirect returning to the app
        // - Mobile native Google idToken sign-in
        _createUserIfNeeded(session);
      });
    });
  }

  @override
  void dispose() {
    _authStateSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      data: (session) {
        return session == null ? const WelcomeScreen() : const MainScaffold();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) {
        return Scaffold(body: Center(child: Text('Error: $error')));
      },
    );
  }
}
