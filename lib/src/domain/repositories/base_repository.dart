import '../entities/base_response.dart';

/// Contrato base para todos los repositorios del proyecto.
/// Define las operaciones CRUD genéricas que cada repositorio puede implementar.
///
/// ```dart
/// abstract class LoginRepository extends BaseRepository<LoginUser> {
///   Future<BaseResponse<LoginUser>> login(String email, String password);
/// }
/// ```
abstract class BaseRepository<T> {
  /// Obtiene un recurso por su ID
  Future<BaseResponse<T>> getById(String id);

  /// Obtiene una lista de recursos
  Future<BaseResponse<List<T>>> getAll();

  /// Crea un nuevo recurso
  Future<BaseResponse<T>> create(Map<String, dynamic> data);

  /// Actualiza un recurso existente
  Future<BaseResponse<T>> update(String id, Map<String, dynamic> data);

  /// Elimina un recurso
  Future<BaseResponse<bool>> delete(String id);
}
