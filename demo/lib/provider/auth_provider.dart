import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  String? role;
  bool isLoading = false;
  String? errorMessage;
  AuthProvider() {
    _authService.authStateChanges().listen((u) async {
      user = u;
      if (user != null) {
        await _loadUserRole(user!.uid);
      } else {
        role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      final doc = await _authService.usersRef.doc(uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      role = data?['role'] as String? ?? 'job_seeker';
    } catch (_) {
      role = 'job_seeker';
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      print('AuthProvider.login start for $email');
      user = await _authService.login(email, password);
      if (user != null) {
        print('AuthProvider.login success uid=${user!.uid}');
        await _loadUserRole(user!.uid);
      }
      return user != null;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? e.code;
      print('AuthProvider.login FirebaseAuthException: $errorMessage');
      return false;
    } catch (e) {
      errorMessage = e.toString();
      print('AuthProvider.login error: $errorMessage');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String selectedRole, {String? taxCode}) async {
  try {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    user = await _authService.register(email, password, selectedRole, taxCode: taxCode);

    if (user != null) {
      role = selectedRole;
    }
    return user != null;
  } on FirebaseAuthException catch (e) {
    errorMessage = e.message ?? e.code;
    return false;
  } catch (e) {
    errorMessage = e.toString();
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  Future<void> logout() async {
    await _authService.logout();
    user = null;
    role = null;
    notifyListeners();
  }
}
