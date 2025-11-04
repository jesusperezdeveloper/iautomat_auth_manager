import 'package:flutter/material.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';
import 'package:supabase/supabase.dart' as supabase;

/// Ejemplo de uso de iautomat_auth_manager con Supabase Auth.
///
/// Este ejemplo muestra cómo:
/// - Inicializar cliente de Supabase
/// - Crear un repositorio de autenticación con Supabase
/// - Registrar usuarios
/// - Iniciar sesión
/// - Manejar errores con el patrón Result
/// - Escuchar cambios de estado de autenticación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SupabaseAuthExample());
}

class SupabaseAuthExample extends StatelessWidget {
  const SupabaseAuthExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Crear repositorio usando Supabase
  late final AuthRepository authRepository;
  late final supabase.SupabaseClient _supabaseClient;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'No autenticado';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();

    // Crear cliente de Supabase
    _supabaseClient = supabase.SupabaseClient(
      'YOUR_SUPABASE_URL', // Reemplazar con tu URL de Supabase
      'YOUR_SUPABASE_ANON_KEY', // Reemplazar con tu clave anónima
    );

    // Opción 1: Crear directamente con SupabaseAuthRepository
    authRepository = SupabaseAuthRepository(
      supabaseClient: _supabaseClient,
    );

    // Opción 2: Usar el Factory
    // authRepository = AuthRepositoryFactory.create(
    //   provider: AuthProvider.supabase,
    //   supabaseClient: _supabaseClient,
    // );

    // Escuchar cambios de autenticación
    authRepository.authStateChanges.listen((user) {
      setState(() {
        _currentUser = user;
        _status = user != null
            ? 'Autenticado como: ${user.email}'
            : 'No autenticado';
      });
    });

    // Verificar usuario actual
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (user) {
        setState(() {
          _currentUser = user;
          _status = user != null
              ? 'Autenticado como: ${user.email}'
              : 'No autenticado';
        });
      },
      (error) {
        setState(() {
          _status = 'Error: ${error.message}';
        });
      },
    );
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'Por favor ingresa email y contraseña';
      });
      return;
    }

    final result = await authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (user) {
        setState(() {
          _status = 'Registro exitoso: ${user.email}';
        });
        _showSnackBar('Usuario registrado correctamente', isError: false);
      },
      (error) {
        setState(() {
          _status = 'Error en registro: ${error.message}';
        });
        _showSnackBar(_getErrorMessage(error), isError: true);
      },
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'Por favor ingresa email y contraseña';
      });
      return;
    }

    final result = await authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (user) {
        setState(() {
          _status = 'Inicio de sesión exitoso: ${user.email}';
        });
        _showSnackBar('Bienvenido ${user.email}', isError: false);
      },
      (error) {
        setState(() {
          _status = 'Error en inicio de sesión: ${error.message}';
        });
        _showSnackBar(_getErrorMessage(error), isError: true);
      },
    );
  }

  Future<void> _signOut() async {
    final result = await authRepository.signOut();

    result.fold(
      (_) {
        setState(() {
          _status = 'Sesión cerrada';
        });
        _showSnackBar('Sesión cerrada correctamente', isError: false);
      },
      (error) {
        setState(() {
          _status = 'Error al cerrar sesión: ${error.message}';
        });
        _showSnackBar('Error al cerrar sesión', isError: true);
      },
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _status = 'Por favor ingresa tu email';
      });
      return;
    }

    final result = await authRepository.sendPasswordResetEmail(email: email);

    result.fold(
      (_) {
        setState(() {
          _status = 'Email de recuperación enviado';
        });
        _showSnackBar('Revisa tu email para restablecer contraseña',
            isError: false);
      },
      (error) {
        setState(() {
          _status = 'Error al enviar email: ${error.message}';
        });
        _showSnackBar(_getErrorMessage(error), isError: true);
      },
    );
  }

  String _getErrorMessage(AuthException error) {
    if (error is InvalidCredentialsException) {
      return 'Credenciales inválidas. Verifica tu email y contraseña.';
    } else if (error is UserNotFoundException) {
      return 'Usuario no encontrado. ¿Necesitas registrarte?';
    } else if (error is EmailAlreadyInUseException) {
      return 'Este email ya está en uso. Intenta iniciar sesión.';
    } else if (error is WeakPasswordException) {
      return 'La contraseña es muy débil. Usa una más segura.';
    } else if (error is InvalidEmailException) {
      return 'El formato del email es inválido.';
    } else if (error is NetworkException) {
      return 'Error de conexión. Verifica tu internet.';
    } else {
      return error.message;
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Supabase Auth Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo o título
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'iautomat_auth_manager',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'con Supabase Auth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_currentUser != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('UID: ${_currentUser!.uid}'),
                      if (_currentUser!.displayName != null)
                        Text('Nombre: ${_currentUser!.displayName}'),
                      Text('Email verificado: ${_currentUser!.emailVerified}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Formulario
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // Botones de acción
            if (_currentUser == null) ...[
              ElevatedButton.icon(
                onPressed: _signUp,
                icon: const Icon(Icons.person_add),
                label: const Text('Registrarse'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _signIn,
                icon: const Icon(Icons.login),
                label: const Text('Iniciar Sesión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _resetPassword,
                icon: const Icon(Icons.email),
                label: const Text('Recuperar Contraseña'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Nota sobre el provider
            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este ejemplo usa Supabase Auth. La API es idéntica a Firebase Auth.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
