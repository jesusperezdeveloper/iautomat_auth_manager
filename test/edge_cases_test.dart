import 'package:flutter_test/flutter_test.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

void main() {
  group('Edge Cases and Boundary Testing', () {
    group('Result edge cases', () {
      test('should handle nested Results correctly', () {
        // Arrange
        const nestedSuccess = Result<Result<String, String>, String>.success(
          Result<String, String>.success('nested value'),
        );
        const nestedFailure = Result<Result<String, String>, String>.success(
          Result<String, String>.failure('nested error'),
        );

        // Act & Assert
        expect(nestedSuccess.isSuccess, isTrue);
        expect(nestedSuccess.valueOrNull!.isSuccess, isTrue);
        expect(nestedSuccess.valueOrNull!.valueOrNull, equals('nested value'));

        expect(nestedFailure.isSuccess, isTrue);
        expect(nestedFailure.valueOrNull!.isFailure, isTrue);
        expect(nestedFailure.valueOrNull!.errorOrNull, equals('nested error'));
      });

      test('should handle Result with nullable types', () {
        // Arrange
        const successWithNull = Result<String?, String>.success(null);
        const failureWithNull = Result<String, String?>.failure(null);

        // Act & Assert
        expect(successWithNull.isSuccess, isTrue);
        expect(successWithNull.valueOrNull, isNull);

        expect(failureWithNull.isFailure, isTrue);
        expect(failureWithNull.errorOrNull, isNull);
      });

      test('should handle complex type transformations', () {
        // Arrange
        const result = Result<List<int>, String>.success([1, 2, 3, 4, 5]);

        // Act
        final transformed = result
            .map((list) => list.where((n) => n.isEven))
            .map((evens) => evens.length);

        // Assert
        expect(transformed.isSuccess, isTrue);
        expect(transformed.valueOrNull, equals(2)); // [2, 4] = length 2
      });

      test('should handle mapError on nested error types', () {
        // Arrange
        const result = Result<String, Exception>.failure(
          FormatException('Invalid format'),
        );

        // Act
        final mappedError = result.mapError((exception) => exception.toString());

        // Assert
        expect(mappedError.isFailure, isTrue);
        expect(mappedError.errorOrNull, contains('FormatException'));
        expect(mappedError.errorOrNull, contains('Invalid format'));
      });

      test('should handle fold with side effects', () {
        // Arrange
        var sideEffectCounter = 0;
        const successResult = Result<int, String>.success(42);
        const failureResult = Result<int, String>.failure('error');

        // Act
        final successFold = successResult.fold(
          (value) {
            sideEffectCounter++;
            return 'Success: $value';
          },
          (error) {
            sideEffectCounter += 10;
            return 'Error: $error';
          },
        );

        final failureFold = failureResult.fold(
          (value) {
            sideEffectCounter++;
            return 'Success: $value';
          },
          (error) {
            sideEffectCounter += 10;
            return 'Error: $error';
          },
        );

        // Assert
        expect(successFold, equals('Success: 42'));
        expect(failureFold, equals('Error: error'));
        expect(sideEffectCounter, equals(11)); // 1 + 10
      });
    });

    group('UserModel edge cases', () {
      test('should handle empty string values', () {
        // Arrange
        const user = UserModel(
          uid: '',
          email: '',
          displayName: '',
          photoURL: '',
          emailVerified: false,
        );

        // Act & Assert
        expect(user.uid, equals(''));
        expect(user.email, equals(''));
        expect(user.displayName, equals(''));
        expect(user.photoURL, equals(''));
      });

      test('should handle very long string values', () {
        // Arrange
        final longString = 'a' * 1000;
        final user = UserModel(
          uid: longString,
          email: '${longString}@example.com',
          displayName: longString,
          photoURL: 'https://example.com/$longString.jpg',
          emailVerified: true,
        );

        // Act & Assert
        expect(user.uid, equals(longString));
        expect(user.email, equals('${longString}@example.com'));
        expect(user.displayName, equals(longString));
        expect(user.photoURL, equals('https://example.com/$longString.jpg'));
      });

      test('should handle special characters in strings', () {
        // Arrange
        const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';
        const user = UserModel(
          uid: 'uid_$specialChars',
          email: 'test+tag$specialChars@example.com',
          displayName: 'Name $specialChars',
          photoURL: 'https://example.com/photo_$specialChars.jpg',
          emailVerified: false,
        );

        // Act & Assert
        expect(user.uid, equals('uid_$specialChars'));
        expect(user.email, equals('test+tag$specialChars@example.com'));
        expect(user.displayName, equals('Name $specialChars'));
        expect(user.photoURL, equals('https://example.com/photo_$specialChars.jpg'));
      });

      test('should handle unicode characters', () {
        // Arrange
        const unicodeChars = '🚀👨‍💻🔥💯🎉中文العربية';
        const user = UserModel(
          uid: 'uid_$unicodeChars',
          email: 'unicode@example.com',
          displayName: 'User $unicodeChars',
          photoURL: 'https://example.com/unicode.jpg',
          emailVerified: true,
        );

        // Act & Assert
        expect(user.uid, equals('uid_$unicodeChars'));
        expect(user.displayName, equals('User $unicodeChars'));
      });

      test('should handle copyWith with all null values', () {
        // Arrange
        const originalUser = UserModel(
          uid: 'original-uid',
          email: 'original@example.com',
          displayName: 'Original Name',
          photoURL: 'https://example.com/original.jpg',
          emailVerified: true,
        );

        // Act
        final copiedUser = originalUser.copyWith(
          uid: null,
          email: null,
          displayName: null,
          photoURL: null,
          emailVerified: null,
        );

        // Assert - should remain unchanged when copying with null
        expect(copiedUser.uid, equals('original-uid'));
        expect(copiedUser.email, equals('original@example.com'));
        expect(copiedUser.displayName, equals('Original Name'));
        expect(copiedUser.photoURL, equals('https://example.com/original.jpg'));
        expect(copiedUser.emailVerified, isTrue);
      });

      test('should handle map conversion with null values', () {
        // Arrange
        const user = UserModel(uid: 'test-uid');

        // Act
        final map = user.toMap();
        final userFromMap = UserModel.fromMap(map);

        // Assert
        expect(map['uid'], equals('test-uid'));
        expect(map['email'], isNull);
        expect(map['displayName'], isNull);
        expect(map['photoURL'], isNull);
        expect(map['emailVerified'], isFalse);

        expect(userFromMap, equals(user));
      });

      test('should handle map with missing emailVerified field', () {
        // Arrange
        final map = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
          // emailVerified is missing
        };

        // Act
        final user = UserModel.fromMap(map);

        // Assert
        expect(user.uid, equals('test-uid'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.photoURL, equals('https://example.com/photo.jpg'));
        expect(user.emailVerified, isFalse); // Should default to false
      });

      test('should handle equality with different object types', () {
        // Arrange
        const user1 = UserModel(uid: 'test-uid');
        const user2 = UserModel(uid: 'test-uid');
        const differentUser = UserModel(uid: 'different-uid');

        // Act & Assert
        expect(user1 == user2, isTrue);
        expect(user1 == differentUser, isFalse);
        expect(user1.hashCode == user2.hashCode, isTrue);
        expect(user1.hashCode == differentUser.hashCode, isFalse);
      });
    });

    group('AuthException edge cases', () {
      test('should handle exception without code', () {
        // Arrange
        const exception = GenericAuthException('Error without code');

        // Act & Assert
        expect(exception.message, equals('Error without code'));
        expect(exception.code, isNull);
        expect(exception.toString(), equals('Error without code'));
      });

      test('should handle exception with empty code', () {
        // Arrange
        const exception = GenericAuthException('Error with empty code', '');

        // Act & Assert
        expect(exception.message, equals('Error with empty code'));
        expect(exception.code, equals(''));
        expect(exception.toString(), equals('[] Error with empty code'));
      });

      test('should handle exception with very long message', () {
        // Arrange
        final longMessage = 'Error message that is extremely long and contains lots of details about what went wrong and why it happened and how to potentially fix it. ' * 10;
        final exception = GenericAuthException(longMessage, 'long-error');

        // Act & Assert
        expect(exception.message, equals(longMessage));
        expect(exception.code, equals('long-error'));
        expect(exception.toString(), contains(longMessage));
        expect(exception.toString(), contains('[long-error]'));
      });

      test('should handle exception hierarchy correctly', () {
        // Arrange
        const invalidCredentials = InvalidCredentialsException('invalid-cred');
        const userNotFound = UserNotFoundException('user-not-found');
        const emailInUse = EmailAlreadyInUseException('email-in-use');
        const weakPassword = WeakPasswordException('weak-password');
        const invalidEmail = InvalidEmailException('invalid-email');
        const operationNotAllowed = OperationNotAllowedException('operation-not-allowed');
        const networkException = NetworkException('network-error');
        const userDisabled = UserDisabledException('user-disabled');
        const genericException = GenericAuthException('Generic error', 'generic');

        // Act & Assert - All should be AuthException instances
        expect(invalidCredentials, isA<AuthException>());
        expect(userNotFound, isA<AuthException>());
        expect(emailInUse, isA<AuthException>());
        expect(weakPassword, isA<AuthException>());
        expect(invalidEmail, isA<AuthException>());
        expect(operationNotAllowed, isA<AuthException>());
        expect(networkException, isA<AuthException>());
        expect(userDisabled, isA<AuthException>());
        expect(genericException, isA<AuthException>());

        // Check specific types
        expect(invalidCredentials, isA<InvalidCredentialsException>());
        expect(userNotFound, isA<UserNotFoundException>());
        expect(emailInUse, isA<EmailAlreadyInUseException>());
        expect(weakPassword, isA<WeakPasswordException>());
        expect(invalidEmail, isA<InvalidEmailException>());
        expect(operationNotAllowed, isA<OperationNotAllowedException>());
        expect(networkException, isA<NetworkException>());
        expect(userDisabled, isA<UserDisabledException>());
        expect(genericException, isA<GenericAuthException>());
      });

      test('should handle exception equality', () {
        // Arrange
        const exception1 = GenericAuthException('Same error', 'same-code');
        const exception2 = GenericAuthException('Same error', 'same-code');
        const exception3 = GenericAuthException('Different error', 'same-code');
        const exception4 = GenericAuthException('Same error', 'different-code');

        // Act & Assert
        expect(exception1.toString(), equals(exception2.toString()));
        expect(exception1.toString(), isNot(equals(exception3.toString())));
        expect(exception1.toString(), isNot(equals(exception4.toString())));
      });
    });

    group('Input validation edge cases', () {
      test('should handle whitespace-only inputs', () {
        // Arrange
        const userWithWhitespace = UserModel(
          uid: '   ',
          email: '\t\n',
          displayName: '   \t  \n  ',
          photoURL: '  ',
          emailVerified: false,
        );

        // Act & Assert
        expect(userWithWhitespace.uid, equals('   '));
        expect(userWithWhitespace.email, equals('\t\n'));
        expect(userWithWhitespace.displayName, equals('   \t  \n  '));
        expect(userWithWhitespace.photoURL, equals('  '));
      });

      test('should handle boundary values for boolean', () {
        // Arrange
        const userVerified = UserModel(uid: 'test', emailVerified: true);
        const userNotVerified = UserModel(uid: 'test', emailVerified: false);

        // Act & Assert
        expect(userVerified.emailVerified, isTrue);
        expect(userNotVerified.emailVerified, isFalse);
      });
    });

    group('Memory and performance edge cases', () {
      test('should handle large number of Result operations', () {
        // Arrange
        var result = const Result<int, String>.success(0);

        // Act - Chain many operations
        for (int i = 1; i <= 1000; i++) {
          result = result.map((value) => value + 1);
        }

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(1000));
      });

      test('should handle multiple UserModel conversions', () {
        // Arrange
        const originalUser = UserModel(
          uid: 'performance-test',
          email: 'perf@example.com',
          displayName: 'Performance User',
          photoURL: 'https://example.com/perf.jpg',
          emailVerified: true,
        );

        // Act - Multiple conversions
        UserModel currentUser = originalUser;
        for (int i = 0; i < 100; i++) {
          final map = currentUser.toMap();
          currentUser = UserModel.fromMap(map);
        }

        // Assert - Should remain unchanged
        expect(currentUser, equals(originalUser));
      });

      test('should handle rapid Result fold operations', () {
        // Arrange
        const results = [
          Result<int, String>.success(1),
          Result<int, String>.failure('error1'),
          Result<int, String>.success(2),
          Result<int, String>.failure('error2'),
          Result<int, String>.success(3),
        ];

        // Act
        final processed = results.map((result) => result.fold(
          (value) => 'Success: $value',
          (error) => 'Error: $error',
        )).toList();

        // Assert
        expect(processed, equals([
          'Success: 1',
          'Error: error1',
          'Success: 2',
          'Error: error2',
          'Success: 3',
        ]));
      });
    });
  });
}