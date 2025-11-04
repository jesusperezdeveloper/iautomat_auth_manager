import 'package:flutter_test/flutter_test.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase/supabase.dart' as supabase;

import 'mocks/firebase_auth_mocks.mocks.dart';

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

void main() {
  group('AuthRepositoryFactory', () {
    test('should create FirebaseAuthRepository when provider is firebase',
        () {
      // Arrange
      final mockFirebaseAuth = MockFirebaseAuth();

      // Act
      final repository = AuthRepositoryFactory.create(
        provider: AuthProvider.firebase,
        firebaseAuth: mockFirebaseAuth,
      );

      // Assert
      expect(repository, isA<FirebaseAuthRepository>());
    });

    test('should create SupabaseAuthRepository when provider is supabase',
        () {
      // Arrange
      final mockSupabaseClient = MockSupabaseClient();

      // Act
      final repository = AuthRepositoryFactory.create(
        provider: AuthProvider.supabase,
        supabaseClient: mockSupabaseClient,
      );

      // Assert
      expect(repository, isA<SupabaseAuthRepository>());
    });

    test('should throw ArgumentError when firebaseAuth is null for Firebase',
        () {
      // Act & Assert
      expect(
        () => AuthRepositoryFactory.create(
          provider: AuthProvider.firebase,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('firebaseAuth es requerido'),
        )),
      );
    });

    test('should throw ArgumentError when supabaseClient is null for Supabase',
        () {
      // Act & Assert
      expect(
        () => AuthRepositoryFactory.create(
          provider: AuthProvider.supabase,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('supabaseClient es requerido'),
        )),
      );
    });
  });
}
