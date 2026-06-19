import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['success'] == true) {
      final token = response['token'];
      final user = UserModel.fromJson(response['user']);
      await _saveSession(token, user);
      apiService.setToken(token);
      return {'token': token, 'user': user};
    }
    throw Exception(response['message'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final response = await apiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });

    if (response['success'] == true) {
      final token = response['token'];
      final user = UserModel.fromJson(response['user']);
      await _saveSession(token, user);
      apiService.setToken(token);
      return {'token': token, 'user': user};
    }
    throw Exception(response['message'] ?? 'Registration failed');
  }

  Future<UserModel> updateProfile({
    required String name,
  }) async {
    final response = await apiService.put('/auth/profile', {
      'name': name,
    });

    if (response['success'] == true) {
      final user = UserModel.fromJson(response['user']);
      // Update cached user (token remains the same)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        await _saveSession(token, user);
      }
      return user;
    }
    throw Exception(response['message'] ?? 'Profile update failed');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    apiService.clearToken();
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token != null && userJson != null) {
      apiService.setToken(token);
      // Quick validate with backend to ensure token is still valid
      try {
        final response = await apiService.get('/auth/me');
        if (response['success'] == true) {
          final user = UserModel.fromJson(response['user']);
          return {'token': token, 'user': user};
        }
      } catch (_) {
        await logout();
        return null;
      }
    }
    return null;
  }

  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
