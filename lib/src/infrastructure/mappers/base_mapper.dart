/// Interface genérica para convertir entre modelos (DTOs) y entidades de dominio.
///
/// [M] = Model (DTO de la API)
/// [E] = Entity (objeto de dominio)
///
/// ```dart
/// class LoginMapper implements BaseMapper<LoginModel, LoginUser> {
///   @override
///   LoginUser fromModel(LoginModel model) => LoginUser(
///     id: model.id,
///     name: model.name,
///     ...
///   );
///
///   @override
///   LoginModel toModel(LoginUser entity) => LoginModel(
///     id: entity.id,
///     ...
///   );
/// }
/// ```
abstract class BaseMapper<M, E> {
  /// Convierte un modelo (DTO) a entidad de dominio
  E fromModel(M model);

  /// Convierte una entidad de dominio a modelo (DTO)
  M toModel(E entity);

  /// Convierte una lista de modelos a lista de entidades
  List<E> fromModelList(List<M> models) =>
      models.map((m) => fromModel(m)).toList();

  /// Convierte una lista de entidades a lista de modelos
  List<M> toModelList(List<E> entities) =>
      entities.map((e) => toModel(e)).toList();
}
