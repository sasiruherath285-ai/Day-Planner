import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static const _userKey = 'day_planner_user';
  static const _signedInKey = 'day_planner_signed_in';

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_signedInKey) ?? false)) return null;
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = UserModel(
      id: email.hashCode.toString(),
      name: displayName?.trim().isNotEmpty == true
          ? displayName!.trim()
          : _nameFromEmail(email),
      email: email.trim(),
    );
    await _persistUser(user);
    return user;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = UserModel(
      id: email.hashCode.toString(),
      name: name.trim(),
      email: email.trim(),
    );
    await _persistUser(user);
    return user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_signedInKey, false);
  }

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_signedInKey, true);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'Planner';
    return local[0].toUpperCase() + local.substring(1);
  }
}
