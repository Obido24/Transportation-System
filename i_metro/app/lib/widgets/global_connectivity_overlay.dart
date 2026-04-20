import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/connectivity_service.dart';

class GlobalConnectivityOverlay extends StatefulWidget {
  const GlobalConnectivityOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalConnectivityOverlay> createState() => _GlobalConnectivityOverlayState();
}

class _GlobalConnectivityOverlayState extends State<GlobalConnectivityOverlay> {
  bool _isOnline = ConnectivityService.instance.isOnline;
  bool _showReconnected = false;
  StreamSubscription<bool>? _sub;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _sub = ConnectivityService.instance.onlineStream.listen((online) {
      if (!mounted) return;
      final wasOnline = _isOnline;
      setState(() => _isOnline = online);
      if (!wasOnline && online) {
        _showReconnectedToast();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showReconnectedToast() {
    _toastTimer?.cancel();
    setState(() => _showReconnected = true);
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showReconnected = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    const offlineBg = Color(0xFFFFF4E5);
    const offlineBorder = Color(0xFFF3CFA6);
    const offlineText = Color(0xFF7A3E00);
    const offlineIcon = Color(0xFFB45309);
    const toastBg = Color(0xFFECFDF3);
    const toastBorder = Color(0xFFBBF7D0);
    const toastText = Color(0xFF0F5132);
    const toastIcon = Color(0xFF16A34A);

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: _isOnline ? const Offset(0, -1) : Offset.zero,
              child: SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: offlineBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: offlineBorder),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: offlineIcon, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline mode: some data may be out of date.',
                          style: GoogleFonts.inter(fontSize: 12, color: offlineText, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _showReconnected ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: _showReconnected ? Offset.zero : const Offset(0, 0.2),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: toastBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: toastBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 8))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi, color: toastIcon, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Back online',
                          style: GoogleFonts.inter(fontSize: 12, color: toastText, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
