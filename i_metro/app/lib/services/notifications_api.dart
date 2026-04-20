import 'api_client.dart';

class NotificationsApi {
  static Future<Map<String, dynamic>> registerDevice({
    required String token,
    required String platform,
    String? deviceId,
  }) {
    return ApiClient.post(
      '/notifications/devices',
      {
        'token': token,
        'platform': platform,
        'deviceId': deviceId,
      },
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> unregisterDevice(String token) {
    return ApiClient.delete(
      '/notifications/devices/$token',
      auth: true,
    );
  }
}
