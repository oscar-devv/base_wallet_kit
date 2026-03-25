import '../../domain/entities/base_response.dart';
import '../../domain/repositories/base_repository.dart';
import '../datasources/base_datasource.dart';

/// Implementación base de repositorio con manejo de errores centralizado.
/// Convierte [DatasourceException] en [BaseResponse.error].
///
/// ```dart
/// class LoginRepositoryImpl extends BaseRepositoryImpl<LoginUser, LoginDatasource> {
///   LoginRepositoryImpl(super.datasource);
///
///   Future<BaseResponse<LoginUser>> login(String email, String password) =>
///       safeCall(() async {
///         final data = await datasource.login(email, password);
///         return LoginMapper().fromModel(LoginModel.fromJson(data));
///       });
/// }
/// ```
abstract class BaseRepositoryImpl<T, D extends BaseDatasource>
    implements BaseRepository<T> {
  final D datasource;

  BaseRepositoryImpl(this.datasource);

  /// Ejecuta una operación del datasource y envuelve el resultado en [BaseResponse].
  Future<BaseResponse<R>> safeCall<R>(Future<R> Function() operation) async {
    try {
      final result = await operation();
      return BaseResponse.success(result);
    } on DatasourceException catch (e) {
      return BaseResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return BaseResponse.error(e.toString());
    }
  }

  @override
  Future<BaseResponse<T>> getById(String id) =>
      safeCall(() => throw UnimplementedError('getById no implementado'));

  @override
  Future<BaseResponse<List<T>>> getAll() =>
      safeCall(() => throw UnimplementedError('getAll no implementado'));

  @override
  Future<BaseResponse<T>> create(Map<String, dynamic> data) =>
      safeCall(() => throw UnimplementedError('create no implementado'));

  @override
  Future<BaseResponse<T>> update(String id, Map<String, dynamic> data) =>
      safeCall(() => throw UnimplementedError('update no implementado'));

  @override
  Future<BaseResponse<bool>> delete(String id) =>
      safeCall(() => throw UnimplementedError('delete no implementado'));
}
