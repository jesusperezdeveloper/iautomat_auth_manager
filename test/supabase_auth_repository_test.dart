import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase/supabase.dart' as supabase;

// Mocks
class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

class MockAuthResponse extends Mock implements supabase.AuthResponse {}

class MockUser extends Mock implements supabase.User {}

class MockSession extends Mock implements supabase.Session {}

class MockUserResponse extends Mock implements supabase.UserResponse {}

class MockResendResponse extends Mock implements supabase.ResendResponse {}

// Fake class for UserAttributes
class FakeUserAttributes extends Fake implements supabase.UserAttributes {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeUserAttributes());
  });

  group('SupabaseAuthRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockAuthResponse mockAuthResponse;
    late MockUser mockUser;
    late MockUserResponse mockUserResponse;
    late MockResendResponse mockResendResponse;
    late SupabaseAuthRepository repository;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      mockAuthResponse = MockAuthResponse();
      mockUser = MockUser();
      mockUserResponse = MockUserResponse();
      mockResendResponse = MockResendResponse();
      repository =
          SupabaseAuthRepository(supabaseClient: mockSupabaseClient);

      // Setup default behavior
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    });

    group('signUpWithEmailAndPassword', () {
      test('should return success when registration is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const uid = 'test-uid';

        when(() => mockUser.id).thenReturn(uid);
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.userMetadata).thenReturn({});
        when(() => mockUser.emailConfirmedAt).thenReturn(null);

        when(() => mockAuthResponse.user).thenReturn(mockUser);

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockAuthResponse);

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

        verify(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).called(1);
      });

      test('should return failure when user is null', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockAuthResponse.user).thenReturn(null);

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockAuthResponse);

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

      test('should return EmailAlreadyInUseException when email exists',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(supabase.AuthException('Email already exists'));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<EmailAlreadyInUseException>());
      });

      test('should return WeakPasswordException for weak password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(supabase.AuthException('Password is too short'));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<WeakPasswordException>());
      });

      test('should return InvalidEmailException for invalid email', () async {
        // Arrange
        const email = 'invalid-email';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(supabase.AuthException('Invalid email format'));

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidEmailException>());
      });
    });

    group('signInWithEmailAndPassword', () {
      test('should return success when sign in is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const uid = 'test-uid';

        when(() => mockUser.id).thenReturn(uid);
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.userMetadata).thenReturn({});
        when(() => mockUser.emailConfirmedAt).thenReturn(DateTime.now().toIso8601String());

        when(() => mockAuthResponse.user).thenReturn(mockUser);

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockAuthResponse);

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
        expect(user.emailVerified, isTrue);

        verify(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).called(1);
      });

      test('should return failure when user is null', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockAuthResponse.user).thenReturn(null);

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockAuthResponse);

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No se pudo autenticar el usuario'));
      });

      test('should return InvalidCredentialsException for wrong password',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(supabase.AuthException('Invalid login credentials'));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidCredentialsException>());
      });

      test('should return UserNotFoundException when user not found',
          () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(supabase.AuthException('User not found'));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<UserNotFoundException>());
      });
    });

    group('sendPasswordResetEmail', () {
      test('should return success when password reset email is sent',
          () async {
        // Arrange
        const email = 'test@example.com';

        when(() => mockGoTrueClient.resetPasswordForEmail(email))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isSuccess, isTrue);

        verify(() => mockGoTrueClient.resetPasswordForEmail(email)).called(1);
      });

      test('should return InvalidEmailException for invalid email', () async {
        // Arrange
        const email = 'invalid-email';

        when(() => mockGoTrueClient.resetPasswordForEmail(email))
            .thenThrow(supabase.AuthException('Invalid email'));

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<InvalidEmailException>());
      });

      test('should return GenericAuthException for unknown errors', () async {
        // Arrange
        const email = 'test@example.com';

        when(() => mockGoTrueClient.resetPasswordForEmail(email))
            .thenThrow(Exception('Unknown error'));

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
      });
    });

    group('signOut', () {
      test('should return success when sign out is successful', () async {
        // Arrange
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isSuccess, isTrue);

        verify(() => mockGoTrueClient.signOut()).called(1);
      });

      test('should return GenericAuthException when sign out fails', () async {
        // Arrange
        when(() => mockGoTrueClient.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
      });
    });

    group('getCurrentUser', () {
      test('should return UserModel when user is authenticated', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@example.com';

        when(() => mockUser.id).thenReturn(uid);
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.userMetadata).thenReturn({
          'display_name': 'Test User',
        });
        when(() => mockUser.emailConfirmedAt).thenReturn(DateTime.now().toIso8601String());

        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.email, equals(email));
        expect(user.displayName, equals('Test User'));
        expect(user.emailVerified, isTrue);
      });

      test('should return null when no user is authenticated', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isNull);
      });

      test('should return GenericAuthException on error', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser)
            .thenThrow(Exception('Failed to get current user'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
      });
    });

    group('sendEmailVerification', () {
      test('should return success when email verification is sent', () async {
        // Arrange
        const email = 'test@example.com';

        when(() => mockUser.email).thenReturn(email);
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
        when(() => mockGoTrueClient.resend(
              type: supabase.OtpType.signup,
              email: email,
            )).thenAnswer((_) async => mockResendResponse);

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result.isSuccess, isTrue);

        verify(() => mockGoTrueClient.resend(
              type: supabase.OtpType.signup,
              email: email,
            )).called(1);
      });

      test('should return failure when no user is authenticated', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No hay usuario autenticado'));
      });
    });

    group('changePassword', () {
      test('should return success when password is changed', () async {
        // Arrange
        const newPassword = 'newPassword123';

        when(() => mockUser.id).thenReturn('test-uid');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
        when(() => mockGoTrueClient.updateUser(
              supabase.UserAttributes(password: newPassword),
            )).thenAnswer((_) async => mockUserResponse);

        // Act
        final result = await repository.changePassword(newPassword: newPassword);

        // Assert
        expect(result.isSuccess, isTrue);

        verify(() => mockGoTrueClient.updateUser(
              supabase.UserAttributes(password: newPassword),
            )).called(1);
      });

      test('should return failure when no user is authenticated', () async {
        // Arrange
        const newPassword = 'newPassword123';

        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        // Act
        final result = await repository.changePassword(newPassword: newPassword);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No hay usuario autenticado'));
      });

      test('should return WeakPasswordException for weak password', () async {
        // Arrange
        const newPassword = '123';

        when(() => mockUser.id).thenReturn('test-uid');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
        when(() => mockGoTrueClient.updateUser(
              supabase.UserAttributes(password: newPassword),
            )).thenThrow(supabase.AuthException('Password is too short'));

        // Act
        final result = await repository.changePassword(newPassword: newPassword);

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<WeakPasswordException>());
      });
    });

    group('updateProfile', () {
      test('should return success when profile is updated', () async {
        // Arrange
        const displayName = 'New Name';
        const photoURL = 'https://example.com/photo.jpg';
        const uid = 'test-uid';

        when(() => mockUser.id).thenReturn(uid);
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.userMetadata).thenReturn({
          'display_name': displayName,
          'photo_url': photoURL,
        });
        when(() => mockUser.emailConfirmedAt).thenReturn(DateTime.now().toIso8601String());

        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
        when(() => mockUserResponse.user).thenReturn(mockUser);
        when(() => mockGoTrueClient.updateUser(
              supabase.UserAttributes(data: {
                'display_name': displayName,
                'photo_url': photoURL,
              }),
            )).thenAnswer((_) async => mockUserResponse);

        // Act
        final result = await repository.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final user = result.valueOrNull!;
        expect(user.displayName, equals(displayName));
        expect(user.photoURL, equals(photoURL));
      });

      test('should return failure when no user is authenticated', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        // Act
        final result = await repository.updateProfile(
          displayName: 'New Name',
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('No hay usuario autenticado'));
      });

      test('should return failure when updated user is null', () async {
        // Arrange
        const displayName = 'New Name';

        when(() => mockUser.id).thenReturn('test-uid');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
        when(() => mockUserResponse.user).thenReturn(null);
        when(() => mockGoTrueClient.updateUser(
              supabase.UserAttributes(data: {
                'display_name': displayName,
              }),
            )).thenAnswer((_) async => mockUserResponse);

        // Act
        final result = await repository.updateProfile(
          displayName: displayName,
        );

        // Assert
        expect(result.isFailure, isTrue);
        final error = result.errorOrNull!;
        expect(error, isA<GenericAuthException>());
        expect(error.message, contains('Error al actualizar el perfil'));
      });
    });

    group('authStateChanges', () {
      test('should emit UserModel when user signs in', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@example.com';

        when(() => mockUser.id).thenReturn(uid);
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.userMetadata).thenReturn({});
        when(() => mockUser.emailConfirmedAt).thenReturn(DateTime.now().toIso8601String());

        final mockSession = MockSession();
        when(() => mockSession.user).thenReturn(mockUser);

        final controller =
            StreamController<supabase.AuthState>();

        when(() => mockGoTrueClient.onAuthStateChange)
            .thenAnswer((_) => controller.stream);

        // Act
        final stream = repository.authStateChanges;

        final future = expectLater(
          stream,
          emits(predicate<UserModel?>((user) =>
              user != null && user.uid == uid && user.email == email)),
        );

        // Emit auth state change
        controller.add(supabase.AuthState(
          supabase.AuthChangeEvent.signedIn,
          mockSession,
        ));

        // Assert
        await future;
        await controller.close();
      });

      test('should emit null when user signs out', () async {
        // Arrange
        final controller =
            StreamController<supabase.AuthState>();

        when(() => mockGoTrueClient.onAuthStateChange)
            .thenAnswer((_) => controller.stream);

        // Act
        final stream = repository.authStateChanges;

        final future = expectLater(
          stream,
          emits(isNull),
        );

        // Emit auth state change
        controller.add(supabase.AuthState(
          supabase.AuthChangeEvent.signedOut,
          null,
        ));

        // Assert
        await future;
        await controller.close();
      });
    });

    group('Network and Generic Error Handling', () {
      test('signUp should handle generic exception with network keyword',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          Exception('Network error occurred'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('signUp should handle exception with SocketException in string',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          Exception('SocketException: Connection failed'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('signUp should handle non-network generic exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          Exception('Unknown error'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<GenericAuthException>());
      });

      test('signIn should handle generic exception with network keyword',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          Exception('Network timeout'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('sendPasswordResetEmail should handle network exception', () async {
        // Arrange
        const email = 'test@example.com';

        when(() => mockGoTrueClient.resetPasswordForEmail(email)).thenThrow(
          Exception('Network connection failed'),
        );

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('sendPasswordResetEmail should handle generic exception', () async {
        // Arrange
        const email = 'test@example.com';

        when(() => mockGoTrueClient.resetPasswordForEmail(email)).thenThrow(
          Exception('Unknown error'),
        );

        // Act
        final result = await repository.sendPasswordResetEmail(email: email);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<GenericAuthException>());
      });

      test('signOut should handle generic exception', () async {
        // Arrange
        when(() => mockGoTrueClient.signOut()).thenThrow(
          Exception('Failed to sign out'),
        );

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<GenericAuthException>());
      });

      test('sendEmailVerification should handle network exception', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.email).thenReturn('test@example.com');

        when(() => mockGoTrueClient.resend(
              type: supabase.OtpType.signup,
              email: any(named: 'email'),
            )).thenThrow(
          Exception('Network error'),
        );

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('changePassword should handle network exception', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        when(() => mockGoTrueClient.updateUser(any())).thenThrow(
          Exception('SocketException: No internet'),
        );

        // Act
        final result = await repository.changePassword(newPassword: 'newpass');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('updateProfile should handle network exception', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        when(() => mockGoTrueClient.updateUser(any())).thenThrow(
          Exception('Network connection lost'),
        );

        // Act
        final result = await repository.updateProfile(displayName: 'New Name');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });
    });

    group('Additional Exception Mapping', () {
      test('should map user not found exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('User not found'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UserNotFoundException>());
      });

      test('should map user does not exist exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('User does not exist'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UserNotFoundException>());
      });

      test('should map already registered exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Already registered'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<EmailAlreadyInUseException>());
      });

      test('should map weak password exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Password must be at least 6 characters'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<WeakPasswordException>());
      });

      test('should map malformed email exception', () async {
        // Arrange
        const email = 'invalid-email';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Malformed email address'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<InvalidEmailException>());
      });

      test('should map operation not allowed exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Operation not allowed'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<OperationNotAllowedException>());
      });

      test('should map disabled provider exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signUp(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Provider disabled'),
        );

        // Act
        final result = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<OperationNotAllowedException>());
      });

      test('should map network timeout exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Connection timeout'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkException>());
      });

      test('should map user disabled exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('User disabled'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UserDisabledException>());
      });

      test('should map account disabled exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Account disabled'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UserDisabledException>());
      });

      test('should map status code 400 to InvalidCredentialsException',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Error', statusCode: '400'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<InvalidCredentialsException>());
      });

      test('should map unknown exception to GenericAuthException', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(() => mockGoTrueClient.signInWithPassword(
              email: email,
              password: password,
            )).thenThrow(
          supabase.AuthException('Unknown error occurred'),
        );

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<GenericAuthException>());
      });
    });

    group('getCurrentUser Error Handling', () {
      test('should handle exception when getting current user', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenThrow(
          Exception('Failed to get current user'),
        );

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<GenericAuthException>());
      });
    });
  });
}
