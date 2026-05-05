import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  static const _tokenKey = 'imt_token';
  static const _userIdKey = 'imt_user_id';
  static const _roleKey = 'imt_role';
  static const _firstNameKey = 'imt_first_name';
  static const _lastNameKey = 'imt_last_name';
  static const _emailKey = 'imt_email';
  static const _phoneKey = 'imt_phone';
  static const _avatarKey = 'imt_avatar';

  static String? token;
  static String? userId;
  static String? role;
  static String? firstName;
  static String? lastName;
  static String? email;
  static String? phone;
  static String? avatarUrl;
  static SharedPreferences? _prefs;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static bool _isPlaceholderAvatar(String? value) {
    final avatar = value?.trim();
    if (avatar == null || avatar.isEmpty) return true;
    return avatar.contains('lh3.googleusercontent.com/aida-public') || avatar.contains('aida-public');
  }

  static bool isPlaceholderAvatar(String? value) => _isPlaceholderAvatar(value);

  static String? _normalizeAvatar(String? value) {
    final avatar = value?.trim();
    if (_isPlaceholderAvatar(avatar)) return null;
    return avatar;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    token = _prefs?.getString(_tokenKey);
    userId = _prefs?.getString(_userIdKey);
    role = _prefs?.getString(_roleKey);
    firstName = _prefs?.getString(_firstNameKey);
    lastName = _prefs?.getString(_lastNameKey);
    email = _prefs?.getString(_emailKey);
    phone = _prefs?.getString(_phoneKey);
    avatarUrl = _normalizeAvatar(_prefs?.getString(_avatarKey));
    if (avatarUrl == null) {
      await _prefs!.remove(_avatarKey);
    }
  }

  static Future<void> setSession({
    required String tokenValue,
    String? userIdValue,
    String? roleValue,
    String? firstNameValue,
    String? lastNameValue,
    String? emailValue,
    String? phoneValue,
    String? avatarUrlValue,
  }) async {
    token = tokenValue;
    userId = userIdValue;
    role = roleValue;
    firstName = firstNameValue ?? firstName;
    lastName = lastNameValue ?? lastName;
    email = emailValue ?? email;
    phone = phoneValue ?? phone;
    avatarUrl = _normalizeAvatar(avatarUrlValue ?? avatarUrl);
    await _persist();
  }

  static Future<void> setProfile({
    String? firstNameValue,
    String? lastNameValue,
    String? emailValue,
    String? phoneValue,
    String? avatarUrlValue,
  }) async {
    firstName = firstNameValue ?? firstName;
    lastName = lastNameValue ?? lastName;
    email = emailValue ?? email;
    phone = phoneValue ?? phone;
    avatarUrl = _normalizeAvatar(avatarUrlValue ?? avatarUrl);
    await _persist();
  }

  static Future<void> setAvatar(String? avatarUrlValue) async {
    avatarUrl = _normalizeAvatar(avatarUrlValue);
    await _persist();
  }

  static Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (token != null) {
      await _prefs!.setString(_tokenKey, token!);
    }
    if (userId != null) {
      await _prefs!.setString(_userIdKey, userId!);
    }
    if (role != null) {
      await _prefs!.setString(_roleKey, role!);
    }
    if (firstName != null) {
      await _prefs!.setString(_firstNameKey, firstName!);
    }
    if (lastName != null) {
      await _prefs!.setString(_lastNameKey, lastName!);
    }
    if (email != null) {
      await _prefs!.setString(_emailKey, email!);
    }
    if (phone != null) {
      await _prefs!.setString(_phoneKey, phone!);
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      await _prefs!.setString(_avatarKey, avatarUrl!);
    } else {
      await _prefs!.remove(_avatarKey);
    }
  }

  static Future<void> clear() async {
    token = null;
    userId = null;
    role = null;
    firstName = null;
    lastName = null;
    email = null;
    phone = null;
    avatarUrl = null;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_userIdKey);
    await _prefs!.remove(_roleKey);
    await _prefs!.remove(_firstNameKey);
    await _prefs!.remove(_lastNameKey);
    await _prefs!.remove(_emailKey);
    await _prefs!.remove(_phoneKey);
    await _prefs!.remove(_avatarKey);
  }
}
