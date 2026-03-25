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
