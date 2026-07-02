# Personal Sync Mode

NutrivoGo is currently configured as a personal-use app.

## What this means

- In-app registration is disabled.
- Local tracking works without logging in.
- Supabase login is only for syncing one already-created personal account.
- The app does not create public user accounts.
- The app remembers the last valid Supabase session on this device and tries to restore it on launch.

## Creating the sync user

If sync is needed, create the user manually in the Supabase project:

1. Open the Supabase dashboard.
2. Go to Authentication.
3. Create or invite the personal user account.
4. Use that email and password in NutrivoGo Settings.

Do not put the email, password, service role key, database password, or any other secret in the app source code.

## Sync behavior

- When logged out, Drift/SQLite remains the local source of truth and the app stays usable.
- The Settings sync button shows `Login required for sync` until the personal account is logged in.
- When logged in, the existing Supabase RLS policies still restrict synced rows to the authenticated user.
- Meaningful local changes schedule an automatic sync after a short debounce.
- If auto-sync fails or the device is offline, the local records stay pending and can be retried with `Sync Now`.
- Logout does not delete local data.
- If the saved session expires and cannot be refreshed, NutrivoGo clears the saved session and shows the normal logged-out state.
