/// Modelo de usuario desacoplado de Firebase Auth.
///
/// [UserModel] representa la información básica del usuario de manera
/// independiente de la implementación específica de autenticación.
class UserModel {
  /// Identificador único del usuario.
  final String uid;

  /// Dirección de correo electrónico del usuario.
  final String? email;

  /// Nombre para mostrar del usuario.
  final String? displayName;

  /// URL de la foto de perfil del usuario.
  final String? photoURL;

  /// Indica si el email del usuario ha sido verificado.
  final bool emailVerified;

  /// Crea una instancia de [UserModel].
  ///
  /// [uid] es requerido e identifica únicamente al usuario.
  /// Los demás campos son opcionales.
  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });

  /// Crea una copia del usuario con los campos especificados modificados.
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  /// Convierte el modelo a un Map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
    };
  }

  /// Crea un [UserModel] desde un Map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      emailVerified: map['emailVerified'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        emailVerified.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, emailVerified: $emailVerified)';
  }
}