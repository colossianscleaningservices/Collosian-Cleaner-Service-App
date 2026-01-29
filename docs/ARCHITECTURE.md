# CCS App Architecture Documentation

## Overview

CCS is a Flutter mobile application built with **GetX** for state management and routing. The app follows a modular architecture pattern with clear separation of concerns, mirroring the structure used in `WAVTech` (same workspace).

## Architecture Pattern

The app uses a **GetX module pattern**:
- **View**: UI screens (`*_view.dart`)
- **Controller**: State + business logic (`*_controller.dart`)
- **Binding**: Dependency injection (`*_binding.dart`)
- **Services**: Cross-cutting concerns (auth, prefs, notifications)
- **Network**: Centralized HTTP client (Dio) + API handler

## Project Structure

```
lib/
├── app/
│   ├── constants/          # App-wide constants
│   ├── modules/            # Feature modules
│   │   ├── splash/
│   │   └── auth/
│   ├── network/            # API layer (Dio + helpers)
│   ├── routes/             # GetX routing configuration
│   └── services/           # Global services (Prefs, Auth, FCM, Network monitor)
├── export.dart             # Central export file (barrel)
└── main.dart               # App entry point
```

## Routing

Routes are defined in:
- `lib/app/routes/app_routes.dart` (constants)
- `lib/app/routes/app_pages.dart` (GetPage list)

## Initialization Flow

1. `main.dart` initializes:
   - `.env` (optional)
   - Local storage (GetStorage via `Prefs`)
   - Firebase (required for FCM)
   - Global DI services (Get.put)
2. App starts at `Routes.SPLASH`
3. Splash routes to role selection (later: route based on token/role)

