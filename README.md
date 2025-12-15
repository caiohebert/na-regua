# na_regua

A new Flutter project.

## Supabase authentication

This app uses Supabase Auth and routes based on the current session:

- Logged out: `WelcomeScreen` (from `lib/screens/welcome_screen.dart`)
- Logged in: `MainScaffold` (from `lib/screens/main_scaffold.dart`)

### 1) Configure environment

Create a `.env` file at the project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Supabase is initialized in `lib/main.dart` using `lib/supabase_options.dart`.

### 2) Enable providers in Supabase

- Email/Password: enable in Supabase Dashboard → Authentication → Providers
- (Optional) Google OAuth: enable and configure redirect URLs for your target platforms.

### 2.1) Configure redirect URLs (web)

If you use Google Sign-In on web, add your web origin in Supabase Dashboard → Authentication → URL Configuration → Redirect URLs.

Examples:

- Local dev: `http://localhost:12345/`
- Production: `https://your-domain.com/`

### 3) Where auth is implemented

- Providers: `lib/auth_provider.dart`
	- `sessionProvider`: emits the current `Session?`
	- `authProvider`: methods for sign-in/sign-up/reset/sign-out
- UI:
	- `lib/screens/login_screen.dart` (email/password, reset, Google OAuth)
	- `lib/screens/register_screen.dart` (sign-up)
	- `lib/screens/profile_screen.dart` (shows current user and sign-out)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
