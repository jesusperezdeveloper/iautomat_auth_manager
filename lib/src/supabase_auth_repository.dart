import 'dart:async';
import 'dart:io';

import 'package:supabase/supabase.dart' as supabase;

import 'auth_repository.dart';
import 'models/user_model.dart';
import 'result.dart';

/// Implementación de [AuthRepository] usando Supabase Auth.
///
/// Esta clase proporciona una implementación concreta de todas las
/// operaciones de autenticación usando Supabase Auth como backend.
class SupabaseAuthRepository implements AuthRepository {
  /// Instancia de SupabaseClient para las operaciones de autenticación.
  final supabase.SupabaseClient _supabaseClient;

  /// Crea una instancia de [SupabaseAuthRepository].
  ///
  /// [supabaseClient] debe ser una instancia configurada de SupabaseClient.
  SupabaseAuthRepository({required supabase.SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Result<UserModel, AuthException>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No se pudo crear el usuario'),
        );
      }

      return Result.success(_mapSupabaseUserToUserModel(user));
    } on supabase.AuthException catch (e) {
      return Result.failure(_mapSupabaseAuthException(e));
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().toLowerCase().contains('network')) {
        return Result.failure(NetworkException(e.toString()));
      }
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel, AuthException>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No se pudo autenticar el usuario'),
        );
      }

      return Result.success(_mapSupabaseUserToUserModel(user));
    } on supabase.AuthException catch (e) {
      return Result.failure(_mapSupabaseAuthException(e));
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().toLowerCase().contains('network')) {
        return Result.failure(NetworkException(e.toString()));
      }
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      return const Result.success(null);
    } on supabase.AuthException catch (e) {
      return Result.failure(_mapSupabaseAuthException(e));
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().toLowerCase().contains('network')) {
        return Result.failure(NetworkException(e.toString()));
      }
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return const Result.success(null);
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel?, AuthException>> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Result.success(null);
      }

      return Result.success(_mapSupabaseUserToUserModel(user));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> sendEmailVerification() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No hay usuario autenticado'),
        );
      }

      // Supabase envía verificación automáticamente al registrarse
      // Si se necesita reenviar, usar resend
      await _supabaseClient.auth.resend(
        type: supabase.OtpType.signup,
        email: user.email!,
      );
      return const Result.success(null);
    } on supabase.AuthException catch (e) {
      return Result.failure(_mapSupabaseAuthException(e));
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().toLowerCase().contains('network')) {
        return Result.failure(NetworkException(e.toString()));
      }
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> changePassword({
    required String newPassword,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No hay usuario autenticado'),
        );
      }

      await _supabaseClient.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      return const Result.success(null);
    } on supabase.AuthException catch (e) {
      return Result.failure(_mapSupabaseAuthException(e));
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().toLowerCase().contains('network')) {
        return Result.failure(NetworkException(e.toString()));
      }
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel, AuthException>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No hay usuario autenticado'),
        );
      }

      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['display_name'] = displayName;
      }
      if (photoURL != null) {
        updates['photo_url'] = photoURL;
      }

      final response = await _supabaseClient.auth.updateUser(
        supabase.UserAttributes(data: updates),
      );

      final updatedUser = response.user;
      if (updatedUser == null) {
        return const Result.failure(
          GenericAuthException('Error al actualizar el perfil'),
        );
      }

      return Result.success(_mapSupabaseUserToUserModel(updatedUser));
    } on supabase.AuthException catch (e) {
      return Result.failure(_mapSupabaseAuthException(e));
    } on SocketException catch (e) {
      return Result.failure(NetworkException(e.toString()));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().toLowerCase().contains('network')) {
        return Result.failure(NetworkException(e.toString()));
      }
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _mapSupabaseUserToUserModel(user) : null;
    });
  }

  /// Convierte un [User] de Supabase a [UserModel].
  UserModel _mapSupabaseUserToUserModel(supabase.User user) {
    return UserModel(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      photoURL: user.userMetadata?['photo_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  /// Mapea una [AuthException] de Supabase a una [AuthException] específica del paquete.
  AuthException _mapSupabaseAuthException(supabase.AuthException e) {
    final message = e.message.toLowerCase();
    final statusCode = e.statusCode ?? '';

    // Mapeo basado en mensajes comunes de Supabase
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        statusCode == '400') {
      return InvalidCredentialsException(statusCode);
    }

    if (message.contains('user not found') ||
        message.contains('user does not exist')) {
      return UserNotFoundException(statusCode);
    }

    if (message.contains('email already') ||
        message.contains('already registered') ||
        message.contains('already exists')) {
      return EmailAlreadyInUseException(statusCode);
    }

    if (message.contains('password') && message.contains('weak') ||
        message.contains('password is too short') ||
        message.contains('password must be')) {
      return WeakPasswordException(statusCode);
    }

    if (message.contains('invalid email') ||
        message.contains('email format') ||
        message.contains('malformed email')) {
      return InvalidEmailException(statusCode);
    }

    if (message.contains('not allowed') ||
        message.contains('disabled') && message.contains('provider')) {
      return OperationNotAllowedException(statusCode);
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return NetworkException(statusCode);
    }

    if (message.contains('user') && message.contains('disabled') ||
        message.contains('account disabled')) {
      return UserDisabledException(statusCode);
    }

    return GenericAuthException(e.message, statusCode);
  }
}
