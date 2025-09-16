import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iautomat_auth_manager/iautomat_auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Manager Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  late final AuthRepository _authRepository;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepository(
      firebaseAuth: FirebaseAuth.instance,
    );

    // Escuchar cambios de autenticación
    _authRepository.authStateChanges.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });

    // Obtener usuario actual al iniciar
    _getCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (user) => setState(() => _currentUser = user),
      (error) => _showMessage('Error: ${error.message}'),
    );
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authRepository.signUpWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    result.fold(
      (user) {
        _showMessage('Usuario registrado exitosamente: ${user.email}');
        _clearFields();
      },
      (error) => _showMessage('Error en registro: ${error.message}'),
    );
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authRepository.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    result.fold(
      (user) {
        _showMessage('Inicio de sesión exitoso: ${user.email}');
        _clearFields();
      },
      (error) => _showMessage('Error en inicio de sesión: ${error.message}'),
    );
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Por favor ingresa tu email');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authRepository.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    result.fold(
      (_) => _showMessage('Email de restablecimiento enviado'),
      (error) => _showMessage('Error al enviar email: ${error.message}'),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);

    final result = await _authRepository.signOut();

    setState(() => _isLoading = false);

    result.fold(
      (_) => _showMessage('Sesión cerrada exitosamente'),
      (error) => _showMessage('Error al cerrar sesión: ${error.message}'),
    );
  }

  Future<void> _sendEmailVerification() async {
    setState(() => _isLoading = true);

    final result = await _authRepository.sendEmailVerification();

    setState(() => _isLoading = false);

    result.fold(
      (_) => _showMessage('Email de verificación enviado'),
      (error) => _showMessage('Error al enviar verificación: ${error.message}'),
    );
  }

  void _showMessage(String message) {
    setState(() => _message = message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Auth Manager Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado del usuario actual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de Autenticación',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_currentUser != null) ...[
                      Text('Usuario: ${_currentUser!.email}'),
                      Text('UID: ${_currentUser!.uid}'),
                      Text('Email verificado: ${_currentUser!.emailVerified}'),
                      if (_currentUser!.displayName != null)
                        Text('Nombre: ${_currentUser!.displayName}'),
                    ] else
                      const Text('No hay usuario autenticado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campos de entrada
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),

            // Botones de autenticación
            if (_currentUser == null) ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Registrarse'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: const Text('Olvidé mi contraseña'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
                child: const Text('Cerrar Sesión'),
              ),
              const SizedBox(height: 8),
              if (!_currentUser!.emailVerified)
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendEmailVerification,
                  child: const Text('Verificar Email'),
                ),
            ],

            const SizedBox(height: 20),

            // Mensaje de estado
            if (_message.isNotEmpty)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}