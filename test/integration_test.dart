import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

import 'mocks/firebase_auth_mocks.mocks.dart';

void main() {
  group('Integration Tests - Complete Auth Flows', () {
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

    group('Complete User Registration Flow', () {
      test('should successfully register, verify email, and sign in', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'securePassword123';
        const uid = 'new-user-uid';

        // Mock user after registration (email not verified)
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async {});

        when(mockUserCredential.user).thenReturn(mockUser);

        // Mock registration
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        // Mock current user access
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act 1: Register user
        final registrationResult = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert 1: Registration successful
        expect(registrationResult.isSuccess, isTrue);
        final registeredUser = registrationResult.valueOrNull!;
        expect(registeredUser.uid, equals(uid));
        expect(registeredUser.email, equals(email));
        expect(registeredUser.emailVerified, isFalse);

        // Act 2: Send email verification
        final verificationResult = await repository.sendEmailVerification();

        // Assert 2: Verification email sent
        expect(verificationResult.isSuccess, isTrue);
        verify(mockUser.sendEmailVerification()).called(1);

        // Simulate user verifying email (update mock)
        when(mockUser.emailVerified).thenReturn(true);

        // Act 3: Sign in after verification
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        final signInResult = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert 3: Sign in successful with verified email
        expect(signInResult.isSuccess, isTrue);
        final signedInUser = signInResult.valueOrNull!;
        expect(signedInUser.uid, equals(uid));
        expect(signedInUser.emailVerified, isTrue);
      });
    });

    group('Complete Password Reset Flow', () {
      test('should reset password and sign in with new password', () async {
        // Arrange
        const email = 'user@example.com';
        const oldPassword = 'oldPassword123';
        const newPassword = 'newPassword456';
        const uid = 'existing-user-uid';

        // Create fresh mocks for this test
        final resetMockUser = MockUser();
        final resetMockCredential = MockUserCredential();

        // Mock existing user
        when(resetMockUser.uid).thenReturn(uid);
        when(resetMockUser.email).thenReturn(email);
        when(resetMockUser.displayName).thenReturn(null);
        when(resetMockUser.photoURL).thenReturn(null);
        when(resetMockUser.emailVerified).thenReturn(true);

        when(resetMockCredential.user).thenReturn(resetMockUser);

        // Act 1: Send password reset email
        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async {});

        final resetEmailResult = await repository.sendPasswordResetEmail(email: email);

        // Assert 1: Reset email sent successfully
        expect(resetEmailResult.isSuccess, isTrue);
        verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);

        // Act 2: Attempt sign in with old password (should fail)
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: oldPassword,
        )).thenThrow(FirebaseAuthException(
          code: 'wrong-password',
          message: 'The password is invalid',
        ));

        final oldPasswordResult = await repository.signInWithEmailAndPassword(
          email: email,
          password: oldPassword,
        );

        // Assert 2: Old password should fail
        expect(oldPasswordResult.isFailure, isTrue);
        expect(oldPasswordResult.errorOrNull, isA<InvalidCredentialsException>());

        // Act 3: Sign in with new password (should succeed)
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: newPassword,
        )).thenAnswer((_) async => resetMockCredential);

        final newPasswordResult = await repository.signInWithEmailAndPassword(
          email: email,
          password: newPassword,
        );

        // Assert 3: New password should work
        expect(newPasswordResult.isSuccess, isTrue);
        final user = newPasswordResult.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.email, equals(email));
      });
    });

    group('Complete Profile Update Flow', () {
      test('should sign in, update profile, and verify changes', () async {
        // Arrange
        const email = 'user@example.com';
        const password = 'password123';
        const uid = 'profile-user-uid';
        const initialName = 'Initial Name';
        const updatedName = 'Updated Name';
        const photoURL = 'https://example.com/new-photo.jpg';

        // Create fresh mocks for this test
        final profileMockUser = MockUser();
        final profileMockCredential = MockUserCredential();

        // Mock initial user state
        when(profileMockUser.uid).thenReturn(uid);
        when(profileMockUser.email).thenReturn(email);
        when(profileMockUser.displayName).thenReturn(initialName);
        when(profileMockUser.photoURL).thenReturn(null);
        when(profileMockUser.emailVerified).thenReturn(true);

        when(profileMockCredential.user).thenReturn(profileMockUser);

        // Act 1: Sign in
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => profileMockCredential);

        final signInResult = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert 1: Sign in successful
        expect(signInResult.isSuccess, isTrue);
        final initialUser = signInResult.valueOrNull!;
        expect(initialUser.displayName, equals(initialName));
        expect(initialUser.photoURL, isNull);

        // Mock profile update operations
        when(profileMockUser.updateDisplayName(updatedName)).thenAnswer((_) async {});
        when(profileMockUser.updatePhotoURL(photoURL)).thenAnswer((_) async {});
        when(profileMockUser.reload()).thenAnswer((_) async {});

        // Mock updated user after reload
        final mockUpdatedUser = MockUser();
        when(mockUpdatedUser.uid).thenReturn(uid);
        when(mockUpdatedUser.email).thenReturn(email);
        when(mockUpdatedUser.displayName).thenReturn(updatedName);
        when(mockUpdatedUser.photoURL).thenReturn(photoURL);
        when(mockUpdatedUser.emailVerified).thenReturn(true);

        // Configurar que las llamadas secuenciales devuelven primero el usuario original, luego el actualizado
        var callCount = 0;
        when(mockFirebaseAuth.currentUser).thenAnswer((_) {
          callCount++;
          return callCount == 1 ? profileMockUser : mockUpdatedUser;
        });

        // Act 2: Update profile
        final updateResult = await repository.updateProfile(
          displayName: updatedName,
          photoURL: photoURL,
        );

        // Assert 2: Profile updated successfully
        expect(updateResult.isSuccess, isTrue);
        final updatedUser = updateResult.valueOrNull!;
        expect(updatedUser.displayName, equals(updatedName));
        expect(updatedUser.photoURL, equals(photoURL));

        verify(profileMockUser.updateDisplayName(updatedName)).called(1);
        verify(profileMockUser.updatePhotoURL(photoURL)).called(1);
        verify(profileMockUser.reload()).called(1);
      });
    });

    group('Complete Authentication State Flow', () {
      test('should handle complete authentication lifecycle', () async {
        // Arrange
        const email = 'lifecycle@example.com';
        const password = 'password123';
        const uid = 'lifecycle-uid';

        late StreamController<User?> authStateController;
        final List<UserModel?> authStateChanges = [];

        // Mock user
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);
        when(mockUser.emailVerified).thenReturn(false);

        when(mockUserCredential.user).thenReturn(mockUser);

        // Mock auth state stream
        authStateController = StreamController<User?>.broadcast();
        when(mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => authStateController.stream);

        // Start listening to auth changes
        final subscription = repository.authStateChanges.listen((user) {
          authStateChanges.add(user);
        });

        // Act 1: Initial state (no user)
        authStateController.add(null);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert 1: Should emit null initially
        expect(authStateChanges.last, isNull);

        // Act 2: Register user
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        final registrationResult = await repository.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Simulate auth state change after registration
        authStateController.add(mockUser);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert 2: Registration successful and auth state updated
        expect(registrationResult.isSuccess, isTrue);
        expect(authStateChanges.last, isNotNull);
        expect(authStateChanges.last!.uid, equals(uid));

        // Act 3: Sign out
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        final signOutResult = await repository.signOut();

        // Simulate auth state change after sign out
        authStateController.add(null);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert 3: Sign out successful and auth state updated
        expect(signOutResult.isSuccess, isTrue);
        expect(authStateChanges.last, isNull);

        // Clean up
        await subscription.cancel();
        await authStateController.close();
      });
    });

    group('Error Recovery Flows', () {
      test('should handle network error and retry successfully', () async {
        // Arrange
        const email = 'retry@example.com';
        const password = 'password123';
        const uid = 'retry-uid';

        // Create fresh mocks for this test
        final retryMockUser = MockUser();
        final retryMockCredential = MockUserCredential();

        when(retryMockUser.uid).thenReturn(uid);
        when(retryMockUser.email).thenReturn(email);
        when(retryMockUser.displayName).thenReturn(null);
        when(retryMockUser.photoURL).thenReturn(null);
        when(retryMockUser.emailVerified).thenReturn(true);
        when(retryMockCredential.user).thenReturn(retryMockUser);

        // Act 1: First attempt fails with network error
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'network-request-failed',
          message: 'A network error occurred',
        ));

        final firstAttempt = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert 1: First attempt should fail with network error
        expect(firstAttempt.isFailure, isTrue);
        expect(firstAttempt.errorOrNull, isA<NetworkException>());

        // Act 2: Retry after network is restored
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => retryMockCredential);

        final retryAttempt = await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert 2: Retry should succeed
        expect(retryAttempt.isSuccess, isTrue);
        final user = retryAttempt.valueOrNull!;
        expect(user.uid, equals(uid));
        expect(user.email, equals(email));
      });

      test('should handle password change after authentication error', () async {
        // Arrange
        const email = 'changepass@example.com';
        const oldPassword = 'oldPassword123';
        const newPassword = 'newPassword456';
        const uid = 'changepass-uid';

        // Create fresh mocks for this test
        final testMockUser = MockUser();
        final testMockCredential = MockUserCredential();

        when(testMockUser.uid).thenReturn(uid);
        when(testMockUser.email).thenReturn(email);
        when(testMockUser.displayName).thenReturn(null);
        when(testMockUser.photoURL).thenReturn(null);
        when(testMockUser.emailVerified).thenReturn(true);
        when(testMockCredential.user).thenReturn(testMockUser);

        // Act 1: Sign in with current user
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: oldPassword,
        )).thenAnswer((_) async => testMockCredential);

        final signInResult = await repository.signInWithEmailAndPassword(
          email: email,
          password: oldPassword,
        );

        expect(signInResult.isSuccess, isTrue);

        // Act 2: Change password
        when(mockFirebaseAuth.currentUser).thenReturn(testMockUser);
        when(testMockUser.updatePassword(newPassword)).thenAnswer((_) async {});

        final changePasswordResult = await repository.changePassword(
          newPassword: newPassword,
        );

        // Assert 2: Password change successful
        expect(changePasswordResult.isSuccess, isTrue);
        verify(testMockUser.updatePassword(newPassword)).called(1);

        // Act 3: Sign out and sign in with new password
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        await repository.signOut();

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: newPassword,
        )).thenAnswer((_) async => testMockCredential);

        final newSignInResult = await repository.signInWithEmailAndPassword(
          email: email,
          password: newPassword,
        );

        // Assert 3: Can sign in with new password
        expect(newSignInResult.isSuccess, isTrue);
        final user = newSignInResult.valueOrNull!;
        expect(user.uid, equals(uid));
      });
    });

    group('Concurrent Operations', () {
      test('should handle multiple simultaneous operations correctly', () async {
        // Arrange
        const email1 = 'concurrent1@example.com';
        const email2 = 'concurrent2@example.com';
        const password = 'password123';

        // Mock for different users
        final mockUser1 = MockUser();
        final mockUser2 = MockUser();
        final mockCredential1 = MockUserCredential();
        final mockCredential2 = MockUserCredential();

        when(mockUser1.uid).thenReturn('uid1');
        when(mockUser1.email).thenReturn(email1);
        when(mockUser1.displayName).thenReturn(null);
        when(mockUser1.photoURL).thenReturn(null);
        when(mockUser1.emailVerified).thenReturn(false);

        when(mockUser2.uid).thenReturn('uid2');
        when(mockUser2.email).thenReturn(email2);
        when(mockUser2.displayName).thenReturn(null);
        when(mockUser2.photoURL).thenReturn(null);
        when(mockUser2.emailVerified).thenReturn(false);

        when(mockCredential1.user).thenReturn(mockUser1);
        when(mockCredential2.user).thenReturn(mockUser2);

        // Mock concurrent registrations
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email1,
          password: password,
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockCredential1;
        });

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email2,
          password: password,
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return mockCredential2;
        });

        // Act: Start both operations simultaneously
        final future1 = repository.signUpWithEmailAndPassword(
          email: email1,
          password: password,
        );

        final future2 = repository.signUpWithEmailAndPassword(
          email: email2,
          password: password,
        );

        final results = await Future.wait([future1, future2]);

        // Assert: Both should succeed independently
        expect(results[0].isSuccess, isTrue);
        expect(results[1].isSuccess, isTrue);

        expect(results[0].valueOrNull?.email, equals(email1));
        expect(results[1].valueOrNull?.email, equals(email2));
      });
    });
  });
}