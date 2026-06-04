import 'api_client.dart';

class AdminApi {
  static Future<List<Map<String, dynamic>>> listAnnouncements() async {
    final data = await ApiClient.getList('/admin/announcements', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String body,
    bool isActive = true,
    bool isPinned = false,
  }) {
    return ApiClient.post(
      '/admin/announcements',
      {
        'title': title,
        'body': body,
        'isActive': isActive,
        'isPinned': isPinned,
      },
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> updateAnnouncement(
    String id, {
    String? title,
    String? body,
    bool? isActive,
    bool? isPinned,
  }) {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (body != null) payload['body'] = body;
    if (isActive != null) payload['isActive'] = isActive;
    if (isPinned != null) payload['isPinned'] = isPinned;
    return ApiClient.patch('/admin/announcements/$id', payload, auth: true);
  }

  static Future<Map<String, dynamic>> deleteAnnouncement(String id) {
    return ApiClient.delete('/admin/announcements/$id', auth: true);
  }

  static Future<List<Map<String, dynamic>>> listUsers() async {
    final data = await ApiClient.getList('/admin/users', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> getUser(String id) async {
    return ApiClient.getMap('/admin/users/$id', auth: true);
  }

  static Future<Map<String, dynamic>> updateUserStatus(
      String id, bool isActive) async {
    return ApiClient.patch(
      '/admin/users/$id/status',
      {'isActive': isActive},
      auth: true,
    );
  }

  static Future<List<Map<String, dynamic>>> listMerchants() async {
    final data = await ApiClient.getList('/admin/merchants', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> getMerchant(String id) async {
    return ApiClient.getMap('/admin/merchants/$id', auth: true);
  }

  static Future<List<Map<String, dynamic>>> listBookings() async {
    final data = await ApiClient.getList('/admin/bookings', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> listPayments() async {
    final data = await ApiClient.getList('/admin/payments', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> listRoutes() async {
    final data = await ApiClient.getList('/routes');
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> listAuditLogs() async {
    final data = await ApiClient.getList('/admin/audit-logs', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> listSupportTickets() async {
    final data = await ApiClient.getList('/admin/support/tickets', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> listSupportActivity() async {
    final data = await ApiClient.getList('/admin/support/activity', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> updateSupportStatus(
      String id, String status) async {
    return ApiClient.patch(
      '/admin/support/messages/$id/status',
      {'status': status},
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> getSystemSettings() async {
    return ApiClient.getMap('/admin/system-settings', auth: true);
  }

  static Future<Map<String, dynamic>> createRoute({
    required String fromLocation,
    required String toLocation,
    required int price,
    String currency = 'NGN',
  }) async {
    return ApiClient.post(
      '/routes',
      {
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'price': price,
        'currency': currency,
      },
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> updateRoute(
    String id, {
    int? price,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (price != null) body['price'] = price;
    if (isActive != null) body['isActive'] = isActive;
    return ApiClient.patch('/routes/$id', body, auth: true);
  }

  static Future<void> deleteRoute(String id) async {
    await ApiClient.delete('/routes/$id', auth: true);
  }
}
