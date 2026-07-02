# Supabase Sync Testing

Use this checklist to test NutrivoGo sync between Windows and Android.

## Prerequisites

- Supabase tables from `supabase/migrations/001_create_products_and_log_items.sql` are applied.
- Email/password auth is enabled in the Supabase project.
- The personal sync user has been created manually in the Supabase dashboard.
- The app is built with the public Supabase project URL and publishable key.
- Use the same test account on both devices.
- In-app registration is disabled in personal-use mode.

## Windows to Android

1. Run NutrivoGo on Windows.
2. Open Settings and log in with the test account.
3. Close and reopen the app, then confirm Settings still shows the signed-in account.
4. Create a product and add it to Today.
5. Wait a few seconds for auto-sync, or open Settings and tap Sync Now.
6. Confirm the main sync status shows:
   - the expected signed-in account
   - pending products/logs count `0`
   - a last sync timestamp
   - last error `None`
7. Run NutrivoGo on Android.
8. Log in with the same test account.
9. Open Settings and tap Sync Now.
10. Confirm the product and log item appear on Android.

## Android to Windows

1. On Android, create another product and log it.
2. Wait a few seconds for auto-sync, or open Settings and tap Sync Now.
3. On Windows, open Settings and tap Sync Now.
4. Confirm the Android-created product and log item appear on Windows.

## Offline/Pending Check

1. Disconnect the device from the network.
2. Create a product and log it.
3. Open Settings and confirm pending counts increase after auto-sync fails.
4. Tap Sync Now and confirm the error explains that local changes remain pending.
5. Reconnect the network.
6. Tap Sync Now again and confirm pending counts return to `0`.

## Account Isolation Check

1. Log in as account A and sync a product.
2. Log out.
3. Log in as account B.
4. Confirm account A's synced data is not visible.
5. Log back in as account A and sync to confirm account A's data is still available.
