class AppConfig {
  // When true, the app runs fully offline using in-memory mock data and
  // skips all SuperTokens / backend / NTFY network calls.
  //
  // Enable the real backend at runtime with:
  //   flutter run --dart-define=OFFLINE_MODE=false
  static const bool offlineMode = bool.fromEnvironment('OFFLINE_MODE', defaultValue: true);
}
