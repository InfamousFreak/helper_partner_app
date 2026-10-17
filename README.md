# EzyHelpers Partner: Helper Partner App

A Flutter prototype for helpers to view assigned jobs, review detailed job specifications, filter/search listings, and update job progress. The application integrates with a local REST API using Riverpod state management and logs non-sensitive user activity using Firebase Analytics.

## Features

- **Helper job list:** Fetches assigned jobs from the REST API. Displays job title, company name, location, salary, experience, priority tags, and status badges. Includes explicit Loading, Empty, and Error states with a manual Retry button.
- **Search and filter (quality improvement):** Live search bar filters jobs by job title or company name.
- **Pull-to-refresh:** Pull down on the list to re-fetch the latest jobs from the server.
- **Job details:** Shows complete job specifications, including required skills (chips), long-form description, work experience, salary, and current status.
- **Status update:** Marks assigned jobs as `IN_PROGRESS` or `COMPLETED` via PATCH requests.
  - Prevents duplicate submissions by disabling the action button while a request is pending.
  - Updates the UI and shows a confirmation SnackBar only after a successful 200 OK response.
- **Firebase Analytics:** Logs `job_list_viewed`, `job_details_viewed`, and `job_status_updated` with non-sensitive parameters. `app_open` is collected automatically.

## Architecture

```
lib/
├── data/
│   ├── api_service.dart        # HTTP client handling GET/PATCH requests, timeouts, and error exceptions
│   └── job.dart                # Job model with JSON serialization and factory constructors
├── presentation/
│   ├── job_detail_screen.dart  # Job specs and status action updates
│   ├── job_list_screen.dart    # Job feed, search filter, and state feedback
│   └── job_provider.dart       # Riverpod providers (jobsProvider, searchQueryProvider)
├── services/
│   └── analytics_service.dart  # Firebase Analytics event wrapper
├── firebase_options.dart       # Generated client configuration for the Firebase project
└── main.dart                   # Entry point: Firebase initialization, ProviderScope, MaterialApp
```

- **State management:** `flutter_riverpod`. `FutureProvider` for network requests and `StateProvider` for the live search query.
- **Data and service layer:** `ApiService` wraps `http.Client` requests with 10-second timeouts. It catches `SocketException` and `TimeoutException` and returns readable error messages.

## Mock API

The app connects to a local json-server instance.

### Local server setup

```
cd mockserver
npx json-server db.json --port 3000
```

### Endpoints

| Method | Path | Description | Body |
|--------|------|-------------|------|
| GET | `/jobs` | Fetch list of assigned jobs | None |
| GET | `/jobs/:id` | Fetch single job detail | None |
| PATCH | `/jobs/:id` | Update job status | `{"status": "IN_PROGRESS"}` or `{"status": "COMPLETED"}` |

### Assumptions

- **Status transitions:** Jobs move in sequence: `ASSIGNED` → `IN_PROGRESS` → `COMPLETED`.
- **Terminal state:** Once a job is `COMPLETED`, further status updates are disabled.
- **Authentication:** The mock endpoints are unauthenticated. A production app would send a Bearer token in the `Authorization` header.

## Device and network configuration

The Flutter app communicates with `http://localhost:3000`. On a physical Android device connected over USB debugging, reverse ADB port forwarding bridges port 3000 on the phone to the host machine:

```
D:\android-sdk\platform-tools\adb.exe reverse tcp:3000 tcp:3000
```

Re-run this command if the USB cable is disconnected or the phone restarts.

## Firebase setup and analytics

- The project is initialized under Firebase project `ezyhelper-partner-2026`.
- Configured with the FlutterFire CLI: `dart pub global run flutterfire_cli:flutterfire configure`. This generates client configuration in `lib/firebase_options.dart`.
- Private keys (`google-services.json`, `GoogleService-Info.plist`) are excluded from source control via `.gitignore`.

### Enabling DebugView on Android

To stream events live into Firebase Console → Analytics → DebugView, or into `adb logcat`:

```
D:\android-sdk\platform-tools\adb.exe shell setprop debug.firebase.analytics.app com.example.helper_partner_app
```

To turn it off, set the value to `.none`.

### Tracked events

| Event | Trigger | Parameters |
|-------|---------|------------|
| `app_open` | Tracked automatically by the Firebase SDK on launch | None |
| `job_list_viewed` | Logged when `JobListScreen` initializes | None |
| `job_details_viewed` | Logged when navigating to `JobDetailScreen` | `job_id`, `job_status` |
| `job_status_updated` | Logged after a PATCH status request succeeds | `job_id`, `job_status` |

No personally identifiable information (names, emails, phone numbers) is logged.

## Setup and running

```
flutter pub get
```

1. Start the mock API server:

   ```
   cd mockserver
   npx json-server db.json --port 3000
   ```

2. Forward the ADB port and launch the app:

   ```
   D:\android-sdk\platform-tools\adb.exe reverse tcp:3000 tcp:3000
   flutter run
   ```

## Automated tests

```
flutter test
```

- `test/job_test.dart`: validates `Job.fromJson` parsing for full payloads, and checks graceful fallback when optional JSON fields are missing.
- `test/widget_test.dart`: app boots and shows the main screen.
- <add your API/error-handling test here, e.g. a timeout or 500 response case>


## Improvement for production

<One paragraph. Example: move the base URL and auth to a config/environment layer, add offline caching with retry, and enforce status transitions on the server.>

## Known limitations

- The base URL is `localhost`, which works only with `adb reverse` over USB.
- An APK shared with others will not reach your laptop's mock server unless the API is hosted online.
- DebugView needs the device debug flag, and it may not receive events on networks that block Google services.
