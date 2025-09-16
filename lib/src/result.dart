/// Representa el resultado de una operación que puede fallar.
///
/// [Result] encapsula el estado de éxito o fallo de una operación,
/// proporcionando una forma segura de manejar errores sin excepciones.
sealed class Result<T, E> {
  const Result();

  /// Crea un resultado exitoso con el valor especificado.
  const factory Result.success(T value) = Success<T, E>;

  /// Crea un resultado de fallo con el error especificado.
  const factory Result.failure(E error) = Failure<T, E>;

  /// Retorna `true` si el resultado es exitoso.
  bool get isSuccess => this is Success<T, E>;

  /// Retorna `true` si el resultado es un fallo.
  bool get isFailure => this is Failure<T, E>;

  /// Retorna el valor si es exitoso, o `null` si es un fallo.
  T? get valueOrNull => switch (this) {
        Success(value: final value) => value,
        Failure() => null,
      };

  /// Retorna el error si es un fallo, o `null` si es exitoso.
  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(error: final error) => error,
      };

  /// Transforma el valor del resultado si es exitoso.
  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
        Success(value: final value) => Success(transform(value)),
        Failure(error: final error) => Failure(error),
      };

  /// Transforma el error del resultado si es un fallo.
  Result<T, R> mapError<R>(R Function(E error) transform) => switch (this) {
        Success(value: final value) => Success(value),
        Failure(error: final error) => Failure(transform(error)),
      };

  /// Ejecuta una función dependiendo del resultado.
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(E error) onFailure,
  ) =>
      switch (this) {
        Success(value: final value) => onSuccess(value),
        Failure(error: final error) => onFailure(error),
      };
}

/// Representa un resultado exitoso.
final class Success<T, E> extends Result<T, E> {
  /// El valor del resultado exitoso.
  final T value;

  /// Crea un resultado exitoso con el valor especificado.
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Representa un resultado de fallo.
final class Failure<T, E> extends Result<T, E> {
  /// El error del resultado de fallo.
  final E error;

  /// Crea un resultado de fallo con el error especificado.
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}