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
      border: Border.all(color: const Color(0xFFBDCAC0).withOpacity(0.6), width: 1),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthStore.isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const primaryFixed = Color(0xFF8DF7C1);
    const onPrimaryFixed = Color(0xFF002113);
    const kineticStart = Color(0xFF006B47);
    const kineticEnd = Color(0xFF00875A);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDkuc151WaMen8WZwS50YmNU_W0OgUUBrTpi1BvJi9Gbwh-RszclYjFbqQHmfXmXoYCnmBdtWAs9fh12GJe9BRkmM15zq0HoKS-KHkQTMBtREjtjquFUxkzeDLuIs4CHVR9VjIb1z7nNRHqimdGZfSBoSu43q5QobqjrxZmlkCqqOIBP0iVyfHZXLG7lSSYNiAlIzHDrinligFWMXyc0sv649NAm0hLJ96ZYgQIHCXCzd_zTV8LtmGrITBgM77s4eIo_6iVfemOpA',
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.12),
                        colorBlendMode: BlendMode.darken,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              background,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(flex: 5, child: SizedBox()),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _brandLogo(size: 40, radius: 12),
                          const SizedBox(width: 8),
                          Text(
                            'I-Metro',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.help_outline, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryFixed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LUXURY IN MOTION',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: onPrimaryFixed,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Efficient, Safe,\nSmart Mobility',
                        style: GoogleFonts.manrope(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Clean-energy fleets, intelligent transport systems, and professional service for Abuja commuters.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(width: 32, height: 6, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(99))),
                          const SizedBox(width: 6),
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: outlineVariant, borderRadius: BorderRadius.circular(99))),
                          const SizedBox(width: 6),
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: outlineVariant, borderRadius: BorderRadius.circular(99))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          backgroundColor: kineticStart,
                          elevation: 0,
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => kineticStart,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Next', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          foregroundColor: onSurfaceVariant,
                        ),
                        child: Text('Skip', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  String? _submitError;

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
      await PushService.instance.initialize();
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      setState(() => _submitError = _loginErrorMessage(response));
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceContainerHigh = Color(0xFFE6E8EA);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const outline = Color(0xFF6E7A71);
    const outlineVariant = Color(0xFFBDCAC0);
    const primary = Color(0xFF006B47);
    const kineticStart = Color(0xFF006B47);
    const kineticEnd = Color(0xFF00875A);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [kineticStart, kineticEnd]),
                boxShadow: [BoxShadow(color: kineticStart.withOpacity(0.04), blurRadius: 120, spreadRadius: 40)],
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [kineticStart, kineticEnd]),
                boxShadow: [BoxShadow(color: kineticStart.withOpacity(0.04), blurRadius: 100, spreadRadius: 30)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _brandLogo(size: 40, radius: 12),
                          const SizedBox(width: 8),
                          Text(
                            'I-Metro',
                            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Luxury in Motion',
                        style: GoogleFonts.manrope(fontSize: 30, fontWeight: FontWeight.w700, color: onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to access clean-energy routes, cashless tickets, and real-time updates.',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceVariant, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                        decoration: BoxDecoration(
                          color: surfaceLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 32, offset: const Offset(0, 12))],
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email/phone',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _loginController,
                                  enabled: !_loading,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.username],
                                  onChanged: (_) => _clearSubmitError(),
                                  validator: (value) {
                                    final input = value?.trim() ?? '';
                                    if (input.isEmpty) {
                                      return 'Enter your email or phone number.';
                                    }
                                    if (input.contains('@')) {
                                      final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input);
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
                                    fillColor: surfaceContainerLow,
                                    prefixIcon: const Icon(Icons.alternate_email, color: outlineVariant),
                                    hintText: 'Enter your credentials',
                                    hintStyle: GoogleFonts.inter(fontSize: 14, color: outline.withOpacity(0.6)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
                                    ),
                                    errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PASSWORD',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.6,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(context, AppRoutes.contactUs),
                                      style: TextButton.styleFrom(
                                        foregroundColor: primary,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                      ),
                                      child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  enabled: !_loading,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
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
                                    fillColor: surfaceContainerLow,
                                    prefixIcon: const Icon(Icons.lock, color: outlineVariant),
                                    hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                                    hintStyle: GoogleFonts.inter(fontSize: 14, color: outline.withOpacity(0.6)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: outline),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                    errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (_submitError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE8E6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _submitError!,
                                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: _loading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: kineticStart,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_loading)
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                        ),
                                      if (_loading) const SizedBox(width: 8),
                                      Text(_loading ? 'Signing in...' : 'Login', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, color: Colors.white),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: Container(height: 1, color: surfaceContainerHigh)),
                                    const SizedBox(width: 12),
                                    Text(
                                      'SECURE CONNECTION',
                                      style: GoogleFonts.inter(fontSize: 10, color: outline, letterSpacing: 1.2),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Container(height: 1, color: surfaceContainerHigh)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
                            children: [
                              TextSpan(
                                text: 'Create account',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pushNamed(context, AppRoutes.createAccount),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.nfc, color: outlineVariant),
                          const SizedBox(width: 18),
                          Icon(Icons.contactless, color: outlineVariant),
                          const SizedBox(width: 18),
                          Icon(Icons.qr_code_2, color: outlineVariant),
                        ],
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
      await PushService.instance.initialize();
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      setState(() => _submitError = _registerErrorMessage(response));
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
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
                boxShadow: [BoxShadow(color: primary.withOpacity(0.05), blurRadius: 120, spreadRadius: 40)],
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
                boxShadow: [BoxShadow(color: const Color(0xFFDDE2F3).withOpacity(0.4), blurRadius: 90, spreadRadius: 30)],
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
                        style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: primary),
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
                                  style: GoogleFonts.manrope(fontSize: 34, fontWeight: FontWeight.w800, color: onSurface),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Journey',
                                    style: GoogleFonts.manrope(fontSize: 34, fontWeight: FontWeight.w800, color: primary),
                                    children: [
                                      TextSpan(
                                        text: '.',
                                        style: GoogleFonts.manrope(fontSize: 34, fontWeight: FontWeight.w800, color: onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your profile to access clean-energy routes, smart ticketing, and reliable city mobility.',
                                  style: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant, height: 1.5),
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
                              border: Border.all(color: outlineVariant.withOpacity(0.2)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 30, offset: const Offset(0, -8))],
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
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
                                          textCapitalization: TextCapitalization.words,
                                          enabled: !_loading,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [AutofillHints.givenName],
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
                                          textCapitalization: TextCapitalization.words,
                                          enabled: !_loading,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [AutofillHints.familyName],
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
                                    autofillHints: const [AutofillHints.telephoneNumber],
                                    validator: (value) {
                                      final input = (value ?? '').trim();
                                      if (input.isEmpty && _emailController.text.trim().isEmpty) {
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
                                      if (input.isEmpty && _phoneController.text.trim().isEmpty) {
                                        return 'Provide an email or phone number.';
                                      }
                                      if (input.isEmpty) {
                                        return null;
                                      }
                                      final emailOk = RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(input);
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
                                    onToggle: () => setState(() => _obscure = !_obscure),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: "By creating an account, I agree to I-Metro's ",
                                            style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                            children: [
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: primary),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () => Navigator.pushNamed(context, AppRoutes.policy),
                                              ),
                                              TextSpan(
                                                text: ' and ',
                                                style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant),
                                              ),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: primary),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () => Navigator.pushNamed(context, AppRoutes.policy),
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
                                      padding: const EdgeInsets.only(left: 8, top: 6),
                                      child: Text(
                                        'Accept the terms to continue.',
                                        style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  if (_submitError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE8E6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _submitError!,
                                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: _loading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_loading)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                          ),
                                        if (_loading) const SizedBox(width: 8),
                                        Text(
                                          _loading ? 'Creating...' : 'Create Account',
                                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.chevron_right, color: Colors.white),
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
                                style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: primary, decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.pushReplacementNamed(context, AppRoutes.login),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: onSurfaceVariant),
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
            prefixIcon: icon == null ? null : Icon(icon, color: outlineVariant.withOpacity(0.6)),
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: outline.withOpacity(0.4)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
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
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: onSurfaceVariant),
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
            prefixIcon: Icon(Icons.lock, color: outlineVariant.withOpacity(0.6)),
            hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: outline.withOpacity(0.4)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primary.withOpacity(0.2), width: 2),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: outline.withOpacity(0.6)),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent),
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
    _ticketRefreshSub = PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      if (!AuthStore.isLoggedIn) return;
      if (event.type == 'ticket_ready' || event.type == 'payment_confirmed' || event.type == 'booking_updated') {
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
        final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
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
    return AuthStore.isLoggedIn ? 'I-Metro rider' : 'Sign in to personalize your trips';
  }

  String _avatarInitials() {
    final parts = _fullName().split(' ').where((part) => part.isNotEmpty).toList();
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
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceContainerHighest = Color(0xFFE0E3E5);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const secondaryContainer = Color(0xFFDDE2F3);
    const tertiaryFixed = Color(0xFFFFDAD7);
    final greetingName = _displayName();
    final featuredRoute = _featuredRoute();
    final featuredFrom = featuredRoute?['fromLocation']?.toString() ?? 'Choose a route';
    final featuredTo = featuredRoute?['toLocation']?.toString() ?? 'Book your next trip';
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
                              icon: const Icon(Icons.menu, color: primary),
                            ),
                            _brandLogo(size: 28, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: primary)),
                            const Spacer(),
                            if (_loadingProfile)
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primary.withOpacity(0.6)),
                              )
                            else
                              IconButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                                icon: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(Icons.notifications, color: Color(0xFF9CA3AF)),
                                    if (hasAlerts)
                                      const Positioned(
                                        right: -1,
                                        top: -1,
                                        child: CircleAvatar(
                                          radius: 4,
                                          backgroundColor: Color(0xFFEF4444),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: surfaceLowest,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: outlineVariant.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 92),
                                      child: Text(
                                        fullName,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: onSurface),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [primary, primaryContainer]),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: avatarProvider == null
                                            ? Text(
                                                avatarInitials,
                                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
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
                child: (!ConnectivityService.instance.isOnline && AuthStore.isLoggedIn)
                    ? OfflineFullScreen(
                        onRetry: _retryHomeData,
                        title: 'Offline profile',
                        body: 'Reconnect to load your latest profile and stats.',
                      )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $greetingName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AuthStore.isLoggedIn ? profileDescriptor : 'Sign in to sync your routes, tickets, and profile.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      OfflineBanner(onRetry: _retryHomeData),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _HomeQuickAction(
                                  height: 160,
                                  title: 'Book Ride',
                                  icon: Icons.directions_bus,
                                  background: const LinearGradient(colors: [primary, primaryContainer]),
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                                  iconFilled: true,
                                  textColor: Colors.white,
                                  shadow: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _HomeQuickAction(
                                  height: 160,
                                  title: 'Scan Ticket',
                                  icon: Icons.qr_code_scanner,
                                  background: LinearGradient(colors: [surfaceLowest, surfaceLowest]),
                                  onTap: _openLatestTicket,
                                  iconColor: primary,
                                  textColor: onSurface,
                                  border: Border.all(color: outlineVariant.withOpacity(0.1)),
                                  shadow: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _HomeQuickAction(
                                  height: 128,
                                  title: 'History',
                                  icon: Icons.history,
                                  background: LinearGradient(colors: [surfaceContainerLow, surfaceContainerLow]),
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                                  iconColor: onSurfaceVariant,
                                  textColor: onSurface,
                                  compact: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _HomeQuickAction(
                                  height: 128,
                                  title: 'Profile',
                                  icon: Icons.person,
                                  background: LinearGradient(colors: [surfaceContainerLow, surfaceContainerLow]),
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                                  iconColor: onSurfaceVariant,
                                  textColor: onSurface,
                                  compact: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, primaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: primary.withOpacity(0.28), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -10,
                              child: Icon(Icons.route_rounded, size: 120, color: Colors.white.withOpacity(0.1)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF8DF7C1), borderRadius: BorderRadius.circular(4))),
                                    const SizedBox(width: 8),
                                    Text(
                                      _loadingRoutes ? 'SYNCING ROUTES' : 'FEATURED ROUTE',
                                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: Colors.white.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$featuredFrom -> $featuredTo',
                                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _loadingRoutes
                                      ? 'Refreshing active routes from the backend'
                                      : activeRoutesCount == 0
                                          ? 'No active routes yet. Check back after routes are published.'
                                          : '$featuredCurrency $featuredPrice fare - $activeRoutesCount active route${activeRoutesCount == 1 ? '' : 's'} available',
                                  style: GoogleFonts.inter(fontSize: 12, height: 1.45, color: Colors.white.withOpacity(0.86)),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _HomeSnapshotStat(
                                        label: 'Recent Trips',
                                        value: recentTripsCount.toString(),
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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  ),
                                  icon: const Icon(Icons.directions_bus_filled_outlined, size: 18),
                                  label: Text('Book this ride', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800)),
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
                          Text('Recently Traveled', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800)),
                          Row(
                            children: [
                              if (_loadingRecent)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: primary.withOpacity(0.7)),
                                  ),
                                ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                                child: Text('See All', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
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
                          body: 'Your completed rides and reusable ticket entries will appear here.',
                          actionLabel: 'Book a ride',
                          onAction: _openFeaturedRoute,
                        )
                      else
                        ..._recentBookings.asMap().entries.map((entry) {
                          final booking = entry.value;
                          final route = (booking['route'] as Map?) ?? {};
                          final payment = (booking['payment'] as Map?) ?? {};
                          final colorPack = entry.key.isEven
                              ? (
                                  bg: secondaryContainer,
                                  fg: const Color(0xFF5E6473),
                                  icon: Icons.apartment,
                                )
                              : (
                                  bg: tertiaryFixed,
                                  fg: const Color(0xFF7D2A2A),
                                  icon: Icons.park,
                                );
                          final from = route['fromLocation']?.toString() ?? 'Route';
                          final to = route['toLocation']?.toString() ?? 'Destination';
                          final currency = payment['currency']?.toString() ?? route['currency']?.toString() ?? 'NGN';
                          final amount = payment['amount'] ?? route['price'] ?? '-';
                          return Padding(
                            padding: EdgeInsets.only(bottom: entry.key == _recentBookings.length - 1 ? 0 : 12),
                            child: _RecentRouteCard(
                              title: from,
                              subtitle: _recentSubtitleDisplay(booking),
                              price: '$currency $amount',
                              icon: colorPack.icon,
                              iconBackground: colorPack.bg,
                              iconColor: colorPack.fg,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.ticketDetails,
                                arguments: {'bookingId': booking['id']?.toString()},
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceLowest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: outlineVariant.withOpacity(0.12)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))],
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
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.insights_rounded, color: primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Transit Snapshot', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: onSurface)),
                                      const SizedBox(height: 4),
                                      Text('Live overview based on your routes and booking history.', style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: onSurfaceVariant)),
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
                                    icon: Icons.confirmation_number_outlined,
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
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
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
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
    required this.height,
    required this.title,
    required this.icon,
    required this.background,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.border,
    this.shadow = false,
    this.compact = false,
    this.iconFilled = false,
  });

  final double height;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: background,
          borderRadius: BorderRadius.circular(24),
          border: border,
          boxShadow: shadow ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: compact ? 24 : 32,
              color: iconColor ?? Colors.white,
            ),
            Text(
              title,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: compact ? 16 : 18,
                fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
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
              fontWeight: FontWeight.w800,
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
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: onSurface),
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasTrips ? primary.withOpacity(0.14) : tertiary.withOpacity(0.12),
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
                  hasTrips ? 'Latest destination' : 'Latest destination pending',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  destination,
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: onSurface),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outlineVariant.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(24)),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: onSurface)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: primary)),
                const SizedBox(height: 2),
                Icon(onTap == null ? Icons.remove : Icons.chevron_right, color: onSurfaceVariant, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavPill extends StatelessWidget {
  const _BottomNavPill({required this.label, required this.icon, this.active = false, required this.onTap});

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const inactive = Color(0xFF9CA3AF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
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
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: active ? primary : inactive,
              ),
            ),
          ],
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

  bool _containsRoute(List<Map<String, dynamic>> routes, Map<String, dynamic>? route) {
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
      final chipMatch = _originChip != null && _originChip!.toLowerCase() == trimmed.toLowerCase();
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
      final message = response['message']?.toString() ?? response['reason']?.toString() ?? 'Unable to start payment.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const hintGrey = Color(0xFF9AA3A0);
    final filteredRoutes = _filteredRoutes();

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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: primary),
                            ),
                            Text('Book a Ride', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
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
                    : (!ConnectivityService.instance.isOnline && _routes.isEmpty)
                        ? OfflineFullScreen(
                            onRetry: _loadRoutes,
                            title: 'No connection',
                            body: 'Connect to the internet to load available routes.',
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Choose your route', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: onSurface)),
                                const SizedBox(height: 6),
                                Text('Select a route and continue to payment.', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                                const SizedBox(height: 12),
                                OfflineBanner(onRetry: _loadRoutes),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      _PaymentChoiceChip(
                                        label: 'Monnify',
                                        active: _provider == 'MONNIFY',
                                        onTap: () => setState(() => _provider = 'MONNIFY'),
                                      ),
                                      const SizedBox(width: 8),
                                      _PaymentChoiceChip(
                                        label: 'Paystack',
                                        active: _provider == 'PAYSTACK',
                                        onTap: () => setState(() => _provider = 'PAYSTACK'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: surfaceLowest,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: outlineVariant.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, color: hintGrey, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                          style: GoogleFonts.inter(fontSize: 13, color: onSurface),
                                          decoration: InputDecoration(
                                            hintText: 'Search route',
                                            hintStyle: GoogleFonts.inter(fontSize: 13, color: hintGrey),
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
                                          icon: const Icon(Icons.close_rounded, size: 18, color: hintGrey),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_searchQuery.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Showing ${filteredRoutes.length} result${filteredRoutes.length == 1 ? '' : 's'} for "${_searchQuery.trim()}"',
                                          style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _applySearch('');
                                          },
                                          child: Text('Clear', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: primary)),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_routes.isNotEmpty && _originChips().isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Popular origins',
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: onSurfaceVariant),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
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
                                          final active = _originChip?.toLowerCase() == origin.toLowerCase();
                                          return _RouteOriginChip(
                                            label: origin,
                                            active: active,
                                            onTap: () {
                                              if (active) {
                                                _searchController.clear();
                                                _applySearch('');
                                              } else {
                                                _searchController.text = origin;
                                                _applySearch(origin, chip: origin);
                                              }
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_routes.isEmpty)
                                  _EmptyStateCard(
                                    icon: Icons.route_outlined,
                                    title: 'No routes yet',
                                    body: 'Routes will appear here once they are published.',
                                    actionLabel: 'Refresh',
                                    onAction: _loadRoutes,
                                  )
                                else if (filteredRoutes.isEmpty)
                                  _EmptyStateCard(
                                    icon: Icons.search_off,
                                    title: 'No matches',
                                    body: 'No routes match "${_searchQuery.trim()}". Try another search.',
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
                                      final isSelected = _selected?['id'] == route['id'];
                                      return GestureDetector(
                                        onTap: () => _selectRoute(route),
                                        child: _RouteOptionCard(
                                          from: route['fromLocation']?.toString() ?? 'From',
                                          to: route['toLocation']?.toString() ?? 'To',
                                          price: 'NGN ${route['price'] ?? '-'}',
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
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [primary, primaryContainer]),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_submitting)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                          )
                                        else
                                          const Icon(Icons.credit_card, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          _submitting ? 'Processing...' : 'Proceed to Payment',
                                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        active: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? primary : primary.withOpacity(0.1), width: selected ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.place, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$from -> $to', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
                const SizedBox(height: 4),
                Text('One-way ticket', style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
              ],
            ),
          ),
          Text(price, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: onSurface)),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primary.withOpacity(0.15)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
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
        const SnackBar(content: Text('Unable to open checkout automatically on this device.')),
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
      final status = response['status']?.toString() ?? response['reason']?.toString();
      final message = status == null || status.isEmpty
          ? 'We are still waiting for confirmation. If you just paid, wait 15-30 seconds and tap Verify again.'
          : 'Still pending: $status. If you just paid, wait 15-30 seconds and tap Verify again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF006B47);
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Colors.white;
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    const onSurface = Color(0xFF191C1E);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        backgroundColor: primary,
        actions: [
          TextButton(
            onPressed: _verifying ? null : _verifyPayment,
            child: Text(
              _verifying ? 'Checking...' : 'Verify',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withOpacity(0.08)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))],
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
                  child: const Icon(Icons.lock_clock_outlined, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Finish checkout, then verify', style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF191C1E))),
                      const SizedBox(height: 4),
                      Text(
                        'Once payment succeeds, return here and tap Verify to load your ticket QR instantly.',
                        style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _CheckoutStepBadge(label: '1. Open checkout', color: primary),
                          _CheckoutStepBadge(label: '2. Pay', color: primary),
                          _CheckoutStepBadge(label: '3. Verify', color: primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: kIsWeb
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: surfaceContainerLow),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.open_in_new_rounded, color: primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Open checkout in a new tab',
                            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: onSurface),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chrome cannot show the in-app payment window, so we open your secure checkout page in a browser tab instead.',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: onSurfaceVariant),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SelectableText(
                              widget.checkoutUrl,
                              style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _openCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              icon: const Icon(Icons.launch_rounded),
                              label: Text(
                                _openedInBrowser ? 'Open checkout again' : 'Open secure checkout',
                                style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'When payment is complete, return here and tap Verify to unlock your ticket.',
                            style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : WebViewWidget(controller: _controller!),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, -6))],
          ),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _verifying ? null : _verifyPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: _verifying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.verified_outlined),
              label: Text(
                _verifying ? 'Checking payment...' : 'Verify payment',
                style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
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
  State<TicketDetailsLoaderScreen> createState() => _TicketDetailsLoaderScreenState();
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
      _ticketRefreshSub = PushService.instance.ticketRefreshStream.listen((event) {
        if (!mounted) return;
        final matchesBooking = widget.bookingId != null && event.bookingId == widget.bookingId;
        final matchesPayment = widget.paymentReference != null && event.paymentReference == widget.paymentReference;
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
      _lastPaymentStatus = data['paymentStatus']?.toString() ?? payment['status']?.toString();
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
      return (widget.paymentReference?.isNotEmpty ?? false) || (_lastBookingId?.isNotEmpty ?? false);
    }

    void _ensureAutoRefresh() {
      if (_autoRefreshTimer != null) return;
      _autoRefreshAttempts = 0;
      _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (timer) {
        if (!mounted) {
          _stopAutoRefresh();
          return;
        }
        if (_autoRefreshAttempts >= _autoRefreshMaxAttempts || !_shouldAutoRefresh()) {
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
      } else if (widget.paymentReference != null && widget.paymentReference!.isNotEmpty) {
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
      'paymentReference': payment['providerRef']?.toString() ?? widget.paymentReference,
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
            return Center(child: Text('Unable to load ticket details'));
          }
          final booking = data['booking'] as Map;
          final route = booking['route'] as Map? ?? {};
          final payment = booking['payment'] as Map? ?? {};
          final ticket = booking['ticket'] as Map? ?? {};
            final qr = data['qr']?.toString();
            final bookingId = booking['id']?.toString();
            final paymentStatus = data['paymentStatus']?.toString() ?? payment['status']?.toString();
            final paymentRef = data['paymentReference']?.toString() ?? widget.paymentReference;
            final paymentProvider = (payment['provider']?.toString() ?? widget.provider).toUpperCase();
            final showRetry = (qr == null || qr.isEmpty) && (paymentStatus?.toUpperCase() != 'SUCCESS');
            final fromLocation = route['fromLocation']?.toString() ?? 'From';
            final toLocation = route['toLocation']?.toString() ?? 'To';
          final fareLabel = 'NGN ${payment['amount'] ?? route['price'] ?? '-'}';
          final reference = payment['providerRef']?.toString() ?? widget.paymentReference ?? '-';
          final createdAt = booking['createdAt']?.toString();
          final date = createdAt != null ? DateTime.tryParse(createdAt) : null;
          final dateLabel = date != null ? '${date.day}-${date.month}-${date.year}' : '-';
          final timeLabel = date != null ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}' : '-';

          return TicketDetailsScreen(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fromCode: fromLocation.isNotEmpty ? fromLocation[0].toUpperCase() : 'F',
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
                      if (response['ok'] == true && response['checkoutUrl'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentWebViewScreen(
                              checkoutUrl: response['checkoutUrl'].toString(),
                              paymentReference: response['paymentReference']?.toString(),
                              bookingId: response['bookingId']?.toString() ?? bookingId,
                              provider: paymentProvider == 'PAYSTACK' ? 'PAYSTACK' : 'MONNIFY',
                            ),
                          ),
                        );
                      } else {
                      final message = response['message']?.toString() ??
                          response['reason']?.toString() ??
                          'Unable to restart payment.';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    const background = Color(0xFFF7F9FB);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const outlineVariant = Color(0xFFBDCAC0);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Ticket Details'),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await onRefresh?.call();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSuccess)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primary.withOpacity(0.2)),
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
                      child: const Icon(Icons.check_circle_rounded, color: primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payment confirmed', style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: onSurface)),
                          const SizedBox(height: 4),
                          Text(
                            (qrPayload == null || qrPayload!.isEmpty)
                                ? 'Your ticket is being issued. Pull to refresh if it does not appear.'
                                : 'Your ticket is ready. Present this QR at the validator gate.',
                            style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: onSurfaceVariant),
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
                gradient: const LinearGradient(colors: [primary, primaryContainer]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _TicketLocationBox(code: fromCode, label: fromLocation),
                  const SizedBox(width: 16),
                  const Icon(Icons.swap_horiz, color: Colors.white),
                  const SizedBox(width: 16),
                  _TicketLocationBox(code: toCode, label: toLocation),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _TicketInfoItem(label: 'Date', value: dateLabel)),
                Expanded(child: _TicketInfoItem(label: 'Time', value: timeLabel, alignEnd: true)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _TicketInfoItem(label: 'Fare', value: fareLabel)),
                Expanded(child: _TicketInfoItem(label: 'Reference', value: reference, alignEnd: true)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineVariant.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_scanner_rounded, size: 18, color: primary),
                            const SizedBox(width: 8),
                            Text(
                              qrPayload == null || qrPayload!.isEmpty ? 'QR pending' : 'Ready to scan',
                              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: primary),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (ticketId != null)
                        Text(
                          'ID ${ticketId!.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: onSurfaceVariant),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Present this code at the validator gate for one-time entry.', style: GoogleFonts.inter(fontSize: 13, height: 1.45, color: onSurfaceVariant)),
                    const SizedBox(height: 18),
                    Center(child: _TicketQrBox(qrPayload: qrPayload)),
                    if (qrPayload != null && qrPayload!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: qrPayload!));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('QR payload copied')),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.copy_rounded, color: primary),
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
                    if ((qrPayload == null || qrPayload!.isEmpty) && paymentStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Payment status: ${paymentStatus!.toLowerCase()}. Tap refresh after payment completes.',
                        style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant.withOpacity(0.8)),
                      ),
                    ),
                  if ((qrPayload == null || qrPayload!.isEmpty) && onRetryPayment != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: retryingPayment ? null : onRetryPayment,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary.withOpacity(0.6)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: retryingPayment
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded, color: primary),
                          label: Text(
                            retryingPayment ? 'Restarting payment...' : 'Retry payment',
                            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: primary),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outlineVariant.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ticket reference', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: onSurfaceVariant)),
                        const SizedBox(height: 6),
                        SelectableText(reference, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: onSurface)),
                        if (ticketId != null) ...[
                          const SizedBox(height: 12),
                          Text('Ticket ID', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: onSurfaceVariant)),
                          const SizedBox(height: 6),
                          SelectableText(ticketId!, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: onSurface)),
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
          Text(code, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8))),
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
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w700, color: onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                    style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
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
                    style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Icon(Icons.hourglass_top_rounded, color: onSurfaceVariant.withOpacity(0.6), size: 34),
              const SizedBox(height: 10),
              Text('Ticket pending', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                'If you completed payment, tap refresh to load your QR.',
                style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant.withOpacity(0.8)),
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
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF006B47)),
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
  TicketCard({
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
        boxShadow: [BoxShadow(color: cardStart.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: accentBlue),
              const SizedBox(width: 6),
              Expanded(child: Text(from, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.flag, size: 16, color: accentBlue),
              const SizedBox(width: 6),
              Expanded(child: Text(to, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 12),
          Text(price, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
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
                            children: const [
                              Text(
                                'Abuja, Nigeria',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
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
                      const Text(
                        'Welcome, Daniel',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
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
                          children: const [
                            SizedBox(width: 14),
                            Icon(Icons.search, color: hintGrey),
                            SizedBox(width: 10),
                            Text(
                              'Search route',
                              style: TextStyle(color: hintGrey, fontSize: 14),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _IndicatorDot(isActive: true),
                          _IndicatorDot(isActive: false),
                          _IndicatorDot(isActive: false),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
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
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
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
                    onTap: () => Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
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
    _ticketRefreshSub = PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      if (!AuthStore.isLoggedIn || AuthStore.userId == null) return;
      if (event.type == 'ticket_ready' || event.type == 'payment_confirmed' || event.type == 'booking_updated') {
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
      final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
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
    if (provider != 'MONIEPOINT' && provider != 'MONNIFY' && provider != 'PAYSTACK') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retry is not supported for this payment provider yet.')),
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
      final message = response['message']?.toString() ?? response['reason']?.toString() ?? 'Unable to restart payment.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

  List<Map<String, dynamic>> _filteredBookings(List<Map<String, dynamic>> bookings) {
    switch (_selectedFilter) {
      case _HistoryFilter.confirmed:
        return bookings.where(_isConfirmedBooking).toList();
      case _HistoryFilter.pending:
        return bookings.where((booking) => !_isConfirmedBooking(booking)).toList();
      case _HistoryFilter.tickets:
        return bookings.where(_hasTicket).toList();
      case _HistoryFilter.all:
        return bookings;
    }
  }

  String _filterLabel(_HistoryFilter filter, List<Map<String, dynamic>> bookings) {
    final count = switch (filter) {
      _HistoryFilter.all => bookings.length,
      _HistoryFilter.confirmed => bookings.where(_isConfirmedBooking).length,
      _HistoryFilter.pending => bookings.where((booking) => !_isConfirmedBooking(booking)).length,
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
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceContainerHigh = Color(0xFFE6E8EA);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const primaryContainer = Color(0xFF00875A);
    const tertiary = Color(0xFF9B403E);

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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
                              icon: const Icon(Icons.menu, color: primary),
                            ),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: primary)),
                            const Spacer(),
                            Text('History', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primary.withOpacity(0.1), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDYwvb0dFRscbrfaw_oh1AbVJAECq7rNIenjGAn35PoaMy_s5KBzAgCejnPmJWFMhSbwLiU5ECwnUNIPVH8iylObIOiuJMKWRdw46UINGfQRzReOji5rPVZd-yIDuTH05DA4U2vPeMQvjMqwAE9_YpKwqmXzGrcPslny8fL_gHzVFp5nRFEHNipjaUPezkp5Pc4GBnPNgCoT_BPnKMem8Jm3qdZOcZMvgeqCk8cHooAVrGMsKo_mgmpNyEkpktZ8t4RKOyP3z8iqQ',
                                  fit: BoxFit.cover,
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
                child: (!ConnectivityService.instance.isOnline && _bookingsFuture != null)
                    ? OfflineFullScreen(
                        onRetry: _refreshBookings,
                        title: 'Offline history',
                        body: 'Reconnect to load your latest trips and tickets.',
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trip History', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface)),
                            const SizedBox(height: 6),
                            Text('Review your past travels and expenses.', style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant)),
                            const SizedBox(height: 12),
                            OfflineBanner(onRetry: _refreshBookings),
                            const SizedBox(height: 16),
                            if (_bookingsFuture == null)
                              _EmptyStateCard(
                                icon: Icons.lock_outline,
                                title: 'Sign in to view history',
                                body: 'Your rides, payments, and tickets will appear here.',
                                actionLabel: 'Sign in',
                                onAction: () => Navigator.pushNamed(context, AppRoutes.login),
                              ),
                            if (_bookingsFuture != null)
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _bookingsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: CircularProgressIndicator(color: primary.withOpacity(0.8)),
                                      ),
                                    );
                                  }
                                  final bookings = snapshot.data ?? [];
                                  final filteredBookings = _filteredBookings(bookings);
                                  if (bookings.isEmpty) {
                                    return _EmptyStateCard(
                                      icon: Icons.history,
                                      title: 'No trips yet',
                                      body: 'Book your first ride to start building your travel history.',
                                      actionLabel: 'Book a ride',
                                      onAction: () => Navigator.pushNamed(context, AppRoutes.booking),
                                    );
                                  }

                                  int totalTrips = 0;
                                  int totalSpent = 0;
                                  String summaryCurrency = 'NGN';

                                  final cards = filteredBookings.map((booking) {
                                    final route = (booking['route'] as Map?) ?? {};
                                    final payment = (booking['payment'] as Map?) ?? {};
                                    final paymentStatus = payment['status']?.toString().toUpperCase() ?? '';
                                    final provider = payment['provider']?.toString().toUpperCase() ?? '';
                                    final ticket = booking['ticket'];
                                    final hasTicket = ticket is Map && ticket.isNotEmpty;
                                    final showRetry = !hasTicket && paymentStatus != 'SUCCESS';
                                    final from = route['fromLocation']?.toString() ?? 'Route';
                                    final to = route['toLocation']?.toString() ?? 'Destination';
                                    final currency = payment['currency']?.toString() ?? route['currency']?.toString() ?? 'NGN';
                                    final amountRaw = payment['amount'] ?? route['price'] ?? 0;
                                    final amount = amountRaw is num ? amountRaw.toInt() : int.tryParse(amountRaw.toString()) ?? 0;
                                    final status = booking['status']?.toString() ?? 'Completed';
                                    final statusColor = status.toUpperCase() == 'CONFIRMED' ? primary : tertiary;
                                    final dateSource = booking['travelDate'] ?? booking['createdAt'];
                                    final bookingId = booking['id']?.toString();

                                    totalTrips += 1;
                                    totalSpent += amount;
                                    if (summaryCurrency == 'NGN' && currency.isNotEmpty) {
                                      summaryCurrency = currency;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _HistoryTripCard(
                                        date: _formatDate(dateSource),
                                        title: from,
                                        destination: to,
                                        price: '$currency $amount',
                                        status: status,
                                        statusColor: statusColor,
                                        icon: Icons.subway,
                                        iconGradient: LinearGradient(colors: [primary, primaryContainer]),
                                        lineColor: primary,
                                        onTap: bookingId == null
                                            ? null
                                            : () => Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.ticketDetails,
                                                  arguments: {'bookingId': bookingId},
                                                ),
                                        showRetry: showRetry,
                                        retrying: _retryingBookingId == bookingId,
                                        onRetry: bookingId == null ? null : () => _retryPayment(bookingId, provider),
                                      ),
                                    );
                                  }).toList();

                            return Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _HistoryChip(
                                        label: _filterLabel(_HistoryFilter.all, bookings),
                                        active: _selectedFilter == _HistoryFilter.all,
                                        onTap: () => setState(() => _selectedFilter = _HistoryFilter.all),
                                      ),
                                      _HistoryChip(
                                        label: _filterLabel(_HistoryFilter.confirmed, bookings),
                                        active: _selectedFilter == _HistoryFilter.confirmed,
                                        onTap: () => setState(() => _selectedFilter = _HistoryFilter.confirmed),
                                      ),
                                      _HistoryChip(
                                        label: _filterLabel(_HistoryFilter.pending, bookings),
                                        active: _selectedFilter == _HistoryFilter.pending,
                                        onTap: () => setState(() => _selectedFilter = _HistoryFilter.pending),
                                      ),
                                      _HistoryChip(
                                        label: _filterLabel(_HistoryFilter.tickets, bookings),
                                        active: _selectedFilter == _HistoryFilter.tickets,
                                        onTap: () => setState(() => _selectedFilter = _HistoryFilter.tickets),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setState(() => _bookingsFuture = _loadBookings()),
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text('Refresh', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                                    style: TextButton.styleFrom(foregroundColor: primary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (filteredBookings.isEmpty)
                                  _EmptyStateCard(
                                    icon: Icons.filter_alt_off,
                                    title: 'No rides for this filter',
                                    body: 'Try a different filter or reset to view all rides.',
                                    actionLabel: 'Show all',
                                    onAction: () => setState(() => _selectedFilter = _HistoryFilter.all),
                                  ),
                                if (filteredBookings.isEmpty) const SizedBox(height: 12),
                                ...cards,
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [primary, primaryContainer]),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: -8,
                                        bottom: -8,
                                        child: Icon(Icons.analytics, size: 120, color: Colors.white.withOpacity(0.1)),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Monthly Summary', style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                          const SizedBox(height: 6),
                                          Text('YOUR RIDES THIS MONTH', style: GoogleFonts.inter(fontSize: 11, letterSpacing: 2.2, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _HistorySummaryStat(label: 'Trips', value: totalTrips.toString()),
                                              _HistorySummaryStat(label: 'Spent', value: '$summaryCurrency $totalSpent'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
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
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
    const surfaceContainerLow = Color(0xFFF2F4F6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? primary : surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
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
    const surfaceContainerLow = Color(0xFFF2F4F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? primary : surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
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
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
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
                    color: iconGradient == null ? iconBackground ?? surfaceContainerLow : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconGradient == null ? onSurfaceVariant : Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: statusColor)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(status == 'Canceled' ? Icons.cancel : Icons.check_circle, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                      ],
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
                        side: BorderSide(color: lineColor.withOpacity(0.6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: retrying
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh_rounded, color: lineColor, size: 16),
                      label: Text(
                        retrying ? 'Restarting...' : 'Retry payment',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: lineColor),
                      ),
                    ),
                  const Spacer(),
                  if (onTap != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Open ticket', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: lineColor)),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: lineColor, size: 18),
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
          child: Text(
            destination,
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface.withOpacity(0.6)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.4, color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
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
                Text(label, style: GoogleFonts.inter(fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(value, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: onSurface)),
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
          border: Border.all(color: outlineVariant.withOpacity(enabled ? 0.35 : 0.2)),
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
                        color: onSurfaceVariant.withOpacity(enabled ? 0.85 : 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (enabled) Icon(Icons.chevron_right, color: onSurfaceVariant),
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
      await AuthApi.getMe();
      final bookings = await UserApi.listBookingsForUser(AuthStore.userId!);
      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));
      int monthTotal = 0;
      for (final booking in bookings) {
        int amount = 0;
        final payment = booking['payment'];
        if (payment is Map && payment['amount'] is num) {
          amount = (payment['amount'] as num).round();
        } else {
          final route = booking['route'];
          if (route is Map && route['price'] is num) {
            amount = (route['price'] as num).round();
          }
        }
        final createdRaw = booking['createdAt']?.toString();
        final createdAt = createdRaw != null ? DateTime.tryParse(createdRaw) : null;
        if (createdAt == null || createdAt.isBefore(monthAgo)) {
          continue;
        }
        monthTotal += amount;
      }
      setState(() {
        _rideCount = bookings.length;
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
    return AuthStore.isLoggedIn ? 'Update your email in profile settings' : 'Sign in to view profile';
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
        final hasAvatar = AuthStore.avatarUrl != null && AuthStore.avatarUrl!.trim().isNotEmpty;
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
                  title: Text('Upload photo', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar();
                  },
                ),
                if (hasAvatar)
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text('Remove photo', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
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

    final nameText = _loading ? 'Loading...' : _displayName();
    final emailText = _loading ? 'Fetching profile...' : _displayEmail();
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
                              icon: const Icon(Icons.menu, color: primary),
                            ),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primaryContainer, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: avatarProvider == null
                                    ? Container(
                                        color: primary.withOpacity(0.12),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: primary),
                                        ),
                                      )
                                    : Image(image: avatarProvider, fit: BoxFit.cover),
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
                                gradient: const LinearGradient(colors: [primary, primaryContainer]),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: avatarProvider == null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [primary.withOpacity(0.2), primaryContainer.withOpacity(0.25)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, color: primary),
                                        ),
                                      )
                                    : Image(image: avatarProvider, fit: BoxFit.cover),
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
                                  border: Border.all(color: outlineVariant.withOpacity(0.5)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: _uploadingAvatar
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.camera_alt_outlined, size: 18, color: primary),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -6,
                            bottom: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: memberColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: memberColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 6))],
                                border: Border.all(color: background, width: 4),
                              ),
                              child: Text(
                                memberLabel,
                                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(nameText, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface)),
                      const SizedBox(height: 6),
                      Text(emailText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                      const SizedBox(height: 12),
                      OfflineBanner(onRetry: _loadProfile),
                      if (_avatarError != null) ...[
                        const SizedBox(height: 8),
                        Text(_avatarError!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _loadProfile,
                          child: Text('Retry', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                        ),
                      ],
                      if (!AuthStore.isLoggedIn) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                            ),
                            child: Center(
                              child: Text(
                                'Sign in to view full profile',
                                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
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
                              label: 'Total Rides',
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
                            style: GoogleFonts.inter(fontSize: 10, letterSpacing: 3.2, fontWeight: FontWeight.w700, color: onSurfaceVariant),
                          ),
                        ),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        subtitle: 'Name, email, and phone',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profileSettings),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.payments_outlined,
                        label: 'Payment Methods',
                        subtitle: 'Manage cards (coming soon)',
                      ),
                      _ProfileSettingItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        subtitle: 'Notifications and preferences',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profileSettings),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.shield_outlined,
                        label: 'Security',
                        subtitle: 'Change password',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                      ),
                      _ProfileSettingItem(
                        icon: Icons.help_outline,
                        label: 'Support',
                        subtitle: 'Contact the I-Metro team',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: outlineVariant.withOpacity(0.4)),
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
                              child: const Icon(Icons.warning_amber_rounded, color: primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ticket Expiry Reminder', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tickets are valid for the day of purchase. Please complete your trip before midnight.',
                                    style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant),
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
                          style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.logout),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: error,
                              side: BorderSide(color: error.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: Text('Log out of I-Metro', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
  bool _pushAvailable = const bool.fromEnvironment('ENABLE_FCM', defaultValue: false);
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
      _firstNameController.text = user['firstName']?.toString() ?? AuthStore.firstName ?? '';
      _lastNameController.text = user['lastName']?.toString() ?? AuthStore.lastName ?? '';
      _emailController.text = user['email']?.toString() ?? AuthStore.email ?? '';
      _phoneController.text = user['phone']?.toString() ?? AuthStore.phone ?? '';
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
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
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
    final enabled = status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional;
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
          const SnackBar(content: Text('Notifications are blocked for this device.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to request notification permissions.')),
      );
    }
    if (!mounted) return;
    setState(() => _pushLoading = false);
  }

  String _lastUpdatedLabel() {
    if (_lastUpdated == null) {
      return 'Last updated on -';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final date = _lastUpdated!;
    return 'Last updated on ${months[date.month - 1]} ${date.day}, ${date.year}';
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
      final message = response['message']?.toString() ?? response['reason']?.toString() ?? 'Unable to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    setState(() => _saving = false);
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

    final canSave = AuthStore.isLoggedIn && !_saving && !_loading;

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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
                              icon: const Icon(Icons.menu, color: primary),
                            ),
                            _brandLogo(size: 26, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primary.withOpacity(0.2), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCqOMZl9d8pL2f8PZbVT09IDg0BdrbYq8Kf_jd1qHcUA3pAaquJ4D_UWPcdYxv74nPbBEEwqRsRV-ucxSFBQnY8fKBiV_Gqd8TRTKV8UWf93HXaM_FecSAtuh4JlbjMdvUHZdWYoDh7MNT0RE2z6a1TXaULO4i5JakJSJRgj4DltECEl6rzknCvIgMKa44ugcnKZ0U2M0N9Toy1m0p3kLBRF_vR2ptY4qMtnaz-w00vEhiGog0hYAlIyNplhVX_v8dohqRLGng8ag',
                                  fit: BoxFit.cover,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCTdOkMaBLSzaxP9LGh6fe4ked8e4JDNo_xooO_m3_iqlUwMm9oEzzk-SjmyiU3OWCnXwxGVP2NfojnifjXIzOweycjjXejBltyWZskuvJlz0Ypi0RU-wyqOE5QLqpTrCpIO2zXoPPxGKaYUjFxF9Tk3mkJF85IhR3aCjzlaAfGbMcoZk8j8mfEycbdsy7J9-9DrbYLfPLLbCIDQQjlPLtpfS0F2PUfZDfDBA3SzJ4zAvRB20IHa4tlB0CU2wmdRSuYmuS_iIxBxw',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Profile Settings', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface)),
                            const SizedBox(height: 6),
                            Text('Update your traveler profile and contact details', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                          ],
                        ),
                      ),
                      if (!AuthStore.isLoggedIn) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: outlineVariant.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text('Sign in to edit your profile details.', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                                child: Text('Go to Login', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
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
                          const SizedBox(width: 16),
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
                      const SizedBox(height: 16),
                      _ProfileInputCard(
                        label: 'Email Address',
                        value: 'Email address',
                        controller: _emailController,
                        enabled: AuthStore.isLoggedIn,
                        trailing: Icon(Icons.verified, color: primary, size: 20),
                      ),
                      const SizedBox(height: 16),
                      _ProfileInputCard(
                        label: 'Phone Number',
                        value: 'Phone number',
                        controller: _phoneController,
                        enabled: AuthStore.isLoggedIn,
                        prefix: '+234',
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text('ACCOUNT PREFERENCES', style: GoogleFonts.inter(fontSize: 11, letterSpacing: 2.4, fontWeight: FontWeight.w700, color: onSurfaceVariant)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            _PushPermissionCard(
                              enabled: _pushEnabled,
                              available: _pushAvailable,
                              loading: _pushLoading,
                              statusLabel: _pushStatusLabel,
                              loggedIn: AuthStore.isLoggedIn,
                              onRequest: _requestPushPermission,
                            ),
                            const _PreferenceToggle(
                              icon: Icons.location_on,
                              title: 'Smart Suggestions',
                              subtitle: 'Personalized routes based on habit',
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
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [primary, primaryContainer]),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_saving)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  else
                                    const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    _saving ? 'Saving...' : 'Update Profile',
                                    style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(_lastUpdatedLabel(), style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
  void dispose() {
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
        const SnackBar(content: Text('Please sign in to change your password.')),
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
        const SnackBar(content: Text('Password must be at least 8 characters.')),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirmation do not match.')),
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
      final message = response['message']?.toString() ?? response['reason']?.toString() ?? 'Unable to update password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    setState(() => _saving = false);
  }

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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: primary),
                            ),
                            Text('Change Password', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primary.withOpacity(0.2), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAx37eVO0zcVZtWg-ZCwRjtr6VtkbR2kB4maw-MFWKD7Fma4lyeOM4OFmQqe8SqsX7t0g490ekrbsBx1SNYL3lo7ydHWSwnWoeZWGdfI0BD8ClbkDNHEXkKXdXY3Z6c3QSnPC3gc0kw_I70zsZxeCru7V8hn6VVBiJHyXWCpjwHWrHyVoW5KebXLCb1atItgHpZAJBT-BGByVdeDxprhfPSi--Dd9vxSxxQXKTD336OWu31xCZwW5N9JRmsB2gB85CTzO8brYe7bg',
                                  fit: BoxFit.cover,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Update Security', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface)),
                      const SizedBox(height: 6),
                      Text(
                        'Protect your I-Metro traveler account with a strong, unique password.',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _PasswordField(
                              label: 'Current Password',
                              placeholder: 'Enter current password',
                              obscure: !showCurrent,
                              controller: _currentController,
                              onToggle: () => setState(() => showCurrent = !showCurrent),
                            ),
                            Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 16), color: outlineVariant.withOpacity(0.1)),
                            _PasswordField(
                              label: 'New Password',
                              placeholder: 'Create new password',
                              obscure: !showNew,
                              controller: _newController,
                              onToggle: () => setState(() => showNew = !showNew),
                            ),
                            const SizedBox(height: 10),
                            const _StrengthBars(activeCount: 1),
                            const SizedBox(height: 6),
                            Text('Password must be at least 8 characters', style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant)),
                            const SizedBox(height: 16),
                            _PasswordField(
                              label: 'Confirm New Password',
                              placeholder: 'Repeat new password',
                              obscure: !showConfirm,
                              controller: _confirmController,
                              onToggle: () => setState(() => showConfirm = !showConfirm),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info, color: primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Session Security', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Updating your password will sign you out of all other active sessions on different devices for your safety.',
                                    style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      IgnorePointer(
                        ignoring: _saving,
                        child: Opacity(
                          opacity: _saving ? 0.7 : 1,
                          child: GestureDetector(
                            onTap: _submit,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [primary, primaryContainer]),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_saving)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  else
                                    const Icon(Icons.lock_reset, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    _saving ? 'Saving...' : 'Save Changes',
                                    style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Cancel and go back',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceContainerHigh.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Icon(Icons.security, size: 100, color: primary.withOpacity(0.1)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.lock, color: primary),
                                const SizedBox(height: 8),
                                Text('Your data is encrypted', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
                                const SizedBox(height: 6),
                                Text(
                                  'I-Metro uses bank-grade security to ensure your personal information remains private.',
                                  style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant),
                                ),
                              ],
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
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    Widget field;
    if (controller == null) {
      field = Row(
        children: [
          if (prefix != null) ...[
            Text(prefix!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
          ),
        ],
      );
    } else {
      field = TextField(
        controller: controller,
        readOnly: !enabled,
        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: value,
          hintStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant.withOpacity(0.6)),
          prefixText: prefix != null ? '$prefix ' : null,
          prefixStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant),
          suffixIcon: trailing,
          contentPadding: EdgeInsets.zero,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: onSurfaceVariant)),
                  const SizedBox(height: 6),
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
    if (!available) {
      return 'Push notifications are not configured on this build.';
    }
    if (!loggedIn) {
      return 'Sign in to enable ticket and payment alerts.';
    }
    if (enabled) {
      return 'You will get payment and ticket updates on this device.';
    }
    return 'Enable notifications to receive ticket updates instantly.';
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
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Notifications'),
        content: const Text(
          'If notifications are blocked, enable them in your device or browser settings.\n\n'
          'Web: Click the lock icon in the address bar -> Site settings -> Notifications -> Allow.\n'
          'Android: Settings -> Apps -> I-Metro -> Notifications -> Allow.\n'
          'iOS: Settings -> Notifications -> I-Metro -> Allow Notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerHigh = Color(0xFFE6E8EA);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const warning = Color(0xFFB54708);

    final isBlocked = statusLabel == 'Blocked';
    final isNotSet = statusLabel == 'Not set';
    Widget trailing;
    if (loading) {
      trailing = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: primary.withOpacity(0.7)),
      );
    } else if (!available) {
      trailing = _statusChip('Unavailable', surfaceContainerHigh, onSurfaceVariant);
    } else if (!loggedIn) {
      trailing = _statusChip('Sign in', surfaceContainerHigh, onSurfaceVariant);
    } else if (enabled) {
      trailing = _statusChip(statusLabel, primary.withOpacity(0.12), primary);
    } else {
      trailing = TextButton(
        onPressed: onRequest,
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text('Enable', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))],
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
                Text('Trip Notifications', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
                const SizedBox(height: 4),
                Text(_subtitle(), style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
                if (!enabled && available && loggedIn)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Status: $statusLabel',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: warning),
                    ),
                  ),
                if (isNotSet && !isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Tap Enable to allow alerts for ticket updates.',
                      style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant),
                    ),
                  ),
                if (isBlocked)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _showHelp(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: primary,
                      ),
                      child: Text(
                        'How to enable',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
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
    const surfaceContainerHigh = Color(0xFFE6E8EA);
    const primary = Color(0xFF006B47);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))],
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
                Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
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
    const surfaceLowest = Color(0xFFFFFFFF);
    const primary = Color(0xFF006B47);
    const onSurfaceVariant = Color(0xFF3E4942);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceLowest,
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant.withOpacity(0.6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primary.withOpacity(0.4), width: 2),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade400),
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
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < activeCount;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? primary.withOpacity(0.2) : surfaceVariant,
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(8, 0))],
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
                                    border: Border.all(color: background, width: 2),
                                  ),
                                  child: const Icon(Icons.star, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('I-Metro Rider', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
                                  const SizedBox(height: 2),
                                  Text('LUXURY IN MOTION', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2.2, fontWeight: FontWeight.w700, color: primary)),
                                ],
                              ),
                            ],
                          ),
                      const SizedBox(height: 24),
                      _MenuItem(
                        icon: Icons.home,
                        label: 'Home',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _MenuItem(
                        icon: Icons.confirmation_number,
                        label: 'Book Ride',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _MenuItem(
                        icon: Icons.history,
                        label: 'History',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _MenuItem(
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 18),
                        color: outlineVariant.withOpacity(0.2),
                      ),
                      _MenuItem(
                        icon: Icons.help,
                        label: 'Support',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
                      ),
                      _MenuItem(
                        icon: Icons.policy,
                        label: 'Policies',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.policy),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.logout),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFFFF5F5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
                              const SizedBox(width: 12),
                              Text('Logout', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFBA1A1A))),
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
            Text(label, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withOpacity(0.75))),
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
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_sending) return;
    if (!AuthStore.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send a support message.')),
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
    final response = await UserApi.sendSupportMessage(subject: subject, message: message);
    if (!mounted) return;
    setState(() => _sending = false);
    if (response['ok'] == true) {
      _subjectController.clear();
      _messageController.clear();
      final emailSent = response['emailSent'] == true;
      final messageText = emailSent
          ? 'Message sent. Our support team will reach out shortly.'
          : 'Message saved. Email delivery is not configured yet.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageText)));
    } else {
      final messageText = response['message']?.toString() ?? response['reason']?.toString() ?? 'Unable to send message.';
      setState(() => _error = messageText);
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const error = Color(0xFFBA1A1A);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAtkF29Qu01aqkGm8daAClwzhQWIL2i6V5AdQLxPQghfhkiq6HgszNGYvA_-XFymnT8tvGE0xE75IWAYLLQQgteh-asmsUr38bI4AOAd9gWPBvsFsTJPwdorNHL13i6nOzRHpUrR0IzNFMTZLm5c5uu3C9meePwa4F4IpvPwTyjphVtDB9f--9esReqoPChvrJ3yMtGIY1vVPsECpTEu8uIixkVO2gQmglkFekjGMI1ltjVVCrit8StqmI4p0MF2r9CGyqkEBMRvA',
                width: MediaQuery.of(context).size.width * 0.5,
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.hamburgerMenu),
                              icon: const Icon(Icons.menu, color: primary),
                            ),
                            _brandLogo(size: 28, radius: 8),
                            const SizedBox(width: 8),
                            Text('I-Metro', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: primary)),
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How can we help?', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, color: onSurface)),
                      const SizedBox(height: 8),
                      Text(
                        'Reach out to Inter-Metro Transport Solution Limited (I-Metro) for support, partnerships, or fleet management enquiries.',
                        style: GoogleFonts.inter(fontSize: 16, color: onSurfaceVariant, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 860;
                          final leftColumn = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _ContactInfoCard(
                                icon: Icons.call,
                                title: 'Call Us',
                                subtitle: 'Customer Support',
                                value: '+234 912 806 6666',
                              ),
                              SizedBox(height: 16),
                              _ContactInfoCard(
                                icon: Icons.apartment,
                                title: 'Head Office',
                                subtitle: 'Abuja, Nigeria',
                                value: 'FCT Transport Secretariat',
                              ),
                              SizedBox(height: 16),
                              _ContactLocationRow(),
                            ],
                          );
                          final rightColumn = Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: surfaceLowest,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ContactFormField(
                                  label: 'Subject',
                                  placeholder: 'What can we help you with?',
                                  controller: _subjectController,
                                ),
                                const SizedBox(height: 16),
                                _ContactMessageField(
                                  label: 'Message',
                                  placeholder: 'Tell us more about your inquiry...',
                                  controller: _messageController,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _sending ? null : _sendMessage,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        else
                                          const Icon(Icons.send, size: 18, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          _sending ? 'Sending...' : 'Send Message',
                                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 10),
                                  Text(_error!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                                ],
                                const SizedBox(height: 12),
                                Text(
                                  'By sending this message, you agree to our privacy policy regarding data collection for support purposes.',
                                  style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: leftColumn),
                                const SizedBox(width: 24),
                                Expanded(child: rightColumn),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leftColumn,
                              const SizedBox(height: 24),
                              rightColumn,
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: background.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: onSurface)),
          const SizedBox(height: 4),
          Text(subtitle.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2.2, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
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
        const Icon(Icons.location_on, color: onSurfaceVariant),
        const SizedBox(width: 8),
        Text('Abuja, Nigeria (FCT)', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
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
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF006B47).withOpacity(0.4), width: 2),
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
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurfaceVariant = Color(0xFF3E4942);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceContainerLow,
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF006B47).withOpacity(0.4), width: 2),
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
    final accentColor = accent ?? primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineVariant.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
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
                    Text(title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
                    const SizedBox(height: 4),
                    Text(body, style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant, height: 1.4)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(actionLabel!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
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
    _ticketRefreshSub = PushService.instance.ticketRefreshStream.listen((event) {
      if (!mounted) return;
      if (!AuthStore.isLoggedIn || AuthStore.userId == null) return;
      if (event.type == 'ticket_ready' || event.type == 'payment_confirmed' || event.type == 'booking_updated') {
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
    final sameDay = now.year == date.year && now.month == date.month && now.day == date.day;
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

  List<Map<String, dynamic>> _buildFromBookings(List<Map<String, dynamic>> bookings) {
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
          'body': 'Payment confirmed for $from -> $to. Tap to issue your ticket.',
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
    const background = Color(0xFFF7F9FB);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const outlineVariant = Color(0xFFBDCAC0);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const primary = Color(0xFF006B47);
    const error = Color(0xFFBA1A1A);

    final loggedIn = AuthStore.isLoggedIn;

    return Scaffold(
      backgroundColor: background,
      body: Column(
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: primary),
                          ),
                          _brandLogo(size: 24, radius: 8),
                          const SizedBox(width: 8),
                          Text('Notifications', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                          const Spacer(),
                          if (_loading)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: primary.withOpacity(0.6)),
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your alerts', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface)),
                        const SizedBox(height: 6),
                        Text('Trip updates, payment confirmations, and ticket alerts.', style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant)),
                        const SizedBox(height: 12),
                        OfflineBanner(onRetry: _loadNotifications),
                        const SizedBox(height: 16),
                        if (!loggedIn)
                          _EmptyStateCard(
                            icon: Icons.lock_outline,
                            title: 'Sign in for alerts',
                            body: 'See payment confirmations and ticket updates here.',
                            actionLabel: 'Sign in',
                            onAction: () => Navigator.pushNamed(context, AppRoutes.login),
                          )
                        else if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_error!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _loadNotifications,
                                  child: Text('Retry', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                                ),
                              ],
                            ),
                          )
                        else if (!_loading && _items.isEmpty)
                          _EmptyStateCard(
                            icon: Icons.notifications_none,
                            title: 'No alerts yet',
                            body: 'We will let you know about payments, tickets, and rides here.',
                            actionLabel: 'View history',
                            onAction: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                          )
                        else
                          ..._items.map(
                            (item) => _NotificationCard(
                              icon: item['icon'] as IconData,
                              color: item['color'] as Color,
                              title: item['title']?.toString() ?? 'Alert',
                              body: item['body']?.toString() ?? '',
                              timeLabel: _formatTime(item['time'] as DateTime?),
                              onTap: () => _openNotification(item),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(timeLabel, style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant, height: 1.4),
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: primary),
                            ),
                            Text('Company Profile', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
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
                        style: GoogleFonts.manrope(fontSize: 30, fontWeight: FontWeight.w800, color: onSurface),
                      ),
                      Text('2026', style: GoogleFonts.manrope(fontSize: 30, fontWeight: FontWeight.w800, color: primary)),
                      const SizedBox(height: 12),
                      Text(
                        'Inter-Metro Transport Solution Limited (I-Metro) is a privately owned, technology-driven urban mobility company headquartered in Abuja, Nigeria. We deploy clean-energy fleets, intelligent transport systems, and professionally managed operations aligned with international standards. I-Metro holds an active operational license issued by the FCTA Transport Secretariat with approval from the Office of the Honourable Minister of the FCT.',
                        style: GoogleFonts.inter(fontSize: 16, color: onSurfaceVariant, height: 1.4),
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
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
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
                                    child: const Icon(Icons.gavel, color: primary),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Vision', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: onSurface)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'To become Nigeria’s most trusted and innovative provider of sustainable, technology-enabled urban mobility solutions.',
                                    style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text('Read vision', style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, size: 16, color: primary),
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
                                    child: const Icon(Icons.security, color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Mission', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'To transform public transportation by deploying clean-energy fleets, smart technologies, and customer-centric services.',
                                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text('Read mission', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _PolicySectionHeader(
                        index: '01',
                        title: 'Core Values',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Our operations are anchored on clear values that guide every decision and rider interaction:',
                        style: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant, height: 1.6),
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
                            Text('Values in Action', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
                            const SizedBox(height: 12),
                            _PolicyBullet(
                              text: 'Safety – passenger and operational safety above all else.',
                            ),
                            const SizedBox(height: 8),
                            _PolicyBullet(
                              text: 'Integrity – transparent, accountable, and ethical operations.',
                            ),
                            const SizedBox(height: 8),
                            _PolicyBullet(
                              text: 'Innovation – continuous adoption of smart mobility solutions.',
                            ),
                            const SizedBox(height: 8),
                            _PolicyBullet(
                              text: 'Professionalism – global service standards and discipline.',
                            ),
                            const SizedBox(height: 8),
                            _PolicyBullet(
                              text: 'Sustainability – environmental responsibility and long-term impact.',
                            ),
                            const SizedBox(height: 8),
                            _PolicyBullet(
                              text: 'Customer Focus – reliable, dignified, and comfortable mobility.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _PolicySectionHeader(
                        index: '02',
                        title: 'Core Services',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Inter-Metro delivers an integrated portfolio of urban and institutional mobility solutions:',
                        style: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _PolicyBullet(text: 'High-capacity CNG bus operations.'),
                          SizedBox(height: 8),
                          _PolicyBullet(text: 'Metered taxi services (first of its kind in Abuja).'),
                          SizedBox(height: 8),
                          _PolicyBullet(text: 'Fleet management partnerships for third-party vehicles.'),
                          SizedBox(height: 8),
                          _PolicyBullet(text: 'Hire-purchase vehicle operations.'),
                          SizedBox(height: 8),
                          _PolicyBullet(text: 'Driver recruitment, training, and supervision.'),
                          SizedBox(height: 8),
                          _PolicyBullet(text: 'Route planning, scheduling, and cashless fare collection.'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PolicyMiniCard(
                              title: 'Fleet Partnerships',
                              body: 'I-Metro manages daily operations, staffing, technology, monitoring, and reporting for partner-owned vehicles.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PolicyMiniCard(
                              title: 'Hire-Purchase',
                              body: 'Vehicles are taken into service and paid for over time from operational proceeds with transparent oversight.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _PolicySectionHeader(
                        index: '03',
                        title: 'Technology & Safety Infrastructure',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Operations are underpinned by a centralized, cloud-based mobility management system designed for transparency, efficiency, and safety.',
                        style: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(left: BorderSide(color: primary, width: 4)),
                        ),
                        child: Text(
                          'GPS-enabled real-time vehicle tracking\nOnboard CCTV with two-way monitoring\nCashless fare collection (POS, smart cards, validators)\nCentralized cloud-based fleet management platform',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: onSurfaceVariant, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Public sector & institutional partnerships include:',
                            style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          const _PolicyBullet(text: 'Presidential Compressed Natural Gas Initiative (P-CNGi).'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(text: 'Office of the Honourable Minister of the FCT.'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(text: 'FCT Transport Secretariat and DRTS.'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(text: 'Federal Ministry of Transport and Environment.'),
                          const SizedBox(height: 6),
                          const _PolicyBullet(text: 'AMAC, FRSC, and the Nigerian Police Force & NSCDC.'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
                        ),
                        child: Column(
                          children: [
                            Text('Need more information? Call +234 912 806 6666.', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
                                ),
                                child: Text('Contact I-Metro', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('I-Metro Bus Profile - 2026', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500, letterSpacing: 2.0)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, -8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavPill(
                        label: 'Home',
                        icon: Icons.home,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                      ),
                      _BottomNavPill(
                        label: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.completedRides),
                      ),
                      _BottomNavPill(
                        label: 'Booking',
                        icon: Icons.confirmation_number,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      _BottomNavPill(
                        label: 'Profile',
                        icon: Icons.person,
                        active: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
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
        Text(index, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: primary)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: outlineVariant.withOpacity(0.3))),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF191C1E))),
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
          child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant, height: 1.4)),
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
          Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface)),
          const SizedBox(height: 8),
          Text(body, style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant, height: 1.4)),
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
    const surfaceContainerLow = Color(0xFFF2F4F6);
    const onSurface = Color(0xFF191C1E);
    const onSurfaceVariant = Color(0xFF3E4942);
    const tertiary = Color(0xFF9B403E);
    const tertiaryContainer = Color(0xFFBA5855);
    const tertiaryFixed = Color(0xFFFFDAD7);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Stack(
        children: [
          const ProfileScreen(),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: inverseSurface.withOpacity(0.4)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: surfaceLowest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: tertiaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout, color: tertiary, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Are you sure you want to log out?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: onSurface),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You will need to enter your credentials to access your traveler profile again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
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
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          'Log Out',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceVariant),
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






