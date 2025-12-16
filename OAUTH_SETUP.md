# Google OAuth Setup Guide

## Issue: Can't Interact with Google Login Page

If you're experiencing issues where you can't click or type on the Google login page, follow these steps:

## 1. Configure Supabase Redirect URLs

Go to your Supabase Dashboard:
1. Navigate to **Authentication** → **URL Configuration**
2. Add these URLs to **Redirect URLs**:
   ```
   http://localhost:*
   http://localhost:8080/*
   http://localhost:8080
   ```
3. Set **Site URL** to: `http://localhost:8080` (or your dev server URL)
4. Click **Save**

## 2. Enable Google OAuth Provider

1. Go to **Authentication** → **Providers**
2. Find **Google** in the list
3. Click to expand it
4. Toggle **Enable Sign in with Google**
5. Add your Google OAuth credentials:
   - **Client ID** (from Google Cloud Console)
   - **Client Secret** (from Google Cloud Console)
6. Click **Save**

## 3. Configure Google Cloud Console

You need to set up OAuth 2.0 in Google Cloud Console:

### Step 1: Create OAuth Credentials
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Choose **Web application**
6. Add these **Authorized JavaScript origins**:
   ```
   http://localhost:8080
   http://localhost
   ```
7. Add these **Authorized redirect URIs**:
   ```
   https://gubjgwuwskflxzzkkdlp.supabase.co/auth/v1/callback
   http://localhost:8080
   ```
8. Click **Create**
9. Copy the **Client ID** and **Client Secret**
10. Paste them into Supabase (Step 2 above)

### Step 2: Configure OAuth Consent Screen
1. Go to **OAuth consent screen**
2. Choose **External** (for testing)
3. Fill in required fields:
   - App name: **Na Régua**
   - User support email: Your email
   - Developer contact: Your email
4. Add test users if needed
5. Save and continue

## 4. Browser Settings

### Allow Popups
1. In Chrome, click the icon in the address bar (🚫 or similar)
2. Select **Always allow pop-ups and redirects**
3. Reload the page

### Clear Cache
1. Press `Ctrl + Shift + Delete`
2. Select **Cached images and files**
3. Click **Clear data**

## 5. Test the Flow

1. Stop your Flutter app
2. Run: `flutter clean`
3. Run: `flutter run -d chrome`
4. Click **"Continuar com Google"**
5. A new tab should open with Google's login page
6. You should now be able to click and type

## Troubleshooting

### Problem: New tab opens but is blank
- Check your Supabase redirect URLs (Step 1)
- Verify Google OAuth is enabled (Step 2)

### Problem: "Invalid redirect URI" error
- Double-check the redirect URI in Google Cloud Console
- Make sure it matches: `https://YOUR-PROJECT.supabase.co/auth/v1/callback`

### Problem: Page opens but I still can't click
- Try a different browser (Firefox, Edge)
- Disable browser extensions temporarily
- Check browser console for errors (F12 → Console tab)

### Problem: "Access blocked" message
- Your app needs to be verified by Google (for production)
- For testing: Add your email as a test user in OAuth consent screen

## Code Changes Made

The app now uses `LaunchMode.externalApplication` which forces OAuth to open in a new browser tab instead of a popup window. This should resolve most interaction issues.

## Need Help?

1. Check the browser console (F12) for errors
2. Check Supabase logs in the Dashboard
3. Verify all URLs match exactly (no trailing slashes differences)


