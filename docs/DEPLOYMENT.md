# Deployment Guide — Vidya Soudha

## Prerequisites

### Flutter App
- Flutter SDK 3.10 or higher
- Dart SDK 3.0+
- Android Studio (for Android emulator) or Xcode (for iOS simulator)
- Android SDK 33+ (API level 33)

### ML Backend
- Python 3.8 or higher
- pip package manager
- Virtual environment support (venv)

### Database
- Supabase account (cloud-hosted PostgreSQL)
- No local database installation needed

---

## Development Setup

### 1. Clone & Install Flutter Dependencies

```bash
cd school_infra_app
flutter pub get
```

### 2. Verify Flutter Setup

```bash
flutter doctor
# Ensure: Flutter, Android toolchain, and connected device show [OK]
```

### 3. Run on Emulator

```bash
# List available devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554

# Run on specific device
flutter run -d <device-id>
```

### 4. Start ML Backend (Optional)

```bash
# From project root
./start_backend.sh

# This will:
# 1. Create Python virtual environment (first time)
# 2. Install dependencies from requirements.txt
# 3. Start uvicorn on http://0.0.0.0:8000
```

**Manual start:**
```bash
cd school-infra-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 5. Backend Environment Variables

Create `school-infra-backend/.env`:
```env
SUPABASE_URL=https://yiihjrxfupuohxzubusv.supabase.co
SUPABASE_KEY=<your-supabase-anon-key>
```

---

## Build Release APK

### Android Release Build

```bash
cd school_infra_app

# Analyze for errors first
flutter analyze

# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build (requires macOS + Xcode)

```bash
flutter build ios --release
```

---

## Network Configuration

### Android Emulator
The Android emulator runs in its own network space. To reach the host machine's localhost:

| Target | URL |
|--------|-----|
| Host machine localhost | `http://10.0.2.2:8000` |
| Emulator's own localhost | `http://localhost:8000` |

**Current configuration** (`api_config.dart`):
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

### Physical Device
Change `api_config.dart` to use your machine's IP:
```dart
static const String baseUrl = 'http://192.168.x.x:8000';
```

### iOS Simulator
iOS simulators share the host's network:
```dart
static const String baseUrl = 'http://localhost:8000';
```

---

## Supabase Configuration

### Current Setup
- **URL**: `https://yiihjrxfupuohxzubusv.supabase.co`
- **Anon Key**: Configured in `api_config.dart` (line 8)
- **Tables**: All prefixed with `si_` (see DATABASE.md)

### Production Migration
For production deployment:

1. Create a dedicated Supabase project
2. Run migration scripts to create tables
3. Update `SupabaseConfig` in `api_config.dart`:
   ```dart
   static const String url = 'https://your-project.supabase.co';
   static const String anonKey = 'your-anon-key';
   ```
4. Enable Row-Level Security on all tables
5. Configure Supabase Auth for real user authentication

---

## Project Structure for Deployment

```
school infrastructure/
  school_infra_app/
    android/                  # Android build configuration
      app/
        build.gradle          # compileSdk, minSdk, targetSdk
        src/main/
          AndroidManifest.xml # Permissions: INTERNET, CAMERA, etc.
    ios/                      # iOS build configuration
    lib/                      # Dart source code
    pubspec.yaml              # Flutter dependencies
    pubspec.lock              # Locked dependency versions

  school-infra-backend/
    app/                      # Python source code
    requirements.txt          # Python dependencies
    .env                      # Environment variables (not committed)
    venv/                     # Virtual environment (not committed)

  notebooks/
    model_analysis.ipynb      # Jupyter notebook with outputs

  docs/                       # Documentation
  start_backend.sh            # Backend launcher
```

---

## Dependencies

### Flutter (pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^3.0.0 | State management |
| supabase_flutter | ^2.3.0 | Database client |
| fl_chart | ^0.66.0 | Charts (bar, line, pie) |
| flutter_map | ^7.0.0 | OpenStreetMap |
| latlong2 | ^0.9.0 | Map coordinates |
| hive_flutter | ^1.1.0 | Local cache |
| dio | ^5.4.0 | HTTP client (backend) |
| share_plus | ^7.0.0 | Share/export files |
| excel | ^4.0.0 | Excel generation |
| pdf | ^3.10.0 | PDF generation |
| path_provider | ^2.1.0 | File system paths |
| image_picker | ^1.0.0 | Camera/gallery |
| intl | ^0.19.0 | Date formatting |

### Python (requirements.txt)

| Package | Version | Purpose |
|---------|---------|---------|
| fastapi | >= 0.109.0 | Web framework |
| uvicorn[standard] | >= 0.27.0 | ASGI server |
| pandas | >= 2.2.0 | Data manipulation |
| numpy | >= 1.26.3 | Numerical operations |
| scikit-learn | >= 1.4.0 | ML models |
| supabase | >= 2.3.4 | Database client |
| python-dotenv | >= 1.0.1 | Environment variables |
| openpyxl | >= 3.1.2 | Excel support |
| pydantic | >= 2.6.0 | Data validation |
| httpx | >= 0.26.0 | HTTP client |

---

## Verification Checklist

After deployment, verify:

- [ ] App launches without crash
- [ ] Role selection screen shows all 5 roles
- [ ] Dashboard loads with real data from Supabase
- [ ] Overview tab shows stats cards and priority pie chart
- [ ] Schools tab loads 319 schools with search/filter
- [ ] Map tab shows school markers with clustering
- [ ] Validation tab shows demand plans with AI validation
- [ ] Analytics tab shows 9 sections with charts
- [ ] School profile shows enrolment chart, forecast, budget planner
- [ ] Backend health indicator shows green dot (if backend running)
- [ ] Forecast shows "AI-Enhanced: LinearRegression" (with backend)
- [ ] Telugu toggle switches all UI text
- [ ] Excel export downloads 3-sheet workbook
- [ ] PDF export generates school report card
- [ ] Offline mode works with cached data

---

## Troubleshooting

### App won't connect to backend
1. Check backend is running: `curl http://localhost:8000/health`
2. Verify URL in `api_config.dart` matches your setup
3. For emulator: use `10.0.2.2` instead of `localhost`

### Supabase connection fails
1. Check internet connectivity
2. Verify Supabase URL and anon key in `api_config.dart`
3. Check RLS policies allow read access

### Flutter analyze shows errors
```bash
flutter pub get   # Re-fetch dependencies
flutter clean     # Clean build cache
flutter analyze   # Re-run analysis
```

### Backend dependency conflicts
```bash
cd school-infra-backend
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```
