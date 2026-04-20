import 'api_client.dart';

class UserApi {
  static Future<List<Map<String, dynamic>>> listRoutes() async {
    final data = await ApiClient.getList('/routes');
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> listBookingsForUser(String userId) async {
    final data = await ApiClient.getList('/bookings/user/$userId', auth: true);
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String routeId,
    String? travelDate,
  }) {
    return ApiClient.post(
      '/bookings',
      {
        'userId': userId,
        'routeId': routeId,
        'travelDate': travelDate,
      },
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> initiateMonnify({
    required String userId,
    required String routeId,
  }) {
    return ApiClient.post(
      '/payments/monnify/initiate',
      {'userId': userId, 'routeId': routeId},
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> initiatePaystack({
    required String userId,
    required String routeId,
  }) {
    return ApiClient.post(
      '/payments/paystack/initiate',
      {'userId': userId, 'routeId': routeId},
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> verifyMonnify(String paymentReference) {
    return ApiClient.post(
      '/payments/monnify/verify',
      {'paymentReference': paymentReference},
      auth: false,
    );
  }

  static Future<Map<String, dynamic>> retryMonnify(String bookingId) {
    return ApiClient.post(
      '/payments/monnify/retry',
      {'bookingId': bookingId},
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> retryPaystack(String bookingId) {
    return ApiClient.post(
      '/payments/paystack/retry',
      {'bookingId': bookingId},
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> verifyPaystack(String paymentReference) {
    return ApiClient.post(
      '/payments/paystack/verify',
      {'paymentReference': paymentReference},
      auth: false,
    );
  }

  static Future<Map<String, dynamic>> getBooking(String bookingId) {
    return ApiClient.getMap('/bookings/$bookingId');
  }

  static Future<Map<String, dynamic>> issueTicket(String bookingId) {
    return ApiClient.post(
      '/bookings/$bookingId/issue-ticket',
      {},
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> sendSupportMessage({
    required String subject,
    required String message,
  }) {
    return ApiClient.post(
      '/support/messages',
      {'subject': subject, 'message': message},
      auth: true,
    );
  }
}
