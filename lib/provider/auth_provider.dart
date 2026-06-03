import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  String? role;
  String? fullName;
  String? phone;
  String? address;
  String? hobbies;
  String? strengths;
  String? dreamJob;
  List<String> bookmarkedJobIds = [];
  bool isLoading = false;
  String? errorMessage;
  AuthProvider() {
    _authService.authStateChanges().listen((u) async {
      user = u;
      if (user != null) {
        await _loadUserRole(user!.uid);
      } else {
        role = null;
        bookmarkedJobIds = [];
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      final doc = await _authService.usersRef.doc(uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      role = data?['role'] as String? ?? 'job_seeker';
      bookmarkedJobIds = List<String>.from(data?['bookmarkedJobIds'] ?? []);
      fullName = data?['fullName'] as String?;
      phone = data?['phone'] as String?;
      address = data?['address'] as String?;
      hobbies = data?['hobbies'] as String?;
      strengths = data?['strengths'] as String?;
      dreamJob = data?['dreamJob'] as String?;
    } catch (_) {
      role = 'job_seeker';
      bookmarkedJobIds = [];
      hobbies = null;
      strengths = null;
      dreamJob = null;
    }
  }

  Future<void> reloadUserProfile() async {
    if (user == null) return;
    await _loadUserRole(user!.uid);
    notifyListeners();
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
    bookmarkedJobIds = [];
    notifyListeners();
  }

  Future<void> toggleBookmark(String jobId) async {
    if (user == null) return;

    final isBookmarked = bookmarkedJobIds.contains(jobId);
    if (isBookmarked) {
      bookmarkedJobIds.remove(jobId);
    } else {
      bookmarkedJobIds.add(jobId);
    }

    await _authService.usersRef.doc(user!.uid).set({
      'bookmarkedJobIds': bookmarkedJobIds,
    }, SetOptions(merge: true));
    notifyListeners();
  }
}
