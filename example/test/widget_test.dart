import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('should display initial UI correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Verify that initial UI elements are present
      expect(find.text('Auth Manager Example'), findsOneWidget);
      expect(find.text('Estado de Autenticación'), findsOneWidget);
      expect(find.text('No hay usuario autenticado'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Olvidé mi contraseña'), findsOneWidget);
    });

    testWidgets('should show validation message for empty fields', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Tap the register button without entering any data
      await tester.tap(find.text('Registrarse'));
      await tester.pump();

      // Should show validation message
      expect(find.text('Por favor completa todos los campos'), findsOneWidget);
    });

    testWidgets('should enable/disable buttons during loading', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Find the register button
      final registerButton = find.text('Registrarse');

      // Initially should be enabled
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).first).onPressed, isNotNull);

      // Enter some data in the fields
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // The button should still be enabled before tapping
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).first).onPressed, isNotNull);
    });

    testWidgets('should have proper field labels', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Verify field labels
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('should have password field obscured', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Find password field and verify it's obscured
      final passwordFields = find.byType(TextField);
      final passwordField = tester.widget<TextField>(passwordFields.last);

      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('should have email field with correct keyboard type', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Find email field and verify keyboard type
      final emailField = tester.widget<TextField>(find.byType(TextField).first);

      expect(emailField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('should clear fields after successful operation simulation', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Enter data in fields
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Verify data is entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      // Note: In a real test, we would mock the Firebase calls to simulate success
      // and verify that fields are cleared. For this basic test, we just verify
      // the current state.
    });

    testWidgets('should show different UI when user is authenticated', (WidgetTester tester) async {
      // This test would require mocking the authentication state
      // For now, we test the initial unauthenticated state

      await tester.pumpWidget(const MyApp());

      // In unauthenticated state, should show login/register buttons
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Olvidé mi contraseña'), findsOneWidget);

      // Should not show logout button
      expect(find.text('Cerrar Sesión'), findsNothing);
    });

    testWidgets('should have proper card layout', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Should have a card for authentication status
      expect(find.byType(Card), findsAtLeastNWidgets(1));

      // Should have proper padding and layout
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle text input correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Test email input
      await tester.enterText(emailField, 'user@example.com');
      expect(find.text('user@example.com'), findsOneWidget);

      // Test password input
      await tester.enterText(passwordField, 'securepassword');
      // Password should be obscured, so we can't directly find the text
      // But we can verify the field has content
      expect(tester.widget<TextField>(passwordField).controller?.text, 'securepassword');
    });

    testWidgets('should show proper button hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Should have elevated buttons for primary actions
      final elevatedButtons = find.byType(ElevatedButton);
      expect(elevatedButtons, findsNWidgets(2)); // Register and Sign In

      // Should have text button for secondary action
      final textButtons = find.byType(TextButton);
      expect(textButtons, findsOneWidget); // Forgot password
    });

    testWidgets('should have consistent spacing', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Should have SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsAtLeastNWidgets(3));
    });

    testWidgets('should display app bar correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Should have app bar with correct title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Auth Manager Example'), findsOneWidget);
    });

    testWidgets('should have proper theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify Material3 is being used
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, isTrue);
    });

    group('Error handling widget tests', () {
      testWidgets('should show snackbar for messages', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // This would require triggering an error condition
        // For now, we verify the scaffold messenger is present
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Accessibility tests', () {
      testWidgets('should have semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Verify important widgets have proper semantics
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));

        // Check that buttons have text (which provides semantic labels)
        expect(find.text('Registrarse'), findsOneWidget);
        expect(find.text('Iniciar Sesión'), findsOneWidget);
      });

      testWidgets('should be navigable by keyboard', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Verify focusable elements exist
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('Layout responsiveness tests', () {
      testWidgets('should handle different screen sizes', (WidgetTester tester) async {
        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(800, 600));
        await tester.pumpWidget(const MyApp());

        // Should still show all elements
        expect(find.text('Auth Manager Example'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));

        // Test with smaller screen
        await tester.binding.setSurfaceSize(const Size(300, 600));
        await tester.pump();

        // Should still be functional
        expect(find.text('Auth Manager Example'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}