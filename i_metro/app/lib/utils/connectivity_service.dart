import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription? _subscription;
  bool _isOnline = true;

  Stream<bool> get onlineStream => _controller.stream;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    if (_subscription != null) {
      return;
    }
    final current = await Connectivity().checkConnectivity();
    _updateStatus(current);
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  bool _toOnline(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    if (result is List<ConnectivityResult>) {
      return result.any((entry) => entry != ConnectivityResult.none);
    }
    return true;
  }

  void _updateStatus(dynamic result) {
    final online = _toOnline(result);
    if (online == _isOnline) {
      return;
    }
    _isOnline = online;
    _controller.add(online);
  }
}
