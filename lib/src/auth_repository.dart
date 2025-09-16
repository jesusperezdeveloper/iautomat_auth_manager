import 'result.dart';
import 'models/user_model.dart';

/// Excepciones específicas para operaciones de autenticación.
sealed class AuthException implements Exception {
  /// Mensaje descriptivo del error.
  final String message;

  /// Código de error opcional.
  final String? code;

  const AuthException(this.message, [this.code]);

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Error de credenciales inválidas.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? code])
      : super('Credenciales inválidas', code);
}

/// Error de usuario no encontrado.
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? code])
      : super('Usuario no encontrado', code);
}

/// Error de email ya en uso.
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException([String? code])
      : super('El email ya está en uso', code);
}

/// Error de contraseña débil.
class WeakPasswordException extends AuthException {
  const WeakPasswordException([String? code])
      : super('La contraseña es demasiado débil', code);
}

/// Error de email mal formateado.
class InvalidEmailException extends AuthException {
  const InvalidEmailException([String? code])
      : super('El formato del email es inválido', code);
}

/// Error de operación no permitida.
class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException([String? code])
      : super('Operación no permitida', code);
}

/// Error de red.
class NetworkException extends AuthException {
  const NetworkException([String? code])
      : super('Error de conexión de red', code);
}

/// Error de usuario deshabilitado.
class UserDisabledException extends AuthException {
  const UserDisabledException([String? code])
      : super('El usuario ha sido deshabilitado', code);
}

/// Error genérico de autenticación.
class GenericAuthException extends AuthException {
  const GenericAuthException(super.message, [super.code]);
}

/// Interfaz abstracta para el repositorio de autenticación.
///
/// Define todas las operaciones de autenticación necesarias usando
/// el patrón Result para manejo de errores sin excepciones.
abstract class AuthRepository {
  /// Registra un nuevo usuario con email y contraseña.
  ///
  /// Retorna [Result] con [UserModel] si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<UserModel, AuthException>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Inicia sesión con email y contraseña.
  ///
  /// Retorna [Result] con [UserModel] si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<UserModel, AuthException>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Envía un email de restablecimiento de contraseña.
  ///
  /// Retorna [Result] con [void] si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<void, AuthException>> sendPasswordResetEmail({
    required String email,
  });

  /// Cierra la sesión del usuario actual.
  ///
  /// Retorna [Result] con [void] si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<void, AuthException>> signOut();

  /// Obtiene el usuario actualmente autenticado.
  ///
  /// Retorna [Result] con [UserModel] si hay un usuario autenticado,
  /// o [AuthException] si no hay usuario o falla.
  Future<Result<UserModel?, AuthException>> getCurrentUser();

  /// Envía un email de verificación al usuario actual.
  ///
  /// Retorna [Result] con [void] si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<void, AuthException>> sendEmailVerification();

  /// Cambia la contraseña del usuario actual.
  ///
  /// Retorna [Result] con [void] si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<void, AuthException>> changePassword({
    required String newPassword,
  });

  /// Actualiza el perfil del usuario actual.
  ///
  /// Retorna [Result] con [UserModel] actualizado si es exitoso,
  /// o [AuthException] si falla.
  Future<Result<UserModel, AuthException>> updateProfile({
    String? displayName,
    String? photoURL,
  });

  /// Stream del estado de autenticación.
  ///
  /// Emite [UserModel] cuando un usuario está autenticado,
  /// o `null` cuando no hay usuario autenticado.
  Stream<UserModel?> get authStateChanges;
}