# Ejemplo de iautomat_auth_manager

Este proyecto demuestra el uso básico del paquete `iautomat_auth_manager` para autenticación con Firebase Auth.

## Características del ejemplo

- ✅ Registro de nuevos usuarios
- ✅ Inicio de sesión con credenciales existentes
- ✅ Restablecimiento de contraseña
- ✅ Cierre de sesión
- ✅ Verificación de email
- ✅ Visualización del estado de autenticación en tiempo real

## Configuración previa

### 1. Configurar Firebase

Antes de ejecutar este ejemplo, necesitas configurar Firebase para tu proyecto:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o usa uno existente
3. Habilita Authentication con Email/Password
4. Descarga los archivos de configuración:
   - `google-services.json` para Android → `android/app/`
   - `GoogleService-Info.plist` para iOS → `ios/Runner/`
   - Configuración web para Web

### 2. Instalar dependencias

```bash
cd example
flutter pub get
```

## Ejecución

```bash
flutter run
```

## Funcionalidades incluidas

### Registro de usuario
1. Ingresa email y contraseña
2. Presiona "Registrarse"
3. El usuario se crea automáticamente en Firebase Auth

### Inicio de sesión
1. Ingresa credenciales de un usuario existente
2. Presiona "Iniciar Sesión"
3. El usuario se autentica

### Restablecimiento de contraseña
1. Ingresa solo el email
2. Presiona "Olvidé mi contraseña"
3. Se envía un email de restablecimiento

### Verificación de email
1. Una vez autenticado, si el email no está verificado
2. Presiona "Verificar Email"
3. Se envía un email de verificación

### Estado en tiempo real
- El estado de autenticación se actualiza automáticamente
- Muestra información del usuario actual
- Cambia la interfaz según el estado de autenticación

## Estructura del código

```dart
// Inicialización del repositorio
final authRepository = FirebaseAuthRepository(
  firebaseAuth: FirebaseAuth.instance,
);

// Escucha de cambios de autenticación
authRepository.authStateChanges.listen((user) {
  // Actualizar UI según el estado
});

// Operaciones de autenticación
final result = await authRepository.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Manejo de resultados
result.fold(
  (user) => handleSuccess(user),
  (error) => handleError(error),
);
```

## Notas importantes

- Asegúrate de tener Firebase configurado correctamente
- El ejemplo usa el patrón Result para manejo de errores
- Todas las operaciones son asíncronas
- La UI se actualiza automáticamente con los cambios de estado