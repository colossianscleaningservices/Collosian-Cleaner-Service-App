# Development Guide (CCS)

## Setup

1. Install Flutter (3.27+ recommended)
2. Install dependencies: `flutter pub get`
3. Optional environment variables:
   - Create `.env` in project root
   - Add `API_BASE_URL=...`

## Adding a New Feature Module

Create module structure:

```
lib/app/modules/feature_name/
├── feature_name_view.dart
├── feature_name_controller.dart
├── feature_name_binding.dart
└── widgets/ (optional)
```

Wire routing:
- Add route constant in `lib/app/routes/app_routes.dart`
- Add route definition in `lib/app/routes/app_pages.dart`

## Conventions

- Keep views thin; put business logic in controllers.
- Use services for cross-module concerns (Auth, Prefs, FCM).
- Use Dio client from DI for HTTP calls.

## Common Commands

- Analyze: `flutter analyze`
- Test: `flutter test`
- Clean: `flutter clean && flutter pub get`

