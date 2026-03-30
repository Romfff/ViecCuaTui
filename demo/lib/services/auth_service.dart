import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> register(String email, String password, String role) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null) {
      try {
        await usersRef.doc(user.uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 20));
        print('Firestore user document created for ${user.uid}');
      } catch (error) {
        // Throw so AuthProvider can set errorMessage and stop loading UI.
        print('Firestore write failed during register: $error');
        throw error;
      }
    }
    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

