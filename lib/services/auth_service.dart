import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    UserCredential? credential;

    try {
      print('=== INICIO REGISTRO ===');
      print('Email: $email');

      // Paso 1: Crear usuario en Firebase Auth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Auth exitoso. UID: ${credential.user?.uid}');

      if (credential.user == null) {
        throw Exception('No se pudo crear el usuario en Auth');
      }

      // Paso 2: Crear objeto UserModel
      final userData = {
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(), // Usar server timestamp
        'profileImageUrl': null,
      };

      print('Datos a guardar: $userData');

      // Paso 3: Guardar en Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      print('Guardado en Firestore exitoso');

      // Paso 4: Crear UserModel para retornar
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        createdAt: DateTime.now(),
      );

      print('=== REGISTRO COMPLETADO ===');
      return user;

    } catch (e) {
      print('=== ERROR EN REGISTRO ===');
      print('Error tipo: ${e.runtimeType}');
      print('Error mensaje: $e');

      // Limpiar si algo falló
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
          print('Usuario eliminado de Auth');
        } catch (deleteError) {
          print('Error al eliminar de Auth: $deleteError');
        }
      }

      rethrow;
    }
  }

  // Resto de métodos...
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Error al actualizar: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Error al enviar email: ${e.toString()}');
    }
  }
}