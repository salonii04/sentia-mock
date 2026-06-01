import 'package:shared_preferences/shared_preferences.dart';

/// Local auth helper for prototype flows.
///
/// Integration note:
/// - Login accepts any non-empty email/password.
/// - Signup stores username/email/password locally and marks session logged in.
/// - Logout only clears login state so local profile data can still be reused.
class AuthService {
  static const _isLoggedInKey = 'auth_is_logged_in';
  static const _usernameKey = 'auth_username';
  static const _emailKey = 'auth_email';
  static const _passwordKey = 'auth_password';

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, normalizedEmail);
    await prefs.setBool(_isLoggedInKey, true);

    final existingUsername = prefs.getString(_usernameKey)?.trim() ?? '';
    if (existingUsername.isEmpty) {
      await prefs.setString(_usernameKey, _usernameFromEmail(normalizedEmail));
    }
    return true;
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();

    if (normalizedUsername.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPassword.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, normalizedUsername);
    await prefs.setString(_emailKey, normalizedEmail);
    await prefs.setString(_passwordKey, normalizedPassword);
    await prefs.setBool(_isLoggedInKey, true);
    return true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString(_usernameKey)?.trim() ?? '';
    if (storedUsername.isNotEmpty) {
      return storedUsername;
    }

    final storedEmail = prefs.getString(_emailKey)?.trim() ?? '';
    if (storedEmail.isNotEmpty) {
      return _usernameFromEmail(storedEmail);
    }
    return 'Marionette';
  }

  String _usernameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    return localPart.isEmpty ? 'Marionette' : localPart;
  }
}
