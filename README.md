# Tiet Kiem

Offline-first Flutter finance app with Drift as on-device source of truth and Supabase for auth, sync, realtime, and wallet-based sharing.

## Stack

- Flutter
- Drift + SQLite
- Riverpod
- Supabase Auth
- Supabase Realtime

## Offline-first architecture

- Reads always come from local Drift tables.
- Writes go to Drift first, then into a local sync queue.
- Sync runs in the background and pushes queued changes to Supabase.
- Realtime updates from Supabase are merged back into Drift.
- Conflict strategy is `updated_at` last-write-wins.

## Supabase setup

1. Create a Supabase project.
2. Run the SQL migration in [supabase/migrations/002_wallet_sharing_refactor.sql](supabase/migrations/002_wallet_sharing_refactor.sql).
3. Copy [.env.example](.env.example) to `.env` in the project root and fill in your own values:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

4. Keep `.env` local only. It is gitignored and must not be committed.
5. Make sure Email + Password auth is enabled in Supabase Auth.

## Flutter setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## What was added

- Multi-user backend schema with `wallets` and `wallet_members`
- RLS policies on all shared tables
- Realtime for `wallets`, `categories`, `transactions`, and `budgets`
- Wallet-scoped sync and sharing
- Local sync queue
- Background sync bootstrap wired from `main.dart`

## Current sync model

- `wallets`, `categories`, `transactions`, and `budgets` are sync-ready
- deletes are soft-deletes using `deleted_at`
- transfer transactions sync with `category_id = null` remotely while local app keeps its existing transfer handling

## Build

```bash
flutter build apk --release
```

## Public repo notes

- Do not commit `.env`, API keys, access tokens, or local CLI state.
- The client uses the Supabase anon key only. Never use a service role key in the app.
