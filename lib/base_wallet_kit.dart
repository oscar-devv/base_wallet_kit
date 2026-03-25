/// base_wallet_kit
/// Librería base con arquitectura Clean Architecture + Riverpod
/// para proyectos Flutter de tipo wallet/fintech.
library base_wallet_kit;

// ─── Config ───────────────────────────────────────────────────────────────────
export 'src/config/router/base_router.dart';
export 'src/config/transitions/page_transitions.dart';

// ─── Constants ────────────────────────────────────────────────────────────────
export 'src/constants/environment.dart';

// ─── Domain ───────────────────────────────────────────────────────────────────
export 'src/domain/entities/base_user.dart';
export 'src/domain/entities/base_account.dart';
export 'src/domain/entities/base_response.dart';
export 'src/domain/repositories/base_repository.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────
export 'src/infrastructure/datasources/base_datasource.dart';
export 'src/infrastructure/datasources/base_auth_datasource.dart';
export 'src/infrastructure/mappers/base_mapper.dart';
export 'src/infrastructure/models/base_response_model.dart';
export 'src/infrastructure/repositories/base_repository_impl.dart';

// ─── Providers ────────────────────────────────────────────────────────────────
export 'src/providers/riverpodVar/info_user_provider.dart';
export 'src/providers/riverpodVar/form_state_provider.dart';
export 'src/providers/riverpodBack/base_auth_provider.dart';
export 'src/providers/riverpodBack/base_account_provider.dart';

// ─── Services ─────────────────────────────────────────────────────────────────
export 'src/services/api_dio_factory.dart';
export 'src/services/api_url_manager.dart';
export 'src/services/crashlytics_dio_interceptor.dart';
export 'src/services/device_info_service.dart';
export 'src/services/dynamic_base_url_interceptor.dart';
export 'src/services/lazy_location_service.dart';
export 'src/services/location_service.dart';
export 'src/services/mandatory_permissions_service.dart';
export 'src/services/navigation_state_service.dart';
export 'src/services/remote_config_service.dart';
export 'src/services/secure_token_storage.dart';
export 'src/services/token_expired_interceptor.dart';
export 'src/services/update_service.dart';

// ─── Utils ────────────────────────────────────────────────────────────────────
export 'src/utils/address_parser_service.dart';
export 'src/utils/background_operation_manager.dart';
export 'src/utils/biometric_preferences.dart';
export 'src/utils/curp_normalizer.dart';
export 'src/utils/ios_update_checker.dart';
export 'src/utils/isolate_processing_service.dart';
export 'src/utils/migration_manager.dart';
export 'src/utils/phone_number_utils.dart';
export 'src/utils/rating_preferences.dart';
export 'src/utils/secure_credentials.dart';

// ─── Widgets ──────────────────────────────────────────────────────────────────
export 'src/widgets/custom_alert.dart';
export 'src/widgets/custom_appbar.dart';
export 'src/widgets/permission_guard.dart';
export 'src/widgets/permissions_blocking_screen.dart';
export 'src/widgets/rating_dialog.dart';
