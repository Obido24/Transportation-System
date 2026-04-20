import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFFFF4E5);
    const border = Color(0xFFF3CFA6);
    const textColor = Color(0xFF7A3E00);
    const iconColor = Color(0xFFB45309);

    return StreamBuilder<bool>(
      stream: ConnectivityService.instance.onlineStream,
      initialData: ConnectivityService.instance.isOnline,
      builder: (context, snapshot) {
        final online = snapshot.data ?? true;
        if (online) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You are offline. Reconnect to refresh live data.',
                  style: GoogleFonts.inter(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(foregroundColor: textColor),
                  child: Text('Retry', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class OfflineFullScreen extends StatelessWidget {
  const OfflineFullScreen({
    super.key,
    this.onRetry,
    this.title = 'You are offline',
    this.body = 'Reconnect to load the latest data.',
  });

  final VoidCallback? onRetry;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFFFF4E5);
    const border = Color(0xFFF3CFA6);
    const textColor = Color(0xFF7A3E00);
    const iconColor = Color(0xFFB45309);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.wifi_off, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: textColor.withOpacity(0.9), height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(foregroundColor: textColor),
                child: Text('Retry', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
