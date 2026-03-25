# base_wallet_kit

Librería base con arquitectura **Clean Architecture + Riverpod** para proyectos Flutter de tipo wallet/fintech.

---

## Instalación

En el `pubspec.yaml` de tu proyecto:

```yaml
dependencies:
  base_wallet_kit:
    git:
      url: https://github.com/tu-org/base_wallet_kit.git
      ref: main
```

---

## Inicialización en `main.dart`

```dart
import 'package:base_wallet_kit/base_wallet_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configurar entorno
  Environment.instance = AppEnvironment();

  // 2. Configurar versiones para el MigrationManager
  MigrationManager.configure(ios: '1.0.0', android: '1.0.0');

  // 3. Inicializar BaseWalletKit (navigatorKey + rutas)
  BaseWalletKit.init(
    navigatorKey: rootNavigatorKey,
    loginRoute: '/login',
    authenticatedRoutes: ['home', 'account', 'cards'],
    authRoutes: ['login', 'register', 'forgot-password'],
  );

  // 4. Inicializar ApiUrlManager (Firebase Remote Config)
  await ApiUrlManager.instance.initialize();

  // 5. Verificar versión de app
  await MigrationManager.checkAppVersion();

  runApp(const ProviderScope(child: MyApp()));
}
```

---

## Estructura de capas

```
base_wallet_kit/
├── config/          → Router base, transiciones de página
├── constants/       → Environment (abstract)
├── domain/          → BaseUser, BaseAccount, BaseResponse, BaseRepository
├── infrastructure/  → BaseDatasource, BaseMapper, BaseRepositoryImpl
├── providers/
│   ├── riverpodBack/  → BaseAuthProvider, BaseAccountProvider
│   └── riverpodVar/   → UserInfoProvider, AccountInfoProvider, FormStateProviders
├── services/        → ApiDioFactory, TokenExpiredInterceptor, SecureTokenStorage, etc.
├── utils/           → MigrationManager, SecureCredentials, BiometricPreferences, etc.
└── widgets/         → CustomAlert, CustomAppBar, PermissionGuard, RatingDialog
```

---

## Uso por capa

### Environment
```dart
class AppEnvironment extends Environment {
  @override
  String get urlBase => 'https://api.miapp.com/';

  @override
  String get urlBaseOld => 'https://api-legacy.miapp.com/';
}
```

### Entidades de dominio
```dart
class LoginUser extends BaseUser {
  final String token;
  final String company;

  const LoginUser({
    required super.id,
    required super.name,
    required super.lastname,
    required super.email,
    required super.status,
    required this.token,
    required this.company,
  });
}
```

### Datasource
```dart
class LoginDatasource extends BaseDatasource {
  LoginDatasource() : super(dio: ApiDioFactory.create());

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await safeRequest(() => dio.post(
      '/v1/auth/login/',
      data: {'email': email, 'password': password},
    ));
    return response.data;
  }
}
```

### Mapper
```dart
class LoginMapper implements BaseMapper<LoginModel, LoginUser> {
  @override
  LoginUser fromModel(LoginModel model) => LoginUser(
    id: model.id,
    name: model.name,
    lastname: model.lastname,
    email: model.email,
    status: model.status,
    token: model.token,
    company: model.company,
  );

  @override
  LoginModel toModel(LoginUser entity) => LoginModel(id: entity.id, ...);
}
```

### Provider de datos de usuario (stringListUser)
```dart
// Guardar datos después de login
ref.read(UserInfoProvider.notifier).addString(user.id);
ref.read(UserInfoProvider.notifier).addString(user.name);
ref.read(UserInfoProvider.notifier).addString(user.email);

// Leer datos de forma segura
final userInfo = ref.watch(UserInfoProvider);
final userName = userInfo.safeGet(1);  // Sin RangeError

// Limpiar al hacer logout
await ref.read(UserInfoProvider.notifier).clearList();
```

### Verificación de actualización iOS
```dart
IOSUpdateChecker(
  iOSBundleId: 'com.miempresa.miapp',
  iOSAppStoreCountry: 'MX',
).checkForUpdate(context);
```

### Credenciales biométricas
```dart
// Guardar
await SecureCredentials.save(email, password);

// Leer
final credentials = await SecureCredentials.read();

// Limpiar (logout)
await SecureCredentials.clear();
```

---

## Limpieza de Keychain en primera instalación iOS

El Keychain de iOS persiste datos **incluso después de desinstalar la app**, a diferencia de Android donde `flutter_secure_storage` se borra automáticamente al desinstalar. Esto puede dejar credenciales residuales en reinstalaciones.

Para limpiar esos residuos, agrega esto al inicio de tu login screen:

```dart
if (Platform.isIOS) {
  final initialized = await BiometricPreferences.isAppInitialized();
  if (!initialized) {
    await SecureCredentials.clear();
    await SecureTokenStorage.clearAllTokens();
    await BiometricPreferences.markAppAsInitialized();
  }
}
```

El flag `app_initialized` se guarda en SharedPreferences, que **sí se borra al desinstalar en ambas plataformas**. Por eso este bloque solo corre en primera instalación o reinstalación, nunca en actualizaciones normales.

**Android no necesita este patrón** — el SO limpia el almacenamiento seguro automáticamente al desinstalar.
