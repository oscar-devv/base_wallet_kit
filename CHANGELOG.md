## 1.0.3

* Added LocationService and LazyLocationService for GPS access with CDMX fallback.
* Added MandatoryPermissionsService for location permission dialogs and blocking screen.
* Added PermissionsBlockingScreen widget shown when permissions are permanently denied.
* Added DeviceInfoService for Android/iOS device info, device ID and physical device check.
* Added UpdateService with configurable MethodChannel for Android in-app updates.
* Added AddressParserService (ParsedAddress model) for structured INE/OCR address parsing.
* Added BackgroundOperationManager with retry logic for async background operations.
* Added RatingPreferences for persisting app rating prompt state.
* Added IsolateProcessingService for video/image/file Base64 encoding via compute().
* Added `image` package dependency for image processing in isolates.

## 1.0.1

* Added repository, homepage and issue_tracker URLs to pubspec.yaml.
* Fixed pub.dev dry-run warnings: version constraints, unused imports and fields.

## 1.0.0

* Initial release.
* Clean Architecture base structure (domain, infrastructure, providers).
* ApiDioFactory with dynamic URL, token expiration and Crashlytics interceptors.
* SecureCredentials and SecureTokenStorage using flutter_secure_storage.
* MigrationManager for safe iOS/Android app updates without data loss.
* BiometricPreferences with iOS first-install Keychain cleanup pattern.
* UserInfoProvider and AccountInfoProvider (stringList with safe index access).
* BaseAuthProvider and BaseAccountProvider (Riverpod StateNotifier base classes).
* IOSUpdateChecker with App Store redirect.
* NavigationStateService configurable via BaseWalletKit.init().
* Reusable widgets: CustomAlert, CustomAppBar, PermissionGuard, RatingDialog.
* Utils: PhoneNumberUtils, CurpNormalizer.
