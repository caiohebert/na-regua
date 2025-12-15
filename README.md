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

- Google OAuth: enable and configure redirect URLs for your target platforms.

### 3) Where auth is implemented

- Providers: `lib/auth_provider.dart`
	- `sessionProvider`: emits the current `Session?`
	- `authProvider`: method for Google sign-in
- UI:
	- `lib/screens/login_screen.dart` (Google OAuth)
	- `lib/screens/profile_screen.dart` (shows current user and sign-out)
