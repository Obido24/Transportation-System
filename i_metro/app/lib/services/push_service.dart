import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../app_messenger.dart';
import 'auth_store.dart';
import 'notifications_api.dart';

class PushService {
  PushService._();

  static final PushService instance = PushService._();

  bool _initializing = false;
  bool _initialized = false;
  String? _lastToken;
  final StreamController<TicketRefreshEvent> _ticketRefreshController =
      StreamController<TicketRefreshEvent>.broadcast();

  Stream<TicketRefreshEvent> get ticketRefreshStream => _ticketRefreshController.stream;

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    if (!AuthStore.isLoggedIn) return;
    if (!_supportedPlatform()) return;
    if (!const bool.fromEnvironment('ENABLE_FCM', defaultValue: false)) {
      return;
    }

    _initializing = true;
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      final vapidKey = kIsWeb ? const String.fromEnvironment('FCM_VAPID_KEY', defaultValue: '') : null;
      if (kIsWeb && (vapidKey == null || vapidKey.isEmpty)) {
        _initializing = false;
        return;
      }
      final token = await messaging.getToken(
        vapidKey: vapidKey,
      );
      if (token != null && token.isNotEmpty) {
        _lastToken = token;
        await NotificationsApi.registerDevice(
          token: token,
          platform: _platformLabel(),
        );
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        _lastToken = token;
        if (token.isNotEmpty) {
          await NotificationsApi.registerDevice(
            token: token,
            platform: _platformLabel(),
          );
        }
      });

      FirebaseMessaging.onMessage.listen(_handleMessage);

      _initialized = true;
    } catch (_) {
      _initialized = false;
    } finally {
      _initializing = false;
    }
  }

  Future<void> unregister() async {
    final token = _lastToken;
    if (token == null || token.isEmpty) return;
    await NotificationsApi.unregisterDevice(token);
  }

  bool _supportedPlatform() {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }
}

class TicketRefreshEvent {
  const TicketRefreshEvent({
    required this.type,
    this.bookingId,
    this.paymentReference,
    this.ticketId,
    this.silent = false,
  });

  final String type;
  final String? bookingId;
  final String? paymentReference;
  final String? ticketId;
  final bool silent;
}

void _handleMessage(RemoteMessage message) {
  final data = message.data;
  final type = (data['type'] ?? data['event'] ?? '').toString();
  final bookingId = data['bookingId']?.toString();
  final paymentReference = data['paymentReference']?.toString();
  final ticketId = data['ticketId']?.toString();
  final silentFlag = (data['silent'] ?? '').toString().toLowerCase();
  final isSilent = silentFlag == '1' || silentFlag == 'true' || silentFlag == 'yes';

  if (type.isNotEmpty) {
    switch (type) {
      case 'ticket_ready':
      case 'ticket_updated':
      case 'payment_confirmed':
      case 'booking_updated':
        PushService.instance._ticketRefreshController.add(
          TicketRefreshEvent(
            type: type,
            bookingId: bookingId,
            paymentReference: paymentReference,
            ticketId: ticketId,
            silent: isSilent,
          ),
        );
        break;
      default:
        break;
    }
  }

  if (!isSilent && message.notification != null) {
    final title = message.notification?.title ?? 'I-Metro';
    final body = message.notification?.body ?? 'You have a new update.';
    appMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('$title: $body')),
    );
  }
}
