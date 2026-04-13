# Firestore Integration - AquaSense

## Overview
Real-time data fetching from Firestore has been successfully integrated into the AquaSense Flutter application. The app now retrieves sensor data from Firestore collection `realtime_data`, document `device_1`.

## Changes Made

### 1. **pubspec.yaml** 
Added Firebase dependencies:
- `firebase_core: ^3.0.0` - Firebase core library
- `cloud_firestore: ^5.0.0` - Firestore database library

### 2. **lib/main.dart**
- Added Firebase initialization in `main()` using `Firebase.initializeApp()`
- Added `WidgetsFlutterBinding.ensureInitialized()` before Firebase initialization

### 3. **lib/service/api_service.dart**
Added two new methods:
- `getRealtimeData()` - Fetch one-time data from Firestore
- `getRealtimeDataStream()` - Stream real-time updates from Firestore

The stream listens to document `realtime_data/device_1` and automatically updates whenever data changes.

### 4. **lib/pages/home.dart**
Updated state variables:
- `currentTempAir` - Water temperature (suhu_air)
- `currentTempLingkungan` - Environment temperature (suhu_lingkungan)
- `currentDO` - Dissolved oxygen (dissolved_oxygen)
- `currentTurbidity` - Water turbidity (turbidity)
- `currentPH` - Water pH (pH_air)
- `currentTDS` - Total dissolved solids (tds)
- `stokPakan` - Food stock percentage (pakan_percent)
- `updatedAt` - Last update timestamp

Methods added:
- `_initializeFirestore()` - Initialize Firestore connection
- `_listenToFirestoreData()` - Listen to real-time updates from Firestore

## Firestore Collection Structure

**Collection:** `realtime_data`
**Document:** `device_1`

```
{
  "dissolved_oxygen": <double>,
  "pH_air": <double>,
  "pakan_percent": <int>,
  "suhu_air": <double>,
  "suhu_lingkungan": <double>,
  "tds": <double>,
  "turbidity": <double>,
  "updatedAt": <timestamp>
}
```

## How It Works

1. When the HomePage loads, `_initializeFirestore()` is called in `initState()`
2. `_listenToFirestoreData()` establishes a real-time stream listener
3. Data from Firestore is mapped to the state variables with null safety
4. Default values are used if any field is missing (null coalescing)
5. Sensor cards automatically update when Firestore data changes
6. Data buffer is populated with incoming sensor data for AI prediction

## UI Display

The sensor data is displayed in grid format:
- **Suhu Air** (Water Temperature) - °C
- **Suhu Lingkungan** (Environment Temperature) - °C
- **TDS** (Total Dissolved Solids) - ppm
- **pH Air** (Water pH) - pH units
- **Turbidity** - NTU
- **DO** (Dissolved Oxygen) - mg/L

Food stock percentage is displayed in a separate container with color coding:
- Green (> 60%)
- Yellow (25-60%)
- Red (< 25%)

## Error Handling

- Firestore errors are displayed via SnackBar notification
- Missing fields default to reasonable values
- Real-time stream handles errors gracefully

## Testing Features

The existing testing menu still functions:
- Press floating action button to access test scenarios
- Scenarios override real-time data for testing AI predictions:
  - NORMAL - Healthy water conditions
  - PANAS - High temperature anomaly
  - DO_DROP - Low dissolved oxygen anomaly
  - KERUH - High turbidity anomaly
  - PH_ASAM - Low pH anomaly

## Installation Requirements

Before running the app:
1. Ensure Firebase is configured in your Flutter project
2. Run `flutter pub get` to install dependencies
3. Download and install google-services.json (Android) / GoogleService-Info.plist (iOS)
4. Configure Firestore in your Firebase console

## Next Steps

To get google-services.json and GoogleService-Info.plist:
1. Go to Firebase Console (console.firebase.google.com)
2. Select your project
3. Add Android/iOS app under Project Settings
4. Download the configuration files
5. Place them in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
