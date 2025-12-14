import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'supabase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:na_regua/auth_provider.dart';
import 'package:na_regua/app_theme.dart';
import 'package:na_regua/screens/welcome_screen.dart';
import 'package:na_regua/screens/main_scaffold.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

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
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<void> _handleAuthCallbackUri(Uri uri) async {
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) return;

    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
    } on AuthException catch (e) {
      debugPrint('Auth callback error: ${e.message}');
    } catch (e) {
      debugPrint('Auth callback error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Web OAuth callback returns to the current URL (http/https). Handle it on startup.
    if (kIsWeb) {
      // Fire-and-forget; auth state will update the UI once session is set.
      unawaited(_handleAuthCallbackUri(Uri.base));
    }

    // This stream provides the initial link (cold start) and subsequent links.
    _sub = _appLinks.uriLinkStream.listen(
      (uri) async {
        await _handleAuthCallbackUri(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Na Régua',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends ConsumerWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      data: (session) {
        return session == null ? const WelcomeScreen() : const MainScaffold();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) {
        return Scaffold(body: Center(child: Text('Error: $error')));
      },
    );
  }
}
