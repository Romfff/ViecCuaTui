import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  Uint8List? avatarBytes;
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
        avatarBytes = null;
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

      // Load avatar from Hive
      try {
        final avatarBox = await Hive.openBox<Uint8List>('user_avatars');
        avatarBytes = avatarBox.get(uid);
      } catch (e) {
        print('Error loading avatar from Hive: $e');
      }
    } catch (_) {
      role = 'job_seeker';
      bookmarkedJobIds = [];
      hobbies = null;
      strengths = null;
      dreamJob = null;
      avatarBytes = null;
    }
  }

  Future<void> updateAvatar(Uint8List bytes) async {
    if (user == null) return;
    avatarBytes = bytes;
    notifyListeners();
    try {
      final avatarBox = await Hive.openBox<Uint8List>('user_avatars');
      await avatarBox.put(user!.uid, bytes);
    } catch (e) {
      print('Error saving avatar to Hive: $e');
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
    avatarBytes = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Không thể gửi email đặt lại mật khẩu');
    } catch (e) {
      throw Exception(e.toString());
    }
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
