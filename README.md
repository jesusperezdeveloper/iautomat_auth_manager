# 🔐 iautomat_auth_manager

[![pub package](https://img.shields.io/pub/v/iautomat_auth_manager.svg)](https://pub.dev/packages/iautomat_auth_manager)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Coverage](https://img.shields.io/badge/coverage-87.58%25-brightgreen.svg)](https://github.com/yourusername/iautomat_auth_manager)

**Un paquete Flutter robusto para gestión de autenticación con múltiples providers (Firebase Auth y Supabase Auth) usando exclusivamente email y contraseña.**

Diseñado con arquitectura desacoplada, patrón Result para manejo de errores sin excepciones, y cobertura de tests del 87.58%.

## ✨ Características Principales

- 🔥 **Múltiples providers** - Firebase Auth y Supabase Auth con la misma interface
- 🔐 **Autenticación completa** - Registro, login, logout, reset de contraseña
- 🏗️ **Arquitectura desacoplada** - Repository pattern con inyección de dependencias
- 🎯 **Patrón Result** - Manejo de errores type-safe sin try-catch
- 🧪 **129 tests** - Cobertura del 87.58% con tests unitarios, integración y edge cases
- 📱 **Multiplataforma** - Android, iOS y Web
- 🔄 **Estado en tiempo real** - Stream de cambios de autenticación
- 📚 **Documentación completa** - Cada método documentado con ejemplos

## 🔐 Operaciones Soportadas

- ✅ **Registro** con email y contraseña
- ✅ **Inicio de sesión** con validación completa
- ✅ **Restablecimiento de contraseña** vía email
- ✅ **Cierre de sesión** seguro
- ✅ **Usuario actual** con estado persistente
- ✅ **Verificación de email** automática
- ✅ **Cambio de contraseña** para usuarios autenticados
- ✅ **Actualización de perfil** (nombre, foto)
- ✅ **Gestión de errores** con 9 tipos de excepciones específicas

## 📦 Instalación

Añade la dependencia a tu `pubspec.yaml`:

```yaml
dependencies:
  iautomat_auth_manager: ^1.1.1

  # Para Firebase Auth
  firebase_auth: ^6.0.2

  # Para Supabase Auth
  supabase: ^2.10.0
```

## ⚙️ Configuración

### Firebase Auth

Este paquete requiere que tengas Firebase configurado en tu proyecto Flutter. Sigue las [instrucciones oficiales de Firebase](https://firebase.google.com/docs/flutter/setup).

### Supabase Auth

Para usar Supabase, sigue las [instrucciones oficiales de Supabase](https://supabase.com/docs/guides/getting-started/quickstarts/flutter).

## 🚀 Uso básico

### 1. Inicialización

#### Opción A: Usando Firebase Auth

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

// Directamente con FirebaseAuthRepository
final authRepository = FirebaseAuthRepository(
  firebaseAuth: FirebaseAuth.instance,
);

// O usando el Factory
final authRepository = AuthRepositoryFactory.create(
  provider: AuthProvider.firebase,
  firebaseAuth: FirebaseAuth.instance,
);
```

#### Opción B: Usando Supabase Auth

```dart
import 'package:supabase/supabase.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

// Crear cliente de Supabase
final supabaseClient = SupabaseClient(
  'YOUR_SUPABASE_URL',
  'YOUR_SUPABASE_ANON_KEY',
);

// Directamente con SupabaseAuthRepository
final authRepository = SupabaseAuthRepository(
  supabaseClient: supabaseClient,
);

// O usando el Factory
final authRepository = AuthRepositoryFactory.create(
  provider: AuthProvider.supabase,
  supabaseClient: supabaseClient,
);
```

> **Nota:** El resto de la API es idéntica para ambos providers. Simplemente elige tu provider preferido y usa la misma interface `AuthRepository`.

### 2. Registro de usuario

```dart
final result = await authRepository.signUpWithEmailAndPassword(
  email: 'usuario@ejemplo.com',
  password: 'miContraseñaSegura123',
);

result.fold(
  (user) => print('Usuario registrado: ${user.email}'),
  (error) => print('Error: ${error.message}'),
);
```

### 3. Inicio de sesión

```dart
final result = await authRepository.signInWithEmailAndPassword(
  email: 'usuario@ejemplo.com',
  password: 'miContraseñaSegura123',
);

result.fold(
  (user) => print('Usuario autenticado: ${user.email}'),
  (error) => print('Error: ${error.message}'),
);
```

### 4. Escuchar cambios de autenticación

```dart
authRepository.authStateChanges.listen((user) {
  if (user != null) {
    print('Usuario autenticado: ${user.email}');
  } else {
    print('Usuario no autenticado');
  }
});
```

### 5. Cerrar sesión

```dart
final result = await authRepository.signOut();

result.fold(
  (_) => print('Sesión cerrada exitosamente'),
  (error) => print('Error al cerrar sesión: ${error.message}'),
);
```

## Manejo de errores

El paquete utiliza un patrón `Result<Success, Failure>` para el manejo de errores sin excepciones:

```dart
final result = await authRepository.signInWithEmailAndPassword(
  email: email,
  password: password,
);

if (result.isSuccess) {
  final user = result.valueOrNull!;
  // Usar el usuario
} else {
  final error = result.errorOrNull!;

  switch (error.runtimeType) {
    case InvalidCredentialsException:
      // Manejar credenciales inválidas
      break;
    case UserNotFoundException:
      // Manejar usuario no encontrado
      break;
    case NetworkException:
      // Manejar error de red
      break;
    default:
      // Manejar otros errores
      break;
  }
}
```

## API completa

### AuthRepository

- `signUpWithEmailAndPassword()` - Registro con email/contraseña
- `signInWithEmailAndPassword()` - Inicio de sesión con email/contraseña
- `sendPasswordResetEmail()` - Envío de email de restablecimiento
- `signOut()` - Cierre de sesión
- `getCurrentUser()` - Obtener usuario actual
- `sendEmailVerification()` - Envío de verificación de email
- `changePassword()` - Cambio de contraseña
- `updateProfile()` - Actualización de perfil
- `authStateChanges` - Stream de cambios de autenticación

### Excepciones

- `InvalidCredentialsException` - Credenciales inválidas
- `UserNotFoundException` - Usuario no encontrado
- `EmailAlreadyInUseException` - Email ya en uso
- `WeakPasswordException` - Contraseña débil
- `InvalidEmailException` - Email mal formateado
- `OperationNotAllowedException` - Operación no permitida
- `NetworkException` - Error de red
- `UserDisabledException` - Usuario deshabilitado
- `GenericAuthException` - Error genérico

## 🔄 Cambiar entre Providers

Una de las ventajas clave de este paquete es que puedes cambiar entre Firebase y Supabase sin modificar tu lógica de negocio:

```dart
// En desarrollo, puedes usar Firebase
final authRepo = AuthRepositoryFactory.create(
  provider: AuthProvider.firebase,
  firebaseAuth: FirebaseAuth.instance,
);

// En producción, cambiar a Supabase es tan simple como:
final authRepo = AuthRepositoryFactory.create(
  provider: AuthProvider.supabase,
  supabaseClient: Supabase.instance.client,
);
```

## 📊 Comparación de Providers

| Característica | Firebase Auth | Supabase Auth |
|---------------|--------------|---------------|
| Email/Password | ✅ | ✅ |
| Verificación Email | ✅ | ✅ |
| Reset Password | ✅ | ✅ |
| Actualizar Perfil | ✅ | ✅ |
| Auth State Stream | ✅ | ✅ |
| Manejo de Errores | Unificado | Unificado |
| Interface | Idéntica | Idéntica |

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commitea tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
