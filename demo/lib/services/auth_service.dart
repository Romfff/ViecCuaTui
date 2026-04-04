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

  Future<User?> register(String email, String password, String role, {String? taxCode}) async {
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
        if (role == 'job_poster') 'taxCode': taxCode, // chỉ lưu nếu là nhà tuyển dụng
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 20));
      print('Firestore user document created for ${user.uid}');
    } catch (error) {
      print('Firestore write failed during register: $error');
      rethrow;
    }
  }
  return user;
}


  Future<void> logout() async {
    await _auth.signOut();
  }
}

