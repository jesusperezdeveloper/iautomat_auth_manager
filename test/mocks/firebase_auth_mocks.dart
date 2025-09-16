import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

/// Genera mocks para Firebase Auth y User
@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
])
void main() {}