import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../routes.dart';
import '../services/auth_api.dart';
import '../services/auth_store.dart';
import '../services/user_api.dart';
import '../services/push_service.dart';
import '../utils/browser_checkout.dart'
    if (dart.library.html) '../utils/browser_checkout_web.dart';
import '../utils/connectivity_service.dart';
import '../widgets/offline_banner.dart';

const String _brandLogoAsset = 'assets/brand/imetro_logo.png';

Widget _brandLogo({double size = 40, double radius = 12}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border:
          Border.all(color: const Color(0xFFBDCAC0).withOpacity(0.6), width: 1),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        _brandLogoAsset,
        fit: BoxFit.cover,
      ),
    ),
  );
}

class SplashOnboardingScreen extends StatefulWidget {
  const SplashOnboardingScreen({super.key});

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final nextRoute = !AuthStore.hasSeenOnboarding
          ? AppRoutes.onboarding
          : (AuthStore.isLoggedIn ? AppRoutes.rideServices : AppRoutes.login);
      Navigator.pushReplacementNamed(context, nextRoute);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF006B47);
    const deepGreen = Color(0xFF00583B);
    const glowGreen = Color(0xFF0B875E);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF007A51), deepGreen],
                ),
              ),
            ),
          ),
          Positioned(
            right: -74,
            top: -50,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -72,
            bottom: -88,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: glowGreen.withOpacity(0.24),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(_brandLogoAsset, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'I-Metro',
                  style: GoogleFonts.manrope(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Smart, calm, and reliable bus travel.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.62),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: SizedBox(
                width: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotStepBadge extends StatelessWidget {
  const _ForgotStepBadge({
    required this.label,
    required this.title,
  });

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F3ED),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordField extends StatelessWidget {
  const _ForgotPasswordField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.35,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.018),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 50, minHeight: 54),
              prefixIcon: Icon(icon, color: outlineVariant, size: 22),
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: outline.withOpacity(0.48),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: outlineVariant.withOpacity(0.52),
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: outlineVariant.withOpacity(0.52),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: primary.withOpacity(0.72),
                  width: 2,
                ),
              ),
              errorStyle:
                  GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordActionButton extends StatefulWidget {
  const _ForgotPasswordActionButton({
    required this.label,
    required this.loading,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<_ForgotPasswordActionButton> createState() =>
      _ForgotPasswordActionButtonState();
}

class _ForgotPasswordActionButtonState
    extends State<_ForgotPasswordActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const kineticEnd = Color(0xFF009B67);
    final enabled = widget.onPressed != null;
    final active = enabled && (_hovered || _pressed);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: enabled
                    ? const [primary, kineticEnd]
                    : [
                        primary.withOpacity(0.48),
                        kineticEnd.withOpacity(0.48),
                      ],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(active ? 0.28 : 0.18),
                  blurRadius: active ? 24 : 18,
                  offset: Offset(0, active ? 13 : 9),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  if (widget.loading) const SizedBox(width: 10),
                  Text(
                    widget.loading ? 'Please wait...' : widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(widget.icon, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _slides = [
    _OnboardingSlideData(
      title: 'Book your bus ride',
      body:
          'Enter your pickup and destination to find available I-Metro buses near you.',
      visual: _OnboardingVisualType.booking,
    ),
    _OnboardingSlideData(
      title: 'Track your bus',
      body:
          'Follow your bus location in real time and know exactly when it will arrive.',
      visual: _OnboardingVisualType.tracking,
    ),
    _OnboardingSlideData(
      title: 'Rate your trip',
      body:
          'Share your feedback so we can keep improving your I-Metro experience.',
      visual: _OnboardingVisualType.rating,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    AuthStore.markOnboardingSeen().then((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _goToLogin();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_index == 0) {
      _goToLogin();
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAFA);
    const primary = Color(0xFF007A51);
    const muted = Color(0xFF56615B);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return _OnboardingSlide(slide: slide);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OnboardingDots(count: _slides.length, activeIndex: _index),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      SizedBox(
                        width: 132,
                        child: TextButton(
                          onPressed: _back,
                          style: TextButton.styleFrom(
                            foregroundColor: muted,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _index == 0 ? 'Skip' : 'Back',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shadowColor: primary.withOpacity(0.22),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            _index == _slides.length - 1
                                ? 'Get started'
                                : 'Next',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _OnboardingVisualType { booking, tracking, rating }

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.body,
    required this.visual,
  });

  final String title;
  final String body;
  final _OnboardingVisualType visual;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.slide});

  final _OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF191C1E);
    const muted = Color(0xFF56615B);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 660;
        final visualTopGap = slide.visual == _OnboardingVisualType.tracking
            ? (compact ? 20.0 : 46.0)
            : (compact ? 24.0 : 54.0);
        final visualBottomGap = slide.visual == _OnboardingVisualType.tracking
            ? (compact ? 22.0 : 28.0)
            : (compact ? 26.0 : 34.0);
        return Column(
          children: [
            SizedBox(height: visualTopGap),
            _OnboardingVisual(
              type: slide.visual,
              compact: compact,
            ),
            SizedBox(height: visualBottomGap),
            const Spacer(),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: compact ? 23 : 25,
                fontWeight: FontWeight.w700,
                color: text,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              slide.body,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w500,
                height: 1.36,
                color: muted.withOpacity(0.88),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({
    required this.type,
    required this.compact,
  });

  final _OnboardingVisualType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 320.0 : 384.0;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var panelWidth = constraints.maxWidth;
          if (panelWidth > 390) panelWidth = 390;

          return Center(
            child: SizedBox(
              width: panelWidth,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EFE5),
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007A51).withOpacity(0.10),
                      blurRadius: 52,
                      spreadRadius: 8,
                      offset: const Offset(0, 22),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.78),
                      blurRadius: 28,
                      spreadRadius: -6,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.28),
                              const Color(0xFFC1E3D4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (type == _OnboardingVisualType.booking)
                      const _BookingOnboardingArt(),
                    if (type == _OnboardingVisualType.tracking)
                      const _TrackingOnboardingArt(),
                    if (type == _OnboardingVisualType.rating)
                      const _RatingOnboardingArt(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookingOnboardingArt extends StatelessWidget {
  const _BookingOnboardingArt();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF007A51);

    return Stack(
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: 34,
          child: _OnboardingCard(
            height: 92,
            radius: 28,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const _OnboardingIconTile(icon: Icons.location_on, size: 50),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a route',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF191C1E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'From pickup to destination',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF56615B),
                        ),
                      ),
                    ],
                  ),
                ),
                const _OnboardingIconTile(
                    icon: Icons.directions_bus_filled, size: 50),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 34,
          child: _OnboardingCard(
            height: 128,
            radius: 30,
            padding: const EdgeInsets.all(18),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 40,
                  right: 92,
                  top: 34,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7E9E1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  top: 27,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 54,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.055),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Text(
                      'Available buses',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3E4942),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 42,
                  top: 24,
                  child: _OnboardingIconTile(
                    icon: Icons.directions_bus_filled,
                    size: 78,
                    notification: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingOnboardingArt extends StatelessWidget {
  const _TrackingOnboardingArt();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF007A51);

    return Stack(
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: 38,
          child: _OnboardingCard(
            height: 166,
            radius: 30,
            padding: const EdgeInsets.all(22),
            child: Stack(
              children: [
                const Positioned(
                  left: 0,
                  top: 8,
                  child:
                      _OnboardingIconTile(icon: Icons.map_outlined, size: 50),
                ),
                Positioned(
                  right: 28,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F3ED),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Live tracking',
                      style: GoogleFonts.inter(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 54,
                  right: 78,
                  top: 78,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7DF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const Positioned(
                  left: 96,
                  top: 62,
                  child: Icon(
                    Icons.directions_bus_filled,
                    color: primary,
                    size: 28,
                  ),
                ),
                const Positioned(
                  right: 54,
                  top: 60,
                  child: Icon(Icons.location_on, color: primary, size: 40),
                ),
                Positioned(
                  right: 36,
                  top: 44,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 46,
          bottom: 30,
          child: Container(
            width: 148,
            height: 102,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.075),
                  blurRadius: 30,
                  offset: const Offset(0, 17),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.65),
                  blurRadius: 16,
                  offset: const Offset(-8, -8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ETA',
                  style: GoogleFonts.inter(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '8 min away',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF191C1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingOnboardingArt extends StatelessWidget {
  const _RatingOnboardingArt();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF007A51);

    return Stack(
      children: [
        Positioned(
          left: 26,
          right: 26,
          top: 34,
          child: _OnboardingCard(
            height: 154,
            child: Stack(
              children: [
                const Positioned(
                  left: 2,
                  top: 4,
                  child: _OnboardingIconTile(icon: Icons.star),
                ),
                Positioned(
                  left: 76,
                  right: 8,
                  top: 8,
                  child: Text(
                    'Rate your trip',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ),
                Positioned(
                  left: 76,
                  top: 48,
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 17,
                        color: index < 4 ? primary : const Color(0xFFD6E2DD),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 2,
                  right: 2,
                  bottom: 4,
                  child: Row(
                    children: [
                      _RatingChip(label: 'Comfort'),
                      SizedBox(width: 10),
                      _RatingChip(label: 'Safety'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 42,
          bottom: 52,
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EADF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  blurRadius: 18,
                  offset: const Offset(-6, -6),
                ),
              ],
            ),
            child: const Icon(Icons.celebration, color: primary, size: 36),
          ),
        ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.height,
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(18),
  });

  final double height;
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 18,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OnboardingIconTile extends StatelessWidget {
  const _OnboardingIconTile({
    required this.icon,
    this.size = 52,
    this.notification = false,
  });

  final IconData icon;
  final double size;
  final bool notification;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF007A51);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F3ED),
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Icon(icon, color: primary, size: size * 0.42),
        ),
        if (notification)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F3ED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF007A51),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF007A51);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: active ? 36 : 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: active ? primary : const Color(0xFFDDE8E3),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _rememberMe = false;
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _rememberMe = AuthStore.rememberMe;
    if (_rememberMe) {
      _loginController.text = AuthStore.rememberedLogin ?? '';
      _passwordController.text = AuthStore.rememberedPassword ?? '';
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearSubmitError() {
    if (_submitError == null) return;
    setState(() => _submitError = null);
  }

  String _loginErrorMessage(Map<String, dynamic> response) {
    final reason = response['reason']?.toString();
    switch (reason) {
      case 'invalid_credentials':
        return 'Invalid email/phone or password.';
      default:
        return 'Login failed. Check your credentials.';
    }
  }

  Future<void> _handleLogin() async {
    if (_loading) return;
    setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _loading = true;
      _submitError = null;
    });
    final response = await AuthApi.login(login, password);
    setState(() => _loading = false);
    if (!mounted) return;
    if (response['ok'] == true) {
      await AuthStore.markOnboardingSeen();
      await AuthStore.setRememberedCredentials(
        enabled: _rememberMe,
        loginValue: login,
        passwordValue: password,
      );
      await PushService.instance.initialize();
      Navigator.pushReplacementNamed(context, AppRoutes.rideServices);
    } else {
      setState(() => _submitError = _loginErrorMessage(response));
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAFA);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const kineticStart = Color(0xFF006B47);
    const kineticEnd = Color(0xFF00875A);
    const paleGreen = Color(0xFFF7FBF9);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -66,
            right: -78,
            child: Container(
              width: 196,
              height: 196,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kineticEnd.withOpacity(0.96),
                    kineticStart,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                      color: kineticStart.withOpacity(0.07),
                      blurRadius: 80,
                      spreadRadius: 18)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -82,
            left: -78,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kineticStart.withOpacity(0.94),
                    kineticEnd.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                      color: kineticStart.withOpacity(0.06),
                      blurRadius: 72,
                      spreadRadius: 16)
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.56),
                      background.withOpacity(0.92),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;
                var topGap = constraints.maxHeight * 0.12;
                if (topGap < 52) topGap = 52;
                if (topGap > 118) topGap = 118;
                final pagePadding = compact ? 24.0 : 40.0;
                final cardPadding = compact ? 24.0 : 30.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: topGap),
                          Row(
                            children: [
                              _brandLogo(size: 44, radius: 13),
                              const SizedBox(width: 12),
                              Text(
                                'I-Metro',
                                style: GoogleFonts.manrope(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                    color: primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Luxury in Motion',
                            style: GoogleFonts.manrope(
                              fontSize: compact ? 32 : 38,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              letterSpacing: 0,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sign in to access clean-energy routes, cashless tickets, and real-time updates.',
                            style: GoogleFonts.inter(
                              fontSize: compact ? 14 : 15,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceVariant.withOpacity(0.82),
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 34),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                cardPadding, 30, cardPadding, 24),
                            decoration: BoxDecoration(
                              color: surfaceLowest,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.82),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.05),
                                  blurRadius: 40,
                                  offset: const Offset(0, 22),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.035),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autoValidate
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: AutofillGroup(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email/phone',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.6,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _loginController,
                                      enabled: !_loading,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.username
                                      ],
                                      onChanged: (_) => _clearSubmitError(),
                                      validator: (value) {
                                        final input = value?.trim() ?? '';
                                        if (input.isEmpty) {
                                          return 'Enter your email or phone number.';
                                        }
                                        if (input.contains('@')) {
                                          final emailOk = RegExp(
                                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                              .hasMatch(input);
                                          if (!emailOk) {
                                            return 'Enter a valid email address.';
                                          }
                                        } else if (input.length < 7) {
                                          return 'Enter a valid phone number.';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: surfaceLowest,
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                                minWidth: 50, minHeight: 54),
                                        prefixIcon: const Icon(
                                          Icons.alternate_email,
                                          color: outlineVariant,
                                          size: 22,
                                        ),
                                        hintText: 'Enter your credentials',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: outline.withOpacity(0.52),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 19, horizontal: 18),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                              color: outlineVariant
                                                  .withOpacity(0.55),
                                              width: 1),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            borderSide: BorderSide(
                                                color: outlineVariant
                                                    .withOpacity(0.55))),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                              color: primary.withOpacity(0.72),
                                              width: 2),
                                        ),
                                        errorStyle: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      'PASSWORD',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.6,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _passwordController,
                                      enabled: !_loading,
                                      obscureText: _obscure,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password
                                      ],
                                      onChanged: (_) => _clearSubmitError(),
                                      onFieldSubmitted: (_) => _handleLogin(),
                                      validator: (value) {
                                        final input = value ?? '';
                                        if (input.isEmpty) {
                                          return 'Enter your password.';
                                        }
                                        if (input.length < 6) {
                                          return 'Password must be at least 6 characters.';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: surfaceLowest,
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                                minWidth: 50, minHeight: 54),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: outlineVariant,
                                          size: 22,
                                        ),
                                        hintText: 'Enter your password',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: outline.withOpacity(0.52),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 19, horizontal: 18),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                              color: outlineVariant
                                                  .withOpacity(0.55),
                                              width: 1),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            borderSide: BorderSide(
                                                color: outlineVariant
                                                    .withOpacity(0.55))),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                              color: primary.withOpacity(0.72),
                                              width: 2),
                                        ),
                                        suffixIcon: IconButton(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          constraints: const BoxConstraints(
                                              minWidth: 50, minHeight: 50),
                                          icon: Icon(
                                              _obscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: outline.withOpacity(0.82)),
                                          onPressed: () => setState(
                                              () => _obscure = !_obscure),
                                        ),
                                        errorStyle: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: _loading
                                                ? null
                                                : (value) => setState(() =>
                                                    _rememberMe =
                                                        value ?? false),
                                            activeColor: primary,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            side: BorderSide(
                                              color: outlineVariant
                                                  .withOpacity(0.75),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Text(
                                          'Remember me',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: onSurfaceVariant
                                                .withOpacity(0.82),
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () => Navigator.pushNamed(
                                              context,
                                              AppRoutes.forgotPassword),
                                          style: TextButton.styleFrom(
                                            foregroundColor: primary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2, vertical: 4),
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Forgot password?',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 22),
                                    if (_submitError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE8E6),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.error_outline,
                                                  color: Colors.redAccent,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _submitError!,
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.redAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    _PremiumLoginButton(
                                      loading: _loading,
                                      onPressed: _loading ? null : _handleLogin,
                                    ),
                                    const SizedBox(height: 22),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: paleGreen,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: outlineVariant
                                                .withOpacity(0.36)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.lock_outline,
                                              size: 16, color: primary),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Encrypted access to your I-Metro account',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: onSurfaceVariant
                                                    .withOpacity(0.78),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: onSurfaceVariant.withOpacity(0.88),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Create account',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: primary,
                                      decorationThickness: 1.4,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.pushNamed(
                                          context, AppRoutes.createAccount),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumLoginButton extends StatefulWidget {
  const _PremiumLoginButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  State<_PremiumLoginButton> createState() => _PremiumLoginButtonState();
}

class _PremiumLoginButtonState extends State<_PremiumLoginButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const kineticStart = Color(0xFF006B47);
    const kineticEnd = Color(0xFF009B67);
    final enabled = widget.onPressed != null;
    final active = enabled && (_hovered || _pressed);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: enabled
                    ? const [kineticStart, kineticEnd]
                    : [
                        kineticStart.withOpacity(0.48),
                        kineticEnd.withOpacity(0.48),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kineticStart.withOpacity(active ? 0.3 : 0.2),
                  blurRadius: active ? 26 : 18,
                  offset: Offset(0, active ? 14 : 10),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  if (widget.loading) const SizedBox(width: 10),
                  Text(
                    widget.loading ? 'Signing in...' : 'Login',
                    style: GoogleFonts.manrope(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 11),
                  AnimatedSlide(
                    offset: Offset(active ? 0.12 : 0, 0),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _obscure = true;
  bool _agreed = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  String? _submitError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearSubmitError() {
    if (_submitError == null) return;
    setState(() => _submitError = null);
  }

  String _registerErrorMessage(Map<String, dynamic> response) {
    final reason = response['reason']?.toString();
    switch (reason) {
      case 'missing_contact':
        return 'Please provide an email or phone number.';
      case 'email_in_use':
        return 'That email is already in use.';
      case 'phone_in_use':
        return 'That phone number is already in use.';
      default:
        return 'Registration failed. Please check your details.';
    }
  }

  Future<void> _handleRegister() async {
    if (_loading) return;
    setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_agreed) {
      setState(() => _submitError = 'Please accept the terms to continue.');
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _loading = true;
      _submitError = null;
    });
    final response = await AuthApi.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: email,
      phone: phone,
      password: password,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (response['ok'] == true) {
      await AuthStore.markOnboardingSeen();
      await PushService.instance.initialize();
      Navigator.pushReplacementNamed(context, AppRoutes.rideServices);
    } else {
      setState(() => _submitError = _registerErrorMessage(response));
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAFA);
    const surface = Color(0xFFFFFFFF);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: primary.withOpacity(0.05),
                      blurRadius: 120,
                      spreadRadius: 40)
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE2F3).withOpacity(0.35),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFDDE2F3).withOpacity(0.4),
                      blurRadius: 90,
                      spreadRadius: 30)
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: primary),
                      ),
                      _brandLogo(size: 28, radius: 8),
                      const SizedBox(width: 8),
                      Text(
                        'I-Metro',
                        style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Join the',
                                  style: GoogleFonts.manrope(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: onSurface),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Journey',
                                    style: GoogleFonts.manrope(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w700,
                                        color: primary),
                                    children: [
                                      TextSpan(
                                        text: '.',
                                        style: GoogleFonts.manrope(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w700,
                                            color: onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your profile to access clean-energy routes, smart ticketing, and reliable city mobility.',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: onSurfaceVariant,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceLowest,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: outlineVariant.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 30,
                                    offset: const Offset(0, -8))
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autoValidate
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CreateAccountField(
                                          label: 'First name',
                                          hint: 'Jane',
                                          controller: _firstNameController,
                                          onChanged: (_) => _clearSubmitError(),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          enabled: !_loading,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.givenName
                                          ],
                                          validator: (value) {
                                            if ((value ?? '').trim().isEmpty) {
                                              return 'Enter your first name.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _CreateAccountField(
                                          label: 'Last name',
                                          hint: 'Doe',
                                          controller: _lastNameController,
                                          onChanged: (_) => _clearSubmitError(),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          enabled: !_loading,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.familyName
                                          ],
                                          validator: (value) {
                                            if ((value ?? '').trim().isEmpty) {
                                              return 'Enter your last name.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _CreateAccountField(
                                    label: 'Phone',
                                    hint: '+1 (555) 000-0000',
                                    icon: Icons.call,
                                    controller: _phoneController,
                                    onChanged: (_) => _clearSubmitError(),
                                    enabled: !_loading,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.telephoneNumber
                                    ],
                                    validator: (value) {
                                      final input = (value ?? '').trim();
                                      if (input.isEmpty &&
                                          _emailController.text
                                              .trim()
                                              .isEmpty) {
                                        return 'Provide a phone number or email.';
                                      }
                                      if (input.isEmpty) {
                                        return null;
                                      }
                                      if (input.length < 7) {
                                        return 'Enter a valid phone number.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _CreateAccountField(
                                    label: 'Email',
                                    hint: 'jane.doe@example.com',
                                    icon: Icons.mail,
                                    controller: _emailController,
                                    onChanged: (_) => _clearSubmitError(),
                                    enabled: !_loading,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    validator: (value) {
                                      final input = (value ?? '').trim();
                                      if (input.isEmpty &&
                                          _phoneController.text
                                              .trim()
                                              .isEmpty) {
                                        return 'Provide an email or phone number.';
                                      }
                                      if (input.isEmpty) {
                                        return null;
                                      }
                                      final emailOk =
                                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                              .hasMatch(input);
                                      if (!emailOk) {
                                        return 'Enter a valid email address.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _CreateAccountPasswordField(
                                    controller: _passwordController,
                                    obscure: _obscure,
                                    onToggle: () =>
                                        setState(() => _obscure = !_obscure),
                                    onChanged: (_) => _clearSubmitError(),
                                    enabled: !_loading,
                                    validator: (value) {
                                      final input = value ?? '';
                                      if (input.isEmpty) {
                                        return 'Enter a password.';
                                      }
                                      if (input.length < 6) {
                                        return 'Password must be at least 6 characters.';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _handleRegister(),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _agreed,
                                        onChanged: (value) => setState(() {
                                          _agreed = value ?? false;
                                          if (_agreed) {
                                            _submitError = null;
                                          }
                                        }),
                                        activeColor: primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text:
                                                "By creating an account, I agree to I-Metro's ",
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: onSurfaceVariant,
                                                height: 1.4),
                                            children: [
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: primary),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () =>
                                                          _showLegalDocumentDialog(
                                                            context: context,
                                                            title:
                                                                'Terms of Service',
                                                            subtitle:
                                                                'Please read these terms carefully before booking rides or using I-Metro services.',
                                                            badge:
                                                                'Legal Agreement',
                                                            variant:
                                                                _LegalDocumentVariant
                                                                    .terms,
                                                            sections: const [
                                                              _LegalSectionData(
                                                                title:
                                                                    'Acceptance of Terms',
                                                                body:
                                                                    'By creating an account, booking a ticket, or using I-Metro, you agree to follow these terms and any service rules shown inside the app.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'User Accounts',
                                                                body:
                                                                    'You are responsible for keeping your login details accurate and secure. Account activity made through your credentials may be treated as your activity.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Ticket Booking & Payments',
                                                                body:
                                                                    'Tickets are confirmed only after payment is successfully processed. Pending or failed payments do not guarantee a seat, fare, or completed booking.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Passenger Responsibilities',
                                                                body:
                                                                    'Passengers must arrive on time, carry valid ticket details, follow driver and staff instructions, and avoid conduct that affects safety or comfort.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Route Availability',
                                                                body:
                                                                    'Routes, schedules, buses, fares, and service availability may change because of traffic, safety, weather, operational needs, or regulatory direction.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Refund & Cancellation Policy',
                                                                body:
                                                                    'Refunds and cancellations may depend on payment confirmation, trip status, route rules, and operational review. Approved refunds are returned through supported payment channels.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Prohibited Activities',
                                                                body:
                                                                    'Do not misuse the app, submit false information, interfere with systems, harass staff or passengers, resell tickets, or use I-Metro for unlawful activity.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Limitation of Liability',
                                                                body:
                                                                    'I-Metro works to provide reliable transport, but is not liable for indirect losses caused by delays, disruptions, third-party services, or events outside reasonable control.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Account Suspension',
                                                                body:
                                                                    'We may suspend or restrict accounts that appear fraudulent, unsafe, abusive, unpaid, or in breach of these terms.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Intellectual Property',
                                                                body:
                                                                    'The I-Metro name, brand assets, interface, content, and service design belong to I-Metro or its licensors and may not be copied without permission.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Changes to Terms',
                                                                body:
                                                                    'We may update these terms as our services grow. Continued use of I-Metro after updates means you accept the revised terms.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Contact Information',
                                                                body:
                                                                    'For questions about these terms, contact I-Metro support through the app or call +234 912 806 6666.',
                                                              ),
                                                            ],
                                                          ),
                                              ),
                                              TextSpan(
                                                text: ' and ',
                                                style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color: onSurfaceVariant),
                                              ),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: primary),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () =>
                                                          _showLegalDocumentDialog(
                                                            context: context,
                                                            title:
                                                                'Privacy Policy',
                                                            subtitle:
                                                                'Learn how I-Metro collects, protects, and uses data to deliver safer, smarter bus travel.',
                                                            badge:
                                                                'Data Protection',
                                                            variant:
                                                                _LegalDocumentVariant
                                                                    .privacy,
                                                            sections: const [
                                                              _LegalSectionData(
                                                                title:
                                                                    'Information We Collect',
                                                                body:
                                                                    'We may collect account details, contact information, booking history, support messages, and other information you provide while using I-Metro.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'How We Use Data',
                                                                body:
                                                                    'We use data to create accounts, process bookings, confirm payments, send service updates, improve routes, support passengers, and protect the platform.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'GPS/Location Services',
                                                                body:
                                                                    'Location data may be used to support pickup and destination features, route planning, real-time service information, safety, and operational monitoring.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Payment Information',
                                                                body:
                                                                    'Payment processing is handled through approved payment partners. I-Metro may store payment references and status, but does not store full card details in the app.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Device Information',
                                                                body:
                                                                    'We may collect device type, app version, network status, push notification identifiers, and diagnostic information to improve reliability and security.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Security & Data Protection',
                                                                body:
                                                                    'We use reasonable safeguards to protect user data, limit access, and reduce unauthorized use, loss, or misuse of personal information.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Third-Party Services',
                                                                body:
                                                                    'I-Metro may use trusted providers for authentication, payments, notifications, analytics, hosting, and customer support. These providers process data only as needed for service delivery.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Cookies & Analytics',
                                                                body:
                                                                    'Web versions of I-Metro may use cookies, local storage, or analytics tools to keep sessions working, understand performance, and improve the product.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'User Rights',
                                                                body:
                                                                    'You may request access, correction, or deletion of your personal information, subject to legal, safety, payment, and operational record requirements.',
                                                              ),
                                                              _LegalSectionData(
                                                                title:
                                                                    'Contact Information',
                                                                body:
                                                                    'For privacy questions or data requests, contact I-Metro support through the app or call +234 912 806 6666.',
                                                              ),
                                                            ],
                                                          ),
                                              ),
                                              const TextSpan(text: '.'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_autoValidate && !_agreed)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, top: 6),
                                      child: Text(
                                        'Accept the terms to continue.',
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  if (_submitError != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE8E6),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline,
                                                color: Colors.redAccent,
                                                size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _submitError!,
                                                style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.redAccent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed:
                                        _loading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_loading)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white)),
                                          ),
                                        if (_loading) const SizedBox(width: 8),
                                        Text(
                                          _loading
                                              ? 'Creating...'
                                              : 'Create Account',
                                          style: GoogleFonts.manrope(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.chevron_right,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: onSurfaceVariant),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: primary,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          Navigator.pushReplacementNamed(
                                              context, AppRoutes.login),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateAccountField extends StatelessWidget {
  const _CreateAccountField({
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool? enabled;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const kineticEnd = Color(0xFF009B67);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: outlineVariant.withOpacity(0.6)),
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: outline.withOpacity(0.4)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
            ),
            errorStyle:
                GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

class _CreateAccountPasswordField extends StatelessWidget {
  const _CreateAccountPasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD',
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            prefixIcon:
                Icon(Icons.lock, color: outlineVariant.withOpacity(0.6)),
            hintText:
                '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: outline.withOpacity(0.4)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off,
                  color: outline.withOpacity(0.6)),
            ),
            errorStyle:
                GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loadingRecent = false;
  bool _loadingRoutes = false;
  bool _loadingProfile = false;
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _availableRoutes = [];
  StreamSubscription<bool>? _onlineSub;
  StreamSubscription<TicketRefreshEvent>? _ticketRefreshSub;

  @override
  void initState() {
    super.initState();
    _loadHomeProfile();
    _loadRecentBookings();
    _loadHomeRoutes();
    _onlineSub = ConnectivityService.instance.onlineStream.listen((online) {
      if (online) {
        _retryHomeData();
      }
    });
    _ticketRefreshSub =
        PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      if (!AuthStore.isLoggedIn) return;
      if (event.type == 'ticket_ready' ||
          event.type == 'payment_confirmed' ||
          event.type == 'booking_updated') {
        _loadRecentBookings();
      }
    });
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _ticketRefreshSub?.cancel();
    super.dispose();
  }

  Future<void> _loadHomeProfile() async {
    if (!AuthStore.isLoggedIn) return;
    setState(() => _loadingProfile = true);
    try {
      await AuthApi.getMe();
    } catch (_) {
      // Keep the cached profile if the latest refresh is unavailable.
    }
    if (!mounted) return;
    setState(() => _loadingProfile = false);
  }

  Future<void> _loadHomeRoutes() async {
    setState(() => _loadingRoutes = true);
    try {
      final routes = await UserApi.listRoutes();
      if (!mounted) return;
      setState(() {
        _availableRoutes = routes;
        _loadingRoutes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRoutes = false);
    }
  }

  Future<void> _loadRecentBookings() async {
    if (!AuthStore.isLoggedIn || AuthStore.userId == null) {
      return;
    }
    setState(() => _loadingRecent = true);
    try {
      final bookings = await UserApi.listBookingsForUser(AuthStore.userId!);
      bookings.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      if (!mounted) return;
      setState(() {
        _recentBookings = bookings.take(2).toList();
        _loadingRecent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRecent = false);
    }
  }

  void _retryHomeData() {
    if (!ConnectivityService.instance.isOnline) {
      return;
    }
    _loadHomeProfile();
    _loadRecentBookings();
    _loadHomeRoutes();
  }

  Future<void> _openLatestTicket() async {
    if (!AuthStore.isLoggedIn || AuthStore.userId == null) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    if (_recentBookings.isEmpty) {
      Navigator.pushNamed(context, AppRoutes.completedRides);
      return;
    }

    final preferred = _recentBookings.firstWhere(
      (booking) {
        final payment = (booking['payment'] as Map?) ?? {};
        final status = booking['status']?.toString().toUpperCase() ?? '';
        final paymentStatus = payment['status']?.toString().toUpperCase() ?? '';
        return status == 'CONFIRMED' || paymentStatus == 'SUCCESS';
      },
      orElse: () => _recentBookings.first,
    );

    Navigator.pushNamed(
      context,
      AppRoutes.ticketDetails,
      arguments: {'bookingId': preferred['id']?.toString()},
    );
  }

  String _displayName() {
    final first = AuthStore.firstName?.trim();
    if (first != null && first.isNotEmpty) {
      return first;
    }
    final fallback = AuthStore.email?.trim() ?? AuthStore.phone?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return 'Rider';
  }

  String _fullName() {
    final first = AuthStore.firstName?.trim() ?? '';
    final last = AuthStore.lastName?.trim() ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return _displayName();
  }

  String _profileDescriptor() {
    final email = AuthStore.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    final phone = AuthStore.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }
    return AuthStore.isLoggedIn
        ? 'I-Metro rider'
        : 'Sign in to personalize your trips';
  }

  String _avatarInitials() {
    final parts =
        _fullName().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.length == 1 && parts.first.isNotEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final email = AuthStore.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'IM';
  }

  ImageProvider? _avatarImageProvider() {
    final data = AuthStore.avatarUrl;
    if (data == null || data.trim().isEmpty) {
      return null;
    }
    if (data.startsWith('http')) {
      return NetworkImage(data);
    }
    if (data.startsWith('data:image')) {
      final comma = data.indexOf(',');
      if (comma != -1) {
        final base64Part = data.substring(comma + 1);
        try {
          return MemoryImage(base64Decode(base64Part));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  String _recentSubtitle(Map<String, dynamic> booking) {
    final status = booking['status']?.toString() ?? 'Pending';
    final createdAt = booking['createdAt']?.toString();
    if (createdAt != null && createdAt.contains('T')) {
      final parts = createdAt.split('T');
      final time = parts[1].split('.').first;
      final shortTime = time.length >= 5 ? time.substring(0, 5) : time;
      return '${parts[0]} - $shortTime - $status';
    }
    return status;
  }

  String _recentSubtitleDisplay(Map<String, dynamic> booking) {
    final status = booking['status']?.toString() ?? 'Pending';
    final createdAt = booking['createdAt']?.toString();
    if (createdAt != null && createdAt.contains('T')) {
      final parts = createdAt.split('T');
      final time = parts[1].split('.').first;
      final shortTime = time.length >= 5 ? time.substring(0, 5) : time;
      return '${parts[0]} - $shortTime - $status';
    }
    return status;
  }

  Map<String, dynamic>? _featuredRoute() {
    if (_availableRoutes.isNotEmpty) {
      return _availableRoutes.first;
    }
    return null;
  }

  String _latestDestination() {
    if (_recentBookings.isEmpty) {
      return 'No completed rides yet';
    }
    final route = (_recentBookings.first['route'] as Map?) ?? {};
    return route['toLocation']?.toString() ?? 'Unknown destination';
  }

  void _openFeaturedRoute() {
    final featuredRouteId = _featuredRoute()?['id']?.toString();
    Navigator.pushNamed(
      context,
      AppRoutes.booking,
      arguments: featuredRouteId == null ? null : {'routeId': featuredRouteId},
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF3F7F5);
    const surfaceContainerHighest = Color(0xFFE3ECE7);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const secondaryContainer = Color(0xFFE8F5EE);
    const tertiaryFixed = Color(0xFFF8F2E1);
    final greetingName = _displayName();
    final featuredRoute = _featuredRoute();
    final featuredFrom =
        featuredRoute?['fromLocation']?.toString() ?? 'Choose a route';
    final featuredTo =
        featuredRoute?['toLocation']?.toString() ?? 'Book your next trip';
    final featuredCurrency = featuredRoute?['currency']?.toString() ?? 'NGN';
    final featuredPrice = featuredRoute?['price']?.toString() ?? '-';
    final recentTripsCount = _recentBookings.length;
    final activeRoutesCount = _availableRoutes.length;
    final latestDestination = _latestDestination();
    final fullName = _fullName();
    final profileDescriptor = _profileDescriptor();
    final avatarInitials = _avatarInitials();
    final avatarProvider = _avatarImageProvider();
    final hasAlerts = _recentBookings.isNotEmpty;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(0.12),
                      primary.withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -80,
            top: 210,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFBCE6D2).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 78,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: surfaceLowest.withOpacity(0.86),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: outlineVariant.withOpacity(0.12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.hamburgerMenu),
                                icon: const Icon(Icons.menu_rounded,
                                    color: primary, size: 20),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _brandLogo(size: 28, radius: 9),
                            const SizedBox(width: 10),
                            Text(
                              'I-Metro',
                              style: GoogleFonts.manrope(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Spacer(),
                            if (_loadingProfile)
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primary.withOpacity(0.6)),
                              )
                            else
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: surfaceLowest.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: outlineVariant.withOpacity(0.12)),
                                ),
                                child: IconButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.notifications),
                                  padding: EdgeInsets.zero,
                                  icon: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(
                                          Icons.notifications_none_rounded,
                                          color: Color(0xFF7E8A84),
                                          size: 20),
                                      if (hasAlerts)
                                        const Positioned(
                                          right: 1,
                                          top: 1,
                                          child: CircleAvatar(
                                            radius: 3.5,
                                            backgroundColor: Color(0xFFEF4444),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 10),
                            InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.profile),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 7),
                                decoration: BoxDecoration(
                                  color: surfaceLowest.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                      color: outlineVariant.withOpacity(0.12)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.035),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 92),
                                      child: Text(
                                        fullName,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: onSurface),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          primary,
                                          primaryContainer
                                        ]),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: avatarProvider == null
                                            ? Text(
                                                avatarInitials,
                                                style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              )
                                            : Image(
                                                image: avatarProvider,
                                                width: 28,
                                                height: 28,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: (!ConnectivityService.instance.isOnline &&
                        AuthStore.isLoggedIn)
                    ? OfflineFullScreen(
                        onRetry: _retryHomeData,
                        title: 'Offline profile',
                        body:
                            'Reconnect to load your latest profile and stats.',
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 132),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $greetingName!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 1.04,
                                  letterSpacing: -0.55,
                                  color: onSurface),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AuthStore.isLoggedIn
                                  ? profileDescriptor
                                  : 'Sign in to sync your routes, tickets, and profile.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: onSurfaceVariant.withOpacity(0.82)),
                            ),
                            const SizedBox(height: 14),
                            OfflineBanner(onRetry: _retryHomeData),
                            const SizedBox(height: 22),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;
                                final gap = totalWidth < 360 ? 12.0 : 16.0;
                                final topHeroWidth = (totalWidth - gap) * 0.6;
                                final topSideWidth =
                                    totalWidth - gap - topHeroWidth;
                                final topRowHeight = topSideWidth * 0.98;
                                final bottomRowHeight =
                                    totalWidth < 360 ? 96.0 : 104.0;
                                final actionHeight =
                                    topRowHeight + gap + bottomRowHeight;

                                return SizedBox(
                                  height: actionHeight,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: topRowHeight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(
                                              width: topHeroWidth,
                                              child: _HomeQuickAction(
                                                title: 'Book Ride',
                                                icon: Icons
                                                    .directions_bus_rounded,
                                                background:
                                                    const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF005E3F),
                                                    primary,
                                                    primaryContainer,
                                                  ],
                                                  stops: [0.0, 0.48, 1.0],
                                                ),
                                                onTap: () =>
                                                    Navigator.pushNamed(context,
                                                        AppRoutes.booking),
                                                iconFilled: true,
                                                textColor: Colors.white,
                                                shadow: true,
                                                hero: true,
                                                expand: true,
                                              ),
                                            ),
                                            SizedBox(width: gap),
                                            Expanded(
                                              child: _HomeQuickAction(
                                                title: 'Scan Ticket',
                                                icon: Icons
                                                    .qr_code_scanner_rounded,
                                                background:
                                                    const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    surfaceLowest,
                                                    Color(0xFFF8FCFA),
                                                  ],
                                                ),
                                                onTap: _openLatestTicket,
                                                iconColor: primary,
                                                textColor: onSurface,
                                                border: Border.all(
                                                    color: outlineVariant
                                                        .withOpacity(0.09)),
                                                shadow: true,
                                                expand: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: gap),
                                      SizedBox(
                                        height: bottomRowHeight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: _HomeQuickAction(
                                                title: 'History',
                                                icon: Icons.history_rounded,
                                                background:
                                                    const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFF1F3F2),
                                                    Color(0xFFF7F8F8),
                                                  ],
                                                ),
                                                onTap: () =>
                                                    Navigator.pushNamed(
                                                        context,
                                                        AppRoutes
                                                            .completedRides),
                                                iconColor: onSurfaceVariant
                                                    .withOpacity(0.6),
                                                textColor:
                                                    onSurface.withOpacity(0.76),
                                                compact: true,
                                                muted: true,
                                                expand: true,
                                              ),
                                            ),
                                            SizedBox(width: gap),
                                            Expanded(
                                              child: _HomeQuickAction(
                                                title: 'Profile',
                                                icon: Icons.person_rounded,
                                                background:
                                                    const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFF1F3F2),
                                                    Color(0xFFF7F8F8),
                                                  ],
                                                ),
                                                onTap: () =>
                                                    Navigator.pushNamed(context,
                                                        AppRoutes.profile),
                                                iconColor: onSurfaceVariant
                                                    .withOpacity(0.6),
                                                textColor:
                                                    onSurface.withOpacity(0.76),
                                                compact: true,
                                                muted: true,
                                                expand: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primary,
                                    primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.26),
                                    blurRadius: 26,
                                    spreadRadius: -4,
                                    offset: const Offset(0, 16),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF8DF7C1)
                                        .withOpacity(0.16),
                                    blurRadius: 36,
                                    spreadRadius: -10,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -10,
                                    right: -8,
                                    child: Opacity(
                                      opacity: 0.12,
                                      child: Container(
                                        width: 104,
                                        height: 132,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF8DF7C1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4))),
                                          const SizedBox(width: 8),
                                          Text(
                                            _loadingRoutes
                                                ? 'SYNCING ROUTES'
                                                : 'FEATURED ROUTE',
                                            style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.6,
                                                color: Colors.white
                                                    .withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '$featuredFrom -> $featuredTo',
                                        style: GoogleFonts.manrope(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.35,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _loadingRoutes
                                            ? 'Refreshing active routes from the backend'
                                            : activeRoutesCount == 0
                                                ? 'No active routes yet. Check back after routes are published.'
                                                : '$featuredCurrency $featuredPrice fare - $activeRoutesCount active route${activeRoutesCount == 1 ? '' : 's'} available',
                                        style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            height: 1.5,
                                            color:
                                                Colors.white.withOpacity(0.86)),
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _HomeSnapshotStat(
                                              label: 'Recent Trips',
                                              value:
                                                  recentTripsCount.toString(),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _HomeSnapshotStat(
                                              label: 'Latest Stop',
                                              value: latestDestination,
                                              compactValue: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: _openFeaturedRoute,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: primary,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(999)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 15),
                                        ),
                                        icon: const Icon(
                                            Icons
                                                .directions_bus_filled_outlined,
                                            size: 18),
                                        label: Text('Book this ride',
                                            style: GoogleFonts.manrope(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Recently Traveled',
                                    style: GoogleFonts.manrope(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.25)),
                                Row(
                                  children: [
                                    if (_loadingRecent)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: primary.withOpacity(0.7)),
                                        ),
                                      ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, AppRoutes.completedRides),
                                      child: Text('See All',
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primary)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_recentBookings.isEmpty)
                              _EmptyStateCard(
                                icon: Icons.train_outlined,
                                title: 'No trips yet',
                                body:
                                    'Your completed rides and reusable ticket entries will appear here.',
                                actionLabel: 'Book a ride',
                                onAction: _openFeaturedRoute,
                              )
                            else
                              ..._recentBookings.asMap().entries.map((entry) {
                                final booking = entry.value;
                                final route = (booking['route'] as Map?) ?? {};
                                final payment =
                                    (booking['payment'] as Map?) ?? {};
                                final colorPack = entry.key.isEven
                                    ? (
                                        bg: secondaryContainer,
                                        fg: primary,
                                        icon: Icons.directions_bus_rounded,
                                      )
                                    : (
                                        bg: tertiaryFixed,
                                        fg: primary,
                                        icon: Icons.directions_bus_rounded,
                                      );
                                final from =
                                    route['fromLocation']?.toString() ??
                                        'Route';
                                final to = route['toLocation']?.toString() ??
                                    'Destination';
                                final currency =
                                    payment['currency']?.toString() ??
                                        route['currency']?.toString() ??
                                        'NGN';
                                final amount =
                                    payment['amount'] ?? route['price'] ?? '-';
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: entry.key ==
                                              _recentBookings.length - 1
                                          ? 0
                                          : 12),
                                  child: _RecentRouteCard(
                                    title: '$from -> $to',
                                    subtitle: _recentSubtitleDisplay(booking),
                                    price: '$currency $amount',
                                    icon: colorPack.icon,
                                    iconBackground: colorPack.bg,
                                    iconColor: colorPack.fg,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.ticketDetails,
                                      arguments: {
                                        'bookingId': booking['id']?.toString()
                                      },
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color: outlineVariant.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.045),
                                    blurRadius: 18,
                                    spreadRadius: -2,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                            Icons.insights_rounded,
                                            color: primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Transit Snapshot',
                                                style: GoogleFonts.manrope(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: onSurface)),
                                            const SizedBox(height: 4),
                                            Text(
                                                'Live overview based on your routes and booking history.',
                                                style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    height: 1.4,
                                                    color: onSurfaceVariant)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _HomeInfoTile(
                                          label: 'Routes Online',
                                          value: activeRoutesCount.toString(),
                                          icon: Icons.alt_route_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _HomeInfoTile(
                                          label: 'Recent Tickets',
                                          value: recentTripsCount.toString(),
                                          icon: Icons
                                              .confirmation_number_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _HomeLatestDestinationCard(
                                    destination: latestDestination,
                                    hasTrips: _recentBookings.isNotEmpty,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.74),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.58),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 28,
                        spreadRadius: -8,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        active: true,
                        onTap: () {},
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickAction extends StatelessWidget {
  const _HomeQuickAction({
    required this.title,
    required this.icon,
    required this.background,
    required this.onTap,
    this.height,
    this.iconColor,
    this.textColor,
    this.border,
    this.shadow = false,
    this.compact = false,
    this.iconFilled = false,
    this.hero = false,
    this.muted = false,
    this.expand = false,
  });

  final double? height;
  final String title;
  final IconData icon;
  final LinearGradient background;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Border? border;
  final bool shadow;
  final bool compact;
  final bool iconFilled;
  final bool hero;
  final bool muted;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? Colors.white;
    final resolvedTextColor = textColor ?? Colors.white;
    final iconSurface = hero
        ? Colors.white.withOpacity(0.16)
        : iconFilled
            ? Colors.white.withOpacity(0.14)
            : muted
                ? Colors.white.withOpacity(0.54)
                : Colors.white.withOpacity(0.78);

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: expand ? null : height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: background,
            borderRadius: BorderRadius.circular(28),
            border: border,
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: hero
                          ? const Color(0xFF006B47).withOpacity(0.24)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: hero ? 28 : 20,
                      spreadRadius: hero ? -6 : -3,
                      offset: Offset(0, hero ? 18 : 12),
                    ),
                    if (hero)
                      BoxShadow(
                        color: const Color(0xFF6DD5A6).withOpacity(0.18),
                        blurRadius: 34,
                        spreadRadius: -14,
                        offset: const Offset(0, 20),
                      ),
                  ]
                : [
                    BoxShadow(
                      color: muted
                          ? Colors.black.withOpacity(0.018)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: muted ? 10 : 14,
                      spreadRadius: -5,
                      offset: Offset(0, muted ? 6 : 10),
                    )
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: hero
                    ? 58
                    : compact
                        ? 40
                        : 50,
                height: hero
                    ? 58
                    : compact
                        ? 40
                        : 50,
                decoration: BoxDecoration(
                  color: iconSurface,
                  borderRadius: BorderRadius.circular(hero ? 20 : 18),
                  boxShadow: hero
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            spreadRadius: -8,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: hero
                      ? 30
                      : compact
                          ? 20
                          : 26,
                  color: resolvedIconColor,
                ),
              ),
              Text(
                title,
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: hero
                      ? 22
                      : compact
                          ? 14
                          : 17,
                  fontWeight: hero ? FontWeight.w700 : FontWeight.w600,
                  height: hero ? 1.02 : 1.1,
                  letterSpacing: hero ? -0.45 : -0.2,
                  color: resolvedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox.expand(child: content);
    }

    return content;
  }
}

class _HomeSnapshotStat extends StatelessWidget {
  const _HomeSnapshotStat({
    required this.label,
    required this.value,
    this.compactValue = false,
  });

  final String label;
  final String value;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.white.withOpacity(0.78),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: compactValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: compactValue ? 13 : 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeInfoTile extends StatelessWidget {
  const _HomeInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700, color: onSurface),
          ),
        ],
      ),
    );
  }
}

class _HomeLatestDestinationCard extends StatelessWidget {
  const _HomeLatestDestinationCard({
    required this.destination,
    required this.hasTrips,
  });

  final String destination;
  final bool hasTrips;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const tertiary = Color(0xFF9B403E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasTrips
              ? [
                  primary.withOpacity(0.08),
                  Colors.white,
                ]
              : [
                  tertiary.withOpacity(0.06),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasTrips
                  ? primary.withOpacity(0.14)
                  : tertiary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              hasTrips ? Icons.place_rounded : Icons.hourglass_empty_rounded,
              color: hasTrips ? primary : tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasTrips
                      ? 'Latest destination'
                      : 'Latest destination pending',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  destination,
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRouteCard extends StatelessWidget {
  const _RecentRouteCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const successBg = Color(0xFFE7F7F0);
    const successFg = Color(0xFF0B7D58);
    const pendingBg = Color(0xFFFFF1CC);
    const pendingFg = Color(0xFF9A6B00);
    final parts = subtitle.split(' - ');
    final status = parts.isNotEmpty ? parts.last.trim() : subtitle;
    final meta = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join(' | ')
        : subtitle;
    final isConfirmed = status.toUpperCase() == 'CONFIRMED';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: outlineVariant.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 16,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: onSurface)),
                    const SizedBox(height: 4),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: onSurfaceVariant.withOpacity(0.78))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price,
                      style: GoogleFonts.manrope(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: primary)),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isConfirmed ? successBg : pendingBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isConfirmed ? successFg : pendingFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(onTap == null ? Icons.remove : Icons.chevron_right_rounded,
                  color: onSurfaceVariant.withOpacity(0.76), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavPill extends StatelessWidget {
  const _BottomNavPill(
      {required this.label,
      required this.icon,
      this.active = false,
      required this.onTap});

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const inactive = Color(0xFF9CA3AF);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
            color: active ? primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.12),
                      blurRadius: 18,
                      spreadRadius: -8,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? primary : inactive),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 1.1,
                  color: active ? primary : inactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RideServiceSelectorScreen extends StatelessWidget {
  const RideServiceSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAFA);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            var topGap = constraints.maxHeight * 0.28;
            if (topGap < 130) topGap = 130;
            if (topGap > 270) topGap = 270;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: topGap),
                    Row(
                      children: [
                        _brandLogo(size: 54, radius: 12),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Your Ride',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                  height: 1.02,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select a service to get started.',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _RideServiceTile(
                      title: 'Bus',
                      subtitle: 'Available now',
                      icon: Icons.directions_bus_filled,
                      active: true,
                      onTap: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.home),
                    ),
                    const SizedBox(height: 20),
                    const _RideServiceTile(
                      title: 'Taxi Meter',
                      subtitle: 'Coming soon',
                      icon: Icons.local_taxi,
                      statusLabel: 'Coming soon',
                      locked: true,
                    ),
                    const SizedBox(height: 20),
                    const _RideServiceTile(
                      title: 'Bike Delivery',
                      subtitle: 'Coming soon',
                      icon: Icons.delivery_dining,
                      statusLabel: 'Coming soon',
                      locked: true,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RideServiceTile extends StatelessWidget {
  const _RideServiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.statusLabel,
    this.locked = false,
    this.active = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? statusLabel;
  final bool locked;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFFFFFFF);
    const inactiveSurface = Color(0xFFF3F7F6);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF007A51);
    const disabled = Color(0xFF9AA3A0);
    final enabled = onTap != null;
    final tileColor = enabled ? surface : inactiveSurface;
    final iconColor = enabled ? primary : disabled;
    final textColor = enabled ? onSurface : onSurface.withOpacity(0.74);
    final subTextColor =
        enabled ? onSurfaceVariant : onSurfaceVariant.withOpacity(0.62);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 700;
    final tileHeight = compact ? 88.0 : 104.0;
    final iconBox = compact ? 56.0 : 72.0;
    final iconSize = compact ? 27.0 : 31.0;
    final horizontalPadding = compact ? 20.0 : 24.0;
    final titleSize = compact ? 21.0 : 23.0;
    final subtitleSize = compact ? 14.0 : 15.0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.78,
        child: Container(
          width: double.infinity,
          height: tileHeight,
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active ? outlineVariant : outlineVariant.withOpacity(0.35),
              width: active ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(enabled ? 0.04 : 0.025),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFFE2F3EC)
                      : const Color(0xFFE5EAEA),
                  borderRadius: BorderRadius.circular(compact ? 18 : 20),
                ),
                child: Icon(icon, color: iconColor, size: iconSize),
              ),
              SizedBox(width: compact ? 16 : 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusLabel != null) ...[
                SizedBox(width: compact ? 8 : 10),
                SizedBox(
                  width: compact ? 94 : 112,
                  child: Text(
                    statusLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: disabled,
                    ),
                  ),
                ),
              ],
              SizedBox(width: compact ? 10 : 16),
              if (locked)
                Icon(Icons.lock_outline,
                    color: disabled, size: compact ? 20 : 22)
              else
                Container(
                  width: compact ? 42 : 48,
                  height: compact ? 42 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: outlineVariant, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.10),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.arrow_forward, color: primary, size: 25),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, this.initialRouteId});

  final String? initialRouteId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _loading = true;
  bool _submitting = false;
  List<Map<String, dynamic>> _routes = [];
  Map<String, dynamic>? _selected;
  String _provider = 'MONNIFY';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _originChip;
  Timer? _searchDebounce;
  StreamSubscription<bool>? _onlineSub;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _onlineSub = ConnectivityService.instance.onlineStream.listen((online) {
      if (online) {
        _loadRoutes();
      }
    });
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _routeById(String? routeId) {
    if (routeId == null || routeId.isEmpty) {
      return null;
    }
    for (final route in _routes) {
      if (route['id']?.toString() == routeId) {
        return route;
      }
    }
    return null;
  }

  List<String> _originChips() {
    final counts = <String, int>{};
    for (final route in _routes) {
      final from = route['fromLocation']?.toString().trim();
      if (from == null || from.isEmpty) continue;
      counts[from] = (counts[from] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });
    return entries.map((e) => e.key).take(6).toList();
  }

  bool _containsRoute(
      List<Map<String, dynamic>> routes, Map<String, dynamic>? route) {
    if (route == null) return false;
    final id = route['id']?.toString();
    if (id == null || id.isEmpty) return false;
    return routes.any((item) => item['id']?.toString() == id);
  }

  void _applySearch(String value, {String? chip}) {
    final filtered = _filterRoutesWithQuery(value);
    setState(() {
      _searchQuery = value;
      _originChip = chip;
      if (filtered.isEmpty) {
        _selected = null;
      } else if (!_containsRoute(filtered, _selected)) {
        _selected = filtered.first;
      }
    });
  }

  List<Map<String, dynamic>> _filterRoutesWithQuery(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return _routes;
    return _routes.where((route) {
      final from = route['fromLocation']?.toString().toLowerCase() ?? '';
      final to = route['toLocation']?.toString().toLowerCase() ?? '';
      final fromCode = route['fromCode']?.toString().toLowerCase() ?? '';
      final toCode = route['toCode']?.toString().toLowerCase() ?? '';
      final price = route['price']?.toString().toLowerCase() ?? '';
      final haystack = '$from $to $fromCode $toCode $price';
      return haystack.contains(needle);
    }).toList();
  }

  Future<void> _loadRoutes() async {
    setState(() => _loading = true);
    try {
      final data = await UserApi.listRoutes();
      setState(() {
        _routes = data;
        final filtered = _filterRoutesWithQuery(_searchQuery);
        _selected = _routeById(widget.initialRouteId) ?? _selected;
        if (filtered.isEmpty) {
          _selected = null;
        } else if (!_containsRoute(filtered, _selected)) {
          _selected = filtered.first;
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _selectRoute(Map<String, dynamic> route) {
    setState(() => _selected = route);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final trimmed = value.trim();
      final chipMatch = _originChip != null &&
          _originChip!.toLowerCase() == trimmed.toLowerCase();
      _applySearch(value, chip: chipMatch ? _originChip : null);
    });
  }

  List<Map<String, dynamic>> _filteredRoutes() {
    return _filterRoutesWithQuery(_searchQuery);
  }

  Future<void> _proceedToPayment() async {
    if (_submitting) return;
    if (!AuthStore.isLoggedIn || AuthStore.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to book a ride.')),
      );
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a route to continue.')),
      );
      return;
    }
    setState(() => _submitting = true);
    final response = _provider == 'PAYSTACK'
        ? await UserApi.initiatePaystack(
            userId: AuthStore.userId!,
            routeId: _selected!['id'].toString(),
          )
        : await UserApi.initiateMonnify(
            userId: AuthStore.userId!,
            routeId: _selected!['id'].toString(),
          );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (response['ok'] == true && response['checkoutUrl'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            checkoutUrl: response['checkoutUrl'].toString(),
            paymentReference: response['paymentReference']?.toString(),
            bookingId: response['bookingId']?.toString(),
            provider: _provider,
          ),
        ),
      );
    } else {
      final message = response['message']?.toString() ??
          response['reason']?.toString() ??
          'Unable to start payment.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const hintGrey = Color(0xFF9AA3A0);
    final filteredRoutes = _filteredRoutes();
    final previewRoute = _selected ??
        (filteredRoutes.isNotEmpty
            ? filteredRoutes.first
            : (_routes.isNotEmpty ? _routes.first : null));
    final selectedFrom =
        previewRoute?['fromLocation']?.toString().trim().isNotEmpty == true
            ? previewRoute!['fromLocation'].toString()
            : 'Area 1';
    final selectedTo =
        previewRoute?['toLocation']?.toString().trim().isNotEmpty == true
            ? previewRoute!['toLocation'].toString()
            : 'Nyanya';
    final selectedPrice = previewRoute?['price']?.toString() ?? '600';
    final selectedCurrency =
        previewRoute?['currency']?.toString().trim().isNotEmpty == true
            ? previewRoute!['currency'].toString()
            : 'NGN';
    final routeCount = filteredRoutes.length;
    final paymentLabel = _provider == 'PAYSTACK' ? 'Paystack' : 'Monnify';

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 64,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon:
                                  const Icon(Icons.arrow_back, color: primary),
                            ),
                            Text('Book a Ride',
                                style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (!ConnectivityService.instance.isOnline &&
                            _routes.isEmpty)
                        ? OfflineFullScreen(
                            onRetry: _loadRoutes,
                            title: 'No connection',
                            body:
                                'Connect to the internet to load available routes.',
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Book your trip',
                                    style: GoogleFonts.manrope(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.4,
                                        color: onSurface)),
                                const SizedBox(height: 6),
                                Text(
                                    'Choose a route, compare fares, and move to payment in a clean flow.',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: onSurfaceVariant
                                            .withOpacity(0.86))),
                                const SizedBox(height: 12),
                                OfflineBanner(onRetry: _loadRoutes),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: surfaceLowest,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.045),
                                        blurRadius: 18,
                                        spreadRadius: -4,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFBFCFB),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: outlineVariant
                                                      .withOpacity(0.14),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'From',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.1,
                                                      color: onSurfaceVariant,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    selectedFrom,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Current location',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      color: onSurfaceVariant
                                                          .withOpacity(0.78),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: outlineVariant
                                                    .withOpacity(0.16),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.03),
                                                  blurRadius: 10,
                                                  spreadRadius: -6,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.swap_horiz_rounded,
                                              color: primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFBFCFB),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: outlineVariant
                                                      .withOpacity(0.14),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'To',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.1,
                                                      color: onSurfaceVariant,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    selectedTo,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Destination',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      color: onSurfaceVariant
                                                          .withOpacity(0.78),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$selectedCurrency $selectedPrice \u2022 $paymentLabel',
                                              style: GoogleFonts.manrope(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: onSurface,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 7),
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              '$routeCount route${routeCount == 1 ? '' : 's'}',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      _PaymentChoiceChip(
                                        label: 'Monnify',
                                        active: _provider == 'MONNIFY',
                                        onTap: () => setState(
                                            () => _provider = 'MONNIFY'),
                                      ),
                                      const SizedBox(width: 8),
                                      _PaymentChoiceChip(
                                        label: 'Paystack',
                                        active: _provider == 'PAYSTACK',
                                        onTap: () => setState(
                                            () => _provider = 'PAYSTACK'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Search routes',
                                    style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: surfaceLowest,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.035),
                                        blurRadius: 14,
                                        spreadRadius: -6,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search_rounded,
                                          color: hintGrey, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                          style: GoogleFonts.inter(
                                              fontSize: 13.5, color: onSurface),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search by route, location, or fare',
                                            hintStyle: GoogleFonts.inter(
                                                fontSize: 13, color: hintGrey),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_searchQuery.trim().isNotEmpty)
                                        IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _applySearch('');
                                          },
                                          icon: const Icon(Icons.close_rounded,
                                              size: 18, color: hintGrey),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_searchQuery.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Showing ${filteredRoutes.length} result${filteredRoutes.length == 1 ? '' : 's'} for "${_searchQuery.trim()}"',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: onSurfaceVariant),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _applySearch('');
                                          },
                                          child: Text('Clear',
                                              style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: primary)),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_routes.isNotEmpty &&
                                    _originChips().isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Popular origins',
                                          style: GoogleFonts.manrope(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: onSurface),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Tap to filter',
                                          style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: onSurfaceVariant
                                                  .withOpacity(0.72)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _RouteOriginChip(
                                        label: 'Show all',
                                        active: _searchQuery.trim().isEmpty,
                                        onTap: () {
                                          _searchController.clear();
                                          _applySearch('');
                                        },
                                      ),
                                      ..._originChips().map((origin) {
                                        final active =
                                            _originChip?.toLowerCase() ==
                                                origin.toLowerCase();
                                        return _RouteOriginChip(
                                          label: origin,
                                          active: active,
                                          onTap: () {
                                            if (active) {
                                              _searchController.clear();
                                              _applySearch('');
                                            } else {
                                              _searchController.text = origin;
                                              _applySearch(origin,
                                                  chip: origin);
                                            }
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                if (_routes.isEmpty)
                                  _EmptyStateCard(
                                    icon: Icons.route_outlined,
                                    title: 'No routes yet',
                                    body:
                                        'Routes will appear here once they are published.',
                                    actionLabel: 'Refresh',
                                    onAction: _loadRoutes,
                                  )
                                else if (filteredRoutes.isEmpty)
                                  _EmptyStateCard(
                                    icon: Icons.search_off,
                                    title: 'No matches',
                                    body:
                                        'No routes match "${_searchQuery.trim()}". Try another search.',
                                    actionLabel: 'Clear search',
                                    onAction: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _originChip = null;
                                      });
                                    },
                                  )
                                else
                                  Column(
                                    children: filteredRoutes.map((route) {
                                      final isSelected =
                                          _selected?['id'] == route['id'];
                                      return GestureDetector(
                                        onTap: () => _selectRoute(route),
                                        child: _RouteOptionCard(
                                          from: route['fromLocation']
                                                  ?.toString() ??
                                              'From',
                                          to: route['toLocation']?.toString() ??
                                              'To',
                                          price:
                                              '${route['currency'] ?? 'NGN'} ${route['price'] ?? '-'}',
                                          selected: isSelected,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: _submitting ? null : _proceedToPayment,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [primary, primaryContainer]),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                            color: primary.withOpacity(0.2),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8))
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_submitting)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white)),
                                          )
                                        else
                                          const Icon(Icons.credit_card,
                                              color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          _submitting
                                              ? 'Processing...'
                                              : 'Proceed to Payment',
                                          style: GoogleFonts.manrope(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 30,
                          offset: const Offset(0, -8))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        active: true,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteOptionCard extends StatelessWidget {
  const _RouteOptionCard({
    required this.from,
    required this.to,
    required this.price,
    this.selected = false,
  });

  final String from;
  final String to;
  final String price;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF2FBF6) : surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: selected
                ? primary.withOpacity(0.75)
                : primary.withOpacity(0.08),
            width: selected ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 14,
              spreadRadius: -5,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.alt_route_rounded, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$from -> $to',
                    style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: onSurface)),
                const SizedBox(height: 4),
                Text('One-way ticket',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: onSurfaceVariant.withOpacity(0.82))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8F4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(price,
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: onSurface)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? primary : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: primary.withOpacity(0.12)),
            ),
            child: Icon(
              selected ? Icons.check_rounded : Icons.chevron_right_rounded,
              color: selected ? Colors.white : primary.withOpacity(0.72),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChoiceChip extends StatelessWidget {
  const _PaymentChoiceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? primary : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: active ? primary : primary.withOpacity(0.1)),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.14),
                      blurRadius: 14,
                      spreadRadius: -8,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    this.paymentReference,
    this.bookingId,
    this.provider = 'MONNIFY',
  });

  final String checkoutUrl;
  final String? paymentReference;
  final String? bookingId;
  final String provider;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  WebViewController? _controller;
  bool _verifying = false;
  bool _openedInBrowser = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final opened = openCheckoutInBrowser(widget.checkoutUrl);
        if (mounted) {
          setState(() => _openedInBrowser = opened);
        }
      });
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.checkoutUrl));
    }
  }

  void _openCheckout() {
    final opened = openCheckoutInBrowser(widget.checkoutUrl);
    if (!mounted) return;
    setState(() => _openedInBrowser = opened);
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Unable to open checkout automatically on this device.')),
      );
    }
  }

  Future<void> _verifyPayment() async {
    if (_verifying) return;
    if (widget.paymentReference == null || widget.paymentReference!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment reference is missing.')),
      );
      return;
    }
    setState(() => _verifying = true);
    final response = widget.provider == 'PAYSTACK'
        ? await UserApi.verifyPaystack(widget.paymentReference!)
        : await UserApi.verifyMonnify(widget.paymentReference!);
    setState(() => _verifying = false);
    if (!mounted) return;
    if (response['ok'] == true) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.ticketDetails,
        arguments: {
          'bookingId': response['bookingId']?.toString() ?? widget.bookingId,
          'paymentReference': widget.paymentReference,
          'provider': widget.provider,
          'justVerified': true,
        },
      );
    } else {
      final status =
          response['status']?.toString() ?? response['reason']?.toString();
      final message = status == null || status.isEmpty
          ? 'We are still waiting for confirmation. If you just paid, wait 15-30 seconds and tap Verify again.'
          : 'Still pending: $status. If you just paid, wait 15-30 seconds and tap Verify again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Colors.white;
    const surfaceContainerLow = Color(0xFFF1F5F3);
    const surfaceSoft = Color(0xFFF8FBF9);
    const onSurfaceVariant = Color(0xFF3E4942);
    const onSurface = Color(0xFF191C1E);
    final providerLabel =
        widget.provider == 'PAYSTACK' ? 'Paystack' : 'Monnify';

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.14),
                    primaryContainer.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -44,
            top: 220,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.84),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: primary, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Secure Checkout',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    providerLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: onSurfaceVariant.withOpacity(0.72),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock_rounded,
                                      size: 13, color: primary),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Protected',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: kIsWeb
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete your payment',
                              style: GoogleFonts.manrope(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.45,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Finish checkout securely, then verify to unlock your I-Metro ticket instantly.',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                height: 1.5,
                                color: onSurfaceVariant.withOpacity(0.84),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.045),
                                    blurRadius: 18,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.verified_user_rounded,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Checkout flow',
                                          style: GoogleFonts.manrope(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Open the secure payment page, complete checkout, then verify your payment here.',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            height: 1.45,
                                            color: onSurfaceVariant
                                                .withOpacity(0.82),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _CheckoutStepBadge(
                                              label: '1. Open checkout',
                                              color: primary,
                                            ),
                                            _CheckoutStepBadge(
                                              label: '2. Pay securely',
                                              color: primary,
                                            ),
                                            _CheckoutStepBadge(
                                              label: '3. Verify ticket',
                                              color: primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 18,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.open_in_new_rounded,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Open checkout in a new tab',
                                    style: GoogleFonts.manrope(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chrome on web cannot display the in-app gateway window, so your secure checkout opens in a browser tab instead.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: onSurfaceVariant.withOpacity(0.84),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: surfaceSoft,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: surfaceContainerLow,
                                      ),
                                    ),
                                    child: SelectableText(
                                      widget.checkoutUrl,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton.icon(
                                      onPressed: _openCheckout,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: primary.withOpacity(0.28),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                      icon: const Icon(Icons.launch_rounded),
                                      label: Text(
                                        _openedInBrowser
                                            ? 'Open checkout again'
                                            : 'Open secure checkout',
                                        style: GoogleFonts.manrope(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'When payment is complete, come back here and tap Verify payment below.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: onSurfaceVariant.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete your payment',
                              style: GoogleFonts.manrope(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.45,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Finish checkout securely, then verify to unlock your I-Metro ticket instantly.',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                height: 1.5,
                                color: onSurfaceVariant.withOpacity(0.84),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.045),
                                    blurRadius: 18,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.verified_user_rounded,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Checkout flow',
                                          style: GoogleFonts.manrope(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Open the secure payment page, complete checkout, then verify your payment here.',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            height: 1.45,
                                            color: onSurfaceVariant
                                                .withOpacity(0.82),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 18,
                                      spreadRadius: -8,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Secure gateway',
                                          style: GoogleFonts.manrope(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: onSurface,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            providerLabel,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Your payment page is embedded below. Complete the transaction, then verify when you return.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        color:
                                            onSurfaceVariant.withOpacity(0.82),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: WebViewWidget(
                                            controller: _controller!),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: _openCheckout,
                                        style: TextButton.styleFrom(
                                          foregroundColor: primary,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.open_in_new_rounded,
                                          size: 16,
                                        ),
                                        label: Text(
                                          'Open full screen',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                spreadRadius: -8,
                offset: const Offset(0, -6),
              )
            ],
          ),
          child: Row(
            children: [
              if (kIsWeb) ...[
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _openCheckout,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary.withOpacity(0.26)),
                        backgroundColor: primary.withOpacity(0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded,
                          color: primary, size: 18),
                      label: Text(
                        'Checkout',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _verifying ? null : _verifyPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: primary.withOpacity(0.28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: _verifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: Text(
                      _verifying ? 'Checking payment...' : 'Verify payment',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutStepBadge extends StatelessWidget {
  const _CheckoutStepBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class TicketDetailsLoaderScreen extends StatefulWidget {
  const TicketDetailsLoaderScreen({
    super.key,
    this.bookingId,
    this.paymentReference,
    this.provider = 'MONNIFY',
    this.showSuccess = false,
  });

  final String? bookingId;
  final String? paymentReference;
  final String provider;
  final bool showSuccess;

  @override
  State<TicketDetailsLoaderScreen> createState() =>
      _TicketDetailsLoaderScreenState();
}

class _TicketDetailsLoaderScreenState extends State<TicketDetailsLoaderScreen> {
  late Future<Map<String, dynamic>> _bookingFuture;
  StreamSubscription<TicketRefreshEvent>? _ticketRefreshSub;
  bool _retryingPayment = false;
  Timer? _autoRefreshTimer;
  int _autoRefreshAttempts = 0;
  String? _lastPaymentStatus;
  String? _lastQr;
  String? _lastBookingId;
  static const Duration _autoRefreshInterval = Duration(seconds: 4);
  static const int _autoRefreshMaxAttempts = 30;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _loadBooking().then((data) {
      _syncPollingState(data);
      return data;
    });
    _ticketRefreshSub =
        PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      final matchesBooking =
          widget.bookingId != null && event.bookingId == widget.bookingId;
      final matchesPayment = widget.paymentReference != null &&
          event.paymentReference == widget.paymentReference;
      if (matchesBooking || matchesPayment) {
        _refreshBooking();
      }
    });
  }

  @override
  void dispose() {
    _ticketRefreshSub?.cancel();
    _stopAutoRefresh();
    super.dispose();
  }

  Future<void> _refreshBooking() async {
    if (!mounted) return;
    final future = _loadBooking().then((data) {
      _syncPollingState(data);
      return data;
    });
    setState(() {
      _bookingFuture = future;
    });
    await future;
  }

  void _syncPollingState(Map<String, dynamic> data) {
    if (data['ok'] != true) {
      _stopAutoRefresh();
      return;
    }
    final booking = data['booking'] as Map? ?? {};
    final payment = booking['payment'] as Map? ?? {};
    _lastBookingId = booking['id']?.toString();
    _lastPaymentStatus =
        data['paymentStatus']?.toString() ?? payment['status']?.toString();
    _lastQr = data['qr']?.toString();

    if (_shouldAutoRefresh()) {
      _ensureAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
  }

  bool _shouldAutoRefresh() {
    final status = (_lastPaymentStatus ?? '').toUpperCase();
    if (_lastQr != null && _lastQr!.isNotEmpty) return false;
    if (status == 'SUCCESS') return false;
    return (widget.paymentReference?.isNotEmpty ?? false) ||
        (_lastBookingId?.isNotEmpty ?? false);
  }

  void _ensureAutoRefresh() {
    if (_autoRefreshTimer != null) return;
    _autoRefreshAttempts = 0;
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (timer) {
      if (!mounted) {
        _stopAutoRefresh();
        return;
      }
      if (_autoRefreshAttempts >= _autoRefreshMaxAttempts ||
          !_shouldAutoRefresh()) {
        _stopAutoRefresh();
        return;
      }
      _autoRefreshAttempts += 1;
      _refreshBooking();
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<Map<String, dynamic>> _loadBooking() async {
    Map<String, dynamic> booking = {};
    if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
      booking = await UserApi.getBooking(widget.bookingId!);
    } else if (widget.paymentReference != null &&
        widget.paymentReference!.isNotEmpty) {
      final verify = widget.provider == 'PAYSTACK'
          ? await UserApi.verifyPaystack(widget.paymentReference!)
          : await UserApi.verifyMonnify(widget.paymentReference!);
      if (verify['ok'] == true && verify['bookingId'] != null) {
        booking = await UserApi.getBooking(verify['bookingId'].toString());
      }
    }
    if (booking.isEmpty) {
      return {'ok': false, 'reason': 'booking_not_found'};
    }

    String? qrPayload;
    String? ticketId;
    if (booking['ticket'] is Map) {
      ticketId = booking['ticket']['id']?.toString();
    }

    final payment = booking['payment'] as Map? ?? {};
    final paymentStatus = payment['status']?.toString();
    final canRequestQr = ticketId != null || paymentStatus == 'SUCCESS';

    if (canRequestQr) {
      final issue = await UserApi.issueTicket(booking['id'].toString());
      if (issue['ok'] == true) {
        qrPayload = issue['qr']?.toString();
        ticketId = issue['ticketId']?.toString() ?? ticketId;
      }
    }

    return {
      'ok': true,
      'booking': booking,
      'qr': qrPayload,
      'ticketId': ticketId,
      'paymentStatus': paymentStatus,
      'paymentReference':
          payment['providerRef']?.toString() ?? widget.paymentReference,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? {};
          if (data['ok'] != true) {
            return const Center(child: Text('Unable to load ticket details'));
          }
          final booking = data['booking'] as Map;
          final route = booking['route'] as Map? ?? {};
          final payment = booking['payment'] as Map? ?? {};
          final ticket = booking['ticket'] as Map? ?? {};
          final qr = data['qr']?.toString();
          final bookingId = booking['id']?.toString();
          final paymentStatus = data['paymentStatus']?.toString() ??
              payment['status']?.toString();
          final paymentRef =
              data['paymentReference']?.toString() ?? widget.paymentReference;
          final paymentProvider =
              (payment['provider']?.toString() ?? widget.provider)
                  .toUpperCase();
          final showRetry = (qr == null || qr.isEmpty) &&
              (paymentStatus?.toUpperCase() != 'SUCCESS');
          final fromLocation = route['fromLocation']?.toString() ?? 'From';
          final toLocation = route['toLocation']?.toString() ?? 'To';
          final fareLabel = 'NGN ${payment['amount'] ?? route['price'] ?? '-'}';
          final reference = payment['providerRef']?.toString() ??
              widget.paymentReference ??
              '-';
          final createdAt = booking['createdAt']?.toString();
          final date = createdAt != null ? DateTime.tryParse(createdAt) : null;
          final dateLabel =
              date != null ? '${date.day}-${date.month}-${date.year}' : '-';
          final timeLabel = date != null
              ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
              : '-';

          return TicketDetailsScreen(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fromCode:
                fromLocation.isNotEmpty ? fromLocation[0].toUpperCase() : 'F',
            toCode: toLocation.isNotEmpty ? toLocation[0].toUpperCase() : 'T',
            dateLabel: dateLabel,
            timeLabel: timeLabel,
            fareLabel: fareLabel,
            reference: reference,
            qrPayload: qr,
            ticketId: data['ticketId']?.toString() ?? ticket['id']?.toString(),
            showSuccess: widget.showSuccess,
            onRefresh: _refreshBooking,
            bookingId: bookingId,
            paymentStatus: paymentStatus,
            retryingPayment: _retryingPayment,
            onRetryPayment: (bookingId != null && showRetry)
                ? () async {
                    if (_retryingPayment) return;
                    setState(() => _retryingPayment = true);
                    final response = paymentProvider == 'PAYSTACK'
                        ? await UserApi.retryPaystack(bookingId)
                        : await UserApi.retryMonnify(bookingId);
                    if (!mounted) return;
                    setState(() => _retryingPayment = false);
                    if (response['ok'] == true &&
                        response['checkoutUrl'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentWebViewScreen(
                            checkoutUrl: response['checkoutUrl'].toString(),
                            paymentReference:
                                response['paymentReference']?.toString(),
                            bookingId:
                                response['bookingId']?.toString() ?? bookingId,
                            provider: paymentProvider == 'PAYSTACK'
                                ? 'PAYSTACK'
                                : 'MONNIFY',
                          ),
                        ),
                      );
                    } else {
                      final message = response['message']?.toString() ??
                          response['reason']?.toString() ??
                          'Unable to restart payment.';
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(message)));
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}

class TicketDetailsScreen extends StatelessWidget {
  const TicketDetailsScreen({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.fromCode,
    required this.toCode,
    required this.dateLabel,
    required this.timeLabel,
    required this.fareLabel,
    required this.reference,
    this.qrPayload,
    this.ticketId,
    this.showSuccess = false,
    this.onRefresh,
    this.onRetryPayment,
    this.retryingPayment = false,
    this.bookingId,
    this.paymentStatus,
  });

  final String fromLocation;
  final String toLocation;
  final String fromCode;
  final String toCode;
  final String dateLabel;
  final String timeLabel;
  final String fareLabel;
  final String reference;
  final String? qrPayload;
  final String? ticketId;
  final bool showSuccess;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetryPayment;
  final bool retryingPayment;
  final String? bookingId;
  final String? paymentStatus;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const outlineVariant = Color(0xFFD7E4DB);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -70,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.16),
                    primaryContainer.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -36,
            top: 260,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: primary, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ticket Details',
                                    style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: primary)),
                                Text('Ride pass',
                                    style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant
                                            .withOpacity(0.72))),
                              ],
                            ),
                            const Spacer(),
                            if (onRefresh != null)
                              GestureDetector(
                                onTap: () async {
                                  await onRefresh?.call();
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.035),
                                        blurRadius: 12,
                                        spreadRadius: -8,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.refresh_rounded,
                                      color: primary, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your ticket',
                          style: GoogleFonts.manrope(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.45,
                              color: onSurface)),
                      const SizedBox(height: 8),
                      Text(
                        'Keep this pass ready for boarding and present the QR at the validator when prompted.',
                        style: GoogleFonts.inter(
                            fontSize: 13.5,
                            height: 1.5,
                            color: onSurfaceVariant.withOpacity(0.84)),
                      ),
                      const SizedBox(height: 16),
                      if (showSuccess)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.08),
                                blurRadius: 14,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.check_circle_rounded,
                                    color: primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Payment confirmed',
                                        style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: onSurface)),
                                    const SizedBox(height: 4),
                                    Text(
                                      (qrPayload == null || qrPayload!.isEmpty)
                                          ? 'Your ticket is being issued. Pull to refresh if it does not appear.'
                                          : 'Your ticket is ready. Present this QR at the validator gate.',
                                      style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          height: 1.45,
                                          color: onSurfaceVariant
                                              .withOpacity(0.82)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primary, primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: primary.withOpacity(0.18),
                                blurRadius: 22,
                                spreadRadius: -10,
                                offset: const Offset(0, 14))
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _TicketLocationBox(
                                    code: fromCode, label: fromLocation),
                                const SizedBox(width: 16),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                _TicketLocationBox(
                                    code: toCode, label: toLocation),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _TicketInfoItem(
                                              label: 'Date',
                                              value: dateLabel,
                                              light: true)),
                                      Expanded(
                                          child: _TicketInfoItem(
                                              label: 'Time',
                                              value: timeLabel,
                                              alignEnd: true,
                                              light: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _TicketInfoItem(
                                              label: 'Fare',
                                              value: fareLabel,
                                              light: true)),
                                      Expanded(
                                          child: _TicketInfoItem(
                                              label: 'Reference',
                                              value: reference,
                                              alignEnd: true,
                                              light: true)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: outlineVariant.withOpacity(0.24)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 18,
                                spreadRadius: -10,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.qr_code_scanner_rounded,
                                          size: 18, color: primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        qrPayload == null || qrPayload!.isEmpty
                                            ? 'QR pending'
                                            : 'Ready to scan',
                                        style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: primary),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                if (ticketId != null)
                                  Text(
                                    'ID ${ticketId!.substring(0, 8).toUpperCase()}',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: onSurfaceVariant),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                                'Present this code at the validator gate for one-time entry.',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: onSurfaceVariant.withOpacity(0.84))),
                            const SizedBox(height: 18),
                            Center(child: _TicketQrBox(qrPayload: qrPayload)),
                            if (qrPayload != null && qrPayload!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: qrPayload!));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('QR payload copied')),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: primary.withOpacity(0.34)),
                                    backgroundColor: primary.withOpacity(0.04),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  icon: const Icon(Icons.copy_rounded,
                                      color: primary),
                                  label: Text(
                                    'Copy QR text',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SelectableText(
                                qrPayload!,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: onSurfaceVariant.withOpacity(0.85),
                                ),
                              ),
                            ],
                            if ((qrPayload == null || qrPayload!.isEmpty) &&
                                paymentStatus != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Payment status: ${paymentStatus!.toLowerCase()}. Tap refresh after payment completes.',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: onSurfaceVariant.withOpacity(0.8)),
                                ),
                              ),
                            if ((qrPayload == null || qrPayload!.isEmpty) &&
                                onRetryPayment != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        retryingPayment ? null : onRetryPayment,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: primary.withOpacity(0.34)),
                                      backgroundColor:
                                          primary.withOpacity(0.04),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                    icon: retryingPayment
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.refresh_rounded,
                                            color: primary),
                                    label: Text(
                                      retryingPayment
                                          ? 'Restarting payment...'
                                          : 'Retry payment',
                                      style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: primary),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FCFA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ticket reference',
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          letterSpacing: 1.4,
                                          fontWeight: FontWeight.w700,
                                          color: onSurfaceVariant)),
                                  const SizedBox(height: 6),
                                  SelectableText(reference,
                                      style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: onSurface)),
                                  if (ticketId != null) ...[
                                    const SizedBox(height: 12),
                                    Text('Ticket ID',
                                        style: GoogleFonts.inter(
                                            fontSize: 10,
                                            letterSpacing: 1.4,
                                            fontWeight: FontWeight.w700,
                                            color: onSurfaceVariant)),
                                    const SizedBox(height: 6),
                                    SelectableText(ticketId!,
                                        style: GoogleFonts.manrope(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: onSurface)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketLocationBox extends StatelessWidget {
  const _TicketLocationBox({required this.code, required this.label});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code,
              style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _TicketInfoItem extends StatelessWidget {
  const _TicketInfoItem({
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.light = false,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final bool light;

  @override
  Widget build(BuildContext context) {
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
                color:
                    light ? Colors.white.withOpacity(0.72) : onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: light ? Colors.white : onSurface)),
      ],
    );
  }
}

class _TicketQrBox extends StatelessWidget {
  const _TicketQrBox({this.qrPayload});

  final String? qrPayload;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFF2F4F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    void openQrPreview() {
      if (qrPayload == null || qrPayload!.isEmpty) {
        return;
      }
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show this QR at the validator',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep the QR full screen and steady for the camera to read it easily.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: surface),
                    ),
                    child: QrImageView(
                      data: qrPayload!,
                      size: 320,
                      gapless: true,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF006B47),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0F3F2C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    qrPayload!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (qrPayload == null || qrPayload!.isEmpty) {
      return Container(
        width: 232,
        height: 232,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded,
                  color: onSurfaceVariant.withOpacity(0.6), size: 34),
              const SizedBox(height: 10),
              Text('Ticket pending',
                  style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                'If you completed payment, tap refresh to load your QR.',
                style: GoogleFonts.inter(
                    fontSize: 11, color: onSurfaceVariant.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: openQrPreview,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: surface),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: QrImageView(
                data: qrPayload!,
                size: 280,
                gapless: true,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: Color(0xFF006B47)),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0F3F2C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to enlarge',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.from,
    required this.to,
    required this.price,
    required this.accentBlue,
    required this.cardStart,
    required this.cardEnd,
  });

  final String from;
  final String to;
  final String price;
  final Color accentBlue;
  final Color cardStart;
  final Color cardEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cardStart, cardEnd]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: cardStart.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: accentBlue),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(from,
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.flag, size: 16, color: accentBlue),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(to,
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ],
          ),
          const SizedBox(height: 12),
          Text(price,
              style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF53B96A) : const Color(0xFFD8DAD2),
        shape: BoxShape.circle,
      ),
    );
  }
}

class AfterBookingScreen extends StatelessWidget {
  const AfterBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF9FAF5);
    const accentGreen = Color(0xFF4A8A5E);
    const softGrey = Color(0xFFE7E9E0);
    const hintGrey = Color(0xFFB6BAB1);
    const cardStart = Color(0xFF0F2231);
    const cardEnd = Color(0xFF0B0B0B);
    const bluePin = Color(0xFF3E7BD9);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Abuja, Nigeria',
                                style: GoogleFonts.inter(
                                  color: accentGreen,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: accentGreen,
                                size: 18,
                              ),
                            ],
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F2EC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome, Daniel',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: softGrey),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            const Icon(Icons.search, color: hintGrey),
                            const SizedBox(width: 10),
                            Text(
                              'Search route',
                              style: GoogleFonts.inter(
                                color: hintGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF7D676), Color(0xFFF0B642)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Opacity(
                          opacity: 0.18,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: AssetImage('assets/ui/splash/Cloud.png'),
                                fit: BoxFit.cover,
                                repeat: ImageRepeat.repeat,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _IndicatorDot(isActive: true),
                          _IndicatorDot(isActive: false),
                          _IndicatorDot(isActive: false),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                        child: TicketCard(
                          from: 'Lugbe, carwash, Airport road, Abuja',
                          to: 'Airport Junction, Abuja',
                          price: 'View ticket',
                          accentBlue: bluePin,
                          cardStart: cardStart,
                          cardEnd: cardEnd,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                        child: TicketCard(
                          from: 'Lugbe, carwash, Airport road, Abuja',
                          to: 'Airport Junction, Abuja',
                          price: 'Buy ticket (N2000)',
                          accentBlue: bluePin,
                          cardStart: cardStart,
                          cardEnd: cardEnd,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.home_outlined, size: 24),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
                    child: const Icon(Icons.menu, size: 26),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedRidesScreen extends StatefulWidget {
  const CompletedRidesScreen({super.key});

  @override
  State<CompletedRidesScreen> createState() => _CompletedRidesScreenState();
}

enum _HistoryFilter {
  all,
  confirmed,
  pending,
  tickets,
}

class _CompletedRidesScreenState extends State<CompletedRidesScreen> {
  Future<List<Map<String, dynamic>>>? _bookingsFuture;
  _HistoryFilter _selectedFilter = _HistoryFilter.all;
  StreamSubscription<bool>? _onlineSub;
  StreamSubscription<TicketRefreshEvent>? _ticketRefreshSub;
  String? _retryingBookingId;

  @override
  void initState() {
    super.initState();
    if (AuthStore.isLoggedIn && AuthStore.userId != null) {
      _bookingsFuture = _loadBookings();
    }
    _onlineSub = ConnectivityService.instance.onlineStream.listen((online) {
      if (online) {
        _refreshBookings();
      }
    });
    _ticketRefreshSub =
        PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      if (!AuthStore.isLoggedIn || AuthStore.userId == null) return;
      if (event.type == 'ticket_ready' ||
          event.type == 'payment_confirmed' ||
          event.type == 'booking_updated') {
        _refreshBookings();
      }
    });
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _ticketRefreshSub?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadBookings() async {
    final bookings = await UserApi.listBookingsForUser(AuthStore.userId!);
    bookings.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return bookings;
  }

  void _refreshBookings() {
    if (!AuthStore.isLoggedIn || AuthStore.userId == null) {
      return;
    }
    setState(() {
      _bookingsFuture = _loadBookings();
    });
  }

  Future<void> _retryPayment(String bookingId, String provider) async {
    if (_retryingBookingId == bookingId) return;
    if (provider != 'MONIEPOINT' &&
        provider != 'MONNIFY' &&
        provider != 'PAYSTACK') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Retry is not supported for this payment provider yet.')),
      );
      return;
    }
    setState(() => _retryingBookingId = bookingId);
    final response = provider == 'PAYSTACK'
        ? await UserApi.retryPaystack(bookingId)
        : await UserApi.retryMonnify(bookingId);
    if (!mounted) return;
    setState(() => _retryingBookingId = null);
    if (response['ok'] == true && response['checkoutUrl'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            checkoutUrl: response['checkoutUrl'].toString(),
            paymentReference: response['paymentReference']?.toString(),
            bookingId: response['bookingId']?.toString() ?? bookingId,
            provider: provider == 'PAYSTACK' ? 'PAYSTACK' : 'MONNIFY',
          ),
        ),
      );
    } else {
      final message = response['message']?.toString() ??
          response['reason']?.toString() ??
          'Unable to restart payment.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool _isConfirmedBooking(Map<String, dynamic> booking) {
    final payment = (booking['payment'] as Map?) ?? {};
    final status = booking['status']?.toString().toUpperCase() ?? '';
    final paymentStatus = payment['status']?.toString().toUpperCase() ?? '';
    return status == 'CONFIRMED' || paymentStatus == 'SUCCESS';
  }

  bool _hasTicket(Map<String, dynamic> booking) {
    final ticket = booking['ticket'];
    if (ticket is Map && ticket.isNotEmpty) {
      return true;
    }
    return _isConfirmedBooking(booking);
  }

  List<Map<String, dynamic>> _filteredBookings(
      List<Map<String, dynamic>> bookings) {
    switch (_selectedFilter) {
      case _HistoryFilter.confirmed:
        return bookings.where(_isConfirmedBooking).toList();
      case _HistoryFilter.pending:
        return bookings
            .where((booking) => !_isConfirmedBooking(booking))
            .toList();
      case _HistoryFilter.tickets:
        return bookings.where(_hasTicket).toList();
      case _HistoryFilter.all:
        return bookings;
    }
  }

  String _filterLabel(
      _HistoryFilter filter, List<Map<String, dynamic>> bookings) {
    final count = switch (filter) {
      _HistoryFilter.all => bookings.length,
      _HistoryFilter.confirmed => bookings.where(_isConfirmedBooking).length,
      _HistoryFilter.pending =>
        bookings.where((booking) => !_isConfirmedBooking(booking)).length,
      _HistoryFilter.tickets => bookings.where(_hasTicket).length,
    };

    final baseLabel = switch (filter) {
      _HistoryFilter.all => 'All Rides',
      _HistoryFilter.confirmed => 'Confirmed',
      _HistoryFilter.pending => 'Pending',
      _HistoryFilter.tickets => 'Tickets',
    };

    return '$baseLabel ($count)';
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) {
      final date = value.toIso8601String().split('T').first;
      final time = value.toIso8601String().split('T').last.split('.').first;
      final timeShort = time.length >= 5 ? time.substring(0, 5) : time;
      return '$date - $timeShort';
    }
    if (value is String && value.contains('T')) {
      final parts = value.split('T');
      final date = parts[0];
      final time = parts[1].split('.').first;
      final timeShort = time.length >= 5 ? time.substring(0, 5) : time;
      return '$date - $timeShort';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    const outlineVariant = Color(0xFFD7E4DB);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const tertiary = Color(0xFF9B403E);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -74,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.16),
                    primaryContainer.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -42,
            top: 250,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.hamburgerMenu),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.menu, color: primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('I-Metro',
                                    style: GoogleFonts.manrope(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: primary)),
                                Text('Trip activity',
                                    style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant
                                            .withOpacity(0.72))),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: surfaceLowest.withOpacity(0.94),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Text('History',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: (!ConnectivityService.instance.isOnline &&
                        _bookingsFuture != null)
                    ? OfflineFullScreen(
                        onRetry: _refreshBookings,
                        title: 'Offline history',
                        body:
                            'Reconnect to load your latest trips and tickets.',
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 138),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trip History',
                                style: GoogleFonts.manrope(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.45,
                                    color: onSurface)),
                            const SizedBox(height: 8),
                            Text(
                                'Review your past travels, payment status, and ticket activity in one place.',
                                style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: onSurfaceVariant.withOpacity(0.84))),
                            const SizedBox(height: 12),
                            OfflineBanner(onRetry: _refreshBookings),
                            const SizedBox(height: 16),
                            if (_bookingsFuture == null)
                              _EmptyStateCard(
                                icon: Icons.lock_outline,
                                title: 'Sign in to view history',
                                body:
                                    'Your rides, payments, and tickets will appear here.',
                                actionLabel: 'Sign in',
                                onAction: () => Navigator.pushNamed(
                                    context, AppRoutes.login),
                              ),
                            if (_bookingsFuture != null)
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _bookingsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: primary.withOpacity(0.8)),
                                      ),
                                    );
                                  }
                                  final bookings = snapshot.data ?? [];
                                  final filteredBookings =
                                      _filteredBookings(bookings);
                                  if (bookings.isEmpty) {
                                    return _EmptyStateCard(
                                      icon: Icons.history,
                                      title: 'No trips yet',
                                      body:
                                          'Book your first ride to start building your travel history.',
                                      actionLabel: 'Book a ride',
                                      onAction: () => Navigator.pushNamed(
                                          context, AppRoutes.booking),
                                    );
                                  }

                                  final now = DateTime.now();
                                  final monthStart =
                                      DateTime(now.year, now.month);
                                  final nextMonthStart =
                                      DateTime(now.year, now.month + 1);
                                  int confirmedTrips = 0;
                                  int confirmedSpent = 0;
                                  String summaryCurrency = 'NGN';
                                  for (final booking in bookings) {
                                    final payment =
                                        (booking['payment'] as Map?) ?? {};
                                    final paymentStatus = payment['status']
                                            ?.toString()
                                            .toUpperCase() ??
                                        '';
                                    final paidRaw =
                                        payment['paidAt']?.toString();
                                    final paidAt = paidRaw != null
                                        ? DateTime.tryParse(paidRaw)
                                        : null;
                                    if (paymentStatus != 'SUCCESS' ||
                                        paidAt == null ||
                                        paidAt.isBefore(monthStart) ||
                                        !paidAt.isBefore(nextMonthStart) ||
                                        payment['amount'] is! num) {
                                      continue;
                                    }
                                    confirmedTrips += 1;
                                    confirmedSpent +=
                                        (payment['amount'] as num).round();
                                    final currency =
                                        payment['currency']?.toString() ??
                                            'NGN';
                                    if (summaryCurrency == 'NGN' &&
                                        currency.isNotEmpty) {
                                      summaryCurrency = currency;
                                    }
                                  }

                                  final cards = filteredBookings.map((booking) {
                                    final route =
                                        (booking['route'] as Map?) ?? {};
                                    final payment =
                                        (booking['payment'] as Map?) ?? {};
                                    final paymentStatus = payment['status']
                                            ?.toString()
                                            .toUpperCase() ??
                                        '';
                                    final provider = payment['provider']
                                            ?.toString()
                                            .toUpperCase() ??
                                        '';
                                    final ticket = booking['ticket'];
                                    final hasTicket =
                                        ticket is Map && ticket.isNotEmpty;
                                    final showRetry = !hasTicket &&
                                        paymentStatus != 'SUCCESS';
                                    final from =
                                        route['fromLocation']?.toString() ??
                                            'Route';
                                    final to =
                                        route['toLocation']?.toString() ??
                                            'Destination';
                                    final currency =
                                        payment['currency']?.toString() ??
                                            route['currency']?.toString() ??
                                            'NGN';
                                    final amountRaw = payment['amount'] ??
                                        route['price'] ??
                                        0;
                                    final amount = amountRaw is num
                                        ? amountRaw.toInt()
                                        : int.tryParse(amountRaw.toString()) ??
                                            0;
                                    final status =
                                        booking['status']?.toString() ??
                                            'Completed';
                                    final statusColor =
                                        status.toUpperCase() == 'CONFIRMED'
                                            ? primary
                                            : tertiary;
                                    final dateSource = booking['travelDate'] ??
                                        booking['createdAt'];
                                    final bookingId = booking['id']?.toString();

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _HistoryTripCard(
                                        date: _formatDate(dateSource),
                                        title: from,
                                        destination: to,
                                        price: '$currency $amount',
                                        status: status,
                                        statusColor: statusColor,
                                        icon: Icons.subway,
                                        iconGradient: const LinearGradient(
                                            colors: [
                                              primary,
                                              primaryContainer
                                            ]),
                                        lineColor: primary,
                                        onTap: bookingId == null
                                            ? null
                                            : () => Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.ticketDetails,
                                                  arguments: {
                                                    'bookingId': bookingId
                                                  },
                                                ),
                                        showRetry: showRetry,
                                        retrying:
                                            _retryingBookingId == bookingId,
                                        onRetry: bookingId == null
                                            ? null
                                            : () => _retryPayment(
                                                bookingId, provider),
                                      ),
                                    );
                                  }).toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF006B47),
                                              Color(0xFF00875A)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primary.withOpacity(0.18),
                                              blurRadius: 24,
                                              spreadRadius: -12,
                                              offset: const Offset(0, 16),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              right: -8,
                                              top: -6,
                                              child: Icon(
                                                Icons.history_rounded,
                                                size: 110,
                                                color: Colors.white
                                                    .withOpacity(0.08),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Travel snapshot',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10.5,
                                                      letterSpacing: 1.8,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white
                                                          .withOpacity(0.78),
                                                    )),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${bookings.length} rides recorded',
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -0.35,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Your confirmed rides and monthly spend stay updated here as tickets and payments change.',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.5,
                                                    height: 1.45,
                                                    color: Colors.white
                                                        .withOpacity(0.82),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          _HistorySummaryStat(
                                                        label:
                                                            'Confirmed trips',
                                                        value: confirmedTrips
                                                            .toString(),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child:
                                                          _HistorySummaryStat(
                                                        label: 'Spent',
                                                        value:
                                                            '$summaryCurrency $confirmedSpent',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _HistoryChip(
                                              label: _filterLabel(
                                                  _HistoryFilter.all, bookings),
                                              active: _selectedFilter ==
                                                  _HistoryFilter.all,
                                              onTap: () => setState(() =>
                                                  _selectedFilter =
                                                      _HistoryFilter.all),
                                            ),
                                            _HistoryChip(
                                              label: _filterLabel(
                                                  _HistoryFilter.confirmed,
                                                  bookings),
                                              active: _selectedFilter ==
                                                  _HistoryFilter.confirmed,
                                              onTap: () => setState(() =>
                                                  _selectedFilter =
                                                      _HistoryFilter.confirmed),
                                            ),
                                            _HistoryChip(
                                              label: _filterLabel(
                                                  _HistoryFilter.pending,
                                                  bookings),
                                              active: _selectedFilter ==
                                                  _HistoryFilter.pending,
                                              onTap: () => setState(() =>
                                                  _selectedFilter =
                                                      _HistoryFilter.pending),
                                            ),
                                            _HistoryChip(
                                              label: _filterLabel(
                                                  _HistoryFilter.tickets,
                                                  bookings),
                                              active: _selectedFilter ==
                                                  _HistoryFilter.tickets,
                                              onTap: () => setState(() =>
                                                  _selectedFilter =
                                                      _HistoryFilter.tickets),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Text(
                                            'Recent rides',
                                            style: GoogleFonts.manrope(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: onSurface,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton.icon(
                                            onPressed: () => setState(() =>
                                                _bookingsFuture =
                                                    _loadBookings()),
                                            icon: const Icon(
                                                Icons.refresh_rounded,
                                                size: 18),
                                            label: Text('Refresh',
                                                style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            style: TextButton.styleFrom(
                                                foregroundColor: primary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (filteredBookings.isEmpty)
                                        _EmptyStateCard(
                                          icon: Icons.filter_alt_off,
                                          title: 'No rides for this filter',
                                          body:
                                              'Try a different filter or reset to view all rides.',
                                          actionLabel: 'Show all',
                                          onAction: () => setState(() =>
                                              _selectedFilter =
                                                  _HistoryFilter.all),
                                        ),
                                      if (filteredBookings.isEmpty)
                                        const SizedBox(height: 12),
                                      ...cards,
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.76),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 24,
                          offset: const Offset(0, -8))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        active: true,
                        onTap: () {},
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.label, this.active = false, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurfaceVariant = Color(0xFF3E4942);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? primary : surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.12),
                    blurRadius: 12,
                    spreadRadius: -8,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RouteOriginChip extends StatelessWidget {
  const _RouteOriginChip({
    required this.label,
    this.active = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurfaceVariant = Color(0xFF3E4942);
    const surfaceContainerLow = Color(0xFFF2F5F3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? primary : surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.12),
                    blurRadius: 12,
                    spreadRadius: -8,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _HistoryTripCard extends StatelessWidget {
  const _HistoryTripCard({
    required this.date,
    required this.title,
    required this.destination,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.lineColor,
    this.iconGradient,
    this.iconBackground,
    this.onTap,
    this.showRetry = false,
    this.retrying = false,
    this.onRetry,
  });

  final String date;
  final String title;
  final String destination;
  final String price;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color lineColor;
  final LinearGradient? iconGradient;
  final Color? iconBackground;
  final VoidCallback? onTap;
  final bool showRetry;
  final bool retrying;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 16,
              spreadRadius: -10,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: iconGradient,
                    color: iconGradient == null
                        ? iconBackground ?? surfaceContainerLow
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: iconGradient == null
                          ? onSurfaceVariant
                          : Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date.toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: onSurfaceVariant.withOpacity(0.78)),
                      ),
                      const SizedBox(height: 4),
                      Text(title,
                          style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: onSurface)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price,
                        style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              status == 'Canceled'
                                  ? Icons.cancel_outlined
                                  : Icons.check_circle_rounded,
                              size: 14,
                              color: statusColor),
                          const SizedBox(width: 4),
                          Text(status.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HistoryTimeline(
              destination: destination,
              lineColor: lineColor,
            ),
            if (showRetry || onTap != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  if (showRetry)
                    OutlinedButton.icon(
                      onPressed: retrying ? null : onRetry,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: lineColor.withOpacity(0.34)),
                        backgroundColor: lineColor.withOpacity(0.04),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: retrying
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh_rounded,
                              color: lineColor, size: 16),
                      label: Text(
                        retrying ? 'Restarting...' : 'Retry payment',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: lineColor),
                      ),
                    ),
                  const Spacer(),
                  if (onTap != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Open ticket',
                            style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: lineColor)),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            color: lineColor, size: 18),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  const _HistoryTimeline({required this.destination, required this.lineColor});

  final String destination;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: surfaceLowest,
                border: Border.all(color: lineColor, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 26,
              color: lineColor.withOpacity(0.2),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: lineColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination,
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurface.withOpacity(0.74)),
              ),
              const SizedBox(height: 3),
              Text(
                'Destination stop',
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceVariant.withOpacity(0.68)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistorySummaryStat extends StatelessWidget {
  const _HistorySummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(value,
                    style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingItem extends StatelessWidget {
  const _ProfileSettingItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outlineVariant = Color(0xFFBDCAC0);
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: outlineVariant.withOpacity(enabled ? 0.35 : 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: onSurfaceVariant.withOpacity(enabled ? 1 : 0.5)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: enabled ? onSurface : onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color:
                            onSurfaceVariant.withOpacity(enabled ? 0.85 : 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (enabled)
              const Icon(Icons.chevron_right, color: onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;
  int _rideCount = 0;
  int _spentMonth = 0;
  bool _uploadingAvatar = false;
  String? _avatarError;
  final ImagePicker _picker = ImagePicker();
  StreamSubscription<bool>? _onlineSub;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _onlineSub = ConnectivityService.instance.onlineStream.listen((online) {
      if (online) {
        _loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!AuthStore.isLoggedIn || AuthStore.userId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        AuthApi.getMe(),
        UserApi.listBookingsForUser(AuthStore.userId!),
      ]);
      final bookings = (results[1] as List).cast<Map<String, dynamic>>();
      final successfulBookings = bookings.where((booking) {
        final payment = booking['payment'];
        if (payment is! Map) return false;
        return payment['status']?.toString().toUpperCase() == 'SUCCESS';
      }).toList();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);
      int monthTotal = 0;
      for (final booking in successfulBookings) {
        final payment = booking['payment'];
        if (payment is! Map || payment['amount'] is! num) {
          continue;
        }
        final paidRaw = payment['paidAt']?.toString();
        final paidAt = paidRaw != null ? DateTime.tryParse(paidRaw) : null;
        if (paidAt == null || paidAt.isBefore(monthStart)) {
          continue;
        }
        monthTotal += (payment['amount'] as num).round();
      }
      setState(() {
        _rideCount = successfulBookings.length;
        _spentMonth = monthTotal;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Unable to load profile data';
      });
    }
  }

  String _displayName() {
    final first = AuthStore.firstName?.trim() ?? '';
    final last = AuthStore.lastName?.trim() ?? '';
    final combined = [first, last].where((value) => value.isNotEmpty).join(' ');
    if (combined.isNotEmpty) {
      return combined;
    }
    return AuthStore.isLoggedIn ? 'I-Metro Rider' : 'Guest Rider';
  }

  String _displayEmail() {
    if (AuthStore.email != null && AuthStore.email!.trim().isNotEmpty) {
      return AuthStore.email!;
    }
    return AuthStore.isLoggedIn
        ? 'Update your email in profile settings'
        : 'Sign in to view profile';
  }

  String _avatarInitials() {
    final first = AuthStore.firstName?.trim() ?? '';
    final last = AuthStore.lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.substring(0, 1).toUpperCase();
    }
    final email = AuthStore.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'IM';
  }

  String _formatNgn(int amount) {
    final sign = amount < 0 ? '-' : '';
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final indexFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return 'NGN $sign${buffer.toString()}';
  }

  ImageProvider? _avatarImageProvider() {
    final data = AuthStore.avatarUrl;
    if (data == null || data.trim().isEmpty) {
      return null;
    }
    if (data.startsWith('http')) {
      return NetworkImage(data);
    }
    if (data.startsWith('data:image')) {
      final comma = data.indexOf(',');
      if (comma != -1) {
        final base64Part = data.substring(comma + 1);
        try {
          return MemoryImage(base64Decode(base64Part));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  Future<void> _pickAvatar() async {
    if (_uploadingAvatar) return;
    if (!AuthStore.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to update your profile photo.')),
      );
      return;
    }
    setState(() {
      _uploadingAvatar = true;
      _avatarError = null;
    });
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        imageQuality: 85,
      );
      if (file == null) {
        setState(() => _uploadingAvatar = false);
        return;
      }
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        setState(() {
          _uploadingAvatar = false;
          _avatarError = 'Please choose an image under 2MB.';
        });
        return;
      }
      final name = file.name.toLowerCase();
      final ext = name.contains('.') ? name.split('.').last : '';
      final mime = ext == 'png'
          ? 'image/png'
          : ext == 'gif'
              ? 'image/gif'
              : 'image/jpeg';
      final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      await AuthStore.setAvatar(dataUrl);
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploadingAvatar = false;
        _avatarError = 'Unable to update photo right now.';
      });
    }
  }

  Future<void> _removeAvatar() async {
    await AuthStore.setAvatar(null);
    if (!mounted) return;
    setState(() {});
  }

  void _openAvatarSheet() {
    if (!AuthStore.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to update your profile photo.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF7F9FB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final hasAvatar = AuthStore.avatarUrl != null &&
            AuthStore.avatarUrl!.trim().isNotEmpty;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDCAC0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text('Upload photo',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar();
                  },
                ),
                if (hasAvatar)
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text('Remove photo',
                        style:
                            GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                    onTap: () {
                      Navigator.pop(context);
                      _removeAvatar();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceContainerHigh = Color(0xFFE6E8EA);
    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const error = Color(0xFFBA1A1A);

    final nameText = _displayName();
    final emailText = _displayEmail();
    final ridesValue = _loading ? '--' : _rideCount.toString();
    final spentValue = _loading ? 'NGN --' : _formatNgn(_spentMonth);
    final avatarProvider = _avatarImageProvider();
    final initials = _avatarInitials();
    final memberLabel = AuthStore.isLoggedIn ? 'I-METRO MEMBER' : 'GUEST';
    final memberColor = AuthStore.isLoggedIn ? primary : onSurfaceVariant;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 64,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.hamburgerMenu),
                              icon: const Icon(Icons.menu, color: primary),
                            ),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro',
                                style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primary)),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: primaryContainer, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: avatarProvider == null
                                    ? Container(
                                        color: primary.withOpacity(0.12),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.manrope(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: primary),
                                        ),
                                      )
                                    : Image(
                                        image: avatarProvider,
                                        fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: _openAvatarSheet,
                            child: Container(
                              width: 128,
                              height: 128,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [primary, primaryContainer]),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: avatarProvider == null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primary.withOpacity(0.2),
                                              primaryContainer.withOpacity(0.25)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.manrope(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: primary),
                                        ),
                                      )
                                    : Image(
                                        image: avatarProvider,
                                        fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: GestureDetector(
                              onTap: _openAvatarSheet,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: outlineVariant.withOpacity(0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ],
                                ),
                                child: _uploadingAvatar
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.camera_alt_outlined,
                                        size: 18, color: primary),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -6,
                            bottom: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: memberColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: memberColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6))
                                ],
                                border: Border.all(color: background, width: 4),
                              ),
                              child: Text(
                                memberLabel,
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(nameText,
                          style: GoogleFonts.manrope(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: onSurface)),
                      const SizedBox(height: 6),
                      Text(emailText,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceVariant)),
                      const SizedBox(height: 12),
                      OfflineBanner(onRetry: _loadProfile),
                      if (_avatarError != null) ...[
                        const SizedBox(height: 8),
                        Text(_avatarError!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: error)),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: error)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _loadProfile,
                          child: Text('Retry',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primary)),
                        ),
                      ],
                      if (!AuthStore.isLoggedIn) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Sign in to view full profile',
                                style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileStatCard(
                              icon: Icons.commute,
                              label: 'Confirmed Rides',
                              value: ridesValue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ProfileStatCard(
                              icon: Icons.savings,
                              label: 'Spent This Month',
                              value: spentValue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'ACCOUNT SETTINGS',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 3.2,
                                fontWeight: FontWeight.w700,
                                color: onSurfaceVariant),
                          ),
                        ),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        subtitle: 'Name, email, and phone',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.profileSettings),
                      ),
                      const _ProfileSettingItem(
                        icon: Icons.payments_outlined,
                        label: 'Payment Methods',
                        subtitle: 'Manage cards (coming soon)',
                      ),
                      _ProfileSettingItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        subtitle: 'Notifications and preferences',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.profileSettings),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.shield_outlined,
                        label: 'Security',
                        subtitle: 'Change password',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.changePassword),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.help_outline,
                        label: 'Support',
                        subtitle: 'Contact the I-Metro team',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.contactUs),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.quiz_outlined,
                        label: 'Help & FAQ',
                        subtitle: 'Answers to common rider questions',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.faq),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: outlineVariant.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.warning_amber_rounded,
                                  color: primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ticket Expiry Reminder',
                                      style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: onSurface)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tickets are valid for the day of purchase. Please complete your trip before midnight.',
                                    style: GoogleFonts.inter(
                                        fontSize: 11, color: onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (AuthStore.isLoggedIn) ...[
                        Text(
                          'Need to logout?',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.logout),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: error,
                              side: BorderSide(color: error.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: Text('Log out of I-Metro',
                                style: GoogleFonts.manrope(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 30,
                          offset: const Offset(0, -8))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  DateTime? _lastUpdated;
  bool _pushLoading = false;
  bool _pushEnabled = false;
  final bool _pushAvailable =
      const bool.fromEnvironment('ENABLE_FCM', defaultValue: false);
  String _pushStatusLabel = 'Off';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPushPermission();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!AuthStore.isLoggedIn) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await AuthApi.getMe();
      final user = response['user'] is Map ? response['user'] as Map : {};
      _firstNameController.text =
          user['firstName']?.toString() ?? AuthStore.firstName ?? '';
      _lastNameController.text =
          user['lastName']?.toString() ?? AuthStore.lastName ?? '';
      _emailController.text =
          user['email']?.toString() ?? AuthStore.email ?? '';
      _phoneController.text =
          user['phone']?.toString() ?? AuthStore.phone ?? '';
      setState(() => _loading = false);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadPushPermission() async {
    if (!_pushAvailable) {
      if (!mounted) return;
      setState(() {
        _pushEnabled = false;
        _pushStatusLabel = 'Unavailable';
      });
      return;
    }
    if (!AuthStore.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _pushEnabled = false;
        _pushStatusLabel = 'Sign in required';
      });
      return;
    }
    try {
      await Firebase.initializeApp();
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      _applyPushStatus(settings.authorizationStatus);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pushEnabled = false;
        _pushStatusLabel = 'Unavailable';
      });
    }
  }

  void _applyPushStatus(AuthorizationStatus status) {
    if (!mounted) return;
    final enabled = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    final label = switch (status) {
      AuthorizationStatus.authorized => 'Enabled',
      AuthorizationStatus.provisional => 'Enabled (Quiet)',
      AuthorizationStatus.denied => 'Blocked',
      AuthorizationStatus.notDetermined => 'Not set',
      _ => 'Unknown',
    };
    setState(() {
      _pushEnabled = enabled;
      _pushStatusLabel = label;
    });
  }

  Future<void> _requestPushPermission() async {
    if (_pushLoading || !_pushAvailable) return;
    if (!AuthStore.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to enable notifications.')),
      );
      return;
    }
    setState(() => _pushLoading = true);
    try {
      await Firebase.initializeApp();
      final settings = await FirebaseMessaging.instance.requestPermission();
      await PushService.instance.initialize();
      _applyPushStatus(settings.authorizationStatus);
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Notifications are blocked for this device.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to request notification permissions.')),
      );
    }
    if (!mounted) return;
    setState(() => _pushLoading = false);
  }

  String _lastUpdatedLabel() {
    if (_lastUpdated == null) {
      return 'Last updated on -';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final date = _lastUpdated!;
    return 'Last updated on ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _profileInitials() {
    final first = _firstNameController.text.trim().isNotEmpty
        ? _firstNameController.text.trim()
        : AuthStore.firstName?.trim() ?? '';
    final last = _lastNameController.text.trim().isNotEmpty
        ? _lastNameController.text.trim()
        : AuthStore.lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.substring(0, 1).toUpperCase();
    }
    final email = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : AuthStore.email?.trim() ?? '';
    if (email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'IM';
  }

  ImageProvider? _profileAvatarProvider() {
    final data = AuthStore.avatarUrl;
    if (data == null || data.trim().isEmpty) {
      return null;
    }
    if (data.startsWith('http')) {
      return NetworkImage(data);
    }
    if (data.startsWith('data:image')) {
      final comma = data.indexOf(',');
      if (comma != -1) {
        final base64Part = data.substring(comma + 1);
        try {
          return MemoryImage(base64Decode(base64Part));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (_saving || !AuthStore.isLoggedIn) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    String? firstName = _firstNameController.text.trim();
    String? lastName = _lastNameController.text.trim();
    String? email = _emailController.text.trim();
    String? phone = _phoneController.text.trim();
    if (firstName.isEmpty) firstName = null;
    if (lastName.isEmpty) lastName = null;
    if (email.isEmpty) email = null;
    if (phone.isEmpty) phone = null;
    final response = await AuthApi.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    if (!mounted) return;
    if (response['ok'] == true) {
      setState(() => _lastUpdated = DateTime.now());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      final message = response['message']?.toString() ??
          response['reason']?.toString() ??
          'Unable to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceContainerLow = Color(0xFFF1F5F2);
    const surfaceContainerHigh = Color(0xFFE5ECE7);
    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);

    final canSave = AuthStore.isLoggedIn && !_saving && !_loading;
    final avatarProvider = _profileAvatarProvider();
    final initials = _profileInitials();
    final firstName = _firstNameController.text.trim().isNotEmpty
        ? _firstNameController.text.trim()
        : AuthStore.firstName?.trim() ?? '';
    final lastName = _lastNameController.text.trim().isNotEmpty
        ? _lastNameController.text.trim()
        : AuthStore.lastName?.trim() ?? '';
    final fullName =
        [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
    final displayName = fullName.isNotEmpty ? fullName : 'I-Metro Traveler';
    final displayEmail = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : (AuthStore.email?.trim().isNotEmpty == true
            ? AuthStore.email!.trim()
            : 'traveler@i-metro.com');

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -72,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.18),
                    primaryContainer.withOpacity(0.04),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -48,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.hamburgerMenu),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.menu, color: primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('I-Metro',
                                    style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: primary)),
                                Text('Profile settings',
                                    style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant
                                            .withOpacity(0.72))),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: surfaceLowest.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.035),
                                    blurRadius: 12,
                                    spreadRadius: -6,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _ProfileInitialAvatar(
                                    size: 34,
                                    initials: initials,
                                    imageProvider: avatarProvider,
                                    borderColor: primary.withOpacity(0.22),
                                  ),
                                  if (AuthStore.isLoggedIn) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      initials,
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              surfaceLowest,
                              const Color(0xFFF8FCFA),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: outlineVariant.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.08),
                              blurRadius: 26,
                              spreadRadius: -16,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 24,
                              spreadRadius: -14,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary.withOpacity(0.08),
                                  ),
                                ),
                                _ProfileInitialAvatar(
                                  size: 98,
                                  initials: initials,
                                  imageProvider: avatarProvider,
                                  borderColor: primary.withOpacity(0.16),
                                  shadow: true,
                                ),
                                Positioned(
                                  bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [primary, primaryContainer],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                          color: surfaceLowest, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withOpacity(0.18),
                                          blurRadius: 14,
                                          spreadRadius: -8,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.verified_rounded,
                                            size: 14, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Verified traveler',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Text(
                              displayName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.45,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayEmail,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: onSurfaceVariant.withOpacity(0.84),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tune_rounded,
                                      size: 16, color: primary),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Update your traveler profile and account preferences',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!AuthStore.isLoggedIn) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceLowest,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: outlineVariant.withOpacity(0.16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 14,
                                spreadRadius: -8,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sign in to edit your profile details.',
                                  style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          onSurfaceVariant.withOpacity(0.92))),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.login),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text('Go to Login',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: primary)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: surfaceLowest.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 22,
                              spreadRadius: -14,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Personal details',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                )),
                            const SizedBox(height: 6),
                            Text(
                              'Keep your rider identity and contact details up to date.',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                height: 1.45,
                                color: onSurfaceVariant.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _ProfileInputCard(
                                    label: 'First Name',
                                    value: 'First name',
                                    controller: _firstNameController,
                                    enabled: AuthStore.isLoggedIn,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _ProfileInputCard(
                                    label: 'Last Name',
                                    value: 'Last name',
                                    controller: _lastNameController,
                                    enabled: AuthStore.isLoggedIn,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _ProfileInputCard(
                              label: 'Email Address',
                              value: 'Email address',
                              controller: _emailController,
                              enabled: AuthStore.isLoggedIn,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(Icons.verified_rounded,
                                    color: primary, size: 16),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _ProfileInputCard(
                              label: 'Phone Number',
                              value: 'Phone number',
                              controller: _phoneController,
                              enabled: AuthStore.isLoggedIn,
                              prefix: '+234',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: surfaceLowest.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 22,
                              spreadRadius: -14,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Account preferences',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                )),
                            const SizedBox(height: 6),
                            Text(
                              'Manage alerts and personalization for a smoother travel experience.',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                height: 1.45,
                                color: onSurfaceVariant.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PushPermissionCard(
                              enabled: _pushEnabled,
                              available: _pushAvailable,
                              loading: _pushLoading,
                              statusLabel: _pushStatusLabel,
                              loggedIn: AuthStore.isLoggedIn,
                              onRequest: _requestPushPermission,
                            ),
                            const _PreferenceToggle(
                              icon: Icons.auto_awesome_rounded,
                              title: 'Smart Suggestions',
                              subtitle:
                                  'Use your travel habits for calmer, faster route suggestions.',
                              enabled: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      IgnorePointer(
                        ignoring: !canSave,
                        child: Opacity(
                          opacity: canSave ? 1 : 0.6,
                          child: GestureDetector(
                            onTap: _saveProfile,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 17),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [primary, primaryContainer]),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.18),
                                    blurRadius: 18,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_saving)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                    )
                                  else
                                    const Icon(Icons.check_circle,
                                        color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    _saving ? 'Saving...' : 'Update Profile',
                                    style: GoogleFonts.manrope(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(_lastUpdatedLabel(),
                          style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: onSurfaceVariant.withOpacity(0.78))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.76),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 24,
                          offset: const Offset(0, -8))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;
  bool _saving = false;
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newController.addListener(_refreshStrength);
    _confirmController.addListener(_refreshStrength);
  }

  void _refreshStrength() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _newController.removeListener(_refreshStrength);
    _confirmController.removeListener(_refreshStrength);
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    if (!AuthStore.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in to change your password.')),
      );
      return;
    }
    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all password fields.')),
      );
      return;
    }
    if (next.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 8 characters.')),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('New password and confirmation do not match.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final response = await AuthApi.changePassword(
      currentPassword: current,
      newPassword: next,
    );
    if (!mounted) return;
    if (response['ok'] == true) {
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } else {
      final message = response['message']?.toString() ??
          response['reason']?.toString() ??
          'Unable to update password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    const surfaceContainerHigh = Color(0xFFE7EEE9);
    const outlineVariant = Color(0xFFD7E4DB);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -74,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.16),
                    primaryContainer.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -38,
            top: 250,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: primary, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Change Password',
                                    style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: primary)),
                                Text('Security settings',
                                    style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant
                                            .withOpacity(0.72))),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: surfaceLowest.withOpacity(0.94),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded,
                                      size: 15, color: primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Protected',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              surfaceLowest,
                              const Color(0xFFF8FCFA),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: outlineVariant.withOpacity(0.18)),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.08),
                              blurRadius: 24,
                              spreadRadius: -14,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              spreadRadius: -14,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.lock_outline_rounded,
                                  color: primary, size: 28),
                            ),
                            const SizedBox(height: 16),
                            Text('Update Security',
                                style: GoogleFonts.manrope(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.45,
                                  color: onSurface,
                                )),
                            const SizedBox(height: 8),
                            Text(
                              'Protect your I-Metro traveler account with a strong, unique password.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: onSurfaceVariant.withOpacity(0.84),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: surfaceLowest.withOpacity(0.96),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 16,
                                    spreadRadius: -10,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _PasswordField(
                                    label: 'Current Password',
                                    placeholder: 'Enter current password',
                                    obscure: !showCurrent,
                                    controller: _currentController,
                                    onToggle: () => setState(
                                        () => showCurrent = !showCurrent),
                                  ),
                                  Container(
                                      height: 1,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      color: outlineVariant.withOpacity(0.24)),
                                  _PasswordField(
                                    label: 'New Password',
                                    placeholder: 'Create new password',
                                    obscure: !showNew,
                                    controller: _newController,
                                    onToggle: () =>
                                        setState(() => showNew = !showNew),
                                  ),
                                  const SizedBox(height: 12),
                                  _StrengthBars(
                                      activeCount: _newController.text.isEmpty
                                          ? 0
                                          : (_newController.text.length >= 12
                                              ? 4
                                              : _newController.text.length >= 10
                                                  ? 3
                                                  : _newController
                                                              .text.length >=
                                                          8
                                                      ? 2
                                                      : 1)),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Password must be at least 8 characters',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            onSurfaceVariant.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _PasswordField(
                                    label: 'Confirm New Password',
                                    placeholder: 'Repeat new password',
                                    obscure: !showConfirm,
                                    controller: _confirmController,
                                    onToggle: () => setState(
                                        () => showConfirm = !showConfirm),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: surfaceContainerLow,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.info_outline,
                                            color: primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Session Security',
                                                style: GoogleFonts.manrope(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: onSurface)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Updating your password will sign you out of all other active sessions on different devices for your safety.',
                                              style: GoogleFonts.inter(
                                                  fontSize: 11.5,
                                                  color: onSurfaceVariant
                                                      .withOpacity(0.84),
                                                  height: 1.45),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            IgnorePointer(
                              ignoring: _saving,
                              child: Opacity(
                                opacity: _saving ? 0.7 : 1,
                                child: GestureDetector(
                                  onTap: _submit,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 17),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [primary, primaryContainer]),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                            color: primary.withOpacity(0.18),
                                            blurRadius: 18,
                                            spreadRadius: -8,
                                            offset: const Offset(0, 10))
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_saving)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white)),
                                          )
                                        else
                                          const Icon(Icons.lock_reset_rounded,
                                              color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          _saving
                                              ? 'Saving...'
                                              : 'Save Changes',
                                          style: GoogleFonts.manrope(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel and go back',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: onSurfaceVariant),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surfaceContainerHigh.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: Icon(Icons.security_rounded,
                                        size: 100,
                                        color: primary.withOpacity(0.08)),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.lock_outline_rounded,
                                          color: primary),
                                      const SizedBox(height: 8),
                                      Text('Your data is encrypted',
                                          style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: onSurfaceVariant)),
                                      const SizedBox(height: 6),
                                      Text(
                                        'I-Metro uses bank-grade security to ensure your personal information remains private.',
                                        style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            height: 1.45,
                                            color: onSurfaceVariant
                                                .withOpacity(0.84)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileInputCard extends StatelessWidget {
  const _ProfileInputCard({
    required this.label,
    required this.value,
    this.trailing,
    this.prefix,
    this.controller,
    this.enabled = true,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final String? prefix;
  final TextEditingController? controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const surfaceContainerLow = Color(0xFFF3F7F4);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    Widget field;
    if (controller == null) {
      field = Row(
        children: [
          if (prefix != null) ...[
            Text(prefix!,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceVariant)),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(value,
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurface)),
          ),
        ],
      );
    } else {
      field = TextField(
        controller: controller,
        readOnly: !enabled,
        style: GoogleFonts.manrope(
            fontSize: 15.5, fontWeight: FontWeight.w700, color: onSurface),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: value,
          hintStyle: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onSurfaceVariant.withOpacity(0.6)),
          prefixText: prefix != null ? '$prefix ' : null,
          prefixStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onSurfaceVariant),
          suffixIcon: trailing,
          contentPadding: EdgeInsets.zero,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 16,
              spreadRadius: -10,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 10.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant.withOpacity(0.8))),
                  const SizedBox(height: 7),
                  field,
                ],
              ),
            ),
            if (controller == null && trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ProfileInitialAvatar extends StatelessWidget {
  const _ProfileInitialAvatar({
    required this.size,
    required this.initials,
    this.imageProvider,
    this.borderRadius,
    this.borderColor,
    this.shadow = false,
  });

  final double size;
  final String initials;
  final ImageProvider? imageProvider;
  final double? borderRadius;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    final radius = borderRadius ?? size / 2;
    final isCircular = borderRadius == null;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(isCircular ? 5 : 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.16),
            const Color(0xFFEAF7F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? primary.withOpacity(0.18),
          width: isCircular ? 2.6 : 2,
        ),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.16),
                  blurRadius: 22,
                  spreadRadius: -14,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  spreadRadius: -12,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular((radius - 4).clamp(0, radius).toDouble()),
        child: imageProvider == null
            ? Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF006B47), Color(0xFF00875A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  initials,
                  style: GoogleFonts.manrope(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              )
            : Image(image: imageProvider!, fit: BoxFit.cover),
      ),
    );
  }
}

class _PushPermissionCard extends StatelessWidget {
  const _PushPermissionCard({
    required this.enabled,
    required this.available,
    required this.loading,
    required this.statusLabel,
    required this.loggedIn,
    required this.onRequest,
  });

  final bool enabled;
  final bool available;
  final bool loading;
  final String statusLabel;
  final bool loggedIn;
  final VoidCallback onRequest;

  String _subtitle() {
    if (!loggedIn) {
      return 'Sign in to manage trip alerts for this device.';
    }
    if (!available) {
      return 'Notification controls depend on device support and app setup.';
    }
    return enabled
        ? 'Trip alerts and service updates are enabled for this account.'
        : 'Stay updated with ticket status, ride reminders, and route changes.';
  }

  Widget _statusChip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerHigh = Color(0xFFE6EDE8);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    final trailing = _statusChip(
      statusLabel,
      enabled ? primary.withOpacity(0.1) : surfaceContainerHigh,
      enabled ? primary : onSurfaceVariant,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          )
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip Notifications',
                    style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: onSurface)),
                const SizedBox(height: 4),
                Text(_subtitle(),
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.45,
                        color: onSurfaceVariant.withOpacity(0.82))),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  const _PreferenceToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerHigh = Color(0xFFE6EDE8);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          )
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: onSurface)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.45,
                        color: onSurfaceVariant.withOpacity(0.82))),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 26,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: enabled ? primary : surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Align(
              alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: enabled ? Colors.white : const Color(0xFFEFF1F3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.placeholder,
    required this.obscure,
    required this.onToggle,
    this.controller,
  });

  final String label;
  final String placeholder;
  final bool obscure;
  final VoidCallback onToggle;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFF8FCFA);
    const primary = Color(0xFF006B47);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: onSurfaceVariant.withOpacity(0.82))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.manrope(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF191C1E),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceLowest,
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: onSurfaceVariant.withOpacity(0.58)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: primary.withOpacity(0.24), width: 1.6),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthBars extends StatelessWidget {
  const _StrengthBars({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const surfaceVariant = Color(0xFFE0E3E5);
    final activeColor = switch (activeCount) {
      0 => surfaceVariant,
      1 => const Color(0xFFD98343),
      2 => const Color(0xFFB88B12),
      3 => const Color(0xFF2A8E68),
      _ => primary,
    };
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < activeCount;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.82) : surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}

class HamburgerMenuScreen extends StatelessWidget {
  const HamburgerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outlineVariant = Color(0xFFBDCAC0);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 300,
              height: double.infinity,
              decoration: BoxDecoration(
                color: background,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(8, 0))
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              _brandLogo(size: 64, radius: 16),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: background, width: 2),
                                  ),
                                  child: const Icon(Icons.star,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('I-Metro Rider',
                                  style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: onSurface)),
                              const SizedBox(height: 2),
                              Text('LUXURY IN MOTION',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      letterSpacing: 2.2,
                                      fontWeight: FontWeight.w700,
                                      color: primary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _MenuItem(
                        icon: Icons.home,
                        label: 'Home',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _MenuItem(
                        icon: Icons.confirmation_number,
                        label: 'Book Ride',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _MenuItem(
                        icon: Icons.history,
                        label: 'History',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _MenuItem(
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 18),
                        color: outlineVariant.withOpacity(0.2),
                      ),
                      _MenuItem(
                        icon: Icons.help,
                        label: 'Support',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.contactUs),
                      ),
                      _MenuItem(
                        icon: Icons.quiz_outlined,
                        label: 'Help & FAQ',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.faq),
                      ),
                      _MenuItem(
                        icon: Icons.policy,
                        label: 'Policies',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.policy),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.logout),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFFFF5F5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout,
                                  color: Color(0xFFBA1A1A)),
                              const SizedBox(width: 12),
                              Text('Logout',
                                  style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFBA1A1A))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const onSurface = Color(0xFF191C1E);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: onSurface.withOpacity(0.7)),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface.withOpacity(0.75))),
          ],
        ),
      ),
    );
  }
}

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  static final Uri _whatsAppUri = Uri.parse('https://wa.me/2347070050444');
  static final Uri _callUri = Uri.parse('tel:07070050444');
  bool _sending = false;
  bool _loadingSupport = true;
  String? _error;
  String? _supportError;
  String? _supportNotice;
  DateTime? _lastSupportSyncAt;
  List<Map<String, dynamic>> _supportItems = [];
  Timer? _supportRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSupportMessages();
    _supportRefreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted && AuthStore.isLoggedIn) {
        _loadSupportMessages(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _supportRefreshTimer?.cancel();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadSupportMessages({bool silent = false}) async {
    if (!AuthStore.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _loadingSupport = false;
        _supportItems = [];
        _supportError = null;
      });
      return;
    }
    if (!silent && mounted) {
      setState(() {
        _loadingSupport = true;
        _supportError = null;
      });
    }
    final response = await UserApi.getMySupportMessages();
    if (!mounted) return;
    final ok = response['ok'] == true;
    final items = ok && response['items'] is List
        ? (response['items'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];
    setState(() {
      _loadingSupport = false;
      _supportItems = items;
      _supportError = ok
          ? null
          : (response['reason']?.toString() ??
              'Unable to load support messages.');
      _lastSupportSyncAt = DateTime.now();
    });
  }

  Future<void> _sendMessage() async {
    if (_sending) return;
    if (!AuthStore.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in to send a support message.')),
      );
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      setState(() => _error = 'Please enter a subject and message.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final response =
        await UserApi.sendSupportMessage(subject: subject, message: message);
    if (!mounted) return;
    setState(() => _sending = false);
    if (response['ok'] == true) {
      _subjectController.clear();
      _messageController.clear();
      final ticketId = response['id']?.toString();
      final notice = response['notice']?.toString() ??
          'Complaint delivered to customer service.';
      final messageText = ticketId == null || ticketId.isEmpty
          ? notice
          : '$notice Ticket #$ticketId';
      setState(() => _supportNotice = messageText);
      await _loadSupportMessages(silent: true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(messageText)));
    } else {
      final messageText = response['message']?.toString() ??
          response['reason']?.toString() ??
          'Unable to send message.';
      setState(() => _error = messageText);
    }
  }

  Future<void> _openWhatsAppSupport() async {
    final opened = await launchUrl(
      _whatsAppUri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open WhatsApp on this device right now.'),
      ),
    );
  }

  Future<void> _openPhoneDialer() async {
    final opened = await launchUrl(
      _callUri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open the phone dialer right now.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFDBE7E0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const error = Color(0xFFBA1A1A);
    final latestSupport = _supportItems.isNotEmpty ? _supportItems.first : null;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -76,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.16),
                    primaryContainer.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -44,
            top: 260,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.hamburgerMenu),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.menu, color: primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro',
                                style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: primary)),
                            const Spacer(),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.035),
                                    blurRadius: 12,
                                    spreadRadius: -6,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: _brandLogo(size: 20, radius: 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 148),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How can we help?',
                                style: GoogleFonts.manrope(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.55,
                                  color: onSurface,
                                )),
                            const SizedBox(height: 10),
                            Text(
                              'Contact I-Metro for support, partnerships, or fleet management enquiries.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.5,
                                color: onSurfaceVariant.withOpacity(0.84),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('Contact options',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          )),
                      const SizedBox(height: 14),
                      _ContactInfoCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Chat With Us',
                        subtitle: 'WhatsApp Business',
                        value: '+234 707 005 0444',
                        helper: 'Tap to chat on WhatsApp',
                        onTap: _openWhatsAppSupport,
                      ),
                      const SizedBox(height: 14),
                      _ContactInfoCard(
                        icon: Icons.call_rounded,
                        title: 'Call Us',
                        subtitle: 'Customer Support',
                        value: '07070050444',
                        helper: 'Tap to call',
                        onTap: _openPhoneDialer,
                      ),
                      const SizedBox(height: 14),
                      const _ContactInfoCard(
                        icon: Icons.apartment_rounded,
                        title: 'Head Office',
                        subtitle: 'Abuja, Nigeria',
                        value:
                            'Suite 401, 4th Floor, Kano House, Ralph Shodeinde Street, Central Business District, Abuja.',
                        helper: 'Corporate office',
                      ),
                      const SizedBox(height: 26),
                      _SupportFaqPreviewCard(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.faq),
                      ),
                      const SizedBox(height: 26),
                      Text('Send a message',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          )),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                        decoration: BoxDecoration(
                          color: surfaceLowest,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: outlineVariant.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 22,
                              spreadRadius: -12,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ContactFormField(
                              label: 'Subject',
                              placeholder: 'What can we help you with?',
                              controller: _subjectController,
                            ),
                            const SizedBox(height: 18),
                            _ContactMessageField(
                              label: 'Message',
                              placeholder: 'Tell us more about your inquiry...',
                              controller: _messageController,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _sending ? null : _sendMessage,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_sending)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.send_rounded,
                                          size: 18, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      _sending ? 'Sending...' : 'Send Message',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('My support requests',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          )),
                      const SizedBox(height: 6),
                      Text(
                        'Track whether your complaint is open, in progress, or resolved.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          color: onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SupportLiveUpdateBanner(
                        notice: _supportNotice,
                        latestItem: latestSupport,
                        lastSyncedAt: _lastSupportSyncAt,
                      ),
                      const SizedBox(height: 14),
                      _SupportStatusPanel(
                        loading: _loadingSupport,
                        errorText: _supportError,
                        items: _supportItems,
                        onRefresh: () => _loadSupportMessages(),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'By sending this message, you agree to our privacy policy regarding data collection for support purposes.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: onSurfaceVariant.withOpacity(0.76),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.76),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 24,
                          offset: const Offset(0, -8))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportStatusPanel extends StatelessWidget {
  const _SupportStatusPanel({
    required this.loading,
    required this.errorText,
    required this.items,
    required this.onRefresh,
  });

  final bool loading;
  final String? errorText;
  final List<Map<String, dynamic>> items;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    const panelBg = Color(0xFFFFFFFF);
    const heading = Color(0xFF203229);
    const muted = Color(0xFF51615A);
    const primary = Color(0xFF006B47);

    final visibleItems = items.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('My support requests',
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: heading)),
              const Spacer(),
              TextButton(
                onPressed: onRefresh,
                child: Text('Refresh',
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Track whether your complaint is open, in progress, or resolved.',
            style: GoogleFonts.inter(
                fontSize: 12.5, color: muted.withOpacity(0.86), height: 1.45),
          ),
          const SizedBox(height: 14),
          if (loading)
            const _SupportLoadingRow()
          else if (errorText != null)
            _SupportEmptyState(message: errorText!)
          else if (visibleItems.isEmpty)
            const _SupportEmptyState(message: 'No support complaints sent yet.')
          else
            Column(
              children: [
                for (final item in visibleItems) ...[
                  _SupportTicketCard(
                    subject: item['subject']?.toString() ?? 'Support request',
                    message: item['message']?.toString() ?? '',
                    status: item['status']?.toString() ?? 'OPEN',
                    updatedAt: item['updatedAt']?.toString() ??
                        item['createdAt']?.toString(),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SupportLiveUpdateBanner extends StatelessWidget {
  const _SupportLiveUpdateBanner({
    required this.notice,
    required this.latestItem,
    required this.lastSyncedAt,
  });

  final String? notice;
  final Map<String, dynamic>? latestItem;
  final DateTime? lastSyncedAt;

  @override
  Widget build(BuildContext context) {
    const heading = Color(0xFF203229);
    const muted = Color(0xFF51615A);
    const success = Color(0xFF006B47);
    const warning = Color(0xFF9C6A08);
    const danger = Color(0xFFB15A62);

    final normalized = latestItem == null
        ? 'OPEN'
        : (latestItem!['status']?.toString().toUpperCase() ?? 'OPEN');
    final statusLabel = switch (normalized) {
      'IN_PROGRESS' => 'In progress',
      'RESOLVED' => 'Resolved',
      _ => 'Open',
    };
    final statusColor = switch (normalized) {
      'IN_PROGRESS' => warning,
      'RESOLVED' => success,
      _ => danger,
    };
    final statusBg = switch (normalized) {
      'IN_PROGRESS' => const Color(0xFFFFF5DE),
      'RESOLVED' => const Color(0xFFE8F5EE),
      _ => const Color(0xFFFBECEE),
    };
    final subject =
        latestItem?['subject']?.toString() ?? 'No support request yet';
    final note = switch (normalized) {
      'IN_PROGRESS' => 'Our team is working on this complaint.',
      'RESOLVED' => 'The issue has been settled.',
      _ => 'Delivered to customer service.',
    };
    final updatedAt = latestItem?['updatedAt']?.toString() ??
        latestItem?['createdAt']?.toString();
    final syncText = lastSyncedAt == null ? null : 'Last refreshed just now';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Latest support update',
                style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w800, color: heading),
              ),
              const Spacer(),
              if (syncText != null)
                Text(syncText,
                    style: GoogleFonts.inter(fontSize: 10, color: muted)),
            ],
          ),
          if (notice != null && notice!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F2EA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified, size: 18, color: success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      notice!,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: heading,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: heading),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: GoogleFonts.inter(fontSize: 12, color: muted, height: 1.4),
          ),
          if (updatedAt != null && updatedAt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Updated: $updatedAt',
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFF71847B)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportTicketCard extends StatelessWidget {
  const _SupportTicketCard({
    required this.subject,
    required this.message,
    required this.status,
    required this.updatedAt,
  });

  final String subject;
  final String message;
  final String status;
  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final statusLabel = switch (normalized) {
      'IN_PROGRESS' => 'In progress',
      'RESOLVED' => 'Resolved',
      _ => 'Open',
    };
    final statusColor = switch (normalized) {
      'IN_PROGRESS' => const Color(0xFF9C6A08),
      'RESOLVED' => const Color(0xFF006B47),
      _ => const Color(0xFFB15A62),
    };
    final statusBg = switch (normalized) {
      'IN_PROGRESS' => const Color(0xFFFFF5DE),
      'RESOLVED' => const Color(0xFFE8F5EE),
      _ => const Color(0xFFFBECEE),
    };
    final supportNote = switch (normalized) {
      'IN_PROGRESS' => 'Our team is working on this complaint.',
      'RESOLVED' => 'The issue has been settled.',
      _ => 'Delivered to customer service.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF203229)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.isEmpty ? supportNote : message,
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF51615A), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Updated: $updatedAt',
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFF71847B)),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            supportNote,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _SupportLoadingRow extends StatelessWidget {
  const _SupportLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 86,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 12,
                  spreadRadius: -10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportEmptyState extends StatelessWidget {
  const _SupportEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            spreadRadius: -10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF51615A)),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.helper,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String? helper;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    final child = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: primary.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: -8,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w700, color: onSurface)),
          const SizedBox(height: 4),
          Text(subtitle.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant.withOpacity(0.74))),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper!,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceVariant.withOpacity(0.78))),
          ],
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}

class _SupportFaqPreviewCard extends StatelessWidget {
  const _SupportFaqPreviewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const outlineVariant = Color(0xFFDBE7E0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const previewItems = [
      'How do I book a ride?',
      'Why is my payment still pending?',
      'Where can I find my ticket?',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            spreadRadius: -12,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.quiz_outlined, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently asked questions',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quick answers before you contact support.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        height: 1.45,
                        color: onSurfaceVariant.withOpacity(0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...previewItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                'View all FAQs',
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLocationRow extends StatelessWidget {
  const _ContactLocationRow();

  @override
  Widget build(BuildContext context) {
    const onSurfaceVariant = Color(0xFF3E4942);
    return Row(
      children: [
        const Icon(Icons.location_on, color: onSurfaceVariant, size: 28),
        const SizedBox(width: 12),
        Text('Abuja, Nigeria (FCT)',
            style: GoogleFonts.inter(fontSize: 15, color: onSurfaceVariant)),
      ],
    );
  }
}

class _ContactFormField extends StatelessWidget {
  const _ContactFormField({
    required this.label,
    required this.placeholder,
    this.controller,
  });

  final String label;
  final String placeholder;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    const surfaceContainerLow = Color(0xFFF5F8F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    const surfaceLowest = Color(0xFFFFFFFF);
    const primary = Color(0xFF006B47);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurfaceVariant.withOpacity(0.86))),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            hintText: placeholder,
            hintStyle:
                GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: primary.withOpacity(0.28), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: surfaceLowest.withOpacity(0.0), width: 0),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactMessageField extends StatelessWidget {
  const _ContactMessageField({
    required this.label,
    required this.placeholder,
    this.controller,
  });

  final String label;
  final String placeholder;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    const surfaceContainerLow = Color(0xFFF5F8F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurfaceVariant.withOpacity(0.86))),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 7,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            hintText: placeholder,
            hintStyle:
                GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: primary.withOpacity(0.28), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const kineticEnd = Color(0xFF009B67);
    final accentColor = accent ?? primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineVariant.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: onSurface)),
                    const SizedBox(height: 4),
                    Text(body,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: onSurfaceVariant,
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(actionLabel!,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  StreamSubscription<bool>? _onlineSub;
  StreamSubscription<TicketRefreshEvent>? _ticketRefreshSub;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _onlineSub = ConnectivityService.instance.onlineStream.listen((online) {
      if (online) {
        _loadNotifications();
      }
    });
    _ticketRefreshSub =
        PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      if (!AuthStore.isLoggedIn || AuthStore.userId == null) return;
      if (event.type == 'ticket_ready' ||
          event.type == 'payment_confirmed' ||
          event.type == 'booking_updated') {
        _loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _ticketRefreshSub?.cancel();
    super.dispose();
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _formatTime(DateTime? date) {
    if (date == null) {
      return 'Just now';
    }
    final now = DateTime.now();
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final dateLabel = date.toIso8601String().split('T').first;
    final time = date.toIso8601String().split('T').last.split('.').first;
    final shortTime = time.length >= 5 ? time.substring(0, 5) : time;
    return sameDay ? 'Today - $shortTime' : '$dateLabel - $shortTime';
  }

  int _timeScore(Map<String, dynamic> item) {
    final time = item['time'];
    if (time is DateTime) {
      return time.millisecondsSinceEpoch;
    }
    return 0;
  }

  List<Map<String, dynamic>> _buildFromBookings(
      List<Map<String, dynamic>> bookings) {
    const primary = Color(0xFF006B47);
    const warning = Color(0xFFB54708);
    const info = Color(0xFF355AA2);
    const neutral = Color(0xFF6B7771);
    final items = <Map<String, dynamic>>[];

    for (final booking in bookings) {
      final route = (booking['route'] as Map?) ?? {};
      final from = route['fromLocation']?.toString() ?? 'Route';
      final to = route['toLocation']?.toString() ?? 'Destination';
      final bookingId = booking['id']?.toString();
      final createdAt = _parseDate(booking['createdAt']);
      final status = booking['status']?.toString().toUpperCase() ?? '';
      final payment = (booking['payment'] as Map?) ?? {};
      final paymentStatus = payment['status']?.toString().toUpperCase() ?? '';
      final ticket = booking['ticket'];

      if (ticket is Map && ticket.isNotEmpty) {
        items.add({
          'title': 'Ticket ready',
          'body': 'Your ticket for $from -> $to is ready. Tap to view the QR.',
          'time': createdAt,
          'icon': Icons.qr_code_2,
          'color': primary,
          'bookingId': bookingId,
        });
      } else if (paymentStatus == 'SUCCESS' || status == 'CONFIRMED') {
        items.add({
          'title': 'Payment confirmed',
          'body':
              'Payment confirmed for $from -> $to. Tap to issue your ticket.',
          'time': createdAt,
          'icon': Icons.verified,
          'color': primary,
          'bookingId': bookingId,
        });
      } else if (paymentStatus.isNotEmpty) {
        items.add({
          'title': 'Payment pending',
          'body': 'We are waiting for payment confirmation for $from -> $to.',
          'time': createdAt,
          'icon': Icons.schedule,
          'color': warning,
          'bookingId': bookingId,
        });
      } else {
        items.add({
          'title': 'Booking started',
          'body': 'Complete payment for $from -> $to to receive your ticket.',
          'time': createdAt,
          'icon': Icons.directions_bus,
          'color': info,
          'bookingId': bookingId,
        });
      }
    }

    items.sort((a, b) => _timeScore(b).compareTo(_timeScore(a)));
    if (items.length > 20) {
      return items.sublist(0, 20);
    }
    return items;
  }

  Future<void> _loadNotifications() async {
    if (!AuthStore.isLoggedIn || AuthStore.userId == null) {
      setState(() {
        _loading = false;
        _items = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookings = await UserApi.listBookingsForUser(AuthStore.userId!);
      setState(() {
        _items = _buildFromBookings(bookings);
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Unable to load notifications right now.';
      });
    }
  }

  void _openNotification(Map<String, dynamic> item) {
    final bookingId = item['bookingId']?.toString();
    if (bookingId != null && bookingId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.ticketDetails,
        arguments: {'bookingId': bookingId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const error = Color(0xFFBA1A1A);

    final loggedIn = AuthStore.isLoggedIn;
    final paymentCount = _items
        .where((item) =>
            (item['title']?.toString().toLowerCase() ?? '').contains('payment'))
        .length;
    final ticketCount = _items
        .where((item) =>
            (item['title']?.toString().toLowerCase() ?? '').contains('ticket'))
        .length;
    final updateCount = _items.length;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -74,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.15),
                    primaryContainer.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -36,
            top: 240,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: primary, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('I-Metro',
                                    style: GoogleFonts.manrope(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: primary)),
                                Text('Notification center',
                                    style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant
                                            .withOpacity(0.72))),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: surfaceLowest.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    spreadRadius: -8,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_loading)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: primary.withOpacity(0.7)),
                                      ),
                                    ),
                                  Text('Alerts',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: (!ConnectivityService.instance.isOnline && loggedIn)
                    ? OfflineFullScreen(
                        onRetry: _loadNotifications,
                        title: 'Offline alerts',
                        body: 'Reconnect to load payment and ticket updates.',
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stay in the loop',
                                style: GoogleFonts.manrope(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.45,
                                    color: onSurface)),
                            const SizedBox(height: 8),
                            Text(
                                'Trip updates, payment confirmations, and ticket alerts in one premium rider feed.',
                                style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: onSurfaceVariant.withOpacity(0.84))),
                            const SizedBox(height: 12),
                            OfflineBanner(onRetry: _loadNotifications),
                            const SizedBox(height: 16),
                            if (loggedIn && (_items.isNotEmpty || _loading))
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.045),
                                      blurRadius: 18,
                                      spreadRadius: -8,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.notifications_active_rounded,
                                            color: primary,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Recent activity',
                                                  style: GoogleFonts.manrope(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: onSurface)),
                                              const SizedBox(height: 4),
                                              Text(
                                                  'Your ticket, ride, and payment events appear here as they happen.',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.5,
                                                      height: 1.45,
                                                      color: onSurfaceVariant
                                                          .withOpacity(0.82))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _NotificationSummaryChip(
                                            label: 'Updates',
                                            value: updateCount.toString(),
                                            tint: primary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _NotificationSummaryChip(
                                            label: 'Payments',
                                            value: paymentCount.toString(),
                                            tint: const Color(0xFF355AA2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _NotificationSummaryChip(
                                            label: 'Tickets',
                                            value: ticketCount.toString(),
                                            tint: const Color(0xFFB54708),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (loggedIn && (_items.isNotEmpty || _loading))
                              const SizedBox(height: 16),
                            if (!loggedIn)
                              _EmptyStateCard(
                                icon: Icons.lock_outline,
                                title: 'Sign in for alerts',
                                body:
                                    'See payment confirmations and ticket updates here.',
                                actionLabel: 'Sign in',
                                onAction: () => Navigator.pushNamed(
                                    context, AppRoutes.login),
                              )
                            else if (_error != null)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 16,
                                      spreadRadius: -8,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Unable to refresh alerts',
                                        style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: error)),
                                    const SizedBox(height: 6),
                                    Text(_error!,
                                        style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            height: 1.45,
                                            color: onSurfaceVariant)),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: _loadNotifications,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Text('Retry',
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: primary)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (!_loading && _items.isEmpty)
                              _EmptyStateCard(
                                icon: Icons.notifications_none,
                                title: 'No alerts yet',
                                body:
                                    'We will let you know about payments, tickets, and rides here.',
                                actionLabel: 'View history',
                                onAction: () => Navigator.pushNamed(
                                    context, AppRoutes.completedRides),
                              )
                            else
                              ..._items.map(
                                (item) => _NotificationCard(
                                  icon: item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  title: item['title']?.toString() ?? 'Alert',
                                  body: item['body']?.toString() ?? '',
                                  timeLabel:
                                      _formatTime(item['time'] as DateTime?),
                                  onTap: () => _openNotification(item),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String timeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 16,
                  spreadRadius: -8,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              timeLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: color.withOpacity(0.88)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: onSurfaceVariant.withOpacity(0.88),
                            height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.chevron_right_rounded,
                    color: onSurfaceVariant.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationSummaryChip extends StatelessWidget {
  const _NotificationSummaryChip({
    required this.label,
    required this.value,
    required this.tint,
  });

  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                  color: tint.withOpacity(0.88))),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w800, color: tint)),
        ],
      ),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAF8);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outlineVariant = Color(0xFFDBE7E0);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);

    final sections = <_FaqSectionData>[
      _FaqSectionData(
        title: 'Account & Access',
        icon: Icons.person_outline_rounded,
        items: const [
          _FaqItemData(
            question: 'How do I create an I-Metro account?',
            answer:
                'Tap Create Account on the sign-in screen, enter your details, accept the terms, and submit. Once successful, you can continue directly into the rider app.',
          ),
          _FaqItemData(
            question: 'What if I forget my password?',
            answer:
                'Use Forgot Password on the login screen. We will send a reset code to your registered email address. If you do not see it, check your spam or promotions folder.',
          ),
          _FaqItemData(
            question: 'Can I use phone number instead of email?',
            answer:
                'Yes. The app supports either an email address or phone number for account creation, as long as at least one contact method is provided.',
          ),
        ],
      ),
      _FaqSectionData(
        title: 'Booking & Tickets',
        icon: Icons.confirmation_number_outlined,
        items: const [
          _FaqItemData(
            question: 'How do I book a ride?',
            answer:
                'Open Book Ride, choose your preferred route, select a payment gateway, complete checkout, and verify payment. Your ticket will appear inside the app once payment is confirmed.',
          ),
          _FaqItemData(
            question: 'Where can I find my ticket after payment?',
            answer:
                'After a successful payment, your digital ticket is available in the ticket details screen and can also be revisited from your trip history.',
          ),
          _FaqItemData(
            question: 'Why is my ticket not showing yet?',
            answer:
                'Sometimes payment confirmation takes a little time. Wait a few seconds, tap Verify payment again, and make sure your internet connection is stable.',
          ),
        ],
      ),
      _FaqSectionData(
        title: 'Payments & Refunds',
        icon: Icons.account_balance_wallet_outlined,
        items: const [
          _FaqItemData(
            question: 'Which payment gateways are supported?',
            answer:
                'I-Metro currently supports Monnify and Paystack, depending on the route checkout flow available in the app.',
          ),
          _FaqItemData(
            question: 'What should I do if payment is pending?',
            answer:
                'Do not make multiple payments immediately. Wait briefly, return to the checkout screen, and tap Verify payment. If it remains pending, contact support with your payment reference.',
          ),
          _FaqItemData(
            question: 'How do refunds work?',
            answer:
                'Refund requests depend on route rules, payment confirmation, operational review, and cancellation status. Contact support from the app if you need help with a failed or disputed transaction.',
          ),
        ],
      ),
      _FaqSectionData(
        title: 'Support & Safety',
        icon: Icons.support_agent_outlined,
        items: const [
          _FaqItemData(
            question: 'How do I contact I-Metro support?',
            answer:
                'Open the Support screen from your profile or menu, use the contact options provided, or send a message directly through the in-app support form.',
          ),
          _FaqItemData(
            question: 'Can I track my support request?',
            answer:
                'Yes. Your submitted support requests appear in the support screen, where you can check whether a message is open, in progress, or resolved.',
          ),
          _FaqItemData(
            question: 'Where can I read your policies?',
            answer:
                'You can review the Privacy Policy and Terms of Service inside the app from the policy and legal sections linked through profile and onboarding flows.',
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -78,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.16),
                    primaryContainer.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -44,
            top: 260,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.82),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      spreadRadius: -6,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: primary, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Text(
                              'I-Metro',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help & FAQ',
                              style: GoogleFonts.manrope(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.55,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Find quick answers about your account, bookings, payments, tickets, and support.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.5,
                                color: onSurfaceVariant.withOpacity(0.84),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceLowest,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: outlineVariant.withOpacity(0.22)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 22,
                              spreadRadius: -12,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded,
                                  color: primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Self-service help',
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Start here before contacting support. If you still need help, our support screen is only one tap away.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      height: 1.45,
                                      color: onSurfaceVariant.withOpacity(0.82),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...sections.map(
                        (section) => _FaqSectionCard(section: section),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.contactUs),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary.withOpacity(0.18)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: surfaceLowest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.support_agent_outlined),
                          label: Text(
                            'Still need help? Contact support',
                            style: GoogleFonts.manrope(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const _UserBottomNavigation(currentIndex: 3),
    );
  }
}

class _FaqSectionData {
  const _FaqSectionData({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_FaqItemData> items;
}

class _FaqItemData {
  const _FaqItemData({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class _FaqSectionCard extends StatelessWidget {
  const _FaqSectionCard({required this.section});

  final _FaqSectionData section;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(section.icon, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...section.items.map(
            (item) => Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                iconColor: primary,
                collapsedIconColor: onSurfaceVariant.withOpacity(0.6),
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  item.question,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                children: [
                  Text(
                    item.answer,
                    style: GoogleFonts.inter(
                      fontSize: 12.8,
                      height: 1.55,
                      color: onSurfaceVariant.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocumentScreen(
      title: 'Terms of Service',
      subtitle:
          'Please read these terms carefully before booking rides or using I-Metro services.',
      badge: 'Legal Agreement',
      variant: _LegalDocumentVariant.terms,
      sections: [
        _LegalSectionData(
          title: 'Acceptance of Terms',
          body:
              'By creating an account, booking a ticket, or using I-Metro, you agree to follow these terms and any service rules shown inside the app.',
        ),
        _LegalSectionData(
          title: 'User Accounts',
          body:
              'You are responsible for keeping your login details accurate and secure. Account activity made through your credentials may be treated as your activity.',
        ),
        _LegalSectionData(
          title: 'Ticket Booking & Payments',
          body:
              'Tickets are confirmed only after payment is successfully processed. Pending or failed payments do not guarantee a seat, fare, or completed booking.',
        ),
        _LegalSectionData(
          title: 'Passenger Responsibilities',
          body:
              'Passengers must arrive on time, carry valid ticket details, follow driver and staff instructions, and avoid conduct that affects safety or comfort.',
        ),
        _LegalSectionData(
          title: 'Route Availability',
          body:
              'Routes, schedules, buses, fares, and service availability may change because of traffic, safety, weather, operational needs, or regulatory direction.',
        ),
        _LegalSectionData(
          title: 'Refund & Cancellation Policy',
          body:
              'Refunds and cancellations may depend on payment confirmation, trip status, route rules, and operational review. Approved refunds are returned through supported payment channels.',
        ),
        _LegalSectionData(
          title: 'Prohibited Activities',
          body:
              'Do not misuse the app, submit false information, interfere with systems, harass staff or passengers, resell tickets, or use I-Metro for unlawful activity.',
        ),
        _LegalSectionData(
          title: 'Limitation of Liability',
          body:
              'I-Metro works to provide reliable transport, but is not liable for indirect losses caused by delays, disruptions, third-party services, or events outside reasonable control.',
        ),
        _LegalSectionData(
          title: 'Account Suspension',
          body:
              'We may suspend or restrict accounts that appear fraudulent, unsafe, abusive, unpaid, or in breach of these terms.',
        ),
        _LegalSectionData(
          title: 'Intellectual Property',
          body:
              'The I-Metro name, brand assets, interface, content, and service design belong to I-Metro or its licensors and may not be copied without permission.',
        ),
        _LegalSectionData(
          title: 'Changes to Terms',
          body:
              'We may update these terms as our services grow. Continued use of I-Metro after updates means you accept the revised terms.',
        ),
        _LegalSectionData(
          title: 'Contact Information',
          body:
              'For questions about these terms, contact I-Metro support through the app or call +234 912 806 6666.',
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalDocumentScreen(
      title: 'Privacy Policy',
      subtitle:
          'Learn how I-Metro collects, protects, and uses data to deliver safer, smarter bus travel.',
      badge: 'Data Protection',
      variant: _LegalDocumentVariant.privacy,
      sections: [
        _LegalSectionData(
          title: 'Information We Collect',
          body:
              'We may collect account details, contact information, booking history, support messages, and other information you provide while using I-Metro.',
        ),
        _LegalSectionData(
          title: 'How We Use Data',
          body:
              'We use data to create accounts, process bookings, confirm payments, send service updates, improve routes, support passengers, and protect the platform.',
        ),
        _LegalSectionData(
          title: 'GPS/Location Services',
          body:
              'Location data may be used to support pickup and destination features, route planning, real-time service information, safety, and operational monitoring.',
        ),
        _LegalSectionData(
          title: 'Payment Information',
          body:
              'Payment processing is handled through approved payment partners. I-Metro may store payment references and status, but does not store full card details in the app.',
        ),
        _LegalSectionData(
          title: 'Device Information',
          body:
              'We may collect device type, app version, network status, push notification identifiers, and diagnostic information to improve reliability and security.',
        ),
        _LegalSectionData(
          title: 'Security & Data Protection',
          body:
              'We use reasonable safeguards to protect user data, limit access, and reduce unauthorized use, loss, or misuse of personal information.',
        ),
        _LegalSectionData(
          title: 'Third-Party Services',
          body:
              'I-Metro may use trusted providers for authentication, payments, notifications, analytics, hosting, and customer support. These providers process data only as needed for service delivery.',
        ),
        _LegalSectionData(
          title: 'Cookies & Analytics',
          body:
              'Web versions of I-Metro may use cookies, local storage, or analytics tools to keep sessions working, understand performance, and improve the product.',
        ),
        _LegalSectionData(
          title: 'User Rights',
          body:
              'You may request access, correction, or deletion of your personal information, subject to legal, safety, payment, and operational record requirements.',
        ),
        _LegalSectionData(
          title: 'Contact Information',
          body:
              'For privacy questions or data requests, contact I-Metro support through the app or call +234 912 806 6666.',
        ),
      ],
    );
  }
}

class _LegalSectionData {
  const _LegalSectionData({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

enum _LegalDocumentVariant {
  terms,
  privacy,
}

Future<void> _showLegalDocumentDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String badge,
  required List<_LegalSectionData> sections,
  _LegalDocumentVariant variant = _LegalDocumentVariant.privacy,
}) {
  final screen = MediaQuery.of(context).size;
  final isPhoneWidth = screen.width < 600;

  if (isPhoneWidth) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.9;
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: _LegalDocumentBody(
            title: title,
            subtitle: subtitle,
            badge: badge,
            sections: sections,
            variant: variant,
            modal: true,
          ),
        );
      },
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final maxHeight = MediaQuery.of(dialogContext).size.height * 0.82;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: SizedBox(
            height: maxHeight,
            child: _LegalDocumentBody(
              title: title,
              subtitle: subtitle,
              badge: badge,
              sections: sections,
              variant: variant,
              modal: true,
            ),
          ),
        ),
      );
    },
  );
}

class _LegalDocumentScreen extends StatelessWidget {
  const _LegalDocumentScreen({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.sections,
    this.variant = _LegalDocumentVariant.privacy,
  });

  final String title;
  final String subtitle;
  final String badge;
  final List<_LegalSectionData> sections;
  final _LegalDocumentVariant variant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _LegalDocumentBody(
              title: title,
              subtitle: subtitle,
              badge: badge,
              sections: sections,
              variant: variant,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalDocumentBody extends StatelessWidget {
  const _LegalDocumentBody({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.sections,
    required this.variant,
    this.modal = false,
  });

  final String title;
  final String subtitle;
  final String badge;
  final List<_LegalSectionData> sections;
  final _LegalDocumentVariant variant;
  final bool modal;

  Widget _buildFloatingHeader(
    BuildContext context, {
    required bool compact,
    required bool isTerms,
    required Color primary,
    required Color primaryDeep,
    required Color headerSurface,
    required Color headerBorder,
    required List<Color> badgeGradient,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 20,
        compact ? 8 : 16,
        compact ? 16 : 20,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              compact ? 10 : 14,
              compact ? 8 : 12,
              compact ? 10 : 14,
              compact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: headerSurface,
              borderRadius: BorderRadius.circular(compact ? 20 : 24),
              border: Border.all(color: headerBorder),
              gradient: isTerms
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.82),
                        const Color(0xFFFFFBF5).withOpacity(0.74),
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(isTerms ? 0.08 : 0.05),
                  blurRadius: isTerms ? 28 : 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    modal ? Icons.close_rounded : Icons.arrow_back,
                    color: primaryDeep,
                    size: compact ? 18 : 20,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: Size(compact ? 34 : 42, compact ? 34 : 42),
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        Colors.white.withOpacity(isTerms ? 0.82 : 0.72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _brandLogo(size: compact ? 28 : 30, radius: 9),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I-Metro',
                    style: GoogleFonts.manrope(
                      fontSize: compact ? 15 : 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: primaryDeep,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 12,
                    vertical: compact ? 4.5 : 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: badgeGradient),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(isTerms ? 0.1 : 0.08),
                        blurRadius: isTerms ? 14 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: compact ? 9 : 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                      color: primaryDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const primaryDeep = Color(0xFF0B7D58);
    const mint = Color(0xFFE9F6F0);
    const mist = Color(0xFFF7FBF9);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF4D5A54);
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = modal || screenWidth < 600;
    final outerRadius = modal ? 30.0 : 34.0;
    final isTerms = variant == _LegalDocumentVariant.terms;
    final shellTop =
        isTerms ? const Color(0xFFFFFCF8) : const Color(0xFFFCFEFD);
    final shellBottom = isTerms ? const Color(0xFFF6F8F1) : mist;
    final ambientGlow =
        isTerms ? const Color(0xFFA9D7A5) : const Color(0xFF6DD5A6);
    final headerSurface = isTerms
        ? const Color(0xFFFFFCF8).withOpacity(0.72)
        : Colors.white.withOpacity(0.72);
    final headerBorder = isTerms
        ? const Color(0xFFE9E6DB).withOpacity(0.68)
        : Colors.white.withOpacity(0.55);
    final mainSurfaceGradient = isTerms
        ? [
            const Color(0xFFFFFDF9).withOpacity(0.96),
            const Color(0xFFF7FAF3).withOpacity(0.98),
          ]
        : [
            Colors.white.withOpacity(0.88),
            Colors.white.withOpacity(0.88),
          ];
    final badgeGradient = isTerms
        ? [
            const Color(0xFFFFF8EE).withOpacity(0.96),
            const Color(0xFFE9F4E5).withOpacity(0.98),
          ]
        : [
            Colors.white.withOpacity(0.92),
            mint.withOpacity(0.86),
          ];
    final updatePillColor = isTerms ? const Color(0xFFF5F7EF) : mint;
    final updatePillBorder =
        isTerms ? const Color(0xFFE2E9DB) : Colors.transparent;
    final mainSurfaceBorder =
        isTerms ? const Color(0xFFE7ECE0).withOpacity(0.9) : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            shellTop,
            shellBottom,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(modal ? outerRadius : 0),
        ).resolve(TextDirection.ltr).copyWith(
              bottomLeft:
                  modal ? Radius.circular(outerRadius - 4) : Radius.zero,
              bottomRight:
                  modal ? Radius.circular(outerRadius - 4) : Radius.zero,
            ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: compact ? -70 : -90,
            right: compact ? -52 : -64,
            child: IgnorePointer(
              child: Container(
                width: compact ? 170 : 220,
                height: compact ? 170 : 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(isTerms ? 0.22 : 0.18),
                      primary.withOpacity(isTerms ? 0.07 : 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? -46 : -58,
            top: compact ? 120 : 138,
            child: IgnorePointer(
              child: Container(
                width: compact ? 120 : 150,
                height: compact ? 120 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ambientGlow.withOpacity(isTerms ? 0.14 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              if (modal) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: isTerms ? 38 : 34,
                    height: 3,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(isTerms ? 0.2 : 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              _buildFloatingHeader(
                context,
                compact: compact,
                isTerms: isTerms,
                primary: primary,
                primaryDeep: primaryDeep,
                headerSurface: headerSurface,
                headerBorder: headerBorder,
                badgeGradient: badgeGradient,
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 16 : 20,
                          compact ? 10 : 20,
                          compact ? 16 : 20,
                          compact ? 18 : 22,
                        ),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 18 : 24,
                            compact ? 20 : 24,
                            compact ? 18 : 24,
                            compact ? 16 : 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: mainSurfaceGradient,
                            ),
                            borderRadius:
                                BorderRadius.circular(compact ? 26 : 30),
                            border: Border.all(color: mainSurfaceBorder),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    primary.withOpacity(isTerms ? 0.1 : 0.07),
                                blurRadius: isTerms ? 42 : 38,
                                offset: Offset(0, isTerms ? 24 : 20),
                              ),
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isTerms ? 0.035 : 0.025),
                                blurRadius: isTerms ? 18 : 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.manrope(
                                  fontSize: compact ? 24 : 31,
                                  fontWeight: FontWeight.w700,
                                  height: 1.06,
                                  letterSpacing: isTerms ? -0.5 : -0.35,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: compact ? 14 : 15,
                                  fontWeight: FontWeight.w400,
                                  height: isTerms ? 1.6 : 1.68,
                                  color: onSurfaceVariant.withOpacity(0.82),
                                ),
                              ),
                              SizedBox(height: isTerms ? 14 : 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: updatePillColor,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: updatePillBorder),
                                ),
                                child: Text(
                                  'Last updated May 27, 2026',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: primaryDeep,
                                  ),
                                ),
                              ),
                              SizedBox(height: compact ? 18 : 22),
                              ...List.generate(sections.length, (index) {
                                final section = sections[index];
                                final softTone = isTerms
                                    ? (index.isEven
                                        ? const Color(0xFFFFFCF8)
                                        : const Color(0xFFF8FAF4))
                                    : (index.isEven
                                        ? Colors.white
                                        : const Color(0xFFF8FCFA));
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == sections.length - 1
                                        ? 0
                                        : (compact ? 12 : 14),
                                  ),
                                  child: _LegalSectionCard(
                                    index: index,
                                    title: section.title,
                                    body: section.body,
                                    backgroundColor: softTone,
                                    compact: compact,
                                    variant: variant,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalSectionCard extends StatefulWidget {
  const _LegalSectionCard({
    required this.index,
    required this.title,
    required this.body,
    required this.backgroundColor,
    required this.compact,
    required this.variant,
  });

  final int index;
  final String title;
  final String body;
  final Color backgroundColor;
  final bool compact;
  final _LegalDocumentVariant variant;

  @override
  State<_LegalSectionCard> createState() => _LegalSectionCardState();
}

class _LegalSectionCardState extends State<_LegalSectionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const primaryDeep = Color(0xFF0B7D58);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF4D5A54);
    final isTerms = widget.variant == _LegalDocumentVariant.terms;
    final cardBorder = isTerms
        ? const Color(0xFFE9EDE3).withOpacity(0.95)
        : Colors.transparent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.992 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(widget.compact ? 16 : 18),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.compact ? 18 : 22),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(_pressed
                    ? (isTerms ? 0.075 : 0.05)
                    : (isTerms ? 0.05 : 0.035)),
                blurRadius:
                    _pressed ? (isTerms ? 20 : 18) : (isTerms ? 16 : 14),
                offset: Offset(0, _pressed ? 8 : 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isTerms
                                  ? const Color(0xFFF2F5E8)
                                  : const Color(0xFFE7F7F0))
                              .withOpacity(0.98),
                          (isTerms ? const Color(0xFFFFFBF4) : Colors.white)
                              .withOpacity(isTerms ? 0.96 : 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(isTerms ? 16 : 14),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(isTerms ? 0.11 : 0.08),
                          blurRadius: isTerms ? 14 : 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.index + 1}'.padLeft(2, '0'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.manrope(
                        fontSize: widget.compact ? 16.5 : 17.5,
                        fontWeight: isTerms ? FontWeight.w700 : FontWeight.w600,
                        height: 1.18,
                        letterSpacing: isTerms ? -0.22 : -0.15,
                        color: onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.body,
                style: GoogleFonts.inter(
                  fontSize: widget.compact ? 13.2 : 13.8,
                  fontWeight: FontWeight.w400,
                  height: isTerms ? 1.62 : 1.65,
                  color: onSurfaceVariant.withOpacity(isTerms ? 0.84 : 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceContainerHigh = Color(0xFFE6E8EA);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 64,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: background.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon:
                                  const Icon(Icons.arrow_back, color: primary),
                            ),
                            Text('Company Profile',
                                style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primary)),
                            const Spacer(),
                            _brandLogo(size: 28, radius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I-Metro Bus Profile',
                        style: GoogleFonts.manrope(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: onSurface),
                      ),
                      Text('2026',
                          style: GoogleFonts.manrope(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: primary)),
                      const SizedBox(height: 12),
                      Text(
                        'Inter-Metro Transport Solution Limited (I-Metro) is a privately owned, technology-driven urban mobility company headquartered in Abuja, Nigeria. We deploy clean-energy fleets, intelligent transport systems, and professionally managed operations aligned with international standards. I-Metro holds an active operational license issued by the FCTA Transport Secretariat with approval from the Office of the Honourable Minister of the FCT.',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: onSurfaceVariant, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6))
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                        const Icon(Icons.gavel, color: primary),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Vision',
                                      style: GoogleFonts.manrope(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: onSurface)),
                                  const SizedBox(height: 8),
                                  Text(
                                    "To become Nigeria's most trusted and innovative provider of sustainable, technology-enabled urban mobility solutions.",
                                    style: GoogleFonts.inter(
                                        fontSize: 12, color: onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text('Read vision',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: primary,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward,
                                          size: 16, color: primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.security,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Mission',
                                      style: GoogleFonts.manrope(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'To transform public transportation by deploying clean-energy fleets, smart technologies, and customer-centric services.',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.85)),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text('Read mission',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward,
                                          size: 16, color: Colors.white),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const _PolicySectionHeader(
                        index: '01',
                        title: 'Core Values',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Our operations are anchored on clear values that guide every decision and rider interaction:',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Values in Action',
                                style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface)),
                            const SizedBox(height: 12),
                            const _PolicyBullet(
                              text:
                                  'Safety - passenger and operational safety above all else.',
                            ),
                            const SizedBox(height: 8),
                            const _PolicyBullet(
                              text:
                                  'Integrity - transparent, accountable, and ethical operations.',
                            ),
                            const SizedBox(height: 8),
                            const _PolicyBullet(
                              text:
                                  'Innovation - continuous adoption of smart mobility solutions.',
                            ),
                            const SizedBox(height: 8),
                            const _PolicyBullet(
                              text:
                                  'Professionalism - global service standards and discipline.',
                            ),
                            const SizedBox(height: 8),
                            const _PolicyBullet(
                              text:
                                  'Sustainability - environmental responsibility and long-term impact.',
                            ),
                            const SizedBox(height: 8),
                            const _PolicyBullet(
                              text:
                                  'Customer Focus - reliable, dignified, and comfortable mobility.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _PolicySectionHeader(
                        index: '02',
                        title: 'Core Services',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Inter-Metro delivers an integrated portfolio of urban and institutional mobility solutions:',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PolicyBullet(
                              text: 'High-capacity CNG bus operations.'),
                          SizedBox(height: 8),
                          _PolicyBullet(
                              text:
                                  'Metered taxi services (first of its kind in Abuja).'),
                          SizedBox(height: 8),
                          _PolicyBullet(
                              text:
                                  'Fleet management partnerships for third-party vehicles.'),
                          SizedBox(height: 8),
                          _PolicyBullet(
                              text: 'Hire-purchase vehicle operations.'),
                          SizedBox(height: 8),
                          _PolicyBullet(
                              text:
                                  'Driver recruitment, training, and supervision.'),
                          SizedBox(height: 8),
                          _PolicyBullet(
                              text:
                                  'Route planning, scheduling, and cashless fare collection.'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: _PolicyMiniCard(
                              title: 'Fleet Partnerships',
                              body:
                                  'I-Metro manages daily operations, staffing, technology, monitoring, and reporting for partner-owned vehicles.',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _PolicyMiniCard(
                              title: 'Hire-Purchase',
                              body:
                                  'Vehicles are taken into service and paid for over time from operational proceeds with transparent oversight.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const _PolicySectionHeader(
                        index: '03',
                        title: 'Technology & Safety Infrastructure',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Operations are underpinned by a centralized, cloud-based mobility management system designed for transparency, efficiency, and safety.',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(
                              left: BorderSide(color: primary, width: 4)),
                        ),
                        child: Text(
                          'GPS-enabled real-time vehicle tracking\nOnboard CCTV with two-way monitoring\nCashless fare collection (POS, smart cards, validators)\nCentralized cloud-based fleet management platform',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                              height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Public sector & institutional partnerships include:',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.6,
                                color: onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          const _PolicyBullet(
                              text:
                                  'Presidential Compressed Natural Gas Initiative (P-CNGi).'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(
                              text:
                                  'Office of the Honourable Minister of the FCT.'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(
                              text: 'FCT Transport Secretariat and DRTS.'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(
                              text:
                                  'Federal Ministry of Transport and Environment.'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(
                              text:
                                  'AMAC, FRSC, and the Nigerian Police Force & NSCDC.'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: outlineVariant.withOpacity(0.2))),
                        ),
                        child: Column(
                          children: [
                            Text(
                                'Need more information? Call +234 912 806 6666.',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: onSurfaceVariant)),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.contactUs),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: primary.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6))
                                  ],
                                ),
                                child: Text('Contact I-Metro',
                                    style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('I-Metro Bus Profile - 2026',
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 2.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 30,
                          offset: const Offset(0, -8))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySectionHeader extends StatelessWidget {
  const _PolicySectionHeader({required this.index, required this.title});

  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const outlineVariant = Color(0xFFBDCAC0);
    return Row(
      children: [
        Text(index,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: primary)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Container(height: 1, color: outlineVariant.withOpacity(0.3))),
        const SizedBox(width: 12),
        Text(title,
            style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191C1E))),
      ],
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  const _PolicyBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontSize: 13, color: onSurfaceVariant, height: 1.4)),
        ),
      ],
    );
  }
}

class _PolicyMiniCard extends StatelessWidget {
  const _PolicyMiniCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
          const SizedBox(height: 8),
          Text(body,
              style: GoogleFonts.inter(
                  fontSize: 12, color: onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const inverseSurface = Color(0xFF2D3133);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F6F4);
    const surfaceSoft = Color(0xFFF8FBF9);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const tertiary = Color(0xFF9B403E);
    const tertiaryContainer = Color(0xFFBA5855);
    const tertiaryFixed = Color(0xFFFFDAD7);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      body: Stack(
        children: [
          const ProfileScreen(),
          Positioned(
            top: 90,
            right: -36,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(0.12),
                    primaryContainer.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: inverseSurface.withOpacity(0.34)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                decoration: BoxDecoration(
                  color: surfaceLowest,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 42,
                      spreadRadius: -10,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7E4DB),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: tertiaryFixed,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: tertiary.withOpacity(0.16),
                                blurRadius: 18,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: tertiary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Session Security',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Sign out safely',
                                style: GoogleFonts.manrope(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.35,
                                  color: onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'You are about to log out of your I-Metro account on this device. You will need to sign in again to access your bookings, tickets, and traveler profile.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        height: 1.5,
                        color: onSurfaceVariant.withOpacity(0.86),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceSoft,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.shield_outlined,
                                color: primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session note',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Logging out removes your active rider session from this device and protects your account if you are on a shared phone.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    height: 1.45,
                                    color: onSurfaceVariant.withOpacity(0.84),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await PushService.instance.unregister();
                          await AuthStore.clear();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.splash,
                            (route) => false,
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Ink(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [tertiary, tertiaryContainer],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: tertiary.withOpacity(0.2),
                                blurRadius: 18,
                                spreadRadius: -8,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Log out',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Ink(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Stay signed in',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'You can change your password anytime from Profile Settings.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          height: 1.45,
                          color: onSurfaceVariant.withOpacity(0.72),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppModeSelectorScreen extends StatelessWidget {
  const AppModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Choose Mode',
                style: GoogleFonts.manrope(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select how you want to continue in I-Metro.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _ModeTile(
                title: 'Rider',
                body: 'Book rides, manage tickets, and view travel history.',
                icon: Icons.person,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: 14),
              _ModeTile(
                title: 'Admin',
                body: 'Manage routes, users, support tickets, and operations.',
                icon: Icons.admin_panel_settings,
                onTap: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.adminLogin),
              ),
              const SizedBox(height: 24),
              Text(
                'Powered by I-Metro',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3ED),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF006B47)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF3E4942),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _sending = false;
  bool _resetting = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_sending) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your email address.';
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _sending = true;
      _message = null;
      _messageIsError = false;
    });
    try {
      final response = await AuthApi.requestPasswordReset(email: email);
      setState(() {
        final ok = response['ok'] == true;
        _messageIsError = !ok;
        _message = ok
            ? 'Reset code sent. Please check your inbox, spam, and promotions folders for the email before trying again.'
            : response['message']?.toString() ??
                'We could not send a reset code right now. Please try again later.';
      });
    } catch (_) {
      setState(() {
        _message = 'Could not send reset code. Please try again.';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_resetting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _resetting = true;
      _message = null;
      _messageIsError = false;
    });
    try {
      final response = await AuthApi.resetPassword(
        email: email,
        code: code,
        newPassword: password,
      );
      final ok = response['ok'] == true;
      setState(() {
        final success = ok;
        _messageIsError = !success;
        _message = ok
            ? 'Password updated successfully. Please sign in.'
            : response['message']?.toString() ??
                'Reset failed. Please check the code and try again.';
      });
      if (ok && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (_) {
      setState(() {
        _message = 'Password reset failed. Please try again.';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6FAFA);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const kineticEnd = Color(0xFF009B67);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -82,
            right: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kineticEnd.withOpacity(0.96), primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.08),
                    blurRadius: 86,
                    spreadRadius: 22,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -88,
            left: -72,
            child: Container(
              width: 172,
              height: 172,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.92),
                    kineticEnd.withOpacity(0.82),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.07),
                    blurRadius: 78,
                    spreadRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.white.withOpacity(0.86)),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.055),
                          blurRadius: 44,
                          offset: const Offset(0, 24),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _brandLogo(size: 42, radius: 13),
                              const SizedBox(width: 12),
                              Text(
                                'I-Metro',
                                style: GoogleFonts.manrope(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'Reset Password',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'We will send a reset code to your email. Enter it here with a new password to continue.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceVariant.withOpacity(0.82),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 26),
                          const _ForgotStepBadge(
                            label: 'Step 1',
                            title: 'Verify Email',
                          ),
                          const SizedBox(height: 16),
                          _ForgotPasswordField(
                            label: 'Email address',
                            hint: 'you@example.com',
                            icon: Icons.mail_outline,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.mark_email_unread_outlined,
                                  size: 15,
                                  color: onSurfaceVariant.withOpacity(0.72),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'We will send your reset code to this email. If you do not see it, check your spam or promotions folder.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: onSurfaceVariant.withOpacity(0.74),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ForgotPasswordActionButton(
                            label: 'Send Reset Code',
                            loading: _sending,
                            icon: Icons.arrow_forward,
                            onPressed: _sending ? null : _sendCode,
                          ),
                          const SizedBox(height: 16),
                          if (_message != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _messageIsError
                                    ? const Color(0xFFFFF6F5)
                                    : const Color(0xFFF7FBF9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _messageIsError
                                      ? const Color(0xFFE7C0BC)
                                      : outlineVariant.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _messageIsError
                                        ? Icons.error_outline
                                        : Icons.info_outline,
                                    color: _messageIsError
                                        ? const Color(0xFFB3261E)
                                        : primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _message!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: _messageIsError
                                            ? const Color(0xFF8C1D18)
                                            : onSurfaceVariant
                                                .withOpacity(0.88),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 28),
                          Container(
                            height: 1,
                            width: double.infinity,
                            color: outlineVariant.withOpacity(0.38),
                          ),
                          const SizedBox(height: 24),
                          const _ForgotStepBadge(
                            label: 'Step 2',
                            title: 'Reset Password',
                          ),
                          const SizedBox(height: 16),
                          _ForgotPasswordField(
                            label: 'Reset code',
                            hint: 'Enter reset code',
                            icon: Icons.pin_outlined,
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          _ForgotPasswordField(
                            label: 'New password',
                            hint: 'Enter new password',
                            icon: Icons.lock_outline,
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final input = value ?? '';
                              if (input.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _ForgotPasswordField(
                            label: 'Confirm password',
                            hint: 'Confirm new password',
                            icon: Icons.verified_user_outlined,
                            controller: _confirmPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              final input = value ?? '';
                              if (input != _passwordController.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _ForgotPasswordActionButton(
                            label: 'Reset Password',
                            loading: _resetting,
                            icon: Icons.check_circle_outline,
                            onPressed: _resetting ? null : _resetPassword,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: Text(
                                'Back to login',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                            ),
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
      ),
    );
  }
}
