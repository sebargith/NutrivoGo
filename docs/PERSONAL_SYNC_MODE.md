# Personal Sync Mode

NutrivoGo is currently configured as a personal-use app.

## What this means

- In-app registration is disabled.
- Local tracking works without logging in.
- Supabase login is only for syncing one already-created personal account.
- The app does not create public user accounts.

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
- Logout does not delete local data.
