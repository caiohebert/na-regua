import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'supabase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:na_regua/auth_provider.dart';
import 'package:na_regua/app_theme.dart';
import 'package:na_regua/screens/welcome_screen.dart';

// Change to true to enable authentication
// with Google Sign In
const authenticationEnabled = false;

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
        home: authenticationEnabled ? const AuthenticationWrapper() : const WelcomeScreen(),
      ),
    ),
  );
}

class AuthenticationWrapper extends ConsumerWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (AuthState state) {
        return state.session == null ? const SignInPage() : const WelcomeScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) {
        return Scaffold(body: Center(child: Text('Error: $error')));
      },
    );
  }
}

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
