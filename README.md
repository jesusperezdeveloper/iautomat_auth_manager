# 🔐 iautomat_auth_manager

[![pub package](https://img.shields.io/pub/v/iautomat_auth_manager.svg)](https://pub.dev/packages/iautomat_auth_manager)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Coverage](https://img.shields.io/badge/coverage-86.39%25-brightgreen.svg)](https://github.com/yourusername/iautomat_auth_manager)

**Un paquete Flutter robusto para gestión de autenticación con Firebase Auth usando exclusivamente email y contraseña.**

Diseñado con arquitectura desacoplada, patrón Result para manejo de errores sin excepciones, y cobertura de tests del 86.39%.

## ✨ Características Principales

- 🔐 **Autenticación completa** - Registro, login, logout, reset de contraseña
- 🏗️ **Arquitectura desacoplada** - Repository pattern con inyección de dependencias
- 🎯 **Patrón Result** - Manejo de errores type-safe sin try-catch
- 🧪 **75+ tests** - Cobertura del 86.39% con tests unitarios, integración y edge cases
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

## Instalación

Añade la dependencia a tu `pubspec.yaml`:

```yaml
dependencies:
  iautomat_auth_manager: ^0.0.1
  firebase_auth: ^6.0.2
```

## Configuración

Este paquete requiere que tengas Firebase configurado en tu proyecto Flutter. Sigue las [instrucciones oficiales de Firebase](https://firebase.google.com/docs/flutter/setup).

## Uso básico

### 1. Inicialización

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

// Crear una instancia del repositorio
final authRepository = FirebaseAuthRepository(
  firebaseAuth: FirebaseAuth.instance,
);
```

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

## Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commitea tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
