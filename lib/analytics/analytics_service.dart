import 'package:flutter/foundation.dart';

/// Lightweight analytics facade for StudyBolt web (Netlify).
///
/// ## Option A — Google Analytics 4 via `index.html` (recommended for web)
/// 1. Create a GA4 property at https://analytics.google.com
/// 2. Uncomment the gtag block in `web/index.html` and replace `G-XXXXXXXXXX`
/// 3. Deploy to Netlify — no extra Flutter packages required.
///
/// ## Option B — Firebase Analytics (`firebase_analytics`)
/// 1. Add to `pubspec.yaml`:
///    ```yaml
///    firebase_core: ^3.0.0
///    firebase_analytics: ^11.0.0
///    ```
/// 2. Run `flutterfire configure` for your web app.
/// 3. In `main.dart`:
///    ```dart
///    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///    ```
/// 4. Replace the `debugPrint` calls below with `FirebaseAnalytics.instance.logEvent(...)`.
///
/// ## Netlify
/// Build with `flutter build web` and publish `build/web/`. GA loads from the
/// hosted `index.html` on first page load; call [logScreenView] on navigation
/// changes if you add named routes later.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  Future<void> logScreenView({required String screenName}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] screen_view: $screenName');
    }
    // Firebase example:
    // await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (kDebugMode) {
      debugPrint('[Analytics] $name ${parameters ?? {}}');
    }
    // Firebase example:
    // await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }
}
