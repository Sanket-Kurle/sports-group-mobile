# Playly — Sports Group Mobile

Flutter client for recurring amateur sports groups. Playly brings session planning, RSVP, actual attendance, group expenses, member ledgers, and manual payment approvals into one group-scoped experience.

## MVP experience

- Phone-first onboarding shell (demo authentication until Firebase is configured)
- Multi-group switching with independent roles and balances
- Home dashboard with the next session, balance, pending actions, and activity
- Upcoming/previous sessions, session creation, RSVP, capacity, and waitlist states
- Separate locked attendance and settlement review interfaces
- Member ledger, immutable transaction history, and payment submission
- Treasurer workspace with payment approvals and member balances
- Group roster, per-group roles, invites, settings, and audit activity
- Group-scoped chat with messages, replies, reactions, mentions, search, attachments, announcements, and structured session/payment cards
- Profile and notification preferences

The current data layer is an interactive in-memory demo so the entire UI can be reviewed without infrastructure. Authoritative authentication, permissions, settlement calculations, ledger writes, and payment approval persistence must be connected to `sports-group-api`; they must not be reimplemented as trusted client logic.

## Run

```sh
flutter pub get
flutter run
```

The demo sign-in button bypasses OTP and enters the app directly.

## Verify

```sh
flutter analyze
flutter test
flutter build web --release
```

## Structure

```text
lib/
├── core/       # theme and formatting
├── data/       # demo fixtures; API adapters belong here
├── domain/     # group, session, ledger, and payment models
├── features/   # auth, home, sessions, finance, group, profile
├── state/      # Riverpod application state
├── widgets/    # shared visual components
├── app.dart    # GoRouter graph and app root
└── main.dart
```

PostgreSQL through the NestJS API is the source of truth. Firebase is reserved for authentication, push notifications, storage, crash reporting, and analytics.
