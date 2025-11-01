import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class SessionService {
  static const String _keyUserId = 'user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Future<void> saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final userBox = Hive.box<UserModel>('users');
    for (var user in userBox.values) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<bool> validateSession() async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;
    final user = await getCurrentUser();
    return user != null;
  }
}