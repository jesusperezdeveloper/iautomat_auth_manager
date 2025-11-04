import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:supabase/supabase.dart' as supabase;

import 'auth_repository.dart';
import 'firebase_auth_repository.dart';
import 'supabase_auth_repository.dart';

/// Enumeración de proveedores de autenticación soportados.
enum AuthProvider {
  /// Firebase Authentication
  firebase,

  /// Supabase Authentication
  supabase,
}

/// Factory para crear instancias de [AuthRepository] según el proveedor.
///
/// Esta clase proporciona un método estático para crear instancias de
/// repositorios de autenticación según el proveedor especificado.
class AuthRepositoryFactory {
  // Constructor privado para prevenir instanciación
  AuthRepositoryFactory._();

  /// Crea una instancia de [AuthRepository] según el proveedor especificado.
  ///
  /// [provider] especifica qué proveedor de autenticación usar.
  /// [firebaseAuth] es requerido cuando [provider] es [AuthProvider.firebase].
  /// [supabaseClient] es requerido cuando [provider] es [AuthProvider.supabase].
  ///
  /// Throws [ArgumentError] si no se proporciona el cliente requerido para el proveedor.
  ///
  /// Ejemplo con Firebase:
  /// ```dart
  /// final authRepo = AuthRepositoryFactory.create(
  ///   provider: AuthProvider.firebase,
  ///   firebaseAuth: FirebaseAuth.instance,
  /// );
  /// ```
  ///
  /// Ejemplo con Supabase:
  /// ```dart
  /// final authRepo = AuthRepositoryFactory.create(
  ///   provider: AuthProvider.supabase,
  ///   supabaseClient: Supabase.instance.client,
  /// );
  /// ```
  static AuthRepository create({
    required AuthProvider provider,
    firebase.FirebaseAuth? firebaseAuth,
    supabase.SupabaseClient? supabaseClient,
  }) {
    switch (provider) {
      case AuthProvider.firebase:
        if (firebaseAuth == null) {
          throw ArgumentError(
            'firebaseAuth es requerido cuando el provider es AuthProvider.firebase',
          );
        }
        return FirebaseAuthRepository(firebaseAuth: firebaseAuth);

      case AuthProvider.supabase:
        if (supabaseClient == null) {
          throw ArgumentError(
            'supabaseClient es requerido cuando el provider es AuthProvider.supabase',
          );
        }
        return SupabaseAuthRepository(supabaseClient: supabaseClient);
    }
  }
}
