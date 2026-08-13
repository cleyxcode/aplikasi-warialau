# FCM (Firebase Cloud Messaging) setup

The app registers for push notifications when Firebase is configured. Without Firebase, **NotificationLocalService** polling continues as the fallback (no crash).

## Android

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app with package name `com.example.mobile_apps_sd`.
3. Download `google-services.json` and place it at:

   `android/app/google-services.json`

   See `android/app/google-services.json.example` for the expected shape.

4. Enable the Google Services Gradle plugin (required once `google-services.json` exists):

   In `android/settings.gradle.kts`, add inside `plugins { }`:

   ```kotlin
   id("com.google.gms.google-services") version "4.4.2" apply false
   ```

   In `android/app/build.gradle.kts`, add at the bottom:

   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

   (Merge with the existing `plugins { }` block at the top of the app module.)

5. Rebuild: `flutter clean && flutter pub get && flutter run`

## iOS (optional)

1. Add an iOS app in Firebase and download `GoogleService-Info.plist`.
2. Add it to `ios/Runner/` via Xcode.
3. Enable Push Notifications and Background Modes → Remote notifications in Xcode.

## API

After login/register, the app calls `POST /device-tokens` with `{ token, platform, device_name }`. On logout it calls `DELETE /device-tokens` with `{ token }`.
