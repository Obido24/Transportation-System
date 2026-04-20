import 'api_client.dart';
import 'auth_store.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    final response = await ApiClient.post(
      '/auth/login',
      {
        'emailOrPhone': emailOrPhone,
        'password': password,
      },
    );

    if (response['ok'] == true && response['accessToken'] != null) {
      await AuthStore.setSession(
        tokenValue: response['accessToken'] as String,
        userIdValue: response['userId'] as String?,
        roleValue: response['role'] as String?,
      );
    }
    return response;
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/register',
      {
        'firstName': firstName.trim().isEmpty ? null : firstName.trim(),
        'lastName': lastName.trim().isEmpty ? null : lastName.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'password': password,
      },
    );

    if (response['ok'] == true && response['accessToken'] != null) {
      await AuthStore.setSession(
        tokenValue: response['accessToken'] as String,
        userIdValue: response['userId'] as String?,
        roleValue: response['role'] as String?,
        firstNameValue: firstName,
        lastNameValue: lastName,
        emailValue: email,
        phoneValue: phone,
      );
    }
    return response;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.getMap('/auth/me', auth: true);
    if (response['ok'] == true && response['user'] is Map) {
      final user = response['user'] as Map;
      await AuthStore.setProfile(
        firstNameValue: user['firstName']?.toString(),
        lastNameValue: user['lastName']?.toString(),
        emailValue: user['email']?.toString(),
        phoneValue: user['phone']?.toString(),
        avatarUrlValue: user['avatarUrl']?.toString(),
      );
    }
    return response;
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final response = await ApiClient.patch(
      '/auth/me',
      {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      },
      auth: true,
    );

    if (response['ok'] == true && response['user'] is Map) {
      final user = response['user'] as Map;
      await AuthStore.setProfile(
        firstNameValue: user['firstName']?.toString(),
        lastNameValue: user['lastName']?.toString(),
        emailValue: user['email']?.toString(),
        phoneValue: user['phone']?.toString(),
        avatarUrlValue: user['avatarUrl']?.toString(),
      );
    }
    return response;
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return ApiClient.post(
      '/auth/change-password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      auth: true,
    );
  }
}
