import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';
import 'models/user_model.dart';
import 'result.dart';

/// Implementación de [AuthRepository] usando Firebase Auth.
///
/// Esta clase proporciona una implementación concreta de todas las
/// operaciones de autenticación usando Firebase Auth como backend.
class FirebaseAuthRepository implements AuthRepository {
  /// Instancia de FirebaseAuth para las operaciones de autenticación.
  final FirebaseAuth _firebaseAuth;

  /// Crea una instancia de [FirebaseAuthRepository].
  ///
  /// [firebaseAuth] debe ser una instancia configurada de FirebaseAuth.
  /// Si no se proporciona, se usa la instancia por defecto.
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Result<UserModel, AuthException>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No se pudo crear el usuario'),
        );
      }

      return Result.success(_mapFirebaseUserToUserModel(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel, AuthException>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No se pudo autenticar el usuario'),
        );
      }

      return Result.success(_mapFirebaseUserToUserModel(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel?, AuthException>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.success(null);
      }

      return Result.success(_mapFirebaseUserToUserModel(user));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No hay usuario autenticado'),
        );
      }

      await user.sendEmailVerification();
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void, AuthException>> changePassword({
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No hay usuario autenticado'),
        );
      }

      await user.updatePassword(newPassword);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserModel, AuthException>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.failure(
          GenericAuthException('No hay usuario autenticado'),
        );
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return const Result.failure(
          GenericAuthException('Error al actualizar el perfil'),
        );
      }

      return Result.success(_mapFirebaseUserToUserModel(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(GenericAuthException(e.toString()));
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUserToUserModel(user) : null;
    });
  }

  /// Convierte un [User] de Firebase a [UserModel].
  UserModel _mapFirebaseUserToUserModel(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  /// Mapea una [FirebaseAuthException] a una [AuthException] específica.
  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserNotFoundException(e.code);
      case 'wrong-password':
      case 'invalid-credential':
        return InvalidCredentialsException(e.code);
      case 'email-already-in-use':
        return EmailAlreadyInUseException(e.code);
      case 'weak-password':
        return WeakPasswordException(e.code);
      case 'invalid-email':
        return InvalidEmailException(e.code);
      case 'operation-not-allowed':
        return OperationNotAllowedException(e.code);
      case 'network-request-failed':
        return NetworkException(e.code);
      case 'user-disabled':
        return UserDisabledException(e.code);
      default:
        return GenericAuthException(e.message ?? 'Error desconocido', e.code);
    }
  }
}