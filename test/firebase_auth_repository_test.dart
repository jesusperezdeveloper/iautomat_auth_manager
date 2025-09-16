import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

import 'mocks/firebase_auth_mocks.mocks.dart';

void main() {
  group('FirebaseAuthRepository', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late FirebaseAuthRepository repository;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      repository = FirebaseAuthRepository(firebaseAuth: mockFirebaseAuth);
    });

    group('signUpWithEmailAndPassword', () {
      test('should return success when registration is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const uid = 'test-uid';

        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUser.emailVerified).thenReturn(false);

        when(mockUserCredential.user).thenReturn(mockUser);

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.email, equals(email));
        expect(user.emailVerified, isFalse);

        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('should return failure when user is null', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockUserCredential.user).thenReturn(null);

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No se pudo crear el usuario'));
      });

      test('should return EmailAlreadyInUseException when email is already used', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use',
        ));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<EmailAlreadyInUseException>());
        expect(error.code, equals('email-already-in-use'));
      });

      test('should return WeakPasswordException when password is weak', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'weak-password',
          message: 'The password is too weak',
        ));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<WeakPasswordException>());
        expect(error.code, equals('weak-password'));
      });

      test('should return InvalidEmailException when email format is invalid', () async {
        // Arrange
        const email = 'invalid-email';
        const password = 'password123';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted',
        ));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidEmailException>());
        expect(error.code, equals('invalid-email'));
      });

      test('should return GenericAuthException for unknown errors', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(Exception('Unknown error'));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('Exception: Unknown error'));
      });
    });

    group('signInWithEmailAndPassword', () {
      test('should return success when sign in is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const uid = 'test-uid';

        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn('Test User');
        when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
        when(mockUser.emailVerified).thenReturn(true);

        when(mockUserCredential.user).thenReturn(mockUser);

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.email, equals(email));
        expect(user.displayName, equals('Test User'));
        expect(user.photoURL, equals('https://example.com/photo.jpg'));
        expect(user.emailVerified, isTrue);

        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('should return InvalidCredentialsException for wrong password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong-password';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'wrong-password',
          message: 'The password is invalid',
        ));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidCredentialsException>());
        expect(error.code, equals('wrong-password'));
      });

      test('should return UserNotFoundException when user does not exist', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user record corresponding to this identifier',
        ));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<UserNotFoundException>());
        expect(error.code, equals('user-not-found'));
      });

      test('should return UserDisabledException when user is disabled', () async {
        // Arrange
        const email = 'disabled@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'user-disabled',
          message: 'The user account has been disabled',
        ));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<UserDisabledException>());
        expect(error.code, equals('user-disabled'));
      });

      test('should return InvalidCredentialsException for invalid credential', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'invalid-credential',
          message: 'The credential is invalid',
        ));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidCredentialsException>());
        expect(error.code, equals('invalid-credential'));
      });
    });

    group('sendPasswordResetEmail', () {
      test('should return success when email is sent successfully', () async {
        // Arrange
        const email = 'test@example.com';

        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
      });

      test('should return UserNotFoundException when user does not exist', () async {
        // Arrange
        const email = 'nonexistent@example.com';

        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenThrow(FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user record corresponding to this identifier',
        ));

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<UserNotFoundException>());
        expect(error.code, equals('user-not-found'));
      });

      test('should return InvalidEmailException for invalid email format', () async {
        // Arrange
        const email = 'invalid-email';

        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenThrow(FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted',
        ));

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidEmailException>());
        expect(error.code, equals('invalid-email'));
      });
    });

    group('signOut', () {
      test('should return success when sign out is successful', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test('should return GenericAuthException when sign out fails', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out failed'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('Exception: Sign out failed'));
      });
    });

    group('getCurrentUser', () {
      test('should return current user when user is authenticated', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@example.com';

        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUser.emailVerified).thenReturn(false);

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user?.uid, equals(uid));
        expect(user?.email, equals(email));
      });

      test('should return null when no user is authenticated', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isNull);
      });

      test('should return GenericAuthException when operation fails', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenThrow(Exception('Failed to get user'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('Exception: Failed to get user'));
      });
    });

    group('sendEmailVerification', () {
      test('should return success when verification email is sent', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async {});

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should return GenericAuthException when no user is authenticated', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No hay usuario autenticado'));
      });

      test('should return OperationNotAllowedException when operation is not allowed', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.sendEmailVerification()).thenThrow(FirebaseAuthException(
          code: 'operation-not-allowed',
          message: 'Email verification is not allowed',
        ));

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<OperationNotAllowedException>());
        expect(error.code, equals('operation-not-allowed'));
      });
    });

    group('changePassword', () {
      test('should return success when password is changed successfully', () async {
        // Arrange
        const newPassword = 'newPassword123';

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.updatePassword(newPassword)).thenAnswer((_) async {});

        // Act
        final result = await repository.changePassword(newPassword: newPassword);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockUser.updatePassword(newPassword)).called(1);
      });

      test('should return GenericAuthException when no user is authenticated', () async {
        // Arrange
        const newPassword = 'newPassword123';
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.changePassword(newPassword: newPassword);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No hay usuario autenticado'));
      });

      test('should return WeakPasswordException when new password is weak', () async {
        // Arrange
        const newPassword = '123';

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.updatePassword(newPassword)).thenThrow(FirebaseAuthException(
          code: 'weak-password',
          message: 'The password is too weak',
        ));

        // Act
        final result = await repository.changePassword(newPassword: newPassword);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<WeakPasswordException>());
        expect(error.code, equals('weak-password'));
      });
    });

    group('updateProfile', () {
      test('should return success when profile is updated successfully', () async {
        // Arrange
        const displayName = 'Updated Name';
        const photoURL = 'https://example.com/new-photo.jpg';
        const uid = 'test-uid';
        const email = 'test@example.com';

        when(mockUser.updateDisplayName(displayName)).thenAnswer((_) async {});
        when(mockUser.updatePhotoURL(photoURL)).thenAnswer((_) async {});
        when(mockUser.reload()).thenAnswer((_) async {});

        // Crear un mock del usuario actualizado
        final mockUpdatedUser = MockUser();
        when(mockUpdatedUser.uid).thenReturn(uid);
        when(mockUpdatedUser.email).thenReturn(email);
        when(mockUpdatedUser.displayName).thenReturn(displayName);
        when(mockUpdatedUser.photoURL).thenReturn(photoURL);
        when(mockUpdatedUser.emailVerified).thenReturn(true);

        // Configurar que las llamadas secuenciales devuelven primero el usuario original, luego el actualizado
        var callCount = 0;
        when(mockFirebaseAuth.currentUser).thenAnswer((_) {
          callCount++;
          return callCount == 1 ? mockUser : mockUpdatedUser;
        });

        // Act
        final result = await repository.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.email, equals(email));
        expect(user.displayName, equals(displayName));
        expect(user.photoURL, equals(photoURL));

        verify(mockUser.updateDisplayName(displayName)).called(1);
        verify(mockUser.updatePhotoURL(photoURL)).called(1);
        verify(mockUser.reload()).called(1);
      });

      test('should return GenericAuthException when no user is authenticated', () async {
        // Arrange
        const displayName = 'Updated Name';
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.updateProfile(displayName: displayName);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No hay usuario autenticado'));
      });

      test('should handle null displayName and photoURL', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@example.com';

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.updateDisplayName(null)).thenAnswer((_) async {});
        when(mockUser.updatePhotoURL(null)).thenAnswer((_) async {});
        when(mockUser.reload()).thenAnswer((_) async {});

        final mockUpdatedUser = MockUser();
        when(mockUpdatedUser.uid).thenReturn(uid);
        when(mockUpdatedUser.email).thenReturn(email);
        when(mockUpdatedUser.displayName).thenReturn(null);
        when(mockUpdatedUser.photoURL).thenReturn(null);
        when(mockUpdatedUser.emailVerified).thenReturn(true);

        when(mockFirebaseAuth.currentUser).thenReturn(mockUpdatedUser);

        // Act
        final result = await repository.updateProfile();

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.displayName, isNull);
        expect(user.photoURL, isNull);
      });
    });

    group('authStateChanges', () {
      test('should emit user when authenticated', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@example.com';

        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUser.emailVerified).thenReturn(false);

        final streamController = StreamController<User?>();
        when(mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => streamController.stream);

        // Act
        final stream = repository.authStateChanges;
        final future = stream.first;

        streamController.add(mockUser);

        final result = await future;

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals(email));

        streamController.close();
      });

      test('should emit null when not authenticated', () async {
        // Arrange
        final streamController = StreamController<User?>();
        when(mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => streamController.stream);

        // Act
        final stream = repository.authStateChanges;
        final future = stream.first;

        streamController.add(null);

        final result = await future;

        // Assert
        expect(result, isNull);

        streamController.close();
      });
    });

    group('NetworkException mapping', () {
      test('should return NetworkException for network-request-failed error', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'network-request-failed',
          message: 'A network error occurred',
        ));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<NetworkException>());
        expect(error.code, equals('network-request-failed'));
      });
    });
  });
}