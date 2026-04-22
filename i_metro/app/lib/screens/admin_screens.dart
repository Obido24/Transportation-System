import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes.dart';
import '../services/admin_api.dart';
import '../services/auth_api.dart';
import '../services/auth_store.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _remember = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    final response = await AuthApi.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (response['ok'] == true) {
      Navigator.pushNamed(context, AppRoutes.admin2fa);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthStore.isLoggedIn) {
      return const AdminDashboardScreen();
    }
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const surface = Color(0xFFF8F9FA);
    const surfaceLow = Color(0xFFF3F4F5);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceHighest = Color(0xFFE1E3E4);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF3E4944);
    const outlineVariant = Color(0xFFBEC9C3);
    const primaryFixedDim = Color(0xFF82D7BA);
    const secondaryContainer = Color(0xFFC8EADC);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: primaryFixedDim.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: secondaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final maxWidth = isWide ? 480.0 : 520.0;
              final textAlign = isWide ? TextAlign.left : TextAlign.center;

              return Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: surfaceLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                            decoration: BoxDecoration(
                              color: surfaceLowest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF191C1D).withOpacity(0.05),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [primary, primaryContainer],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.directions_railway, color: Colors.white, size: 30),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'I-Metro',
                                      style: GoogleFonts.manrope(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: primary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'I-Metro Admin Portal',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  'Welcome back',
                                  textAlign: textAlign,
                                  style: GoogleFonts.manrope(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please enter your credentials to access the command center.',
                                  textAlign: textAlign,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _StitchInput(
                                  label: 'Email Address',
                                  placeholder: 'name@i-metro.gov',
                                  icon: Icons.mail_outline,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                _StitchInput(
                                  label: 'Password',
                                  placeholder: '••••••••',
                                  icon: Icons.lock_outline,
                                  controller: _passwordController,
                                  obscureText: true,
                                  trailing: Icon(Icons.visibility, color: onSurfaceVariant),
                                  labelAction: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminForgotPassword),
                                    child: Text(
                                      'Forgot password?',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _remember,
                                      activeColor: primary,
                                      onChanged: (value) => setState(() => _remember = value ?? false),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      side: BorderSide(color: outlineVariant.withOpacity(0.6)),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Keep me logged in for 30 days',
                                        style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: _signIn,
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [primary, primaryContainer],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withOpacity(0.12),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _loading ? 'Signing in...' : 'Sign in',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Container(height: 1, color: outlineVariant.withOpacity(0.1)),
                                const SizedBox(height: 18),
                                Text(
                                  'Authorized personnel only. Access is monitored and logged. By signing in, you agree to the Operational Guidelines.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('SYSTEM v4.2.1', style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
                                const SizedBox(width: 12),
                                Text('SECURE NODE 09', style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: primaryFixedDim,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('ALL SYSTEMS NOMINAL', style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (MediaQuery.of(context).size.width >= 1200)
            Positioned(
              right: -90,
              top: MediaQuery.of(context).size.height * 0.35,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: surfaceHighest.withOpacity(0.5), width: 40),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (MediaQuery.of(context).size.width >= 1200)
            Positioned(
              right: 140,
              top: 90,
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 24, height: 24, decoration: BoxDecoration(color: surfaceHighest, borderRadius: BorderRadius.circular(6))),
                      Column(
                        children: [
                          Container(height: 6, decoration: BoxDecoration(color: surfaceHighest, borderRadius: BorderRadius.circular(6))),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 60,
                              height: 6,
                              decoration: BoxDecoration(color: surfaceHighest, borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
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

class _StitchInput extends StatefulWidget {
  const _StitchInput({
    required this.label,
    required this.placeholder,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.labelAction,
  });

  final String label;
  final String placeholder;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;
  final Widget? labelAction;

  @override
  State<_StitchInput> createState() => _StitchInputState();
}

class _StitchInputState extends State<_StitchInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const surfaceHighest = Color(0xFFE1E3E4);
    const surfaceLowest = Color(0xFFFFFFFF);
    const primary = Color(0xFF00513F);
    const onSurfaceVariant = Color(0xFF3E4944);
    const outlineVariant = Color(0xFFBEC9C3);

    final focused = _focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            if (widget.labelAction != null) widget.labelAction!,
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: focused ? surfaceLowest : surfaceHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: focused ? primary : Colors.transparent, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(widget.icon, size: 20, color: focused ? primary : onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF191C1D)),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: outlineVariant),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: widget.trailing,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
class _AdminInput extends StatelessWidget {
  const _AdminInput({
    required this.hint,
    required this.borderColor,
    this.trailing,
    this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  final String hint;
  final Color borderColor;
  final Widget? trailing;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _AdminCheckbox extends StatelessWidget {
  const _AdminCheckbox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9A9A9A)),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _terms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const primaryFixed = Color(0xFF9EF3D6);
    const primaryFixedDim = Color(0xFF82D7BA);
    const surface = Color(0xFFF8F9FA);
    const surfaceLow = Color(0xFFF3F4F5);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurfaceVariant = Color(0xFF3E4944);
    const outlineVariant = Color(0xFFBEC9C3);
    const secondaryContainer = Color(0xFFC8EADC);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: primaryContainer.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: secondaryContainer.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isWide
                            ? Row(
                                children: [
                                  Expanded(child: _SignupLeftPanel(primaryFixedDim: primaryFixedDim, primaryFixed: primaryFixed)),
                                  Expanded(
                                    child: _SignupRightPanel(
                                      nameController: _nameController,
                                      emailController: _emailController,
                                      phoneController: _phoneController,
                                      passwordController: _passwordController,
                                      confirmController: _confirmController,
                                      terms: _terms,
                                      onTermsChanged: (value) => setState(() => _terms = value),
                                    ),
                                  ),
                                ],
                              )
                            : _SignupRightPanel(
                                nameController: _nameController,
                                emailController: _emailController,
                                phoneController: _phoneController,
                                passwordController: _passwordController,
                                confirmController: _confirmController,
                                terms: _terms,
                                onTermsChanged: (value) => setState(() => _terms = value),
                                showCompactHeader: true,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SignupLeftPanel extends StatelessWidget {
  const _SignupLeftPanel({
    required this.primaryFixedDim,
    required this.primaryFixed,
  });

  final Color primaryFixedDim;
  final Color primaryFixed;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_transit, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                'I-Metro',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'Master the Urban\nFlow.',
            style: GoogleFonts.manrope(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Join the elite transit authority management team. Secure access to the kinetic heartbeat of the city.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: primaryFixed,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2.4M', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: primaryFixedDim)),
                      const SizedBox(height: 4),
                      Text('Daily Commutes', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('99.9%', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: primaryFixedDim)),
                      const SizedBox(height: 4),
                      Text('System Uptime', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8))),
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

class _SignupRightPanel extends StatelessWidget {
  const _SignupRightPanel({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmController,
    required this.terms,
    required this.onTermsChanged,
    this.showCompactHeader = false,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool terms;
  final ValueChanged<bool> onTermsChanged;
  final bool showCompactHeader;

  @override
  Widget build(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const primary = Color(0xFF00513F);
    const onSurfaceVariant = Color(0xFF3E4944);
    const outlineVariant = Color(0xFFBEC9C3);

    return Container(
      color: surfaceLowest,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCompactHeader)
            Row(
              children: [
                const Icon(Icons.directions_transit, color: primary, size: 28),
                const SizedBox(width: 8),
                Text('I-Metro', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: primary)),
              ],
            ),
          if (showCompactHeader) const SizedBox(height: 24),
          Text(
            'Create Admin Account',
            style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF191C1D)),
          ),
          const SizedBox(height: 6),
          Text(
            'Fill in your details to request access to the terminal.',
            style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
          ),
          const SizedBox(height: 26),
          _StitchInput(
            label: 'Full Name',
            placeholder: 'Johnathan Sterling',
            icon: Icons.person_outline,
            controller: nameController,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final split = constraints.maxWidth >= 520;
              final children = [
                Expanded(
                  child: _StitchInput(
                    label: 'Work Email',
                    placeholder: 'j.sterling@i-metro.gov',
                    icon: Icons.mail_outline,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 18, height: 18),
                Expanded(
                  child: _StitchInput(
                    label: 'Contact Number',
                    placeholder: '+1 (555) 000-0000',
                    icon: Icons.call_outlined,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ];
              if (split) {
                return Row(children: children);
              }
              return Column(children: [
                children[0],
                const SizedBox(height: 18),
                children[2],
              ]);
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final split = constraints.maxWidth >= 520;
              final children = [
                Expanded(
                  child: _StitchInput(
                    label: 'Password',
                    placeholder: '••••••••',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 18, height: 18),
                Expanded(
                  child: _StitchInput(
                    label: 'Confirm',
                    placeholder: '••••••••',
                    icon: Icons.verified_user_outlined,
                    controller: confirmController,
                    obscureText: true,
                  ),
                ),
              ];
              if (split) {
                return Row(children: children);
              }
              return Column(children: [
                children[0],
                const SizedBox(height: 18),
                children[2],
              ]);
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: terms,
                onChanged: (value) => onTermsChanged(value ?? false),
                activeColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: outlineVariant),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant, height: 1.4),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Authority',
                        style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' and acknowledge the '),
                      TextSpan(
                        text: 'Security Protocols',
                        style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00513F), Color(0xFF006B54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Request Admin Access', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text('Already have an authorized account? ', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                  child: Text('Sign In Here', style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniBadge(),
              const SizedBox(width: 12),
              _MiniBadge(),
              const SizedBox(width: 12),
              _MiniBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: Container(
        width: 56,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
class AdminForgotPasswordScreen extends StatelessWidget {
  const AdminForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const primaryFixedDim = Color(0xFF82D7BA);
    const surface = Color(0xFFF8F9FA);
    const surfaceContainer = Color(0xFFEDEEEF);
    const surfaceLow = Color(0xFFF3F4F5);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceHighest = Color(0xFFE1E3E4);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF3E4944);
    const secondaryContainer = Color(0xFFC8EADC);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: secondaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 900;
                        return Row(
                          children: [
                            if (isWide)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(48),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primary, primaryContainer],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
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
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.directions_railway, color: primaryFixedDim, size: 22),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'I-Metro',
                                            style: GoogleFonts.manrope(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 36),
                                      Text(
                                        'Security &\nSeamless Flow.',
                                        style: GoogleFonts.manrope(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Access your transit dashboard with confidence. Our secure recovery process ensures you\'re back in control within moments.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                          height: 1.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'STATUS CHECK',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Colors.white.withOpacity(0.6),
                                                letterSpacing: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(color: primaryFixedDim, shape: BoxShape.circle),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'All transit systems operational',
                                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
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
                            Expanded(
                              child: Container(
                                color: surfaceLowest,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.arrow_back, size: 16, color: primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Back to Login',
                                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.manrope(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter the email address associated with your I-Metro admin account and we\'ll send you a verification code to reset your password.',
                                      style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant, height: 1.5),
                                    ),
                                    const SizedBox(height: 24),
                                    _StitchInput(
                                      label: 'Work Email',
                                      placeholder: 'admin@i-metro.gov',
                                      icon: Icons.mail_outline,
                                      controller: TextEditingController(),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 18),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.adminEmailVerification),
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [primary, primaryContainer],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(color: primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 8)),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Send verification code',
                                              style: GoogleFonts.manrope(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.send, size: 18, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: surfaceLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: surfaceHighest,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.mark_email_unread, color: primary),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('1. Check your inbox', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: onSurface)),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'A 6-digit verification code will be sent to your registered email address within a few minutes.',
                                                  style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: surfaceLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Opacity(
                                        opacity: 0.6,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: surfaceHighest,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.lock_reset, color: onSurfaceVariant),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('2. Reset your password', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: onSurface)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Enter the code and choose a new, strong password to regain access to the I-Metro dashboard.',
                                                    style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: [
                                          Text('Having trouble? ', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                                          Text('Contact Support', style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (MediaQuery.of(context).size.width >= 1000)
            Positioned(
              bottom: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: surfaceLowest,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      'Security Protocol: 2FA Active',
                      style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant),
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
class AdminEmailVerificationScreen extends StatelessWidget {
  const AdminEmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const primaryFixed = Color(0xFF9EF3D6);
    const surface = Color(0xFFF8F9FA);
    const surfaceLow = Color(0xFFF3F4F5);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceHighest = Color(0xFFE1E3E4);
    const surfaceContainer = Color(0xFFEDEEEF);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF3E4944);
    const secondaryContainer = Color(0xFFC8EADC);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                color: primaryFixed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                color: secondaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final showLeft = constraints.maxWidth >= 900;
              return Row(
                children: [
                  if (showLeft)
                    Expanded(
                      child: Container(
                        color: surface,
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.directions_railway, color: primary, size: 32),
                                const SizedBox(width: 8),
                                Text('I-Metro', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: primary)),
                              ],
                            ),
                            const SizedBox(height: 36),
                            Text(
                              'Luxury in\nMotion',
                              style: GoogleFonts.manrope(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Secure access to the I-Metro Admin Portal. Oversee clean-energy fleet operations, safety, and compliance.',
                              style: GoogleFonts.inter(fontSize: 14, color: onSurfaceVariant, height: 1.6),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceLowest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFBEC9C3).withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primaryFixed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.security, color: Color(0xFF002118)),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Verification Secure', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                                          Text('Authentication Protocol active', style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant, letterSpacing: 0.8)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: surfaceHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.66,
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
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
                  Expanded(
                    child: Container(
                      color: showLeft ? surface : surfaceContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!showLeft)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.directions_railway, color: primary, size: 28),
                                const SizedBox(width: 6),
                                Text('I-Metro', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: primary)),
                              ],
                            ),
                          if (!showLeft) const SizedBox(height: 20),
                          Text(
                            'Verify your email',
                            textAlign: showLeft ? TextAlign.left : TextAlign.center,
                            style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: onSurface),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "We've sent a 6-digit verification code to admin@i-metro.gov",
                            textAlign: showLeft ? TextAlign.left : TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) => _OtpInputBox()),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminResetPassword),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primary, primaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Verify', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Text("Didn't receive the code?", style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Resend Code', style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.refresh, size: 14, color: primary),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: surfaceLowest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.help_outline, color: primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Need assistance?', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurface)),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Contact your local station administrator if you're having trouble logging in.",
                                        style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '(c) 2024 Inter-Metro Transport Solution Limited - Secure Access',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OtpInputBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const surfaceHighest = Color(0xFFE1E3E4);
    return Container(
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: surfaceHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '0',
        ),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}
class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.text, required this.highlighted});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: highlighted ? const Color(0xFF6AB04A) : const Color(0xFFDADADA)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AdminTwoFactorScreen extends StatelessWidget {
  const AdminTwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const primaryFixedDim = Color(0xFF82D7BA);
    const surface = Color(0xFFF8F9FA);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceHighest = Color(0xFFE1E3E4);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF3E4944);
    const secondaryContainer = Color(0xFFC8EADC);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(color: primary.withOpacity(0.05), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -140,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(color: secondaryContainer.withOpacity(0.1), shape: BoxShape.circle),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
                      decoration: BoxDecoration(
                        color: surfaceLowest.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 14)),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primary, primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: const Icon(Icons.shield, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 12),
                          Text('I-Metro', style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w800, color: primary)),
                          const SizedBox(height: 4),
                          Text(
                            'I-Metro Security',
                            style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.6, color: onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Two-Factor Authentication',
                            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "We've sent a 6-digit verification code to ad***@i-metro.gov. Enter the code below to secure your session.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) => _OtpCell()),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.schedule, size: 14, color: onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                'Code expires in ',
                                style: GoogleFonts.inter(fontSize: 11, color: onSurfaceVariant),
                              ),
                              Text('04:59', style: GoogleFonts.inter(fontSize: 11, color: primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 22),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primary, primaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text('Verify Account', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Text("Didn't receive the code?", style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                              const SizedBox(height: 6),
                              Text('Resend Code', style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Container(
                            height: 1,
                            color: surfaceHighest,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SecurityChip(icon: Icons.verified_user, label: 'Secure TLS 1.3'),
                              const SizedBox(width: 12),
                              _SecurityChip(icon: Icons.lock, label: 'AES-256 Encrypted'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back, size: 18, color: onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text('Return to Login', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.help_outline, color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const surfaceHighest = Color(0xFFE1E3E4);
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: surfaceHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: TextField(
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF00513F)),
        decoration: const InputDecoration(border: InputBorder.none, hintText: '·'),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

class _SecurityChip extends StatelessWidget {
  const _SecurityChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF3E4944)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.2, color: const Color(0xFF3E4944))),
      ],
    );
  }
}
class AdminResetPasswordScreen extends StatelessWidget {
  const AdminResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const primaryFixed = Color(0xFF9EF3D6);
    const secondaryFixed = Color(0xFFC8EADC);
    const surface = Color(0xFFF8F9FA);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF3F4F5);
    const surfaceHighest = Color(0xFFE1E3E4);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF3E4944);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            left: -120,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(color: primaryFixed.withOpacity(0.2), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(color: secondaryFixed.withOpacity(0.3), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final showLeft = constraints.maxWidth >= 900;
                        return Row(
                          children: [
                            if (showLeft)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(48),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primary, primaryContainer],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.directions_railway, color: Colors.white, size: 28),
                                          const SizedBox(width: 8),
                                          Text('I-Metro', style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                        ],
                                      ),
                                      const SizedBox(height: 36),
                                      Text(
                                        'Securing the\nPulse of Transit.',
                                        style: GoogleFonts.manrope(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Resetting your password maintains the integrity of the I-Metro network infrastructure.',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF94E8CB),
                                          height: 1.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.verified_user, size: 16, color: Colors.white),
                                                const SizedBox(width: 8),
                                                Text('Security Protocol 8.24', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: FractionallySizedBox(
                                                widthFactor: 0.33,
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
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
                            Expanded(
                              child: Container(
                                color: surfaceLowest,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.arrow_back, size: 16, color: onSurfaceVariant),
                                          const SizedBox(width: 6),
                                          Text('Return to Login', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text('Reset Password', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface)),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ensure your new password is at least 12 characters long with a mix of symbols.',
                                      style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 24),
                                    _StitchInput(
                                      label: 'New password',
                                      placeholder: '••••••••••••',
                                      icon: Icons.lock_open,
                                      controller: TextEditingController(),
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 18),
                                    _StitchInput(
                                      label: 'Confirm password',
                                      placeholder: '••••••••••••',
                                      icon: Icons.key,
                                      controller: TextEditingController(),
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: surfaceLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFBEC9C3).withOpacity(0.1)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'SECURITY REQUIREMENTS',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: onSurfaceVariant,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          _RequirementItem(text: '12+ characters', met: true),
                                          _RequirementItem(text: 'One special symbol (!@#\$%)', met: false),
                                          _RequirementItem(text: 'Numerical digits', met: false),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [primary, primaryContainer],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(color: primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Reset', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.published_with_changes, size: 18, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(height: 1, color: surfaceHighest.withOpacity(0.6)),
                                    const SizedBox(height: 12),
                                    Text(
                                      '© 2024 Inter-Metro Transport Solution Limited. Admin Panel. Authorized Personnel Only.',
                                      style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant, height: 1.4),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Legal Policy', style: GoogleFonts.inter(fontSize: 10, color: primary)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FooterLink(text: 'Privacy'),
                const SizedBox(width: 20),
                _FooterLink(text: 'Terms'),
                const SizedBox(width: 20),
                _FooterLink(text: 'Support'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.text, required this.met});

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final icon = met ? Icons.check_circle : Icons.circle;
    final color = met ? const Color(0xFF00513F) : const Color(0xFFBEC9C3);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF3E4944))),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF3E4944)));
  }
}
class AdminResetSuccessScreen extends StatelessWidget {
  const AdminResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00513F);
    const primaryContainer = Color(0xFF006B54);
    const primaryFixedDim = Color(0xFF82D7BA);
    const surface = Color(0xFFF8F9FA);
    const surfaceLowest = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF3E4944);
    const secondary = Color(0xFF466559);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(color: primary.withOpacity(0.05), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(color: secondary.withOpacity(0.1), shape: BoxShape.circle),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: const Icon(Icons.directions_railway, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text('I-Metro', style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: primary)),
                        const SizedBox(height: 4),
                        Text(
                          'Luxury in Motion',
                          style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant, letterSpacing: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: surfaceLowest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: primaryFixedDim.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [primary, primaryContainer],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                                  ],
                                ),
                                child: const Icon(Icons.check_circle, color: Colors.white, size: 44),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Password reset successful',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your account security has been updated. You can now use your new password to access the I-Metro transit dashboard.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant, height: 1.5),
                          ),
                          const SizedBox(height: 22),
                          GestureDetector(
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.adminLogin,
                              (route) => false,
                            ),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primary, primaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Back to login', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shield, size: 16, color: onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                'Secure Infrastructure',
                                style: GoogleFonts.inter(fontSize: 10, color: onSurfaceVariant, letterSpacing: 1.4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text.rich(
                      TextSpan(
                        text: 'Having trouble? ',
                        style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariant),
                        children: [
                          TextSpan(
                            text: 'Contact IT Support',
                            style: GoogleFonts.inter(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
class _AdminDashboardData {
  const _AdminDashboardData({
    required this.totalUsers,
    required this.totalBookings,
    required this.totalRoutes,
    required this.totalSales,
    required this.bookings,
  });

  final int totalUsers;
  final int totalBookings;
  final int totalRoutes;
  final double totalSales;
  final List<Map<String, dynamic>> bookings;

  static const empty = _AdminDashboardData(
    totalUsers: 0,
    totalBookings: 0,
    totalRoutes: 0,
    totalSales: 0,
    bookings: [],
  );
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<_AdminDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AdminDashboardData> _load() async {
    if (AuthStore.token == null) {
      return _AdminDashboardData.empty;
    }
    final users = await AdminApi.listUsers();
    final bookings = await AdminApi.listBookings();
    final payments = await AdminApi.listPayments();
    final routes = await AdminApi.listRoutes();

    double totalSales = 0;
    for (final payment in payments) {
      if ((payment['status'] ?? '') == 'SUCCESS') {
        final amount = payment['amount'];
        if (amount is num) {
          totalSales += amount.toDouble();
        }
      }
    }

    return _AdminDashboardData(
      totalUsers: users.length,
      totalBookings: bookings.length,
      totalRoutes: routes.length,
      totalSales: totalSales,
      bookings: bookings,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<_AdminDashboardData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _AdminDashboardData.empty;
        return AdminDashboardMain(
          data: data,
          onNavigate: (route) => Navigator.pushNamed(context, route),
          onRefresh: () => setState(() {
            _future = _load();
          }),
        );
      },
    );
  }
}

String _bookingUserName(Map<String, dynamic> booking) {
  final user = booking['user'];
  if (user is Map<String, dynamic>) {
    final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    if (name.isNotEmpty) return name;
    return user['email']?.toString() ?? user['phone']?.toString() ?? 'Unknown';
  }
  return 'Unknown';
}

String _bookingRoute(Map<String, dynamic> booking) {
  final route = booking['route'];
  if (route is Map<String, dynamic>) {
    return '${route['fromLocation'] ?? ''}-${route['toLocation'] ?? ''}'.replaceAll(' ', '');
  }
  return 'Route';
}

String _bookingAmount(Map<String, dynamic> booking) {
  final payment = booking['payment'];
  if (payment is Map<String, dynamic>) {
    final amount = payment['amount'] ?? 0;
    return 'N$amount';
  }
  return 'N0';
}

String _bookingStatus(Map<String, dynamic> booking) {
  final payment = booking['payment'];
  if (payment is Map<String, dynamic>) {
    return (payment['status'] ?? 'PENDING').toString();
  }
  return 'PENDING';
}
// Dashboard UI components
class _DashboardColors {
  static const primary = Color(0xFF00513F);
  static const primaryContainer = Color(0xFF006B54);
  static const primaryFixedDim = Color(0xFF82D7BA);
  static const onPrimaryContainer = Color(0xFF94E8CB);
  static const secondary = Color(0xFF466559);
  static const secondaryContainer = Color(0xFFC8EADC);
  static const onSecondaryContainer = Color(0xFF4C6B5F);
  static const tertiary = Color(0xFF753229);
  static const tertiaryContainer = Color(0xFF92493E);
  static const tertiaryFixed = Color(0xFFFFDAD4);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceLow = Color(0xFFF3F4F5);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceHighest = Color(0xFFE1E3E4);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3E4944);
  static const outlineVariant = Color(0xFFBEC9C3);
  static const error = Color(0xFFBA1A1A);
}

class AdminDashboardMain extends StatelessWidget {
  const AdminDashboardMain({
    super.key,
    required this.data,
    required this.onNavigate,
    this.onRefresh,
  });

  final _AdminDashboardData data;
  final ValueChanged<String> onNavigate;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final bookings = data.bookings.take(5).toList();
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Row(
        children: [
          _DashboardSidebar(
            onNavigate: onNavigate,
            selectedRoute: AppRoutes.adminDashboard,
          ),
          Expanded(
            child: Column(
              children: [
                _DashboardTopBar(onRefresh: onRefresh),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Operations Overview',
                                    style: GoogleFonts.manrope(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: _DashboardColors.onSurface,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Real-time performance metrics for the I-Metro network.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _DashboardColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _DashboardFilterButton(
                              label: 'Last 24 Hours',
                              icon: Icons.calendar_today,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width >= 1200
                                ? 4
                                : width >= 900
                                    ? 2
                                    : 1;
                            final ratio = width >= 1200 ? 2.8 : 2.6;
                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: ratio,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: [
                                _DashboardSummaryCard(
                                  title: 'Total Active Users',
                                  value: _formatCount(data.totalUsers),
                                  deltaLabel: '+12.5%',
                                  icon: Icons.group,
                                  accent: _DashboardColors.primary,
                                  accentBackground: _DashboardColors.primaryFixedDim.withOpacity(0.3),
                                ),
                                _DashboardSummaryCard(
                                  title: 'Total Bookings',
                                  value: _formatCount(data.totalBookings),
                                  deltaLabel: '+3.2%',
                                  icon: Icons.confirmation_number,
                                  accent: _DashboardColors.secondary,
                                  accentBackground: _DashboardColors.secondaryContainer,
                                ),
                                _DashboardSummaryCard(
                                  title: 'Ticket Sales (NGN)',
                                  value: _formatCurrency(data.totalSales),
                                  deltaLabel: '+8.1%',
                                  icon: Icons.payments,
                                  accent: _DashboardColors.tertiary,
                                  accentBackground: _DashboardColors.tertiaryFixed.withOpacity(0.35),
                                ),
                                _DashboardSummaryCard(
                                  title: 'Available Routes',
                                  value: _formatCount(data.totalRoutes),
                                  deltaLabel: 'Stable',
                                  icon: Icons.alt_route,
                                  accent: _DashboardColors.onSurface,
                                  accentBackground: _DashboardColors.surfaceHighest,
                                  deltaMuted: true,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 1100;
                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Expanded(flex: 2, child: _DashboardTrendCard()),
                                  SizedBox(width: 18),
                                  Expanded(child: _DashboardMapCard()),
                                ],
                              );
                            }
                            return const Column(
                              children: [
                                _DashboardTrendCard(),
                                SizedBox(height: 18),
                                _DashboardMapCard(),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _DashboardTransactionsTable(bookings: bookings),
                      ],
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

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.onNavigate,
    required this.selectedRoute,
  });

  final ValueChanged<String> onNavigate;
  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      color: const Color(0xFFF0F2F2),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _DashboardColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/brand/imetro_logo.png',
                    fit: BoxFit.contain,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I-Metro',
                    style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0C3B2E)),
                  ),
                  Text(
                    'Luxury in Motion',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: _DashboardColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _DashboardNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedRoute == AppRoutes.adminDashboard,
            onTap: () => onNavigate(AppRoutes.adminDashboard),
          ),
          _DashboardNavItem(
            icon: Icons.group,
            label: 'User Management',
            selected: selectedRoute == AppRoutes.adminTotalUsers,
            onTap: () => onNavigate(AppRoutes.adminTotalUsers),
          ),
          _DashboardNavItem(
            icon: Icons.storefront,
            label: 'Merchant Management',
            selected: selectedRoute == AppRoutes.adminMerchantDetails,
            onTap: () => onNavigate(AppRoutes.adminMerchantDetails),
          ),
          _DashboardNavItem(
            icon: Icons.map,
            label: 'Route Management',
            selected: selectedRoute == AppRoutes.adminAvailableRoutes,
            onTap: () => onNavigate(AppRoutes.adminAvailableRoutes),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => onNavigate(AppRoutes.adminAddRoute),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _DashboardColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'New Route',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Divider(height: 32, color: Color(0xFFD7DBD9)),
          _DashboardNavItem(
            icon: Icons.account_circle,
            label: 'Profile',
            dense: true,
            onTap: () => onNavigate(AppRoutes.adminUserDropdown),
          ),
          _DashboardNavItem(
            icon: Icons.settings,
            label: 'Settings',
            dense: true,
            onTap: () => onNavigate(AppRoutes.adminSystemSettings),
          ),
          _DashboardNavItem(
            icon: Icons.logout,
            label: 'Logout',
            dense: true,
            danger: true,
            onTap: () => onNavigate(AppRoutes.adminLogoutConfirmation),
          ),
        ],
      ),
    );
  }
}

class _DashboardNavItem extends StatelessWidget {
  const _DashboardNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.dense = false,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool dense;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? Colors.white.withOpacity(0.6) : Colors.transparent;
    final textColor = danger
        ? _DashboardColors.error
        : selected
            ? _DashboardColors.primary
            : const Color(0xFF62706A);
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 6 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: dense ? 10 : 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: dense ? 12 : 13, fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search operations, routes, or tickets...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7771)),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Color(0xFF6B7771)),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _DashboardColors.error, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Color(0xFF6B7771)),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I-METRO ADMIN',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: _DashboardColors.primary,
                      ),
                    ),
                    Text(
                      'Alex Rivera',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _DashboardColors.surfaceHighest,
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuD99nG7jCqTx63DKKp_LLnlmrvZNf6FFkZ3N8MbeD8cyBQZrucqqLBX9-BVQYQ5cF_ZsTsXNA3eKrjuD2XbvqNBw28zvZMcp6PI9ZaYIeCDFSMqDJnYbQdt9ovAcudMRKql6nimOv0hjUw-k_l2GGq5ye-3LHPgzgtvhHQRd2hd2LFQWJWVBDxDLhYVBAtcWCaRw2s-Bnq7HIJiBjmwInusPZMkPkuXksEP6NZyeQMgGEB9KDpCdtK5G9ia6z9tKl5h3tW2hZoPA8g',
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

class _DashboardFilterButton extends StatelessWidget {
  const _DashboardFilterButton({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _DashboardColors.surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({
    required this.title,
    required this.value,
    required this.deltaLabel,
    required this.icon,
    required this.accent,
    required this.accentBackground,
    this.deltaMuted = false,
  });

  final String title;
  final String value;
  final String deltaLabel;
  final IconData icon;
  final Color accent;
  final Color accentBackground;
  final bool deltaMuted;

  @override
  Widget build(BuildContext context) {
    final deltaColor = deltaMuted ? _DashboardColors.onSurfaceVariant : const Color(0xFF1F9D5B);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
        border: Border(
          bottom: BorderSide(color: accent.withOpacity(0.25), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              Text(
                deltaLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: deltaColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _DashboardTrendCard extends StatelessWidget {
  const _DashboardTrendCard();

  @override
  Widget build(BuildContext context) {
    final heights = [0.4, 0.6, 0.55, 0.85, 0.95, 0.7, 0.45, 0.5, 0.75, 0.65];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Network Usage Trends',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
              Row(
                children: [
                  _LegendDot(color: _DashboardColors.primary, label: 'Subway'),
                  const SizedBox(width: 12),
                  _LegendDot(color: _DashboardColors.secondary, label: 'Light Rail'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < heights.length; i++)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 200 * heights[i],
                      decoration: BoxDecoration(
                        color: i == 4 ? _DashboardColors.primary : _DashboardColors.surfaceLow,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Text(
                    day,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _DashboardColors.onSurfaceVariant,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DashboardMapCard extends StatelessWidget {
  const _DashboardMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCC0emIpuh6pzir7hGWXljItA4m-zjv20A91GVUdRVVUTtd7Stqc4WzsgJh6bpl-Qj122Xl8EpZiiFn-npxLpZiEYvGuu8dopYrQOtAy11Z1l3W-Z0RlMa23sV0KRijCF5w312SZ7_Q_dqe3F6jHH4fRStML22p5ysipGcvAagrBY7JTfQA5oCIfJE8ibYp6abMbeueHcsguMJVZeJg9R3KKcTJy1h08_zRFrVoxBSy4QSU_ma7PisE73ok3VLp4_UXNX5YVZLPSgg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_DashboardColors.primary.withOpacity(0.85), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Network Map',
                    style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View real-time vehicle positioning and line health status.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Launch Live Map',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _DashboardColors.primary,
                        ),
                      ),
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

class _DashboardTransactionsTable extends StatelessWidget {
  const _DashboardTransactionsTable({required this.bookings});

  final List<Map<String, dynamic>> bookings;

  @override
  Widget build(BuildContext context) {
    final total = bookings.length;
    final countLabel = total == 0
        ? 'No tickets yet'
        : 'Total: $total ticket${total == 1 ? '' : 's'}';
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _DashboardColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                const _DashboardTableHeader(),
                const SizedBox(height: 8),
                if (bookings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No transactions yet.',
                      style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                    ),
                  )
                else
                  for (final booking in bookings) _DashboardTransactionRow(booking: booking),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTableHeader extends StatelessWidget {
  const _DashboardTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: _DashboardColors.onSurfaceVariant,
    );
    return Row(
      children: [
        Expanded(flex: 2, child: Text('Booking ID', style: style)),
        Expanded(flex: 3, child: Text('Passenger', style: style)),
        Expanded(flex: 3, child: Text('Route', style: style)),
        Expanded(flex: 2, child: Text('Time', style: style)),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Status', style: style))),
      ],
    );
  }
}

class _DashboardTransactionRow extends StatelessWidget {
  const _DashboardTransactionRow({required this.booking});

  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final name = _bookingUserName(booking);
    final initials = _bookingInitials(booking);
    final status = _bookingStatus(booking);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _bookingId(booking),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _initialsColor(initials),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _bookingRouteLabel(booking),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _bookingTimeAgo(booking),
              style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _StatusChip(status: status),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    Color background;
    Color textColor;
    if (normalized == 'SUCCESS' || normalized == 'CONFIRMED') {
      background = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else if (normalized == 'PENDING') {
      background = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else {
      background = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Text(
        normalized,
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

String _bookingId(Map<String, dynamic> booking) {
  final raw = booking['id']?.toString() ?? '';
  if (raw.isEmpty) return '#IM-0000';
  final cleaned = raw.replaceAll('-', '').toUpperCase();
  final short = cleaned.length >= 6 ? cleaned.substring(0, 6) : cleaned;
  return '#IM-$short';
}

String _bookingRouteLabel(Map<String, dynamic> booking) {
  final route = booking['route'];
  if (route is Map<String, dynamic>) {
    final from = route['fromLocation']?.toString() ?? '';
    final to = route['toLocation']?.toString() ?? '';
    if (from.isNotEmpty && to.isNotEmpty) {
      return '$from -> $to';
    }
  }
  return 'Route';
}

String _bookingFare(Map<String, dynamic> booking) {
  final payment = booking['payment'];
  if (payment is Map<String, dynamic>) {
    final amount = payment['amount'];
    if (amount is num) {
      return _formatCurrency(amount.toDouble());
    }
  }
  return 'NGN 0';
}

String _bookingStatusLabel(Map<String, dynamic> booking) {
  final bookingStatus = booking['status']?.toString();
  if (bookingStatus == 'CANCELLED') {
    return 'Cancelled';
  }
  final payment = booking['payment'];
  if (payment is Map<String, dynamic>) {
    final status = payment['status']?.toString();
    if (status == 'SUCCESS') return 'Completed';
    if (status == 'FAILED') return 'Cancelled';
  }
  return 'Pending';
}

String _bookingTimeAgo(Map<String, dynamic> booking) {
  final createdAt = booking['createdAt'];
  DateTime? parsed;
  if (createdAt is String) {
    parsed = DateTime.tryParse(createdAt);
  } else if (createdAt is DateTime) {
    parsed = createdAt;
  }
  if (parsed == null) return '-';
  final now = DateTime.now();
  final diff = now.difference(parsed);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  return '${parsed.day}/${parsed.month}/${parsed.year}';
}

String _bookingInitials(Map<String, dynamic> booking) {
  final name = _bookingUserName(booking).trim();
  if (name.isEmpty) return 'IM';
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
}

Color _initialsColor(String initials) {
  final palette = [
    _DashboardColors.secondaryContainer,
    _DashboardColors.primaryFixedDim.withOpacity(0.35),
    _DashboardColors.tertiaryFixed.withOpacity(0.35),
    _DashboardColors.surfaceHighest,
  ];
  final index = initials.codeUnitAt(0) % palette.length;
  return palette[index];
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return value.toString();
}

String _formatCurrency(double value) {
  if (value >= 1000000) {
    return 'NGN ${(value / 1000000).toStringAsFixed(2)}M';
  }
  if (value >= 1000) {
    return 'NGN ${(value / 1000).toStringAsFixed(1)}k';
  }
  return 'NGN ${value.toStringAsFixed(0)}';
}

class AdminTotalUsersScreen extends StatefulWidget {
  const AdminTotalUsersScreen({super.key});

  @override
  State<AdminTotalUsersScreen> createState() => _AdminTotalUsersScreenState();
}

class _AdminTotalUsersScreenState extends State<AdminTotalUsersScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminApi.listUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Row(
        children: [
          _DashboardSidebar(
            onNavigate: (route) => Navigator.pushNamed(context, route),
            selectedRoute: AppRoutes.adminTotalUsers,
          ),
          Expanded(
            child: Column(
              children: [
                _UserManagementTopBar(
                  onRefresh: () => setState(() {
                    _usersFuture = AdminApi.listUsers();
                  }),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _usersFuture,
                      builder: (context, snapshot) {
                        final users = snapshot.data ?? [];
                        final totalUsers = users.length;
                        final activeUsers = users.where((user) => user['isActive'] == true).length;
                        final newToday = users.where((user) => _isCreatedToday(user['createdAt'])).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Users',
                                        style: GoogleFonts.manrope(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                          color: _DashboardColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Manage and monitor the transit system's active passenger base and authentication statuses.",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: _DashboardColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _UserActionButton(
                                  label: 'Filter',
                                  icon: Icons.filter_list,
                                  filled: false,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 12),
                                _UserActionButton(
                                  label: 'Add User',
                                  icon: Icons.person_add,
                                  filled: true,
                                  onTap: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 980;
                                if (wide) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _UserStatCard(
                                          title: 'Active Users',
                                          value: _formatCount(activeUsers),
                                          badge: '+4.2%',
                                          badgeFilled: true,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _UserStatCard(
                                          title: 'New Today',
                                          value: _formatCount(newToday),
                                          badge: 'from city hubs',
                                          badgeFilled: false,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: _UserHealthCard(totalUsers: totalUsers),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _UserStatCard(
                                      title: 'Active Users',
                                      value: _formatCount(activeUsers),
                                      badge: '+4.2%',
                                      badgeFilled: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _UserStatCard(
                                      title: 'New Today',
                                      value: _formatCount(newToday),
                                      badge: 'from city hubs',
                                      badgeFilled: false,
                                    ),
                                    const SizedBox(height: 16),
                                    _UserHealthCard(totalUsers: totalUsers),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _UserDirectoryTable(
                              users: users,
                              onUserTap: (userId) => Navigator.pushNamed(
                                context,
                                AppRoutes.adminUserDetails,
                                arguments: userId,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _UserPaginationFooter(totalUsers: totalUsers, shown: users.length),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final twoColumn = constraints.maxWidth >= 900;
                                if (twoColumn) {
                                  return Row(
                                    children: const [
                                      Expanded(child: _UserSecurityCard()),
                                      SizedBox(width: 16),
                                      Expanded(child: _UserRegionCard()),
                                    ],
                                  );
                                }
                                return const Column(
                                  children: [
                                    _UserSecurityCard(),
                                    SizedBox(height: 16),
                                    _UserRegionCard(),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
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

String _userDisplayName(Map<String, dynamic> user) {
  final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
  if (name.isNotEmpty) return name;
  return user['email']?.toString() ?? user['phone']?.toString() ?? 'Unknown';
}

String _userEmail(Map<String, dynamic> user) {
  return user['email']?.toString() ?? user['phone']?.toString() ?? 'unknown@i-metro.app';
}

String _userInitials(Map<String, dynamic> user) {
  final name = _userDisplayName(user);
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return 'IM';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

String _userGender(Map<String, dynamic> user) {
  return user['gender']?.toString() ?? 'N/A';
}

String _userLocation(Map<String, dynamic> user) {
  return user['location']?.toString() ?? 'N/A';
}

bool _isCreatedToday(dynamic createdAt) {
  DateTime? parsed;
  if (createdAt is String) {
    parsed = DateTime.tryParse(createdAt);
  } else if (createdAt is DateTime) {
    parsed = createdAt;
  }
  if (parsed == null) return false;
  final now = DateTime.now();
  return parsed.year == now.year && parsed.month == now.month && parsed.day == now.day;
}

class _UserManagementTopBar extends StatelessWidget {
  const _UserManagementTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search users, IDs, or locations...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
              child: Row(
                children: [
                  Text(
                    'Admin Profile',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _DashboardColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _DashboardColors.surfaceHighest,
                    backgroundImage: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAX8VHnHrZTHZpcw8q_ZtfOZwtcU3YtUXgzssQTVDPzG_DpvLgxPc9skygNx5olqV6fwbF_p6QjHvGmeeEXgBrFl1wmEdxTsVCBRTBNFZ9A9L4zTnY08nfM0Bybcve3P3HQwYGMsOtzkPEl-2E4w-YkDXMDRToz9Bat3zBqCX1zcFomHfx7kdKBP4Gdt1n30aq8iNZayozDen18TRCJBUdrI7o9Rq5F6uVynhHtZ4tCJh4vVECL22OxuwJ4xOIskUf4RkWEVEun2wQ',
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

class _UserActionButton extends StatelessWidget {
  const _UserActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = filled ? _DashboardColors.primary : _DashboardColors.surfaceLow;
    final foreground = filled ? Colors.white : _DashboardColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: filled
              ? [BoxShadow(color: _DashboardColors.primary.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStatCard extends StatelessWidget {
  const _UserStatCard({
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeFilled,
  });

  final String title;
  final String value;
  final String badge;
  final bool badgeFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: _DashboardColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeFilled ? _DashboardColors.primaryFixedDim.withOpacity(0.25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeFilled ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant,
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

class _UserHealthCard extends StatelessWidget {
  const _UserHealthCard({required this.totalUsers});

  final int totalUsers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -24,
            child: Icon(Icons.cloud_done, size: 120, color: Colors.white.withOpacity(0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NETWORK HEALTH',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '99.8% Reliability',
                style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'User authentication servers are performing within optimal latency thresholds. Total users: ${_formatCount(totalUsers)}.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.85)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserDirectoryTable extends StatelessWidget {
  const _UserDirectoryTable({required this.users, required this.onUserTap});

  final List<Map<String, dynamic>> users;
  final ValueChanged<String> onUserTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Directory',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: _DashboardColors.onSurface,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.download, color: _DashboardColors.onSurfaceVariant),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: _DashboardColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                const _UserTableHeader(),
                const SizedBox(height: 6),
                if (users.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No users yet.',
                      style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                    ),
                  )
                else
                  for (final user in users.take(10))
                    _UserTableRow(
                      user: user,
                      onTap: () {
                        final id = user['id']?.toString() ?? '';
                        if (id.isNotEmpty) onUserTap(id);
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTableHeader extends StatelessWidget {
  const _UserTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: _DashboardColors.onSurfaceVariant,
    );
    return Row(
      children: [
        Expanded(flex: 4, child: Text('User', style: style)),
        Expanded(flex: 2, child: Text('Gender', style: style)),
        Expanded(flex: 3, child: Text('Location', style: style)),
        Expanded(flex: 2, child: Text('Status', style: style)),
        Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: style))),
      ],
    );
  }
}

class _UserTableRow extends StatelessWidget {
  const _UserTableRow({required this.user, this.onTap});

  final Map<String, dynamic> user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = _userDisplayName(user);
    final email = _userEmail(user);
    final initials = _userInitials(user);
    final status = user['isActive'] == true;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _DashboardColors.surfaceHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _userGender(user),
                style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: _DashboardColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _userLocation(user),
                      style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _UserStatusPill(active: status),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: _DashboardColors.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStatusPill extends StatelessWidget {
  const _UserStatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final background = active ? _DashboardColors.primaryFixedDim.withOpacity(0.3) : _DashboardColors.surfaceHighest;
    final text = active ? 'Active' : 'Inactive';
    final dotColor = active ? _DashboardColors.primary : _DashboardColors.outlineVariant;
    final textColor = active ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _UserPaginationFooter extends StatelessWidget {
  const _UserPaginationFooter({required this.totalUsers, required this.shown});

  final int totalUsers;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final totalLabel = totalUsers == 0 ? '0' : _formatCount(totalUsers);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing 1 to $shown of $totalLabel users',
            style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
          ),
          Row(
            children: [
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.chevron_left, color: _DashboardColors.onSurfaceVariant),
              ),
              _PageChip(label: '1', active: true),
              _PageChip(label: '2'),
              _PageChip(label: '3'),
              Text('...', style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant)),
              _PageChip(label: '120'),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageChip extends StatelessWidget {
  const _PageChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? _DashboardColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _UserSecurityCard extends StatelessWidget {
  const _UserSecurityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _DashboardColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security, size: 18, color: _DashboardColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Security Overview',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '24 users requested password resets in the last hour. All requests were verified through multi-factor authentication systems without incident.',
            style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            'View Audit Logs',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _DashboardColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRegionCard extends StatelessWidget {
  const _UserRegionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _DashboardColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map, size: 18, color: _DashboardColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Regional Density',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.65,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: _DashboardColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Europe (Central)',
                style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
              ),
              Text(
                '6,120 users',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.text, required this.selected, this.onTap});

  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? Colors.black : const Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 6),
          if (selected)
            Container(height: 2, width: 70, color: Colors.black)
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

String _formatAccountAge(dynamic createdAt) {
  DateTime? parsed;
  if (createdAt is String) {
    parsed = DateTime.tryParse(createdAt);
  } else if (createdAt is DateTime) {
    parsed = createdAt;
  }
  if (parsed == null) return '0.0y';
  final now = DateTime.now();
  final days = now.difference(parsed).inDays;
  final years = days / 365;
  return '${years.toStringAsFixed(1)}y';
}

class _UserDetailsTopBar extends StatelessWidget {
  const _UserDetailsTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 360,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceHighest,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search transit data...',
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _CircleIconButton(icon: Icons.refresh, onTap: onRefresh),
          const SizedBox(width: 8),
          _CircleIconButton(icon: Icons.notifications, onTap: () {}),
          const SizedBox(width: 8),
          _CircleIconButton(icon: Icons.help_outline, onTap: () {}),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: _DashboardColors.surfaceHighest,
                backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDSVpJ1TwlmhLzH6F3_O9QbK8x4zdKo6uFShEMCikyOtlV__nw2EvaZL5MFXX3A4RpoTlE2q1xNJEccSHDb_Dj3kygZ61qb7zQB1YXpSjpIqr0EYCsJltTBVDeP5PYpPYPZuh8euLsh63XW_OIQHXLgV23hTD8MYY-5NA2iYu48FhPWHGjoytbfA_ryaxR1AtOOhiPIOVnWCh1EmR0QnA26bSHDmbYnWaxTrah7kyEh-hGnFs-qF4lgen8sCvlPppdlCQEzRioXtv0',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _DashboardColors.surfaceLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18, color: _DashboardColors.onSurfaceVariant),
      ),
    );
  }
}

class _UserBreadcrumbs extends StatelessWidget {
  const _UserBreadcrumbs({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          child: Text(
            'User Management',
            style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 14, color: _DashboardColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          'User Details',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
        ),
      ],
    );
  }
}

class _UserDetailsActionButton extends StatelessWidget {
  const _UserDetailsActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.destructive = false,
    this.loading = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool destructive;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = filled
        ? (destructive ? _DashboardColors.error : _DashboardColors.primary)
        : Colors.transparent;
    final textColor = filled ? Colors.white : _DashboardColors.onSurface;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? Colors.transparent : _DashboardColors.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: filled
              ? [BoxShadow(color: background.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              loading ? 'Working...' : label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserIdentityCard extends StatelessWidget {
  const _UserIdentityCard({
    required this.name,
    required this.email,
    required this.isActive,
    required this.totalTrips,
    required this.loyaltyPoints,
    required this.accountAge,
  });

  final String name;
  final String email;
  final bool isActive;
  final int totalTrips;
  final int loyaltyPoints;
  final String accountAge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAWxHpnm0xd5cbJQ2frtCBRkxGFpN7LssfAsHZIk7qB8TlsCVOrEl8p12jMBSScCV6Q8GwosXV5lfW2AGPx46d9WIgGO8QewboUWEV3VeeeUprFWguX7ChPPp6MXAGRjEgQYX-d5Qt35xzwd2A-ktaUjB8YyxwAUp6HlG9794MweUwIYeSpkYr9yQeYnj-SmF8P74U_ckqBK1NEPNFFLTx0BkeignWAoDCJJZ2-XfiXsOGqgQ26e-xHJWUkTl3wQuItgJfdphgQyr0',
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: GoogleFonts.manrope(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: _DashboardColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _DashboardColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: _DashboardColors.primary.withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      isActive ? 'Active Member' : 'Inactive Member',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                        color: _DashboardColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.alternate_email, size: 14, color: _DashboardColors.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _UserMetricTile(
                        label: 'Total Trips',
                        value: _formatCount(totalTrips),
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UserMetricTile(
                        label: 'Loyalty Points',
                        value: _formatCount(loyaltyPoints),
                        icon: Icons.stars,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UserMetricTile(
                        label: 'Account Age',
                        value: accountAge,
                        icon: Icons.history,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMetricTile extends StatelessWidget {
  const _UserMetricTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _DashboardColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: _DashboardColors.primaryContainer),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserContactCard extends StatelessWidget {
  const _UserContactCard({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Details',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _DashboardColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ContactRow(
            icon: Icons.phone,
            title: 'Mobile Number',
            value: phone,
          ),
          const SizedBox(height: 12),
          const _ContactRow(
            icon: Icons.location_on,
            title: 'Primary Address',
            value: '742 Metro Ave, Suite 400\nCentral City, CC 90210',
          ),
          const SizedBox(height: 12),
          const _ContactRow(
            icon: Icons.credit_card,
            title: 'Payment Method',
            value: 'Card ending in **** 9012',
          ),
          const Spacer(),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat, size: 18, color: _DashboardColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Send Notification',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: _DashboardColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserBookingHistoryTable extends StatelessWidget {
  const _UserBookingHistoryTable({required this.bookings});

  final List<Map<String, dynamic>> bookings;

  @override
  Widget build(BuildContext context) {
    final rows = bookings.take(3).toList();
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking History',
                      style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last 10 transactions and journey logs',
                      style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _MiniAction(label: 'Filter', icon: Icons.filter_list),
                    const SizedBox(width: 8),
                    _MiniAction(label: 'Export CSV', icon: Icons.download),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const _UserBookingHeader(),
                const SizedBox(height: 8),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No bookings yet.',
                      style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                    ),
                  )
                else
                  for (final booking in rows) _UserBookingRow(booking: booking),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLowest,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: _DashboardColors.surfaceLow)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 1-${rows.length} of ${_formatCount(bookings.length)} trips',
                  style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                ),
                Row(
                  children: [
                    _PageMiniButton(enabled: false, icon: Icons.chevron_left),
                    const SizedBox(width: 6),
                    _MiniPage(label: '1', active: true),
                    _MiniPage(label: '2'),
                    _MiniPage(label: '3'),
                    _PageMiniButton(enabled: true, icon: Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _DashboardColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
        ],
      ),
    );
  }
}

class _UserBookingHeader extends StatelessWidget {
  const _UserBookingHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: _DashboardColors.onSurfaceVariant,
    );
    return Row(
      children: [
        Expanded(flex: 2, child: Text('Journey ID', style: style)),
        Expanded(flex: 3, child: Text('Date & Time', style: style)),
        Expanded(flex: 4, child: Text('Route / Service', style: style)),
        Expanded(flex: 2, child: Text('Duration', style: style)),
        Expanded(flex: 2, child: Text('Fare', style: style)),
        Expanded(flex: 2, child: Text('Status', style: style)),
        Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: style))),
      ],
    );
  }
}

class _UserBookingRow extends StatelessWidget {
  const _UserBookingRow({required this.booking});

  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(booking['createdAt']?.toString());
    final time = _formatTime(booking['createdAt']?.toString());
    final routeInfo = _bookingRouteLabel(booking);
    final fare = _bookingFare(booking);
    final status = _bookingStatusLabel(booking);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _bookingId(booking),
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                ),
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _DashboardColors.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_subway, size: 16, color: _DashboardColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeInfo,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                      ),
                      Text(
                        'Zone 1 -> Zone 4',
                        style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '--',
              style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fare,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
            ),
          ),
          Expanded(
            flex: 2,
            child: _UserStatusChip(status: status),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 18, color: _DashboardColors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserStatusChip extends StatelessWidget {
  const _UserStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    if (status == 'Completed') {
      background = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else if (status == 'Cancelled') {
      background = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF4B5563);
    } else {
      background = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: textColor, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _PageMiniButton extends StatelessWidget {
  const _PageMiniButton({required this.enabled, required this.icon});

  final bool enabled;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DashboardColors.outlineVariant),
      ),
      child: Icon(icon, size: 14, color: enabled ? _DashboardColors.onSurfaceVariant : _DashboardColors.outlineVariant),
    );
  }
}

class _MiniPage extends StatelessWidget {
  const _MiniPage({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? _DashboardColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? _DashboardColors.primary : _DashboardColors.outlineVariant),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _UserAdminNotesCard extends StatelessWidget {
  const _UserAdminNotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Internal Admin Notes',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  color: _DashboardColors.onSurface,
                ),
              ),
              Text(
                'Add Note',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User requested fare refund for trip #IM-28114 due to station delay. Refund processed via dashboard.',
                  style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: _DashboardColors.onSurface),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Added by: Admin Sarah W.',
                      style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                    ),
                    Text(
                      'Oct 22, 2023',
                      style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSecuritySummaryCard extends StatelessWidget {
  const _UserSecuritySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Security',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: _DashboardColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _SecurityRow(label: 'Last Login', value: '2 hours ago (203.0.113.42)'),
          _SecurityRow(
            label: 'Two-Factor Auth',
            value: 'Enabled',
            highlight: true,
          ),
          _SecurityRow(label: 'Device Count', value: '2 Registered Devices'),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
          ),
          if (highlight)
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A)),
                ),
              ],
            )
          else
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
            ),
        ],
      ),
    );
  }
}

String _formatMerchantOnboarding(dynamic createdAt) {
  DateTime? parsed;
  if (createdAt is String) {
    parsed = DateTime.tryParse(createdAt);
  } else if (createdAt is DateTime) {
    parsed = createdAt;
  }
  if (parsed == null) return 'Oct 2021';
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
    'Dec',
  ];
  final month = months[parsed.month - 1];
  return '$month ${parsed.year}';
}

class _MerchantTopBar extends StatelessWidget {
  const _MerchantTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search transactions, routes or IDs...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _DashboardColors.error, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Admin Profile',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _DashboardColors.onSurface,
                        ),
                      ),
                      Text(
                        'Lead Operator',
                        style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _DashboardColors.surfaceHighest,
                    backgroundImage: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAN36OWD_m3A-5h65_Bk9J8wbmwt7I7wa9Ocu_ro_0_ZJfJzEuWbWCeVbnpf-uiYrckXcyRxFFe3CYEoSUKhF7PQGFyGfaFJMsQCPVSsAEeC7x4ly9-FcO7Lf-CtpKu8YPMYmyv31aBe10aDVDReVtT37igSDeksdMlDJxgqSfqP751dMjlJxDa9roRS46zOtVpoR2BnH-YdX7G1D9UwebJAbkKn2h9r6u1bvwkeEz9xmszJBluF-vyiDN7KY4AlIfaJ-ZapFWq5B4',
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

class _MerchantHeader extends StatelessWidget {
  const _MerchantHeader({required this.name, this.onBack});

  final String name;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onBack,
                  child: Text(
                    'Merchants',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: _DashboardColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 14, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Details',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: _DashboardColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: _DashboardColors.onSurface),
            ),
          ],
        ),
        Row(
          children: [
            _MerchantActionButton(
              label: 'Edit Profile',
              filled: false,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _MerchantActionButton(
              label: 'Generate Report',
              filled: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _MerchantActionButton extends StatelessWidget {
  const _MerchantActionButton({
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = filled
        ? const LinearGradient(
            colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? null : Colors.transparent,
          gradient: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? Colors.transparent : _DashboardColors.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: filled
              ? [BoxShadow(color: _DashboardColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : _DashboardColors.primary,
          ),
        ),
      ),
    );
  }
}

class _MerchantInfoColumn extends StatelessWidget {
  const _MerchantInfoColumn({
    required this.name,
    required this.email,
    required this.phone,
    required this.merchantId,
    required this.onboarding,
  });

  final String name;
  final String email;
  final String phone;
  final String merchantId;
  final String onboarding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MerchantInfoCard(
          name: name,
          email: email,
          phone: phone,
          merchantId: merchantId,
          onboarding: onboarding,
        ),
        const SizedBox(height: 20),
        const _MerchantRoutesCard(),
      ],
    );
  }
}

class _MerchantInfoCard extends StatelessWidget {
  const _MerchantInfoCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.merchantId,
    required this.onboarding,
  });

  final String name;
  final String email;
  final String phone;
  final String merchantId;
  final String onboarding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjC00RzTISaQfjzJN202Z0QKRcfaT4HQYj4E4lboL3I-dce7GosxO0_qpLn-MNofyLi3QGW-HRMWqGm0vAX4Ux83Ievj0W_YDF-cGqHxSd6oQcnsd1T2KsuYJlEkkySftcclolXUk68JO0iAFaSo5HRndmImcAII7gdQ2GyaZobGzKdxPtS7ssHAwJt4OyuY5WBpXJ9rU_RYNO1E5r9R2EhQPAbymYT3gQZmf3KgZhLon7h_TsNa_CJMMqiQRb6wgtIfdRRzwY0G8',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                        ),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuC9lQ1-MnEdBvvf5iziRAJ_-6AXO0djEaRi06kMBN4Q_Fnf93GNcEWzXvAkmlMmwOXSBkl3SbDH7WDP7Vvjn1TFusO_P1zhMmHcFdbga5Z-UlcwwVgY7_4THHeBSdNwcF8-hkAraZTclx7mwnSTZ1QNf0GMcmaSLDzyfY-OMIHGVwBHfju8GpXhsTuCt8aNGzXGB-D0rl2aq2pWCDWn8JPcQosZghwJd07DtHdZ0GfQyv_g5QCDH2diiDJQmNYvymQI2iWcGdIe2EQ',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _DashboardColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Verified Merchant',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: _DashboardColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _MerchantContactRow(
                  icon: Icons.alternate_email,
                  title: 'Email Address',
                  value: email,
                ),
                const SizedBox(height: 12),
                _MerchantContactRow(
                  icon: Icons.call,
                  title: 'Direct Line',
                  value: phone,
                ),
                const SizedBox(height: 12),
                const _MerchantContactRow(
                  icon: Icons.pin_drop,
                  title: 'Office Address',
                  value: 'Suite 400, Level 2, Terminal A',
                ),
                const SizedBox(height: 20),
                Divider(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  'Business Details',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: _DashboardColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MerchantBusinessTile(
                        label: 'Merchant ID',
                        value: merchantId,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MerchantBusinessTile(
                        label: 'Onboarding',
                        value: onboarding,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _MerchantBusinessTile(
                        label: 'Category',
                        value: 'Retail/Food',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MerchantRiskTile(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantContactRow extends StatelessWidget {
  const _MerchantContactRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 16, color: _DashboardColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
              ),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MerchantBusinessTile extends StatelessWidget {
  const _MerchantBusinessTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 9, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _MerchantRiskTile extends StatelessWidget {
  const _MerchantRiskTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RISK TIER',
            style: GoogleFonts.inter(fontSize: 9, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: _DashboardColors.primaryFixedDim, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                'Low',
                style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MerchantRoutesCard extends StatelessWidget {
  const _MerchantRoutesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Associated Routes',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: _DashboardColors.onSurfaceVariant,
                ),
              ),
              Text(
                'View Map',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _MerchantRouteRow(
            initials: 'G-L',
            title: 'Green Line (North)',
            subtitle: 'Station: Central Terminal',
            color: Color(0xFFD1FAE5),
            textColor: Color(0xFF065F46),
          ),
          const _MerchantRouteRow(
            initials: 'E-X',
            title: 'Express Airport Link',
            subtitle: 'Station: Gate 4 Concourse',
            color: Color(0xFFDBEAFE),
            textColor: Color(0xFF1E3A8A),
          ),
          const _MerchantRouteRow(
            initials: 'O-C',
            title: 'Outer Circle Bus',
            subtitle: 'Stop: Mall West Entry',
            color: Color(0xFFFED7AA),
            textColor: Color(0xFF9A3412),
          ),
        ],
      ),
    );
  }
}

class _MerchantRouteRow extends StatelessWidget {
  const _MerchantRouteRow({
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  final String initials;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: _DashboardColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _MerchantStatsAndHistory extends StatelessWidget {
  const _MerchantStatsAndHistory({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            if (wide) {
              return Row(
                children: const [
                  Expanded(
                    child: _MerchantStatCard(
                      title: 'Monthly Volume',
                      value: 'NGN 142.5k',
                      change: '+8.2%',
                      highlight: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MerchantStatCard(
                      title: 'Avg Transaction',
                      value: 'NGN 24.12',
                      change: '-0.4%',
                      highlight: false,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MerchantStatCard(
                      title: 'Commission Rate',
                      value: '2.1%',
                      change: 'Tier 1',
                      highlight: false,
                      chip: true,
                    ),
                  ),
                ],
              );
            }
            return const Column(
              children: [
                _MerchantStatCard(
                  title: 'Monthly Volume',
                  value: 'NGN 142.5k',
                  change: '+8.2%',
                  highlight: true,
                ),
                SizedBox(height: 12),
                _MerchantStatCard(
                  title: 'Avg Transaction',
                  value: 'NGN 24.12',
                  change: '-0.4%',
                  highlight: false,
                ),
                SizedBox(height: 12),
                _MerchantStatCard(
                  title: 'Commission Rate',
                  value: '2.1%',
                  change: 'Tier 1',
                  highlight: false,
                  chip: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        _MerchantTransactionHistory(name: name),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            if (wide) {
              return Row(
                children: const [
                  Expanded(child: _MerchantDeviceDistributionCard()),
                  SizedBox(width: 16),
                  Expanded(child: _MerchantLocationAnalyticsCard()),
                ],
              );
            }
            return const Column(
              children: [
                _MerchantDeviceDistributionCard(),
                SizedBox(height: 16),
                _MerchantLocationAnalyticsCard(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MerchantStatCard extends StatelessWidget {
  const _MerchantStatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.highlight,
    this.chip = false,
  });

  final String title;
  final String value;
  final String change;
  final bool highlight;
  final bool chip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
        border: highlight ? Border(left: BorderSide(color: _DashboardColors.primary, width: 4)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _DashboardColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: _DashboardColors.onSurface),
              ),
              const SizedBox(width: 6),
              if (chip)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _DashboardColors.primaryFixedDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
                  ),
                )
              else
                Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: highlight ? _DashboardColors.primaryContainer : _DashboardColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MerchantTransactionHistory extends StatelessWidget {
  const _MerchantTransactionHistory({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: _DashboardColors.onSurface),
                ),
                Row(
                  children: const [
                    _MerchantIconButton(icon: Icons.filter_list),
                    SizedBox(width: 8),
                    _MerchantIconButton(icon: Icons.download),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: const [
                _MerchantTransactionHeader(),
                _MerchantTransactionRow(
                  id: 'TXN-49201',
                  date: 'May 24, 09:12 AM',
                  customer: 'U-882-9',
                  amount: 'NGN 45.00',
                  status: 'Settled',
                ),
                _MerchantTransactionRow(
                  id: 'TXN-49198',
                  date: 'May 24, 08:45 AM',
                  customer: 'U-102-4',
                  amount: 'NGN 12.50',
                  status: 'Settled',
                ),
                _MerchantTransactionRow(
                  id: 'TXN-49195',
                  date: 'May 23, 11:58 PM',
                  customer: 'U-332-1',
                  amount: 'NGN 89.90',
                  status: 'Pending',
                ),
                _MerchantTransactionRow(
                  id: 'TXN-49190',
                  date: 'May 23, 10:20 PM',
                  customer: 'U-094-8',
                  amount: 'NGN 4.20',
                  status: 'Settled',
                ),
                _MerchantTransactionRow(
                  id: 'TXN-49182',
                  date: 'May 23, 07:15 PM',
                  customer: 'U-772-X',
                  amount: 'NGN 156.00',
                  status: 'Flagged',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _DashboardColors.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 5 of 1,280 transactions',
                  style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                ),
                Row(
                  children: [
                    _PageMiniButton(enabled: true, icon: Icons.chevron_left),
                    const SizedBox(width: 6),
                    _MiniPage(label: '1', active: true),
                    _MiniPage(label: '2'),
                    _MiniPage(label: '3'),
                    _PageMiniButton(enabled: true, icon: Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantTransactionHeader extends StatelessWidget {
  const _MerchantTransactionHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: _DashboardColors.onSurfaceVariant);
    return Row(
      children: [
        Expanded(flex: 2, child: Text('Transaction ID', style: style)),
        Expanded(flex: 3, child: Text('Date & Time', style: style)),
        Expanded(flex: 2, child: Text('Customer ID', style: style)),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Amount', style: style))),
        Expanded(flex: 2, child: Text('Status', style: style)),
        const SizedBox(width: 20),
      ],
    );
  }
}

class _MerchantTransactionRow extends StatelessWidget {
  const _MerchantTransactionRow({
    required this.id,
    required this.date,
    required this.customer,
    required this.amount,
    required this.status,
  });

  final String id;
  final String date;
  final String customer;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(id, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface)),
          ),
          Expanded(
            flex: 3,
            child: Text(date, style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant)),
          ),
          Expanded(
            flex: 2,
            child: Text(customer, style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(amount, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface)),
            ),
          ),
          Expanded(
            flex: 2,
            child: _MerchantStatusChip(status: status),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, size: 18, color: _DashboardColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MerchantStatusChip extends StatelessWidget {
  const _MerchantStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    if (status == 'Settled') {
      background = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF047857);
    } else if (status == 'Pending') {
      background = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
    } else {
      background = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

class _MerchantIconButton extends StatelessWidget {
  const _MerchantIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Icon(icon, size: 18, color: _DashboardColors.onSurfaceVariant),
    );
  }
}

class _MerchantDeviceDistributionCard extends StatelessWidget {
  const _MerchantDeviceDistributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Distribution',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _DashboardColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _DashboardColors.surfaceLow, width: 12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('72%', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('Mobile', style: GoogleFonts.inter(fontSize: 9, color: _DashboardColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: const [
                    _DeviceLegendItem(label: 'I-Metro Pass', value: '72%', color: _DashboardColors.primary),
                    SizedBox(height: 8),
                    _DeviceLegendItem(label: 'Direct NFC', value: '18%', color: _DashboardColors.primaryContainer),
                    SizedBox(height: 8),
                    _DeviceLegendItem(label: 'QR Code', value: '10%', color: _DashboardColors.primaryFixedDim),
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

class _DeviceLegendItem extends StatelessWidget {
  const _DeviceLegendItem({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(value, style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant)),
      ],
    );
  }
}

class _MerchantLocationAnalyticsCard extends StatelessWidget {
  const _MerchantLocationAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Analytics',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: _DashboardColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCv1MWljK0n9zAx5AiEKRN-ZLHw8cFtudLEeJj-0bKJkd98dH4vYvbVshVVWrFlkROtLhNGx2I9zbNcDf5P_rfdWLdaIF68XWvlbbqn_SFm-JixTjJtUmL7RzM08T47ceEBRV_1fD8IKfRoivJhMYxoaxpyhW7ntv15oCfOr4viSVcKi6VgCK2EL04g9R-cgb6oemzQKyHpKc0kCe0N3jXRT_YOQin6HVFA-VkIjQCe2Nv0uJwqgECe-a4XBw--NFT4EobF_BeaLJc',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Zone 1 Hub',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, size: 16, color: _DashboardColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Peak: 12:00 - 14:00',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                'Heatmap',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutesTopBar extends StatelessWidget {
  const _RoutesTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search routes, stations, or IDs...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _DashboardColors.error, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ADMIN',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: _DashboardColors.onSurface,
                      ),
                    ),
                    Text(
                      'Sarah Jenkins',
                      style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _DashboardColors.surfaceHighest,
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDzu_YTiaboKghg-TCuFfOvGH8Sh_p-LTiG332iZUvSAeKQMu5Hpj468h7DfUVYxxp6sXhtz3ef3SYJqtcfKNaf2ZnxBC3yHMu9unS8WpfbQN8_WHYgmrWgEi6_VU6280zR25D5D9qCX3c2tCFRnPcpN1TmR8KC4kwdBvOCIKu39IMTpGvGqeI_MEvT-P9Su1dF0T5M2GU-Y7tTtrCMgp6G_DkFEgg4KjAaGov1CYoj0LzYRJQ1vDkJomusNHeDNKI6yGbKsiTahkQ',
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

class _RoutesHeader extends StatelessWidget {
  const _RoutesHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Admin',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 6),
                  Text('/', style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
                  const SizedBox(width: 6),
                  Text(
                    'Routes',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Route Management',
                style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage and monitor active transit arteries across the metropolitan area.',
                style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Add New Transit Route',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoutesCoverageCard extends StatelessWidget {
  const _RoutesCoverageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F7EF),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Network Coverage',
                style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: '1,240',
                  style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                  children: [
                    TextSpan(
                      text: ' km',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 14, color: _DashboardColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '+4.2% from last month',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutesStatCard extends StatelessWidget {
  const _RoutesStatCard({
    required this.title,
    required this.value,
    this.progress,
    this.showDots = false,
  });

  final String title;
  final String value;
  final double? progress;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
          const SizedBox(height: 12),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 6,
                backgroundColor: _DashboardColors.surfaceHighest,
                color: _DashboardColors.primary,
              ),
            )
          else if (showDots)
            Row(
              children: [
                _DotIndicator(active: false),
                _DotIndicator(active: false),
                _DotIndicator(active: true),
              ],
            ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? _DashboardColors.primary : _DashboardColors.primary.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RoutesTable extends StatelessWidget {
  const _RoutesTable({
    required this.routes,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> routes;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.alt_route, color: _DashboardColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Available Routes',
                      style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    _RoutesTableAction(label: 'Filter', icon: Icons.filter_list),
                    SizedBox(width: 8),
                    _RoutesTableAction(label: 'Export', icon: Icons.download),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                const _RoutesTableHeader(),
                const SizedBox(height: 8),
                if (routes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No routes yet.',
                      style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                    ),
                  )
                else
                  for (final route in routes)
                    _RoutesTableRow(
                      route: route,
                      onEdit: () => onEdit(route),
                      onDelete: () => onDelete(route['id']?.toString() ?? ''),
                    ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _DashboardColors.surfaceLow)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 1-${routes.length} of ${routes.length} routes',
                  style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                ),
                Row(
                  children: [
                    _PageMiniButton(enabled: false, icon: Icons.chevron_left),
                    const SizedBox(width: 6),
                    _MiniPage(label: '1', active: true),
                    _MiniPage(label: '2'),
                    _MiniPage(label: '3'),
                    _PageMiniButton(enabled: true, icon: Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutesTableHeader extends StatelessWidget {
  const _RoutesTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: _DashboardColors.onSurfaceVariant,
    );
    return Row(
      children: [
        Expanded(flex: 2, child: Text('Route ID', style: style)),
        Expanded(flex: 3, child: Text('Pickup Point', style: style)),
        Expanded(flex: 3, child: Text('Destination', style: style)),
        Expanded(flex: 2, child: Text('Status', style: style)),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Price', style: style))),
        const SizedBox(width: 24),
      ],
    );
  }
}

class _RoutesTableRow extends StatelessWidget {
  const _RoutesTableRow({
    required this.route,
    this.onEdit,
    this.onDelete,
  });

  final Map<String, dynamic> route;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = _routeStatus(route);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _routeId(route),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _RouteLocationBlock(
              title: route['fromLocation']?.toString() ?? 'Pickup',
              subtitle: 'Gate 4, Hub A',
            ),
          ),
          Expanded(
            flex: 3,
            child: _RouteLocationBlock(
              title: route['toLocation']?.toString() ?? 'Destination',
              subtitle: 'Arrival Hall B',
            ),
          ),
          Expanded(
            flex: 2,
            child: _RouteStatusChip(status: status),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _routePrice(route),
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit ?? onDelete,
            icon: const Icon(Icons.more_vert, size: 18, color: _DashboardColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RouteLocationBlock extends StatelessWidget {
  const _RouteLocationBlock({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _RouteStatusChip extends StatelessWidget {
  const _RouteStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color dotColor;
    Color textColor;
    if (status == 'Active') {
      background = const Color(0xFFD1FAE5);
      dotColor = const Color(0xFF059669);
      textColor = const Color(0xFF065F46);
    } else if (status == 'Maintenance') {
      background = const Color(0xFFFEF3C7);
      dotColor = const Color(0xFFD97706);
      textColor = const Color(0xFF92400E);
    } else {
      background = const Color(0xFFE5E7EB);
      dotColor = const Color(0xFF94A3B8);
      textColor = const Color(0xFF475569);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _RoutesTableAction extends StatelessWidget {
  const _RoutesTableAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RoutesMapPanel extends StatelessWidget {
  const _RoutesMapPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCLbuVfRq0ZatNvIywEvlWTCJMaCsZqUkhVYS0yyf_xdiZKg755hAFJugJuihayHLZf0kBjcSaMAQc0J75gBvLe2dKOmyQBIXx5xbcLQwLKOmzFntC0kk6FMB9aUax93vM1ZsSJOWF1OOza3fMsvJ-QQaERX6kN26mr0H-Y2Utvi25ii5KqxLRSUfC9-aOvxXFxoKU0NP1531ix8_3pU8TRUonZAyAycxQiBCBUgZ_0ZgZZs7hoaLO4Q0QnyvCbiG0WP50Nw2fEm2c',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Map Live',
                      style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 220,
                      child: Text(
                        'Visualizing high-traffic congestion points in real-time. RT-5022 maintenance is affecting 14% of North traffic.',
                        style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Full Network Insights',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14, color: _DashboardColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutesInsightPanel extends StatelessWidget {
  const _RoutesInsightPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _RoutesAiCard(),
        SizedBox(height: 16),
        _RoutesHealthCard(),
      ],
    );
  }
}

class _AddRouteTopBar extends StatelessWidget {
  const _AddRouteTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search routes, schedules, or transit IDs...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'I-Metro Admin',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: _DashboardColors.onSurface,
                        ),
                      ),
                      Text(
                        'Fleet Manager',
                        style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _DashboardColors.surfaceHighest,
                    backgroundImage: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA9F-W19-WhUzKzYJng_gANBfAU3ms_19CbA96r9AwR2RH69zlR8wR3kOUQwiRyb5QJc6aMyzwBrCtDwGDwohbFCJ1KnBEWrFhogbc48mYUZlAIC1V_yUlIrJ9cNHHCq36BuCmXhpKrx2Nqwgr24Qq1EUfY_v91D7yPRW_QMVBu4MSPuvdEVvkYM1JEgIfMiY80fXx0uGxxckfI18hpVojQjvfh0JZ7ZKpVHVY6HUko99fl1sCqSeTuHEH_ZlbXlQpXDv9Psy4EpXw',
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

class _AddRouteFormPanel extends StatefulWidget {
  const _AddRouteFormPanel({
    required this.fromController,
    required this.toController,
    required this.priceController,
    required this.loading,
    required this.onSubmit,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController priceController;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  State<_AddRouteFormPanel> createState() => _AddRouteFormPanelState();
}

class _AddRouteFormPanelState extends State<_AddRouteFormPanel> {
  String _frequency = 'Every 15 minutes';
  final Map<String, bool> _days = {
    'Mon-Fri': true,
    'Saturday': false,
    'Sunday': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Route Specifications',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _DashboardColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AddRouteField(
                    label: 'Pickup location',
                    hint: 'e.g. Grand Central Station',
                    icon: Icons.location_on,
                    iconColor: _DashboardColors.primary,
                    controller: widget.fromController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AddRouteField(
                    label: 'Destination',
                    hint: 'e.g. Westside Terminal',
                    icon: Icons.near_me,
                    iconColor: _DashboardColors.error,
                    controller: widget.toController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AddRouteField(
                    label: 'Price',
                    hint: '0.00',
                    icon: Icons.payments,
                    suffix: 'NGN',
                    controller: widget.priceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Frequency',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _DashboardColors.surfaceHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _frequency,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: const [
                              DropdownMenuItem(value: 'Every 15 minutes', child: Text('Every 15 minutes')),
                              DropdownMenuItem(value: 'Every 30 minutes', child: Text('Every 30 minutes')),
                              DropdownMenuItem(value: 'Hourly', child: Text('Hourly')),
                              DropdownMenuItem(value: 'Peak hours only', child: Text('Peak hours only')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _frequency = value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Operational Days',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.keys.map((day) {
                final selected = _days[day] ?? false;
                return GestureDetector(
                  onTap: () => setState(() => _days[day] = !selected),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _DashboardColors.primaryContainer : _DashboardColors.surfaceHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : _DashboardColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.fromController.clear();
                    widget.toController.clear();
                    widget.priceController.clear();
                  },
                  child: Text(
                    'Discard',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _DashboardColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.loading ? null : widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _DashboardColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.loading ? 'Saving...' : 'Save Route'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRouteField extends StatelessWidget {
  const _AddRouteField({
    required this.label,
    required this.hint,
    required this.icon,
    this.iconColor,
    this.suffix,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final Color? iconColor;
  final String? suffix;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? _DashboardColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  ),
                ),
              ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddRoutePreviewPanel extends StatelessWidget {
  const _AddRoutePreviewPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AddRouteMapPreview(),
        SizedBox(height: 16),
        _AddRouteAnalyticsCard(),
        SizedBox(height: 16),
        _AddRouteDidYouKnowCard(),
      ],
    );
  }
}

class _AddRouteMapPreview extends StatelessWidget {
  const _AddRouteMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAN9srk-QhnM8VuqObgVcAUqi-GdLkZ3LLSAmsDyD8aznyZBRRyA8pT92Y44rcQSUcK26JFw3363RLPBrN08NLE5jlc8MOPjqxfzsw_J4CCq9fgJWqLw57SdtF0H02lY0nSw4dv5DlBeLd1p8RRNSzR0HKfn-xjuBigJA2sKrlciHreuHYW2f5sYA0fvU-TK06VN_VtSpv4oCY2WK8gc48WcfNQk4bkV36rnDQI-ORWlcuHat-lAU2dxPC-gX61tMBc8JjseFR5Bgo',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _DashboardColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Live Preview',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visualizer',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The route map will automatically update based on your pickup and destination coordinates.',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRouteAnalyticsCard extends StatelessWidget {
  const _AddRouteAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: _DashboardColors.primary),
              const SizedBox(width: 8),
              Text(
                'Route Analytics',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AnalyticsRow(label: 'Est. Capacity', value: '1,200/day'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.66,
              minHeight: 6,
              backgroundColor: _DashboardColors.surfaceHighest,
              color: _DashboardColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _AnalyticsRow(label: 'Carbon Offset', value: 'High Impact', valueColor: const Color(0xFF10B981)),
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  const _AnalyticsRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant)),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor ?? _DashboardColors.onSurface),
        ),
      ],
    );
  }
}

class _AddRouteDidYouKnowCard extends StatelessWidget {
  const _AddRouteDidYouKnowCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.eco, size: 120, color: Colors.white.withOpacity(0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Did you know?',
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Each new metro route added to the I-Metro network reduces city traffic congestion by an average of 4.2% within the first six months.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _routeDisplayId(String? raw) {
  if (raw == null || raw.isEmpty) return 'RT-402';
  final cleaned = raw.replaceAll('-', '').toUpperCase();
  final short = cleaned.length >= 3 ? cleaned.substring(0, 3) : cleaned;
  return 'RT-$short';
}

class _EditRouteTopBar extends StatelessWidget {
  const _EditRouteTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search routes, terminals, or IDs...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _DashboardColors.error, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Admin Profile',
                        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                      ),
                      Text(
                        'Senior Dispatcher',
                        style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _DashboardColors.surfaceHighest,
                    backgroundImage: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC19hLfSfphrGFS9nLUbLAA_ORwXJ_f38F4RZULBTzoDqTQ6P8rJ5V7w5vCZ2K-gMdzjWjVwRbuPOkMM2lacQ8RoxSEZ0eZsZSW7jtDnubxA35_n6CH1ox9rzjnfN-gx7q1pTWFU5kVH1mUydNtsVpKQ_cMFDElWuIOAMyMPrOhmxph7TeyMmfYlAoQwwS-NXEcnNeeXWq-ek6pbxeXkDkksL7SDJMQiylEkJb-ku4ZlJqJYG4cnPKNCwskwOVdm8YvRu4H7BJMIek',
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

class _EditRouteHeader extends StatelessWidget {
  const _EditRouteHeader({
    required this.routeId,
    required this.onDiscard,
    required this.onSave,
  });

  final String routeId;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Route Management',
                  style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 14, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Edit Route $routeId',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Edit Route Details',
              style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: _DashboardColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              'Update schedule, pricing, and availability for the Urban Express line.',
              style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: onDiscard,
              style: OutlinedButton.styleFrom(
                foregroundColor: _DashboardColors.primary,
                side: BorderSide(color: _DashboardColors.outlineVariant.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Discard Changes'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DashboardColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditRouteFormCard extends StatelessWidget {
  const _EditRouteFormCard({
    required this.fromController,
    required this.toController,
    required this.priceController,
    required this.routeIdController,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController priceController;
  final TextEditingController routeIdController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Route Logistics',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EditRouteField(
                  label: 'Pickup Terminal',
                  controller: fromController,
                  icon: Icons.location_on,
                  iconColor: _DashboardColors.primary,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EditRouteField(
                  label: 'Destination Terminal',
                  controller: toController,
                  icon: Icons.near_me,
                  iconColor: _DashboardColors.error,
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EditRouteField(
                  label: 'Base Price (NGN)',
                  controller: priceController,
                  icon: Icons.payments,
                  iconColor: _DashboardColors.primaryContainer,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EditRouteField(
                  label: 'Route ID Reference',
                  controller: routeIdController,
                  icon: Icons.tag,
                  iconColor: _DashboardColors.onSurfaceVariant,
                  readOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditRouteField extends StatelessWidget {
  const _EditRouteField({
    required this.label,
    required this.controller,
    required this.icon,
    this.iconColor,
    this.keyboardType,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color? iconColor;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: _DashboardColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: readOnly ? _DashboardColors.surfaceLow : _DashboardColors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? _DashboardColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditRouteMapCard extends StatelessWidget {
  const _EditRouteMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC-Fq3gsVKgKl36HMQpjrB6BvWqB7B3OFfDF-WLR4EUnOKi59G5SyUL_gdbMln5vyeow_M2KpWgx2DenosLUuYME0mGJlPUIftEy3JpAsgyjcWgqqL850vV3dLACKkiTv1xgSn2AvV71Wzqf5DpgE3IKqs4VJFw95lA9qNVaySXcyjdl5clCays2IPxzBpX6uTa8pOMz8rdeiGBMdIyu7-bQnPz620HJxeLU9GU1afVX5Fle0ClSyqjidxJZmK32TjsiAyfZNEAsDI',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF0F3B2E).withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _DashboardColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.map, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Distance Preview', style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
                            Text('14.2 km', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Est. Time', style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
                        Text('22 mins', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditRouteStatusCard extends StatelessWidget {
  const _EditRouteStatusCard({
    required this.isActive,
    required this.onToggle,
  });

  final bool isActive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route Status',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _DashboardColors.primaryFixedDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.power_settings_new, color: _DashboardColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Enable Route',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onToggle,
                child: _RouteToggleSwitch(enabled: isActive),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Disabling this route will immediately remove it from the public passenger app and notify all scheduled drivers.',
            style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: _DashboardColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Last updated: 12 Oct, 14:30 by Admin',
                style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteToggleSwitch extends StatelessWidget {
  const _RouteToggleSwitch({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: enabled ? _DashboardColors.primary : _DashboardColors.surfaceHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _EditRouteMarketCard extends StatelessWidget {
  const _EditRouteMarketCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3B2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Intelligence',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Suggested Price',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text('NGN 26.00', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.8,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: _DashboardColors.primaryFixedDim,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MarketStatCard(
                  label: 'Peak Demand',
                  value: '+18%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MarketStatCard(
                  label: 'Competitor',
                  value: 'NGN 23.50',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Apply Auto-Pricing',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketStatCard extends StatelessWidget {
  const _MarketStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: _DashboardColors.primaryFixedDim)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _EditRouteCapacityCard extends StatelessWidget {
  const _EditRouteCapacityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capacity Rules',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _CapacityRow(label: 'Max Seats', value: '42', valueColor: _DashboardColors.onSurface),
          _CapacityRow(label: 'Overbooking Allow.', value: 'Disabled', valueColor: _DashboardColors.error),
          _CapacityRow(label: 'Vehicle Class', value: 'Luxury Coach', valueColor: _DashboardColors.onSurface),
        ],
      ),
    );
  }
}

class _CapacityRow extends StatelessWidget {
  const _CapacityRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}

class _RoutesAiCard extends StatelessWidget {
  const _RoutesAiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DashboardColors.primaryContainer.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: _DashboardColors.primary, size: 28),
          const SizedBox(height: 10),
          Text(
            'AI Route Optimization',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Our kinetic engine suggests adding 2 new stops to North Highlands route to increase efficiency by 22%.',
            style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DashboardColors.primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                'Review Suggestions',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutesHealthCard extends StatelessWidget {
  const _RoutesHealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Health',
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
          const SizedBox(height: 12),
          _HealthMetric(label: 'Punctuality', value: '98%', color: const Color(0xFF10B981), progress: 0.98),
          const SizedBox(height: 12),
          _HealthMetric(label: 'Passenger Load', value: '62%', color: const Color(0xFFF59E0B), progress: 0.62),
        ],
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  const _HealthMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });

  final String label;
  final String value;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant)),
            Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: _DashboardColors.surfaceHighest,
            color: color,
          ),
        ),
      ],
    );
  }
}

String _routeId(Map<String, dynamic> route) {
  final raw = route['id']?.toString() ?? '';
  if (raw.isEmpty) return 'RT-0000';
  final cleaned = raw.replaceAll('-', '').toUpperCase();
  final short = cleaned.length >= 4 ? cleaned.substring(0, 4) : cleaned.padRight(4, '0');
  return 'RT-$short';
}

String _routePrice(Map<String, dynamic> route) {
  final price = route['price'];
  if (price is num) {
    return _formatCurrency(price.toDouble());
  }
  return 'NGN 0';
}

String _routeStatus(Map<String, dynamic> route) {
  final isActive = route['isActive'];
  if (isActive == true) return 'Active';
  return 'Draft';
}

class AdminAvailableRoutesScreen extends StatefulWidget {
  const AdminAvailableRoutesScreen({super.key});

  @override
  State<AdminAvailableRoutesScreen> createState() => _AdminAvailableRoutesScreenState();
}

class _AdminAvailableRoutesScreenState extends State<AdminAvailableRoutesScreen> {
  late Future<List<Map<String, dynamic>>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = AdminApi.listRoutes();
  }

  void _refreshRoutes() {
    setState(() {
      _routesFuture = AdminApi.listRoutes();
    });
  }

  void _showDeleteDialog(String routeId) {
    if (routeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route ID missing.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete route'),
          content: const Text('This will remove the route.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await AdminApi.deleteRoute(routeId);
                  if (!mounted) return;
                  _refreshRoutes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Route deleted.')),
                  );
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete route.')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Row(
        children: [
          _DashboardSidebar(
            onNavigate: (route) => Navigator.pushNamed(context, route),
            selectedRoute: AppRoutes.adminAvailableRoutes,
          ),
          Expanded(
            child: Column(
              children: [
                _RoutesTopBar(onRefresh: _refreshRoutes),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _routesFuture,
                    builder: (context, snapshot) {
                      final routes = snapshot.data ?? [];
                      final activeCount = routes.where((route) => route['isActive'] == true).length;
                      final pendingCount = routes.length - activeCount;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RoutesHeader(
                              onAdd: () => Navigator.pushNamed(context, AppRoutes.adminAddRoute).then((_) => _refreshRoutes()),
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 1000;
                                if (wide) {
                                  return Row(
                                    children: [
                                      const Expanded(flex: 2, child: _RoutesCoverageCard()),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _RoutesStatCard(
                                          title: 'Active Routes',
                                          value: activeCount.toString(),
                                          progress: activeCount == 0 ? 0 : activeCount / (routes.isEmpty ? 1 : routes.length),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _RoutesStatCard(
                                          title: 'Pending Review',
                                          value: pendingCount.toString().padLeft(2, '0'),
                                          showDots: true,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    const _RoutesCoverageCard(),
                                    const SizedBox(height: 16),
                                    _RoutesStatCard(
                                      title: 'Active Routes',
                                      value: activeCount.toString(),
                                      progress: activeCount == 0 ? 0 : activeCount / (routes.isEmpty ? 1 : routes.length),
                                    ),
                                    const SizedBox(height: 16),
                                    _RoutesStatCard(
                                      title: 'Pending Review',
                                      value: pendingCount.toString().padLeft(2, '0'),
                                      showDots: true,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _RoutesTable(
                              routes: routes,
                              onEdit: (route) => Navigator.pushNamed(
                                context,
                                AppRoutes.adminEditRoute,
                                arguments: route,
                              ).then((_) => _refreshRoutes()),
                              onDelete: (routeId) => _showDeleteDialog(routeId),
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 1100;
                                if (wide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Expanded(flex: 2, child: _RoutesMapPanel()),
                                      SizedBox(width: 16),
                                      Expanded(child: _RoutesInsightPanel()),
                                    ],
                                  );
                                }
                                return const Column(
                                  children: [
                                    _RoutesMapPanel(),
                                    SizedBox(height: 16),
                                    _RoutesInsightPanel(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
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
class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.letter,
    required this.from,
    required this.to,
    this.onEdit,
    this.onDelete,
  });

  final String letter;
  final String from;
  final String to;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C7A2C),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF7C7C7C)),
                )
              else
                const Icon(Icons.delete_outline, size: 16, color: Color(0xFF7C7C7C)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF2C7A2C), shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 18, color: const Color(0xFFE0E0E0)),
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF3E7BD9)),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(from, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(to, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8F68C),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('N2000', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
class AdminAddRouteScreen extends StatefulWidget {
  const AdminAddRouteScreen({super.key});

  @override
  State<AdminAddRouteScreen> createState() => _AdminAddRouteScreenState();
}

class _AdminAddRouteScreenState extends State<AdminAddRouteScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _priceController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    final rawPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(rawPrice);
    if (from.isEmpty || to.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter pickup, destination, and price.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AdminApi.createRoute(
        fromLocation: from,
        toLocation: to,
        price: price,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add route.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Row(
        children: [
          _DashboardSidebar(
            onNavigate: (route) => Navigator.pushNamed(context, route),
            selectedRoute: AppRoutes.adminAvailableRoutes,
          ),
          Expanded(
            child: Column(
              children: [
                const _AddRouteTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Route',
                                  style: GoogleFonts.manrope(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: _DashboardColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Configure a new metropolitan transit line for the I-Metro network.',
                                  style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: Text(
                                'Back to Routes',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 1100;
                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _AddRouteFormPanel(
                                      fromController: _fromController,
                                      toController: _toController,
                                      priceController: _priceController,
                                      loading: _loading,
                                      onSubmit: _submit,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Expanded(child: _AddRoutePreviewPanel()),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _AddRouteFormPanel(
                                  fromController: _fromController,
                                  toController: _toController,
                                  priceController: _priceController,
                                  loading: _loading,
                                  onSubmit: _submit,
                                ),
                                const SizedBox(height: 20),
                                const _AddRoutePreviewPanel(),
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
          ),
        ],
      ),
    );
  }
}

class AdminEditRouteScreen extends StatefulWidget {
  const AdminEditRouteScreen({super.key});

  @override
  State<AdminEditRouteScreen> createState() => _AdminEditRouteScreenState();
}

class _AdminEditRouteScreenState extends State<AdminEditRouteScreen> {
  final _priceController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _routeIdController = TextEditingController();
  String? _routeId;
  bool _inactive = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _routeId = args['id']?.toString();
      if (_routeIdController.text.isEmpty) {
        _routeIdController.text = _routeDisplayId(_routeId);
      }
      final from = args['fromLocation']?.toString();
      final to = args['toLocation']?.toString();
      if (from != null && _fromController.text.isEmpty) {
        _fromController.text = from;
      }
      if (to != null && _toController.text.isEmpty) {
        _toController.text = to;
      }
      final price = args['price'];
      if (price != null && _priceController.text.isEmpty) {
        _priceController.text = price.toString();
      }
      final isActive = args['isActive'];
      if (isActive is bool) {
        _inactive = !isActive;
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _routeIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (_routeId == null || _routeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route not selected.')),
      );
      return;
    }
    final rawPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(rawPrice);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AdminApi.updateRoute(
        _routeId!,
        price: price,
        isActive: !_inactive,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update route.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Row(
        children: [
          _DashboardSidebar(
            onNavigate: (route) => Navigator.pushNamed(context, route),
            selectedRoute: AppRoutes.adminAvailableRoutes,
          ),
          Expanded(
            child: Column(
              children: [
                const _EditRouteTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EditRouteHeader(
                          routeId: _routeDisplayId(_routeId),
                          onDiscard: () => Navigator.pop(context),
                          onSave: _submit,
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 1100;
                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      children: [
                                        _EditRouteFormCard(
                                          fromController: _fromController,
                                          toController: _toController,
                                          priceController: _priceController,
                                          routeIdController: _routeIdController,
                                        ),
                                        const SizedBox(height: 16),
                                        const _EditRouteMapCard(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        _EditRouteStatusCard(
                                          isActive: !_inactive,
                                          onToggle: () => setState(() => _inactive = !_inactive),
                                        ),
                                        const SizedBox(height: 16),
                                        const _EditRouteMarketCard(),
                                        const SizedBox(height: 16),
                                        const _EditRouteCapacityCard(),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _EditRouteFormCard(
                                  fromController: _fromController,
                                  toController: _toController,
                                  priceController: _priceController,
                                  routeIdController: _routeIdController,
                                ),
                                const SizedBox(height: 16),
                                const _EditRouteMapCard(),
                                const SizedBox(height: 16),
                                _EditRouteStatusCard(
                                  isActive: !_inactive,
                                  onToggle: () => setState(() => _inactive = !_inactive),
                                ),
                                const SizedBox(height: 16),
                                const _EditRouteMarketCard(),
                                const SizedBox(height: 16),
                                const _EditRouteCapacityCard(),
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
          ),
        ],
      ),
    );
  }
}

class AdminUserDetailsScreen extends StatefulWidget {
  const AdminUserDetailsScreen({super.key});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  String? _userId;
  Future<Map<String, dynamic>>? _future;
  bool _updatingStatus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != _userId) {
      _userId = id;
      _future = id != null ? AdminApi.getUser(id) : Future.value({});
    }
  }

  Future<void> _toggleStatus(bool nextActive) async {
    final id = _userId;
    if (id == null || id.isEmpty || _updatingStatus) return;
    setState(() => _updatingStatus = true);
    try {
      await AdminApi.updateUserStatus(id, nextActive);
      if (!mounted) return;
      setState(() {
        _future = AdminApi.getUser(id);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user status.')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final user = snapshot.data ?? {};
        final name = _userDisplayName(user);
        final email = user['email']?.toString() ?? 'unknown@i-metro.app';
        final phone = user['phone']?.toString() ?? '+234 000 000 0000';
        final isActive = user['isActive'] == true;
        final bookings =
            (user['bookings'] is List) ? List<Map<String, dynamic>>.from(user['bookings']) : <Map<String, dynamic>>[];
        final totalTrips = bookings.length;
        final loyaltyPoints = totalTrips * 4;
        final accountAge = _formatAccountAge(user['createdAt']);

        return Scaffold(
          backgroundColor: _DashboardColors.surface,
          body: Row(
            children: [
              _DashboardSidebar(
                onNavigate: (route) => Navigator.pushNamed(context, route),
                selectedRoute: AppRoutes.adminTotalUsers,
              ),
              Expanded(
                child: Column(
                  children: [
                    _UserDetailsTopBar(
                      onRefresh: () {
                        final id = _userId;
                        if (id == null || id.isEmpty) return;
                        setState(() {
                          _future = AdminApi.getUser(id);
                        });
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _UserBreadcrumbs(onBack: () => Navigator.pop(context)),
                                Row(
                                  children: [
                                    _UserDetailsActionButton(
                                      label: 'Edit Profile',
                                      icon: Icons.edit,
                                      filled: false,
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    _UserDetailsActionButton(
                                      label: isActive ? 'Block User' : 'Unblock User',
                                      icon: isActive ? Icons.block : Icons.check_circle,
                                      filled: true,
                                      destructive: isActive,
                                      loading: _updatingStatus,
                                      onTap: () => _toggleStatus(!isActive),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 1100;
                                if (wide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: _UserIdentityCard(
                                          name: name,
                                          email: email,
                                          isActive: isActive,
                                          totalTrips: totalTrips,
                                          loyaltyPoints: loyaltyPoints,
                                          accountAge: accountAge,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 4,
                                        child: _UserContactCard(phone: phone),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _UserIdentityCard(
                                      name: name,
                                      email: email,
                                      isActive: isActive,
                                      totalTrips: totalTrips,
                                      loyaltyPoints: loyaltyPoints,
                                      accountAge: accountAge,
                                    ),
                                    const SizedBox(height: 16),
                                    _UserContactCard(phone: phone),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _UserBookingHistoryTable(bookings: bookings),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final twoColumn = constraints.maxWidth >= 900;
                                if (twoColumn) {
                                  return Row(
                                    children: const [
                                      Expanded(child: _UserAdminNotesCard()),
                                      SizedBox(width: 16),
                                      Expanded(child: _UserSecuritySummaryCard()),
                                    ],
                                  );
                                }
                                return const Column(
                                  children: [
                                    _UserAdminNotesCard(),
                                    SizedBox(height: 16),
                                    _UserSecuritySummaryCard(),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatDate(String? value) {
  final dt = DateTime.tryParse(value ?? '');
  if (dt == null) return '-';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

String _formatTime(String? value) {
  final dt = DateTime.tryParse(value ?? '');
  if (dt == null) return '-';
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _HistoryCell(text: 'S/N', flex: 1, header: true),
        _HistoryCell(text: 'Enter', flex: 2, header: true),
        _HistoryCell(text: 'Exit', flex: 2, header: true),
        _HistoryCell(text: 'Date', flex: 2, header: true),
        _HistoryCell(text: 'Time', flex: 2, header: true),
        _HistoryCell(text: 'Amount', flex: 2, header: true),
        _HistoryCell(text: 'Status', flex: 2, header: true),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.sn,
    required this.enter,
    required this.exit,
    required this.date,
    required this.time,
    required this.amount,
    this.status = 'Complete',
  });

  final String sn;
  final String enter;
  final String exit;
  final String date;
  final String time;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _HistoryCell(text: sn, flex: 1),
          _HistoryCell(text: enter, flex: 2),
          _HistoryCell(text: exit, flex: 2),
          _HistoryCell(text: date, flex: 2),
          _HistoryCell(text: time, flex: 2),
          _HistoryCell(text: amount, flex: 2),
          _HistoryCell(text: status, flex: 2, isAction: true),
        ],
      ),
    );
  }
}

class _HistoryCell extends StatelessWidget {
  const _HistoryCell({
    required this.text,
    required this.flex,
    this.header = false,
    this.isAction = false,
  });

  final String text;
  final int flex;
  final bool header;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: header ? 9 : 10,
          fontWeight: header ? FontWeight.w700 : FontWeight.w500,
          color: isAction ? const Color(0xFF2C7A2C) : const Color(0xFF3F3F3F),
        ),
      ),
    );
  }
}

class AdminMerchantDetailsScreen extends StatefulWidget {
  const AdminMerchantDetailsScreen({super.key});

  @override
  State<AdminMerchantDetailsScreen> createState() => _AdminMerchantDetailsScreenState();
}

class _AdminMerchantDetailsScreenState extends State<AdminMerchantDetailsScreen> {
  String? _merchantId;
  Future<Map<String, dynamic>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != _merchantId) {
      _merchantId = id;
      _future = _loadMerchant(id);
    }
  }

  Future<Map<String, dynamic>> _loadMerchant(String? id) async {
    if (id != null) {
      return AdminApi.getMerchant(id);
    }
    final list = await AdminApi.listMerchants();
    if (list.isNotEmpty) {
      return list.first;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final merchant = snapshot.data ?? {};
        final name = merchant['name']?.toString() ?? 'Metropolis Central Mall';
        final email = merchant['email']?.toString() ?? 'billing@metropolis-mall.com';
        final phone = merchant['phone']?.toString() ?? '+1 (555) 982-1200';
        final merchantId = merchant['id']?.toString() ?? 'M-98210-XC';
        final onboarding = _formatMerchantOnboarding(merchant['createdAt']);

        return Scaffold(
          backgroundColor: _DashboardColors.surface,
          body: Row(
            children: [
              _DashboardSidebar(
                onNavigate: (route) => Navigator.pushNamed(context, route),
                selectedRoute: AppRoutes.adminMerchantDetails,
              ),
              Expanded(
                child: Column(
                  children: [
                    _MerchantTopBar(
                      onRefresh: () {
                        final id = _merchantId;
                        setState(() {
                          _future = _loadMerchant(id);
                        });
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MerchantHeader(
                              name: name,
                              onBack: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 1100;
                                if (wide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _MerchantInfoColumn(
                                          name: name,
                                          email: email,
                                          phone: phone,
                                          merchantId: merchantId,
                                          onboarding: onboarding,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 2,
                                        child: _MerchantStatsAndHistory(name: name),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _MerchantInfoColumn(
                                      name: name,
                                      email: email,
                                      phone: phone,
                                      merchantId: merchantId,
                                      onboarding: onboarding,
                                    ),
                                    const SizedBox(height: 24),
                                    _MerchantStatsAndHistory(name: name),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFB8F68C),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class AdminUserDropdownScreen extends StatefulWidget {
  const AdminUserDropdownScreen({super.key});

  @override
  State<AdminUserDropdownScreen> createState() => _AdminUserDropdownScreenState();
}

class _AdminUserDropdownScreenState extends State<AdminUserDropdownScreen> {
  bool _showProfileMenu = false;

  void _toggleProfileMenu() {
    setState(() {
      _showProfileMenu = !_showProfileMenu;
    });
  }

  void _closeProfileMenu() {
    if (_showProfileMenu) {
      setState(() {
        _showProfileMenu = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Row(
        children: [
          _DashboardSidebar(
            onNavigate: (route) => Navigator.pushNamed(context, route),
            selectedRoute: AppRoutes.adminDashboard,
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _closeProfileMenu,
                  child: Column(
                    children: [
                      _ProfileMenuTopBar(onProfileTap: _toggleProfileMenu),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 88),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _ProfileMenuHeader(),
                              const SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide = constraints.maxWidth >= 1100;
                                  if (wide) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Expanded(flex: 2, child: _ProfileMenuMapCard()),
                                        SizedBox(width: 18),
                                        Expanded(child: _ProfileMenuStatStack()),
                                      ],
                                    );
                                  }
                                  return const Column(
                                    children: [
                                      _ProfileMenuMapCard(),
                                      SizedBox(height: 18),
                                      _ProfileMenuStatStack(),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              const _ProfileMenuLogsCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showProfileMenu)
                  const Positioned(
                    top: 74,
                    right: 32,
                    child: _ProfileMenuDropdown(),
                  ),
                Positioned(
                  bottom: 26,
                  right: 30,
                  child: _ProfileMenuFab(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.adminAddRoute),
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

class _ProfileMenuTopBar extends StatelessWidget {
  const _ProfileMenuTopBar({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search transit data...',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant.withOpacity(0.8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _DashboardColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Color(0xFF6B7771)),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: _DashboardColors.error, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Color(0xFF6B7771)),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: _DashboardColors.outlineVariant.withOpacity(0.3)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceLow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Text(
                    'Admin Metro',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0C3B2E)),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _DashboardColors.surfaceHighest,
                    backgroundImage: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAEJkWMxU5lH0rUojl9jasHAvvZZEZC-rriUhie5u7sr2FEwBfWYsOkJYi8HmHE8ORfY1ft8Zjq3ilOX7lERJ-zsjM5LCUkh2rr-R8HjFoyzwJ3Mb0ynTrmE4_OkOaEAWtrqng4PwhDagkuGKNwpGt77ht31fs3eT4_I9P9Pe_r6hAf7itiuqCwsaCuKEnEhuYdC_nYtj573p-vsuVfzEqdGTe2SI0VvGZ-OXw68KUxqxzarh1vt989qEmZpGgd7OK6k8uLpp1AIPE',
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

class _ProfileMenuHeader extends StatelessWidget {
  const _ProfileMenuHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transit Sanctuary',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: _DashboardColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Morning Overview',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _DashboardColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuMapCard extends StatelessWidget {
  const _ProfileMenuMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCh2MVXg6icnf_eBE9TeDHtm4cWIJj_QeG0v_pZ5zXQqCtY3uth06vLJpIFK9utjCc_1dxQ1KfzYO6a4Gt8DIe9rHX0lJzMrOqu_-Y-QPHEONr55LPPcwdJRVzcnnpw57B0qqogI3gIQyI3e_5p-ns3kOZ5WJTcgYjkEhEezB-W6WoH2dVcZi6O9GZWJeUszTnNxclQ4L03USpv_3SPY-7Yiwb9wAqDETafQmkcjG19se9M_PygxMEkpbx-QXKsgFTasn_0WE1nfRA',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _DashboardColors.surfaceLowest.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceLowest.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network Status',
                    style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF31B47B), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '98.2% OPERATIONAL',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF1F9D5B)),
                      ),
                    ],
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

class _ProfileMenuStatStack extends StatelessWidget {
  const _ProfileMenuStatStack();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileMenuStatCard(
          title: 'Tickets Issued (Today)',
          value: '14,204',
          subtitle: '+12% vs yesterday',
          icon: Icons.confirmation_number,
          gradient: const LinearGradient(colors: [_DashboardColors.primary, _DashboardColors.primaryContainer]),
          textColor: Colors.white,
          subtitleFilled: true,
        ),
        const SizedBox(height: 18),
        _ProfileMenuStatCard(
          title: 'Active Alerts',
          value: '03',
          subtitle: 'View active alerts',
          icon: Icons.warning,
          background: _DashboardColors.surfaceHighest,
          textColor: _DashboardColors.onSurface,
          accent: _DashboardColors.primary,
        ),
      ],
    );
  }
}

class _ProfileMenuStatCard extends StatelessWidget {
  const _ProfileMenuStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.textColor,
    this.gradient,
    this.background,
    this.accent,
    this.subtitleFilled = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color textColor;
  final LinearGradient? gradient;
  final Color? background;
  final Color? accent;
  final bool subtitleFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: background ?? _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 34, color: accent ?? textColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: 12),
          subtitleFilled
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
                  ),
                )
              : Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _DashboardColors.onSurfaceVariant,
                    decoration: TextDecoration.underline,
                  ),
                ),
        ],
      ),
    );
  }
}

class _ProfileMenuLogsCard extends StatelessWidget {
  const _ProfileMenuLogsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Logs',
                    style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Most recent infrastructure events',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _DashboardColors.onSurfaceVariant),
                  ),
                ],
              ),
              Text(
                'Download Report',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _ProfileMenuLogItem(
            title: 'Core Server Maintenance',
            meta: 'Admin Metro - 14 mins ago',
            status: 'Completed',
            statusColor: _DashboardColors.onSurfaceVariant,
            icon: Icons.terminal,
            iconBackground: _DashboardColors.secondaryContainer,
          ),
          const SizedBox(height: 12),
          const _ProfileMenuLogItem(
            title: 'Signal Delay: Route A4',
            meta: 'Automated - 32 mins ago',
            status: 'Critical',
            statusColor: _DashboardColors.tertiary,
            icon: Icons.error_outline,
            iconBackground: _DashboardColors.tertiaryFixed,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuLogItem extends StatelessWidget {
  const _ProfileMenuLogItem({
    required this.title,
    required this.meta,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.iconBackground,
  });

  final String title;
  final String meta;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: _DashboardColors.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuDropdown extends StatelessWidget {
  const _ProfileMenuDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 12))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAjEwtgUim9-3M95n5NN7IAJcmpeYxi7cBK3WZTCzvnzZEW-PAmepZNktxipV_i5Sn-M8U1HTdYkocI0b3gWRvw179mRK7v6vaxIJsz3jhVILhln2HpSNZlwBaSKZ1svEqy84A46CPnUNwr6LylCOTBOJigKL47N0CpfpaOK0sSNTOclu95tb9v603yO2PBjnfTbcQG2Tgxcu-RuCqTzqAxVkK20nkCPjRUxrUZvSCRE61THPJGRrcIYWN3Qq0uJ1c9fuwg389dZYo',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Metro',
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'System Administrator',
                        style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: _DashboardColors.primaryFixedDim, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LEVEL 4 ACCESS',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF1F9D5B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ProfileMenuActionRow(
            icon: Icons.account_circle,
            label: 'Profile Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDetails),
          ),
          _ProfileMenuActionRow(
            icon: Icons.security,
            label: 'Security & Privacy',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _ProfileMenuActionRow(
            icon: Icons.history,
            label: 'Recent Activity',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 1,
            color: _DashboardColors.outlineVariant.withOpacity(0.2),
          ),
          _ProfileMenuLogoutRow(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.adminLogoutConfirmation);
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuActionRow extends StatelessWidget {
  const _ProfileMenuActionRow({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, size: 18, color: _DashboardColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuLogoutRow extends StatelessWidget {
  const _ProfileMenuLogoutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.logout, size: 18, color: _DashboardColors.error),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuFab extends StatelessWidget {
  const _ProfileMenuFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _DashboardColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'New Route',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLogoutConfirmationScreen extends StatelessWidget {
  const AdminLogoutConfirmationScreen({super.key});

  void _handleCancel(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(context, AppRoutes.adminDashboard);
    }
  }

  void _handleConfirm(BuildContext context) {
    AuthStore.clear();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.adminLogin, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.03,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const _LogoutBackgroundMock(),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: _DashboardColors.onSurface.withOpacity(0.08)),
          ),
          Center(
            child: _LogoutModalCard(
              onCancel: () => _handleCancel(context),
              onConfirm: () => _handleConfirm(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutBackgroundMock extends StatelessWidget {
  const _LogoutBackgroundMock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 256,
          color: const Color(0xFFF0F2F2),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _DashboardColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_subway, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I-Metro',
                        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0C3B2E)),
                      ),
                      Text(
                        'Luxury in Motion',
                        style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _LogoutSidebarItem(icon: Icons.dashboard, label: 'Dashboard'),
              _LogoutSidebarItem(icon: Icons.group, label: 'User Management'),
              _LogoutSidebarItem(icon: Icons.storefront, label: 'Merchant Management'),
              _LogoutSidebarItem(icon: Icons.map, label: 'Route Management'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: _DashboardColors.surfaceLowest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: _DashboardColors.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: _DashboardColors.surface,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transit Dashboard',
                  style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  'System status: Operative',
                  style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _LogoutPlaceholderCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _LogoutPlaceholderCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _LogoutPlaceholderCard()),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _DashboardColors.surfaceLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _DashboardColors.surfaceLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

class _LogoutSidebarItem extends StatelessWidget {
  const _LogoutSidebarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _DashboardColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _LogoutPlaceholderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _LogoutModalCard extends StatelessWidget {
  const _LogoutModalCard({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceLowest.withOpacity(0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: _DashboardColors.surfaceLow.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDAD6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.logout, size: 18, color: _DashboardColors.error),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'System Session',
                      style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: const NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBl29r45m-o2zr5X0vt9QypG3i8gfFCDnnsRBwPH-MU-9AmQegoeAnuyW9HNeWvQjL6raDsgjyXgUNN9iHfqsvLCGo0S8-unSdCR3CYi1gOlStKxALjwBQi_pIE8EIdkLiHBarH8yhxrbuhRMAb1hfD4d8ievEBl1NZtkQw6oiQJMc-UGOrtJgF56lGe7CGIT4npSzQBKaRa6foyGvfzpuayQy440ketmPwrsVD051RCfTDIlr4cFPA-3WQKWCbnCyuGT_SAjGML-c',
                          ),
                          backgroundColor: _DashboardColors.surfaceHighest,
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _DashboardColors.primaryFixedDim,
                            shape: BoxShape.circle,
                            border: Border.all(color: _DashboardColors.surfaceLowest, width: 3),
                          ),
                          child: const Icon(Icons.verified, size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to log out?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are currently managing active transit routes. Logging out will end your current administrative session.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: _DashboardColors.outlineVariant.withOpacity(0.6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: Center(
                            child: Text(
                              'Confirm',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 4, decoration: BoxDecoration(color: _DashboardColors.surfaceHighest.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminAuditActivityLogsScreen extends StatefulWidget {
  const AdminAuditActivityLogsScreen({super.key});

  @override
  State<AdminAuditActivityLogsScreen> createState() => _AdminAuditActivityLogsScreenState();
}

class _AdminAuditActivityLogsScreenState extends State<AdminAuditActivityLogsScreen> {
  late Future<List<_AuditLogEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_AuditLogEntry>> _load() async {
    final data = await AdminApi.listAuditLogs();
    if (data.isEmpty) {
      return const <_AuditLogEntry>[];
    }
    return data.map(_AuditLogEntry.fromMap).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<List<_AuditLogEntry>>(
      future: _future,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <_AuditLogEntry>[];
        return Scaffold(
      backgroundColor: _DashboardColors.surface,
      body: Stack(
        children: [
          Row(
            children: [
              const _AuditSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _AuditTopBar(
                      onRefresh: () => setState(() {
                        _future = _load();
                      }),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _AuditHeaderSection(),
                            const SizedBox(height: 20),
                            _AuditFiltersSection(),
                            const SizedBox(height: 20),
                            _AuditTable(logs: logs),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            right: 28,
            bottom: 24,
            child: _AuditFab(),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _AuditSidebar extends StatelessWidget {
  const _AuditSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 20),
      color: const Color(0xFFEDEEEF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I-Metro Admin',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Luxury in Motion',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.6, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _AuditSidebarItem(
            icon: Icons.dashboard,
            label: 'Revenue',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          _AuditSidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _AuditSidebarItem(
            icon: Icons.history,
            label: 'Activity',
            selected: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          _AuditSidebarItem(
            icon: Icons.support_agent,
            label: 'Support',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSupportTicketManagement),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: Text(
                'Create Report',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _AuditFooterLink(
            icon: Icons.verified_user,
            label: 'Security',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _AuditFooterLink(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogoutConfirmation),
          ),
        ],
      ),
    );
  }
}

class _AuditSidebarItem extends StatelessWidget {
  const _AuditSidebarItem({required this.icon, required this.label, this.selected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _DashboardColors.surfaceLowest.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? const Border(right: BorderSide(color: _DashboardColors.primary, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _AuditFooterLink extends StatelessWidget {
  const _AuditFooterLink({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _AuditTopBar extends StatelessWidget {
  const _AuditTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: _DashboardColors.surface.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Inter-Metro Transport Solution Limited',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
              ),
              const SizedBox(width: 22),
              _AuditTopLink(
                label: 'Analytics',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
              ),
              const SizedBox(width: 16),
              _AuditTopLink(
                label: 'Configuration',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
              ),
              const SizedBox(width: 16),
              _AuditTopLink(
                label: 'Logs',
                selected: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 230,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Global search...',
                      hintStyle: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant.withOpacity(0.7)),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: _DashboardColors.surfaceHighest,
                backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC9l91YUWJ3Brj02TQsqqHtHG1E61eA05Stezv_5vjQsYOS99UUytIC-194PN-lV_cAFVOCETd4UGcNCrp58uVRDUZjs2NeF-0QNH2L8SNtPdixePl-Dc7YEXpo_QBtDiHMtSSfJ1XE41DyhG3npn5Ljt-j4DyEZNJ1lzG4UsAIeyp16DorvlT1s9oZov9LjiLPjifuM-o6iNOWxy-KCvng-OyJBkmqzOe7M5saaonjyf11r2Qwqn7XTJtY_x433fbRaz6B4K5gt3Q',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuditTopLink extends StatelessWidget {
  const _AuditTopLink({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: selected ? const Border(bottom: BorderSide(color: _DashboardColors.primary, width: 2)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AuditHeaderSection extends StatelessWidget {
  const _AuditHeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit & Activity Logs',
                style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Monitor administrative actions and security events across the Luxury in Motion infrastructure.',
                style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const _AuditExportButton(label: 'Export PDF', icon: Icons.file_download),
        const SizedBox(width: 10),
        const _AuditExportButton(label: 'Export CSV', icon: Icons.table_chart),
      ],
    );
  }
}

class _AuditExportButton extends StatelessWidget {
  const _AuditExportButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
        ],
      ),
    );
  }
}

class _AuditFiltersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100 ? 4 : width >= 760 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 3.4,
          children: const [
            _AuditFilterCard(
              label: 'Filter by Category',
              child: _AuditFilterDropdown(value: 'All Categories'),
            ),
            _AuditFilterCard(
              label: 'Admin User',
              child: _AuditFilterDropdown(value: 'Everyone'),
            ),
            _AuditFilterCard(
              label: 'Date Range',
              child: _AuditFilterDate(value: 'Last 24 Hours'),
            ),
            _AuditFilterCard(
              label: 'Search Logs',
              highlighted: true,
              child: _AuditFilterSearch(),
            ),
          ],
        );
      },
    );
  }
}

class _AuditFilterCard extends StatelessWidget {
  const _AuditFilterCard({required this.label, required this.child, this.highlighted = false});

  final String label;
  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: highlighted ? Border.all(color: _DashboardColors.primary.withOpacity(0.1), width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AuditFilterDropdown extends StatelessWidget {
  const _AuditFilterDropdown({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
        ),
        const Spacer(),
        const Icon(Icons.expand_more, size: 18, color: _DashboardColors.onSurfaceVariant),
      ],
    );
  }
}

class _AuditFilterDate extends StatelessWidget {
  const _AuditFilterDate({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
        ),
        const Spacer(),
        const Icon(Icons.calendar_today, size: 16, color: _DashboardColors.onSurfaceVariant),
      ],
    );
  }
}

class _AuditFilterSearch extends StatelessWidget {
  const _AuditFilterSearch();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Entry keywords...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant.withOpacity(0.7)),
              isCollapsed: true,
            ),
          ),
        ),
        const Icon(Icons.search, size: 16, color: _DashboardColors.primary),
      ],
    );
  }
}

class _AuditTable extends StatelessWidget {
  const _AuditTable({required this.logs});

  final List<_AuditLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    final total = logs.length;
    final footerLabel = total == 0
        ? 'No entries to show'
        : 'Total: $total entr${total == 1 ? 'y' : 'ies'}';
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _AuditHeaderCell(label: 'Timestamp', flex: 2),
                _AuditHeaderCell(label: 'Admin User', flex: 3),
                _AuditHeaderCell(label: 'Category', flex: 2),
                _AuditHeaderCell(label: 'Details', flex: 3),
                _AuditHeaderCell(label: 'IP Address', flex: 2),
              ],
            ),
          ),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No audit activity yet.',
                style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: List.generate(logs.length, (index) {
                final entry = logs[index];
                return _AuditLogRow(entry: entry, shaded: index.isOdd);
              }),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _DashboardColors.outlineVariant.withOpacity(0.15))),
            ),
            child: Row(
              children: [
                Text(
                  footerLabel,
                  style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                ),
                if (total > 0) ...[
                  const Spacer(),
                  Row(
                    children: [
                      _AuditPageIcon(icon: Icons.chevron_left, disabled: true),
                      const SizedBox(width: 6),
                      _AuditPageNumber(label: '1', selected: true),
                      const SizedBox(width: 6),
                      _AuditPageIcon(icon: Icons.chevron_right),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditHeaderCell extends StatelessWidget {
  const _AuditHeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: _DashboardColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  const _AuditLogRow({required this.entry, required this.shaded});

  final _AuditLogEntry entry;
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      color: shaded ? _DashboardColors.surfaceLow.withOpacity(0.3) : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.date, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
                const SizedBox(height: 4),
                Text(entry.time, style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _DashboardColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: entry.avatarUrl.isEmpty
                      ? const Icon(Icons.shield, size: 18, color: _DashboardColors.primary)
                      : ClipOval(child: Image.network(entry.avatarUrl, fit: BoxFit.cover)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
                    const SizedBox(height: 4),
                    Text(entry.role, style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _AuditCategoryChip(category: entry.category),
          ),
          Expanded(
            flex: 3,
            child: Text(
              entry.details,
              style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant, height: 1.4),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.ipAddress,
              style: GoogleFonts.robotoMono(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditCategoryChip extends StatelessWidget {
  const _AuditCategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    if (category == 'Security') {
      background = const Color(0xFFFFDAD6);
      textColor = const Color(0xFF93000A);
    } else if (category == 'User Mod') {
      background = _DashboardColors.surfaceHighest;
      textColor = _DashboardColors.onSurfaceVariant;
    } else {
      background = _DashboardColors.secondaryContainer;
      textColor = _DashboardColors.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: textColor),
      ),
    );
  }
}

class _AuditPageNumber extends StatelessWidget {
  const _AuditPageNumber({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: selected ? _DashboardColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _DashboardColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _AuditPageIcon extends StatelessWidget {
  const _AuditPageIcon({required this.icon, this.disabled = false});

  final IconData icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: disabled ? _DashboardColors.onSurfaceVariant.withOpacity(0.3) : _DashboardColors.onSurfaceVariant),
    );
  }
}

class _AuditFab extends StatelessWidget {
  const _AuditFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _DashboardColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          const Icon(Icons.add_alert, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            'Create Audit Alert',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AuditLogEntry {
  const _AuditLogEntry({
    required this.date,
    required this.time,
    required this.name,
    required this.role,
    required this.category,
    required this.details,
    required this.ipAddress,
    required this.avatarUrl,
  });

  final String date;
  final String time;
  final String name;
  final String role;
  final String category;
  final String details;
  final String ipAddress;
  final String avatarUrl;

  factory _AuditLogEntry.fromMap(Map<String, dynamic> map) {
    return _AuditLogEntry(
      date: map['date']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      details: map['details']?.toString() ?? '',
      ipAddress: map['ipAddress']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
    );
  }
}

const List<_AuditLogEntry> _auditLogs = [
  _AuditLogEntry(
    date: 'Oct 24, 2023',
    time: '14:22:05',
    name: 'Marcus Chen',
    role: 'Senior Controller',
    category: 'Data Edit',
    details: 'Changed fare multiplier for Route RT-2041 to 1.25x',
    ipAddress: '192.168.1.104',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBL852Qa9hDf2ymTZsf67TUb5FCEiAtry9Yg_xnPCl2-AcJz1wsQl4SdyoWg_DNz3rw3tny-THcdUe2VzxkTQndI0P8iacttTmnX6m4pFJ5nEkt_AfPIRy9rUtAiFMjamKcd_JLBPmfrFZpe3uPj2Hf8e86LVQ48C1tekcomUQmG6Oa-4bOWP1TtPaT0q6mn2HqizCOTn4ATu6NSJFMu5wBKhzYnyjVy82ujLd2fLhySBEjlzDPrDn5uwX1V9Pa7n4kHDpxQGKXErg',
  ),
  _AuditLogEntry(
    date: 'Oct 24, 2023',
    time: '13:58:12',
    name: 'Sarah Jenkins',
    role: 'Security Lead',
    category: 'Security',
    details: 'Failed login attempt detected from unknown region (RU)',
    ipAddress: '45.12.98.201',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCHijj5FR5JEP3t52XxM6y8DprN7OfEp4gd2CWCls1VNdL0NqOfoKCCHahOkc2HBaAbDXDEPWQeEtyF3rjsItMVduXxpoghEomCWBEj-TkUtsFfvp_8uk2WrJLN1LhIO3qrecJBEub4WjCBviBxaXcOV9DZEuoM3YPnmx9NItZsXd2QDiqVfD6rvwZZG5NhxsxkSJBsQfU8eBqaNQ5hhkvdokYJAfS30ydoLTgk5EjWUT3kY91b7fFpRZrtrymA2hTkNf5dAdF9R44',
  ),
  _AuditLogEntry(
    date: 'Oct 24, 2023',
    time: '12:15:30',
    name: 'Dave Rodriguez',
    role: 'Fleet Admin',
    category: 'User Mod',
    details: 'Granted Elevated Dispatch permissions to user @alex_t',
    ipAddress: '192.168.1.55',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBfUdX04Ixh9raJrWo9Lxb3XTpnoip8TsmePomytar1xshlacuPEdO6IygOMxxyBaxlkB3cnUupgSsojHvmKD32yVOKriQ65IICJnHe5ouulP-tYi0e74YQAXQUduyVAd009TH5t8jqT5_cCdl5u0Jgn5IgAnbEuS2myZTDFfNJBNYXqQY11MIHOTW-WPIzeyKeOdlLk9ZimeJPZoDE2E461akScnUn988z3cvj5PM0Wz-uV_5l1G2REy0FkjEPzSa1LHG_W_NL1CY',
  ),
  _AuditLogEntry(
    date: 'Oct 24, 2023',
    time: '10:05:44',
    name: 'Elena Vance',
    role: 'System Auditor',
    category: 'Data Edit',
    details: 'Archived 2,400 completed maintenance tickets from Q2 2023',
    ipAddress: '10.0.0.12',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCZ9fYSpJGKyQkllO8rAS4_Zi1ZrW4QXeF6OAQzeeb1gc4AoCT9JR4PXo9nhr2eeYe4O6MBO_QHZVopG2qFL7DYox55ic-_S0cfCYNpldDxN4_5xRYPjVmJ0wOAhnlm_-BTZ4_ScDwY9YjvLHJOaDTg39dsbBRyPSK5zsFjrsTS2fHytCRaiSXkiv2btj8SYanVNeTv9mEZ9CMzKmIOoX3gH5yeozB6RjmuGJiUqSgOp2Fd5dvHXX8kdfRIumaaWglpuU4_5-loE3Y',
  ),
  _AuditLogEntry(
    date: 'Oct 24, 2023',
    time: '08:30:11',
    name: 'System Agent',
    role: 'Automated Task',
    category: 'Security',
    details: 'API Key rotation successful for external Weather_Svc',
    ipAddress: 'Internal Loop',
    avatarUrl: '',
  ),
];

class AdminSupportTicketManagementScreen extends StatefulWidget {
  const AdminSupportTicketManagementScreen({super.key});

  @override
  State<AdminSupportTicketManagementScreen> createState() => _AdminSupportTicketManagementScreenState();
}

class _AdminSupportTicketManagementScreenState extends State<AdminSupportTicketManagementScreen> {
  late Future<_SupportData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<_SupportData> _load() async {
    final ticketsData = await AdminApi.listSupportTickets();
    final activityData = await AdminApi.listSupportActivity();
    final tickets = ticketsData.map(_SupportTicketEntry.fromMap).toList();
    final activity = activityData.map(_SupportActivityEntry.fromMap).toList();
    return _SupportData(tickets: tickets, activity: activity);
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<_SupportData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _SupportData(tickets: [], activity: []);
        final now = DateTime.now();
        final openCount = data.tickets.where((t) => t.supportStatus == 'OPEN').length;
        final inProgressCount = data.tickets.where((t) => t.supportStatus == 'IN_PROGRESS').length;
        final resolvedCount = data.tickets.where((t) => t.supportStatus == 'RESOLVED').length;
        final overdueCount = data.tickets.where((t) {
          if (t.createdAt == null) return false;
          if (t.supportStatus == 'RESOLVED') return false;
          return now.difference(t.createdAt!).inHours >= 24;
        }).length;
        return Scaffold(
          backgroundColor: _DashboardColors.surface,
          body: Stack(
            children: [
              Row(
                children: [
                  const _SupportSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                    _SupportTopBar(onRefresh: _refresh),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(28, 24, 28, 96),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SupportHeader(),
                                const SizedBox(height: 20),
                                _SupportSummaryGrid(
                                  openCount: openCount,
                                  inProgressCount: inProgressCount,
                                  resolvedCount: resolvedCount,
                                  overdueCount: overdueCount,
                                ),
                                const SizedBox(height: 22),
                                _SupportTicketSection(
                                  tickets: data.tickets,
                                  onStatusChanged: _refresh,
                                ),
                                const SizedBox(height: 22),
                                _SupportBottomSection(
                                  activity: data.activity,
                                  openCount: openCount,
                                  inProgressCount: inProgressCount,
                                  resolvedCount: resolvedCount,
                                  overdueCount: overdueCount,
                                  totalCount: data.tickets.length,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Positioned(
                right: 26,
                bottom: 24,
                child: _SupportFab(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SupportSidebar extends StatelessWidget {
  const _SupportSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      color: const Color(0xFFEDEEEF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I-Metro Admin',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Luxury in Motion',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 22),
          _SupportSidebarItem(
            icon: Icons.dashboard,
            label: 'Revenue',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          _SupportSidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _SupportSidebarItem(
            icon: Icons.history,
            label: 'Activity',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          _SupportSidebarItem(
            icon: Icons.support_agent,
            label: 'Support',
            selected: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSupportTicketManagement),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Create Report',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SupportFooterLink(
            icon: Icons.verified_user,
            label: 'Security',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _SupportFooterLink(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogoutConfirmation),
          ),
        ],
      ),
    );
  }
}

class _SupportSidebarItem extends StatelessWidget {
  const _SupportSidebarItem({required this.icon, required this.label, this.selected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _DashboardColors.surfaceLowest.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? const Border(right: BorderSide(color: _DashboardColors.primary, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _SupportFooterLink extends StatelessWidget {
  const _SupportFooterLink({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SupportTopBar extends StatelessWidget {
  const _SupportTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: _DashboardColors.surface.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Text(
            'Inter-Metro Transport Solution Limited',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(width: 22),
          _SupportTopLink(
            label: 'Analytics',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          const SizedBox(width: 16),
          _SupportTopLink(
            label: 'Configuration',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          const SizedBox(width: 16),
          _SupportTopLink(
            label: 'Logs',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          const Spacer(),
          Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search tickets...',
                      hintStyle: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant.withOpacity(0.7)),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.3)),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBUK8fI7t_HwW2tQYPOCUPMAechmK8GkwqUOT80mLcpeG-bCgIF8Xezi5kDm6vqszSDCGMAjFPP0KbgDf524qjD-9FvYAstcHtHhJioPFNCGUnPbUMxhSTJ8gb2xA-8hQxtVm-34eLXJIaY2WWfI2VDjwh6kKY8nkFYo5K2C9sNx8-sUYAAfgddVfz7pFUlicg8m149l2Aj5BPtznF4atmtZsG3mIaq268yhL_Oy2e0Z4O-tfX-i-YIBD9ZnQilynNztm1pB4w7NiM',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportTopLink extends StatelessWidget {
  const _SupportTopLink({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  const _SupportHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support Ticket Management',
          style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          'Oversee transit concerns and maintain commuter satisfaction.',
          style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SupportSummaryGrid extends StatelessWidget {
  const _SupportSummaryGrid({
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.overdueCount,
  });

  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100 ? 4 : width >= 760 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.6,
          children: [
            _SupportSummaryCard(
              title: 'Open',
              value: _formatCount(openCount),
              subtitle: openCount == 0 ? 'No open tickets' : 'Awaiting response',
              icon: Icons.drafts,
              iconColor: _DashboardColors.primary,
              iconBackground: const Color(0xFFE4F2EC),
              subtitleColor: _DashboardColors.primary,
            ),
            _SupportSummaryCard(
              title: 'In Progress',
              value: _formatCount(inProgressCount),
              subtitle: inProgressCount == 0 ? 'No active escalations' : 'Being handled',
              icon: Icons.pending_actions,
              iconColor: _DashboardColors.tertiaryContainer,
              iconBackground: const Color(0x1F92493E),
              subtitleColor: _DashboardColors.onSurfaceVariant,
            ),
            _SupportSummaryCard(
              title: 'Resolved',
              value: _formatCount(resolvedCount),
              subtitle: resolvedCount == 0 ? 'No resolved tickets yet' : 'Closed successfully',
              icon: Icons.task_alt,
              iconColor: _DashboardColors.secondary,
              iconBackground: const Color(0x33C8EADC),
              subtitleColor: _DashboardColors.secondary,
            ),
            _SupportSummaryCard(
              title: 'Overdue',
              value: _formatCount(overdueCount),
              subtitle: overdueCount == 0 ? 'No SLA breaches' : 'Requires attention',
              icon: Icons.warning,
              iconColor: _DashboardColors.error,
              iconBackground: const Color(0x33FFDAD6),
              subtitleColor: _DashboardColors.error,
            ),
          ],
        );
      },
    );
  }
}

class _SupportSummaryCard extends StatelessWidget {
  const _SupportSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.subtitleColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

class _SupportTicketSection extends StatelessWidget {
  const _SupportTicketSection({required this.tickets, this.onStatusChanged});

  final List<_SupportTicketEntry> tickets;
  final VoidCallback? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final total = tickets.length;
    final countLabel = total == 0
        ? 'Showing 0'
        : 'Showing 1-${total > 10 ? 10 : total} of $total';
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _SupportControlButton(icon: Icons.filter_list, label: 'Filter'),
                const SizedBox(width: 10),
                _SupportControlButton(icon: Icons.sort, label: 'Sort'),
                const Spacer(),
                Text(
                  countLabel,
                  style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: const [
                      _SupportPageButton(icon: Icons.chevron_left),
                      _SupportPageButton(icon: Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: _DashboardColors.surfaceLow.withOpacity(0.5),
            child: Row(
              children: const [
                _SupportHeaderCell(label: 'Ticket ID', flex: 2),
                _SupportHeaderCell(label: 'Subject', flex: 4),
                _SupportHeaderCell(label: 'User Type', flex: 2, center: true),
                _SupportHeaderCell(label: 'Priority', flex: 2),
                _SupportHeaderCell(label: 'Assigned To', flex: 3),
                _SupportHeaderCell(label: 'Status', flex: 2),
                _SupportHeaderCell(label: 'Actions', flex: 2, alignRight: true),
              ],
            ),
          ),
          if (tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No support tickets yet.',
                style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: List.generate(tickets.length, (index) {
                final ticket = tickets[index];
                return _SupportTicketRow(ticket: ticket, onStatusChanged: onStatusChanged);
              }),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All Active Tickets',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.primary),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 16, color: _DashboardColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportControlButton extends StatelessWidget {
  const _SupportControlButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SupportPageButton extends StatelessWidget {
  const _SupportPageButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        border: Border(right: BorderSide(color: _DashboardColors.outlineVariant.withOpacity(0.2))),
      ),
      child: Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
    );
  }
}

class _SupportHeaderCell extends StatelessWidget {
  const _SupportHeaderCell({required this.label, required this.flex, this.center = false, this.alignRight = false});

  final String label;
  final int flex;
  final bool center;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignRight
            ? Alignment.centerRight
            : center
                ? Alignment.center
                : Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SupportTicketRow extends StatelessWidget {
  const _SupportTicketRow({required this.ticket, this.onStatusChanged});

  final _SupportTicketEntry ticket;
  final VoidCallback? onStatusChanged;

  void _openDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String currentStatus = _normalizeSupportStatus(
          ticket.supportStatus.isNotEmpty ? ticket.supportStatus : ticket.status,
        );
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> updateStatus(String nextStatus) async {
              if (isUpdating) return;
              if (ticket.supportId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support ID missing. Unable to update status.')),
                );
                return;
              }
              setState(() => isUpdating = true);
              try {
                await AdminApi.updateSupportStatus(ticket.supportId, nextStatus);
                setState(() => currentStatus = nextStatus);
                onStatusChanged?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status updated to ${_supportStatusLabel(nextStatus)}.')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update status. Please try again.')),
                );
              } finally {
                setState(() => isUpdating = false);
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _DashboardColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mail_outline, color: _DashboardColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Support Message', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(ticket.id, style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Subject', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(ticket.subject, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    if (ticket.contactLabel.isNotEmpty) ...[
                      Text('From', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Text(ticket.contactLabel, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant)),
                      const SizedBox(height: 12),
                    ],
                    Text('Message', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _DashboardColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ticket.fullMessage.isNotEmpty ? ticket.fullMessage : 'No message provided.',
                        style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Update Status', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _SupportStatusButton(
                          label: _supportStatusLabel('OPEN'),
                          selected: currentStatus == 'OPEN',
                          color: _supportStatusColor('OPEN'),
                          disabled: isUpdating,
                          onTap: () => updateStatus('OPEN'),
                        ),
                        _SupportStatusButton(
                          label: _supportStatusLabel('IN_PROGRESS'),
                          selected: currentStatus == 'IN_PROGRESS',
                          color: _supportStatusColor('IN_PROGRESS'),
                          disabled: isUpdating,
                          onTap: () => updateStatus('IN_PROGRESS'),
                        ),
                        _SupportStatusButton(
                          label: _supportStatusLabel('RESOLVED'),
                          selected: currentStatus == 'RESOLVED',
                          color: _supportStatusColor('RESOLVED'),
                          disabled: isUpdating,
                          onTap: () => updateStatus('RESOLVED'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _DashboardColors.outlineVariant.withOpacity(0.12))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              ticket.id,
              style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.subject, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(ticket.subtitle, style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: _SupportTypeChip(label: ticket.userType),
            ),
          ),
          Expanded(
            flex: 2,
            child: _SupportPriorityLabel(priority: ticket.priority),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _SupportAvatar(initials: ticket.assigneeInitials, filled: ticket.assigneeInitials.isNotEmpty),
                const SizedBox(width: 8),
                Text(
                  ticket.assigneeName,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ticket.assigneeInitials.isEmpty ? _DashboardColors.onSurfaceVariant : _DashboardColors.onSurface),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _SupportStatusChip(status: ticket.status, statusKey: ticket.supportStatus),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SupportActionIcon(icon: Icons.visibility, onTap: () => _openDetails(context)),
                  const SizedBox(width: 6),
                  const _SupportActionIcon(icon: Icons.person_add),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportTypeChip extends StatelessWidget {
  const _SupportTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isPassenger = label == 'Passenger';
    final background = isPassenger ? _DashboardColors.secondaryContainer.withOpacity(0.3) : _DashboardColors.surfaceHighest;
    final textColor = isPassenger ? _DashboardColors.onSecondaryContainer : _DashboardColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: textColor),
      ),
    );
  }
}

class _SupportPriorityLabel extends StatelessWidget {
  const _SupportPriorityLabel({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    if (priority == 'Urgent') {
      icon = Icons.error;
      color = _DashboardColors.error;
    } else if (priority == 'High') {
      icon = Icons.warning_amber;
      color = const Color(0xFFB45309);
    } else {
      icon = Icons.expand_more;
      color = _DashboardColors.onSurfaceVariant;
    }
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(priority, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

class _SupportAvatar extends StatelessWidget {
  const _SupportAvatar({required this.initials, required this.filled});

  final String initials;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? _DashboardColors.primaryContainer : _DashboardColors.outlineVariant;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Center(
        child: filled
            ? Text(initials, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))
            : const Icon(Icons.person, size: 14, color: Colors.white),
      ),
    );
  }
}

class _SupportStatusChip extends StatelessWidget {
  const _SupportStatusChip({required this.status, this.statusKey});

  final String status;
  final String? statusKey;

  @override
  Widget build(BuildContext context) {
    final key = _normalizeSupportStatus(statusKey != null && statusKey!.isNotEmpty ? statusKey! : status);
    final label = status.isNotEmpty ? status : _supportStatusLabel(key);
    final color = _supportStatusColor(key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: color),
      ),
    );
  }
}

class _SupportActionIcon extends StatelessWidget {
  const _SupportActionIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _DashboardColors.surfaceHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
      ),
    );
  }
}

class _SupportStatusButton extends StatelessWidget {
  const _SupportStatusButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final background = selected ? color.withOpacity(0.16) : _DashboardColors.surfaceLowest;
    final border = selected ? color : _DashboardColors.outlineVariant.withOpacity(0.3);
    final textColor = selected ? color : _DashboardColors.onSurfaceVariant;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }
}

class _SupportBottomSection extends StatelessWidget {
  const _SupportBottomSection({
    required this.activity,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.overdueCount,
    required this.totalCount,
  });

  final List<_SupportActivityEntry> activity;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int overdueCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _SupportActivityFeed(activity: activity)),
              const SizedBox(width: 18),
              Expanded(
                flex: 2,
                child: _SupportInsightCard(
                  openCount: openCount,
                  inProgressCount: inProgressCount,
                  resolvedCount: resolvedCount,
                  overdueCount: overdueCount,
                  totalCount: totalCount,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            _SupportActivityFeed(activity: activity),
            SizedBox(height: 18),
            _SupportInsightCard(
              openCount: openCount,
              inProgressCount: inProgressCount,
              resolvedCount: resolvedCount,
              overdueCount: overdueCount,
              totalCount: totalCount,
            ),
          ],
        );
      },
    );
  }
}

class _SupportActivityFeed extends StatelessWidget {
  const _SupportActivityFeed({required this.activity});

  final List<_SupportActivityEntry> activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Activity',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
          const SizedBox(height: 16),
          if (activity.isEmpty)
            Text(
              'No recent support activity.',
              style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
            )
          else
            Column(
              children: activity.map((entry) => _SupportActivityRow(activity: entry)).toList(),
            ),
        ],
      ),
    );
  }
}

class _SupportActivityRow extends StatelessWidget {
  const _SupportActivityRow({required this.activity});

  final _SupportActivityEntry activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: activity.color, shape: BoxShape.circle),
            child: Center(
              child: Text(activity.initials, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.message, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface)),
                const SizedBox(height: 4),
                Text(activity.timeAgo, style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportInsightCard extends StatelessWidget {
  const _SupportInsightCard({
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.overdueCount,
    required this.totalCount,
  });

  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int overdueCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _DashboardColors.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Icon(Icons.support_agent, size: 120, color: Colors.white.withOpacity(0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live support snapshot',
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'These counts come from the live support queue, so the team can see what needs attention right now.',
                style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onPrimaryContainer),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SupportMiniStat(label: 'Open', value: openCount.toString()),
                  _SupportMiniStat(label: 'In progress', value: inProgressCount.toString()),
                  _SupportMiniStat(label: 'Resolved', value: resolvedCount.toString()),
                  _SupportMiniStat(label: 'Overdue', value: overdueCount.toString()),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Total tickets: $totalCount',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportMiniStat extends StatelessWidget {
  const _SupportMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.72)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SupportFab extends StatelessWidget {
  const _SupportFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_DashboardColors.primary, _DashboardColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.add_comment, size: 24, color: Colors.white),
    );
  }
}

String _normalizeSupportStatus(String value) {
  final normalized = value.toUpperCase().replaceAll(' ', '_');
  switch (normalized) {
    case 'OPEN':
    case 'IN_PROGRESS':
    case 'RESOLVED':
      return normalized;
    case 'NEW':
      return 'OPEN';
    case 'CLOSED':
      return 'RESOLVED';
    default:
      return 'OPEN';
  }
}

String _supportStatusLabel(String statusKey) {
  switch (statusKey) {
    case 'IN_PROGRESS':
      return 'In Progress';
    case 'RESOLVED':
      return 'Resolved';
    case 'OPEN':
    default:
      return 'Open';
  }
}

Color _supportStatusColor(String statusKey) {
  switch (statusKey) {
    case 'IN_PROGRESS':
      return _DashboardColors.tertiaryContainer;
    case 'RESOLVED':
      return _DashboardColors.secondary;
    case 'OPEN':
    default:
      return _DashboardColors.primary;
  }
}

class _SupportTicketEntry {
  const _SupportTicketEntry({
    required this.id,
    required this.supportId,
    required this.subject,
    required this.subtitle,
    required this.userType,
    required this.priority,
    required this.assigneeName,
    required this.assigneeInitials,
    required this.status,
    required this.supportStatus,
    required this.fullMessage,
    required this.contactLabel,
    required this.createdAt,
  });

  final String id;
  final String supportId;
  final String subject;
  final String subtitle;
  final String userType;
  final String priority;
  final String assigneeName;
  final String assigneeInitials;
  final String status;
  final String supportStatus;
  final String fullMessage;
  final String contactLabel;
  final DateTime? createdAt;

  factory _SupportTicketEntry.fromMap(Map<String, dynamic> map) {
    final email = map['email']?.toString() ?? '';
    final phone = map['phone']?.toString() ?? '';
    final name = map['name']?.toString() ?? '';
    final contact = name.isNotEmpty
        ? name
        : (email.isNotEmpty ? email : phone);
    final contactLabel = [
      if (contact.isNotEmpty) contact,
      if (email.isNotEmpty && contact != email) email,
      if (phone.isNotEmpty && contact != phone) phone,
    ].join(' - ');
    final rawStatus = map['supportStatus']?.toString() ?? map['status']?.toString() ?? '';
    final statusKey = _normalizeSupportStatus(rawStatus);
    final createdRaw = map['createdAt'];
    DateTime? createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw);
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    }

    return _SupportTicketEntry(
      id: map['id']?.toString() ?? '',
      supportId: map['supportId']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      userType: map['userType']?.toString() ?? '',
      priority: map['priority']?.toString() ?? '',
      assigneeName: map['assigneeName']?.toString() ?? '',
      assigneeInitials: map['assigneeInitials']?.toString() ?? '',
      status: _supportStatusLabel(statusKey),
      supportStatus: statusKey,
      fullMessage: map['message']?.toString() ?? '',
      contactLabel: contactLabel,
      createdAt: createdAt,
    );
  }
}

class _SupportActivityEntry {
  const _SupportActivityEntry({required this.initials, required this.message, required this.timeAgo, required this.color});

  final String initials;
  final String message;
  final String timeAgo;
  final Color color;

  factory _SupportActivityEntry.fromMap(Map<String, dynamic> map) {
    final colorHex = map['color']?.toString() ?? '';
    return _SupportActivityEntry(
      initials: map['initials']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      timeAgo: map['timeAgo']?.toString() ?? '',
      color: _colorFromHex(colorHex, fallback: _DashboardColors.primary),
    );
  }
}

class _SupportData {
  const _SupportData({required this.tickets, required this.activity});

  final List<_SupportTicketEntry> tickets;
  final List<_SupportActivityEntry> activity;
}

const List<_SupportTicketEntry> _supportTickets = [
  _SupportTicketEntry(
    id: '#TKT-8902',
    supportId: 'demo-8902',
    subject: 'Fare Refund Request',
    subtitle: 'Transaction ID: IM-4491-00X',
    userType: 'Passenger',
    priority: 'Urgent',
    assigneeName: 'Arjun Kumar',
    assigneeInitials: 'AK',
    status: 'Open',
    supportStatus: 'OPEN',
    fullMessage: 'Customer reports a double charge on the last ride. Wants a refund review.',
    contactLabel: 'Passenger Support',
    createdAt: null,
  ),
  _SupportTicketEntry(
    id: '#TKT-8899',
    supportId: 'demo-8899',
    subject: 'NFC Card Not Updating',
    subtitle: 'Central Station Kiosk Error',
    userType: 'Passenger',
    priority: 'High',
    assigneeName: 'Unassigned',
    assigneeInitials: '',
    status: 'Open',
    supportStatus: 'OPEN',
    fullMessage: 'Card balance does not refresh after top-up. Kiosk shows success but app does not.',
    contactLabel: 'Passenger Support',
    createdAt: null,
  ),
  _SupportTicketEntry(
    id: '#TKT-8895',
    supportId: 'demo-8895',
    subject: 'Bulk Transit Pass API Failure',
    subtitle: 'Enterprise Merchant Portal',
    userType: 'Merchant',
    priority: 'Urgent',
    assigneeName: 'Sarah Lee',
    assigneeInitials: 'SL',
    status: 'Open',
    supportStatus: 'OPEN',
    fullMessage: 'Bulk purchase API returns 500 for enterprise account ET-1042.',
    contactLabel: 'Merchant Support',
    createdAt: null,
  ),
  _SupportTicketEntry(
    id: '#TKT-8890',
    supportId: 'demo-8890',
    subject: 'Route Map Accessibility Correction',
    subtitle: 'Station App Feedback',
    userType: 'Passenger',
    priority: 'Low',
    assigneeName: 'David Miller',
    assigneeInitials: 'DM',
    status: 'Resolved',
    supportStatus: 'RESOLVED',
    fullMessage: 'User requested larger text labels for map legends.',
    contactLabel: 'Passenger Support',
    createdAt: null,
  ),
];

const List<_SupportActivityEntry> _supportActivity = [
  _SupportActivityEntry(
    initials: 'AK',
    message: 'Arjun resolved #TKT-8762',
    timeAgo: '2 mins ago',
    color: _DashboardColors.primaryContainer,
  ),
  _SupportActivityEntry(
    initials: 'DM',
    message: 'David assigned #TKT-8902 to Sarah',
    timeAgo: '15 mins ago',
    color: _DashboardColors.secondary,
  ),
  _SupportActivityEntry(
    initials: 'LS',
    message: 'System flagged #TKT-8910 as overdue',
    timeAgo: '1 hour ago',
    color: _DashboardColors.tertiary,
  ),
];

Color _colorFromHex(String hex, {required Color fallback}) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length == 6) {
    final value = int.tryParse('FF$cleaned', radix: 16);
    if (value != null) {
      return Color(value);
    }
  }
  return fallback;
}

class _SystemSettingsData {
  const _SystemSettingsData({
    required this.platformName,
    required this.timezone,
    required this.maintenanceMode,
    required this.baseFareMultiplier,
    required this.peakStrategy,
    required this.apiKeyMasked,
    required this.webhookUrl,
    required this.emailAdminAlerts,
    required this.slackIntegration,
    required this.smsCriticalDelays,
    required this.pushNotifications,
    required this.primaryColor,
    required this.logoHint,
    required this.lastModified,
  });

  final String platformName;
  final String timezone;
  final bool maintenanceMode;
  final double baseFareMultiplier;
  final String peakStrategy;
  final String apiKeyMasked;
  final String webhookUrl;
  final bool emailAdminAlerts;
  final bool slackIntegration;
  final bool smsCriticalDelays;
  final bool pushNotifications;
  final String primaryColor;
  final String logoHint;
  final String lastModified;

  static const fallback = _SystemSettingsData(
    platformName: 'Inter-Metro Transport Solution Limited',
    timezone: 'UTC (Coordinated Universal Time)',
    maintenanceMode: false,
    baseFareMultiplier: 1.2,
    peakStrategy: 'Dynamic',
    apiKeyMasked: '***********************',
    webhookUrl: '',
    emailAdminAlerts: true,
    slackIntegration: false,
    smsCriticalDelays: true,
    pushNotifications: true,
    primaryColor: '#00513F',
    logoHint: 'Drop SVG or PNG here',
    lastModified: 'Last modified by Admin at 14:45 GMT',
  );

  factory _SystemSettingsData.fromMap(Map<String, dynamic> data) {
    final notifications = data['notifications'];
    final branding = data['branding'];
    final notificationsMap = notifications is Map<String, dynamic> ? notifications : const <String, dynamic>{};
    final brandingMap = branding is Map<String, dynamic> ? branding : const <String, dynamic>{};

    bool _boolValue(String key, bool fallbackValue) {
      if (notificationsMap.containsKey(key)) {
        return notificationsMap[key] == true;
      }
      return fallbackValue;
    }

    return _SystemSettingsData(
      platformName: data['platformName']?.toString() ?? fallback.platformName,
      timezone: data['timezone']?.toString() ?? fallback.timezone,
      maintenanceMode: data['maintenanceMode'] == true ? true : fallback.maintenanceMode,
      baseFareMultiplier: (data['baseFareMultiplier'] is num)
          ? (data['baseFareMultiplier'] as num).toDouble()
          : fallback.baseFareMultiplier,
      peakStrategy: data['peakStrategy']?.toString() ?? fallback.peakStrategy,
      apiKeyMasked: data['apiKeyMasked']?.toString() ?? fallback.apiKeyMasked,
      webhookUrl: data['webhookUrl']?.toString() ?? fallback.webhookUrl,
      emailAdminAlerts: _boolValue('emailAdminAlerts', fallback.emailAdminAlerts),
      slackIntegration: _boolValue('slackIntegration', fallback.slackIntegration),
      smsCriticalDelays: _boolValue('smsCriticalDelays', fallback.smsCriticalDelays),
      pushNotifications: _boolValue('pushNotifications', fallback.pushNotifications),
      primaryColor: brandingMap['primaryColor']?.toString() ?? fallback.primaryColor,
      logoHint: brandingMap['logoHint']?.toString() ?? fallback.logoHint,
      lastModified: data['lastModified']?.toString() ?? fallback.lastModified,
    );
  }
}

class AdminSystemSettingsScreen extends StatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  State<AdminSystemSettingsScreen> createState() => _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState extends State<AdminSystemSettingsScreen> {
  late Future<_SystemSettingsData> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
  }

  Future<_SystemSettingsData> _loadSettings() async {
    final data = await AdminApi.getSystemSettings();
    if (data.isEmpty) {
      return _SystemSettingsData.fallback;
    }
    return _SystemSettingsData.fromMap(data);
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<_SystemSettingsData>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? _SystemSettingsData.fallback;
        return Scaffold(
          backgroundColor: _DashboardColors.surface,
          body: Stack(
            children: [
              Row(
                children: [
                  const _SettingsSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _SettingsTopBar(
                          onRefresh: () => setState(() {
                            _settingsFuture = _loadSettings();
                          }),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(28, 32, 28, 96),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SettingsHeader(),
                                const SizedBox(height: 24),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final wide = constraints.maxWidth >= 1100;
                                    if (wide) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                _SettingsGeneralSection(settings: settings),
                                                const SizedBox(height: 18),
                                                _SettingsFareSection(settings: settings),
                                                const SizedBox(height: 18),
                                                _SettingsApiSection(settings: settings),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                _SettingsNotificationSection(settings: settings),
                                                const SizedBox(height: 18),
                                                _SettingsBrandingSection(settings: settings),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        _SettingsGeneralSection(settings: settings),
                                        const SizedBox(height: 18),
                                        _SettingsFareSection(settings: settings),
                                        const SizedBox(height: 18),
                                        _SettingsApiSection(settings: settings),
                                        const SizedBox(height: 18),
                                        _SettingsNotificationSection(settings: settings),
                                        const SizedBox(height: 18),
                                        _SettingsBrandingSection(settings: settings),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                _SettingsFooterBar(lastModified: settings.lastModified),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Positioned(
                right: 28,
                bottom: 24,
                child: _SettingsFab(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: const Color(0xFFEDEEEF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I-Metro Admin',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Luxury in Motion',
            style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          _SettingsSidebarItem(
            icon: Icons.dashboard,
            label: 'Revenue',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          _SettingsSidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            selected: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _SettingsSidebarItem(
            icon: Icons.history,
            label: 'Activity',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          _SettingsSidebarItem(
            icon: Icons.support_agent,
            label: 'Support',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSupportTicketManagement),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _DashboardColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 16, color: _DashboardColors.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Create Report',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsFooterLink(
            icon: Icons.verified_user,
            label: 'Security',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _SettingsFooterLink(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogoutConfirmation),
          ),
        ],
      ),
    );
  }
}

class _SettingsSidebarItem extends StatelessWidget {
  const _SettingsSidebarItem({required this.icon, required this.label, this.selected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _DashboardColors.surfaceLow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? const Border(right: BorderSide(color: _DashboardColors.primary, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _SettingsFooterLink extends StatelessWidget {
  const _SettingsFooterLink({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: _DashboardColors.surface.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Text(
            'Inter-Metro Transport Solution Limited',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(width: 22),
          _SettingsTopNavLink(
            label: 'Analytics',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          const SizedBox(width: 16),
          _SettingsTopNavLink(
            label: 'Configuration',
            selected: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          const SizedBox(width: 16),
          _SettingsTopNavLink(
            label: 'Logs',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          const Spacer(),
          Container(
            width: 230,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search parameters...',
                      hintStyle: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant.withOpacity(0.7)),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _DashboardColors.surfaceLowest,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCwYgdmS8cYFIdoTqu-wrZE3wQXDah8n4syGBlqqUlEMuv7EPodAjj6XzyYit8ijzl7JeXNC_PnbIXR-0njJJxoh1__-0cxmHICZ2K8G-yQxu4juDahnmlb4Rdc1TTOHh6cDyQMQlgTVLAOjrRzeazXGUtkZgIdOdIsMu2fq6fAoVJtBRnyO3q5eUf0hh3CZGfKJweOgwRzd0IPNABPHMX-HCbfXejzDXZ2U919GrwEJg9OhdW5vs3M27NnHkNYvp2xNFGg_Fo-mAc',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTopNavLink extends StatelessWidget {
  const _SettingsTopNavLink({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: selected ? const Border(bottom: BorderSide(color: _DashboardColors.primary, width: 2)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Configuration',
          style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage the core parameters of the I-Metro transit network. Changes made here affect real-time operations, fare calculations, and system-wide visibility.',
          style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SettingsGeneralSection extends StatelessWidget {
  const _SettingsGeneralSection({required this.settings});

  final _SystemSettingsData settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsSectionShell(
      title: 'General Platform Settings',
      trailing: const Icon(Icons.info, size: 18, color: _DashboardColors.onSurfaceVariant),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SettingsTextField(
                  label: 'Platform Name',
                  value: settings.platformName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SettingsSelectField(
                  label: 'Operational Timezone',
                  value: settings.timezone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _DashboardColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _DashboardColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.construction, size: 28, color: _DashboardColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maintenance Mode', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
                      const SizedBox(height: 4),
                      Text(
                        'Temporarily redirect users to an Under Maintenance page.',
                        style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.maintenanceMode,
                  onChanged: (value) {},
                  activeColor: Colors.white,
                  activeTrackColor: _DashboardColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: _DashboardColors.outlineVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsFareSection extends StatelessWidget {
  const _SettingsFareSection({required this.settings});

  final _SystemSettingsData settings;

  @override
  Widget build(BuildContext context) {
    final multiplierLabel = '${settings.baseFareMultiplier.toStringAsFixed(1)}x';
    final sliderValue = settings.baseFareMultiplier.clamp(0.5, 2.0).toDouble();
    final peakStrategy = settings.peakStrategy.toLowerCase();
    return _SettingsSectionShell(
      title: 'Fare Configuration',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Base Fare Multiplier',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(multiplierLabel, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
                  ],
                ),
                Slider(
                  value: sliderValue,
                  onChanged: (value) {},
                  min: 0.5,
                  max: 2.0,
                  activeColor: _DashboardColors.primary,
                  inactiveColor: _DashboardColors.surfaceHighest,
                ),
                Text(
                  'Applied to all standard ticket types across the network.',
                  style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text(
                  'Peak Hour Strategy',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SettingsChipButton(label: 'Dynamic', selected: peakStrategy == 'dynamic'),
                    const SizedBox(width: 8),
                    _SettingsChipButton(label: 'Fixed', selected: peakStrategy == 'fixed'),
                    const SizedBox(width: 8),
                    _SettingsChipButton(label: 'Disabled', selected: peakStrategy == 'disabled'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Preview',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: _DashboardColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  _SettingsPreviewRow(label: 'Standard Ticket', value: '\$4.50'),
                  const SizedBox(height: 8),
                  _SettingsPreviewRow(label: 'Peak Surcharge', value: '+\$1.25'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsApiSection extends StatelessWidget {
  const _SettingsApiSection({required this.settings});

  final _SystemSettingsData settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsSectionShell(
      title: 'API & Integrations',
      trailing: Text('Revoke All Keys', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSecureField(label: 'Production API Key', value: settings.apiKeyMasked),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SettingsInlineField(
                  label: 'Webhook Endpoint URL',
                  hint: settings.webhookUrl.isNotEmpty ? settings.webhookUrl : 'https://your-domain.com/webhooks/i-metro',
                ),
              ),
              const SizedBox(width: 12),
              const _SettingsActionButton(label: 'Test'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsNotificationSection extends StatelessWidget {
  const _SettingsNotificationSection({required this.settings});

  final _SystemSettingsData settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsSectionShell(
      title: 'Notification Rules',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsSectionSubtitle(label: 'Platform Errors'),
          const SizedBox(height: 10),
          _SettingsCheckboxRow(label: 'Email Admin Alerts', checked: settings.emailAdminAlerts),
          _SettingsCheckboxRow(label: 'Slack Integration', checked: settings.slackIntegration),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const _SettingsSectionSubtitle(label: 'Transit Alerts'),
          const SizedBox(height: 10),
          _SettingsCheckboxRow(label: 'SMS for Critical Delays', checked: settings.smsCriticalDelays),
          _SettingsCheckboxRow(label: 'Mobile Push Notifications', checked: settings.pushNotifications),
        ],
      ),
    );
  }
}

class _SettingsBrandingSection extends StatelessWidget {
  const _SettingsBrandingSection({required this.settings});

  final _SystemSettingsData settings;

  @override
  Widget build(BuildContext context) {
    final primaryColor = _colorFromHex(settings.primaryColor, fallback: _DashboardColors.primary);
    return _SettingsSectionShell(
      title: 'Custom Branding',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Primary Brand Color', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DashboardColors.surfaceLow, width: 3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settings.primaryColor, style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Transit Emerald (Global Default)', style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('Change', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
            ],
          ),
          const SizedBox(height: 18),
          Text('Logo Assets', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.5), width: 2, style: BorderStyle.solid),
              color: _DashboardColors.surfaceLow,
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload, size: 32, color: _DashboardColors.outlineVariant),
                const SizedBox(height: 8),
                Text(
                  settings.logoHint,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text('Max size 2MB', style: GoogleFonts.inter(fontSize: 10, color: _DashboardColors.onSurfaceVariant.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsFooterBar extends StatelessWidget {
  const _SettingsFooterBar({required this.lastModified});

  final String lastModified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: _DashboardColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                lastModified,
                style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              'Discard Changes',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: _DashboardColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 6))],
            ),
            child: Text(
              'Save Configuration',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsFab extends StatelessWidget {
  const _SettingsFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _DashboardColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: _DashboardColors.primary.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.save, size: 26, color: _DashboardColors.onPrimaryContainer),
    );
  }
}

class _SettingsSectionShell extends StatelessWidget {
  const _SettingsSectionShell({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: _DashboardColors.onSurfaceVariant),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  const _SettingsTextField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface)),
        ),
      ],
    );
  }
}

class _SettingsSelectField extends StatelessWidget {
  const _SettingsSelectField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface))),
              const Icon(Icons.expand_more, size: 18, color: _DashboardColors.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsInlineField extends StatelessWidget {
  const _SettingsInlineField({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _DashboardColors.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(hint, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant)),
        ),
      ],
    );
  }
}

class _SettingsSecureField extends StatelessWidget {
  const _SettingsSecureField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _DashboardColors.onSurface)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _DashboardColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: GoogleFonts.robotoMono(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _DashboardColors.surfaceHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.copy, size: 18, color: _DashboardColors.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsActionButton extends StatelessWidget {
  const _SettingsActionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _DashboardColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

class _SettingsChipButton extends StatelessWidget {
  const _SettingsChipButton({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? _DashboardColors.primary.withOpacity(0.05) : _DashboardColors.surfaceHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? _DashboardColors.primary : Colors.transparent, width: 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w600, color: selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant),
      ),
    );
  }
}

class _SettingsPreviewRow extends StatelessWidget {
  const _SettingsPreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface)),
        Text(value, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
      ],
    );
  }
}

class _SettingsSectionSubtitle extends StatelessWidget {
  const _SettingsSectionSubtitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: _DashboardColors.onSurfaceVariant),
    );
  }
}

class _SettingsCheckboxRow extends StatelessWidget {
  const _SettingsCheckboxRow({required this.label, this.checked = false});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (value) {},
          activeColor: _DashboardColors.primary,
        ),
        Expanded(
          child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurface)),
        ),
      ],
    );
  }
}

class _RevenueSummaryData {
  const _RevenueSummaryData({
    required this.totalRevenue,
    required this.totalRevenueTag,
    required this.averageFare,
    required this.averageFareTag,
    required this.refundRate,
    required this.refundRateTag,
    required this.activePromos,
    required this.activePromosTag,
  });

  final String totalRevenue;
  final String totalRevenueTag;
  final String averageFare;
  final String averageFareTag;
  final String refundRate;
  final String refundRateTag;
  final String activePromos;
  final String activePromosTag;

  static const fallback = _RevenueSummaryData(
    totalRevenue: 'NGN 0',
    totalRevenueTag: 'No sales',
    averageFare: 'NGN 0',
    averageFareTag: 'Avg',
    refundRate: '0.00%',
    refundRateTag: 'No refunds',
    activePromos: '0',
    activePromosTag: '0 active',
  );
}

class _RevenueDashboardData {
  const _RevenueDashboardData({
    required this.summary,
    required this.transactions,
    required this.distribution,
    required this.currencyLabel,
  });

  final _RevenueSummaryData summary;
  final List<_RevenueTransaction> transactions;
  final List<_RevenueDistributionItem> distribution;
  final String currencyLabel;

  static final fallback = _RevenueDashboardData(
    summary: _RevenueSummaryData.fallback,
    transactions: const [],
    distribution: const [],
    currencyLabel: 'NGN',
  );
}

class AdminRevenueDashboardScreen extends StatefulWidget {
  const AdminRevenueDashboardScreen({super.key});

  @override
  State<AdminRevenueDashboardScreen> createState() => _AdminRevenueDashboardScreenState();
}

class _AdminRevenueDashboardScreenState extends State<AdminRevenueDashboardScreen> {
  late Future<_RevenueDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_RevenueDashboardData> _loadDashboard() async {
    final payments = await AdminApi.listPayments();
    final routes = await AdminApi.listRoutes();
    final totalCount = payments.length;
    final refundedCount = payments.where((payment) => payment['status']?.toString() == 'REFUNDED').length;
    final successfulPayments = payments.where((payment) => payment['status']?.toString() == 'SUCCESS').toList();
    final successCount = successfulPayments.length;
    final totalRevenue = successfulPayments.fold<int>(0, (sum, payment) => sum + _paymentAmount(payment));
    final averageFare = successCount == 0 ? 0 : (totalRevenue / successCount).round();
    final refundRate = totalCount == 0 ? 0.0 : (refundedCount / totalCount) * 100;

    final currencyLabel = payments
        .map((payment) => payment['currency'])
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => 'NGN')
        .toUpperCase();

    final activeRoutes = routes.where((route) => route['isActive'] == true).length;
    final summary = _RevenueSummaryData(
      totalRevenue: _formatCurrency(totalRevenue.toDouble()),
      totalRevenueTag: 'Live',
      averageFare: _formatCurrency(averageFare.toDouble()),
      averageFareTag: successCount == 0 ? 'No sales' : 'Avg',
      refundRate: '${refundRate.toStringAsFixed(2)}%',
      refundRateTag: refundedCount == 0 ? 'No refunds' : '$refundedCount refunds',
      activePromos: _formatCount(activeRoutes),
      activePromosTag: '${_formatCount(activeRoutes)} active',
    );

    final distribution = _buildRevenueDistribution(successfulPayments);
    final transactions = payments.take(6).map(_mapPaymentToTransaction).toList();

    return _RevenueDashboardData(
      summary: summary,
      transactions: transactions,
      distribution: distribution,
      currencyLabel: currencyLabel,
    );
  }

  int _paymentAmount(Map<String, dynamic> payment) {
    final amount = payment['amount'];
    if (amount is int) {
      return amount;
    }
    if (amount is num) {
      return amount.toInt();
    }
    if (amount is String) {
      return int.tryParse(amount) ?? 0;
    }
    return 0;
  }

  List<_RevenueDistributionItem> _buildRevenueDistribution(List<Map<String, dynamic>> payments) {
    if (payments.isEmpty) {
      return const <_RevenueDistributionItem>[];
    }
    final revenueByRoute = <String, int>{};
    for (final payment in payments) {
      final booking = payment['booking'];
      final route = booking is Map<String, dynamic> ? booking['route'] : null;
      final routeMap = route is Map<String, dynamic> ? route : const <String, dynamic>{};
      final from = routeMap['fromLocation']?.toString();
      final to = routeMap['toLocation']?.toString();
      final label = (from != null && to != null) ? '$from → $to' : 'Unknown Route';
      revenueByRoute[label] = (revenueByRoute[label] ?? 0) + _paymentAmount(payment);
    }
    final totalRevenue = revenueByRoute.values.fold<int>(0, (sum, value) => sum + value);
    if (totalRevenue == 0) {
      return const <_RevenueDistributionItem>[];
    }
    final entries = revenueByRoute.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      _DashboardColors.primary,
      _DashboardColors.primaryContainer,
      _DashboardColors.secondary,
      _DashboardColors.outlineVariant,
    ];
    return entries.take(4).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final percent = ((item.value / totalRevenue) * 100).round();
      return _RevenueDistributionItem(
        label: item.key,
        percent: percent,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  _RevenueTransaction _mapPaymentToTransaction(Map<String, dynamic> payment) {
    final booking = payment['booking'];
    final bookingMap = booking is Map<String, dynamic> ? booking : const <String, dynamic>{};
    final route = bookingMap['route'];
    final routeMap = route is Map<String, dynamic> ? route : const <String, dynamic>{};
    final from = routeMap['fromLocation']?.toString() ?? '-';
    final to = routeMap['toLocation']?.toString() ?? '-';
    final provider = payment['provider']?.toString() ?? 'MONNIFY';
    final status = payment['status']?.toString() ?? 'PENDING';
    final timestamp = payment['paidAt']?.toString() ?? payment['createdAt']?.toString();
    final dateTimeLabel = '${_formatDate(timestamp)} - ${_formatTime(timestamp)}';

    return _RevenueTransaction(
      id: payment['id']?.toString().toUpperCase() ?? '#IM-000000',
      dateTime: dateTimeLabel,
      route: '$from → $to',
      methodLabel: _providerLabel(provider),
      methodIcon: _providerIcon(provider),
      amount: _formatCurrency(_paymentAmount(payment).toDouble()),
      status: _statusLabel(status),
    );
  }

  String _providerLabel(String provider) {
    switch (provider.toUpperCase()) {
      case 'PAYSTACK':
        return 'Paystack';
      case 'USSD':
        return 'USSD';
      case 'MONNIFY':
        return 'Monnify';
      default:
        return provider;
    }
  }

  IconData _providerIcon(String provider) {
    switch (provider.toUpperCase()) {
      case 'PAYSTACK':
        return Icons.credit_card;
      case 'USSD':
        return Icons.dialpad;
      case 'MONNIFY':
        return Icons.account_balance;
      default:
        return Icons.payments;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'Settled';
      case 'REFUNDED':
        return 'Refunded';
      case 'FAILED':
        return 'Failed';
      case 'PENDING':
        return 'Pending';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.isLoggedIn) {
      return const AdminLoginScreen();
    }
    return FutureBuilder<_RevenueDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _RevenueDashboardData.fallback;
        return Scaffold(
          backgroundColor: _DashboardColors.surface,
          body: Row(
            children: [
              const _RevenueSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _RevenueTopBar(
                      onRefresh: () => setState(() {
                        _dashboardFuture = _loadDashboard();
                      }),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _RevenueHeaderSection(),
                            const SizedBox(height: 18),
                            _RevenueSummaryGrid(summary: data.summary, currencyLabel: data.currencyLabel),
                            const SizedBox(height: 20),
                            _RevenueAnalyticsSection(distribution: data.distribution),
                            const SizedBox(height: 20),
                            _RevenueTransactionsTable(transactions: data.transactions),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RevenueSidebar extends StatelessWidget {
  const _RevenueSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: const Color(0xFFEDEEEF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I-Metro Admin',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Luxury in Motion',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.6, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          _RevenueSidebarItem(
            icon: Icons.dashboard,
            label: 'Revenue',
            selected: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          _RevenueSidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _RevenueSidebarItem(
            icon: Icons.history,
            label: 'Activity',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          _RevenueSidebarItem(
            icon: Icons.support_agent,
            label: 'Support',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSupportTicketManagement),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _DashboardColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Create Report',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _RevenueSidebarLink(
            icon: Icons.verified_user,
            label: 'Security',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          _RevenueSidebarLink(
            icon: Icons.logout,
            label: 'Log Out',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminLogoutConfirmation),
          ),
        ],
      ),
    );
  }
}

class _RevenueSidebarItem extends StatelessWidget {
  const _RevenueSidebarItem({required this.icon, required this.label, this.selected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _DashboardColors.surfaceLow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? const Border(right: BorderSide(color: _DashboardColors.primary, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueSidebarLink extends StatelessWidget {
  const _RevenueSidebarLink({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _DashboardColors.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: _DashboardColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _RevenueTopBar extends StatelessWidget {
  const _RevenueTopBar({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: _DashboardColors.surface.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Text(
            'Inter-Metro Transport Solution Limited',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: _DashboardColors.primary),
          ),
          const SizedBox(width: 22),
          _RevenueTopLink(
            label: 'Analytics',
            selected: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenueDashboard),
          ),
          const SizedBox(width: 16),
          _RevenueTopLink(
            label: 'Configuration',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSystemSettings),
          ),
          const SizedBox(width: 16),
          _RevenueTopLink(
            label: 'Logs',
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAuditActivityLogs),
          ),
          const Spacer(),
          Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search transactions...',
                      hintStyle: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant.withOpacity(0.7)),
                      isCollapsed: true,
                    ),
                  ),
                ),
                const Icon(Icons.search, size: 16, color: _DashboardColors.onSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(width: 14),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: _DashboardColors.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: _DashboardColors.onSurfaceVariant),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUserDropdown),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _DashboardColors.surfaceHighest,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB2wkZp4INDATSEAlQLIJIRISG6iq0n8SyHZ1HNbasu8vdfQivj0Puzgwwdt1Cz2GUZlG-4YQSgtg9_uE-gkJ6tzEqQgAPrR3d0DxSRfGPNUU2y7Smw9kTZifnHFj_trd3MwFVNxYG5DQPcHa0oiUp9gTy6uWuZpPHLtJ4Um2RDjR3BfclN5JEguMgQQRJoGcg87ke6NRxLBf4iciBv9mgNobMijuSFJyjeiD4pXDJXeUaP4t_RFLho5U6UXno93SA1hnrEbqk19Lg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueTopLink extends StatelessWidget {
  const _RevenueTopLink({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: selected ? const Border(bottom: BorderSide(color: _DashboardColors.primary, width: 2)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? _DashboardColors.primary : _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RevenueHeaderSection extends StatelessWidget {
  const _RevenueHeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revenue Dashboard',
                style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Financial health and transit movement overview',
                style: GoogleFonts.inter(fontSize: 12, color: _DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _RevenueFilterChip(
          icon: Icons.calendar_today,
          label: 'Last 30 Days',
        ),
        const SizedBox(width: 10),
        const _RevenueFilterChip(
          icon: Icons.route,
          label: 'All Routes',
        ),
      ],
    );
  }
}

class _RevenueFilterChip extends StatelessWidget {
  const _RevenueFilterChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DashboardColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _DashboardColors.primary),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          const Icon(Icons.expand_more, size: 16, color: _DashboardColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _RevenueSummaryGrid extends StatelessWidget {
  const _RevenueSummaryGrid({required this.summary, required this.currencyLabel});

  final _RevenueSummaryData summary;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100 ? 4 : width >= 760 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.6,
          children: [
            _RevenueSummaryCard(
              title: 'Total Revenue (${currencyLabel.toUpperCase()})',
              value: summary.totalRevenue,
              tag: summary.totalRevenueTag,
              icon: Icons.payments,
              iconColor: _DashboardColors.primary,
              iconBackground: const Color(0x1F006B54),
              tagColor: _DashboardColors.primary,
              tagBackground: _DashboardColors.secondaryContainer,
            ),
            _RevenueSummaryCard(
              title: 'Average Fare',
              value: summary.averageFare,
              tag: summary.averageFareTag,
              icon: Icons.confirmation_number,
              iconColor: _DashboardColors.secondary,
              iconBackground: const Color(0x33006654),
              tagColor: _DashboardColors.onSurfaceVariant,
              tagBackground: _DashboardColors.surfaceLow,
            ),
            _RevenueSummaryCard(
              title: 'Refund Rate',
              value: summary.refundRate,
              tag: summary.refundRateTag,
              icon: Icons.assignment_return,
              iconColor: _DashboardColors.error,
              iconBackground: const Color(0x33FFDAD6),
              tagColor: _DashboardColors.error,
              tagBackground: const Color(0xFFFFDAD6),
            ),
            _RevenueSummaryCard(
              title: 'Active Promos',
              value: summary.activePromos,
              tag: summary.activePromosTag,
              icon: Icons.loyalty,
              iconColor: _DashboardColors.tertiary,
              iconBackground: const Color(0x1F92493E),
              tagColor: _DashboardColors.onSurfaceVariant,
              tagBackground: _DashboardColors.surfaceLow,
            ),
          ],
        );
      },
    );
  }
}

class _RevenueSummaryCard extends StatelessWidget {
  const _RevenueSummaryCard({
    required this.title,
    required this.value,
    required this.tag,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.tagColor,
    required this.tagBackground,
  });

  final String title;
  final String value;
  final String tag;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color tagColor;
  final Color tagBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: tagColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: _DashboardColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: _DashboardColors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _RevenueAnalyticsSection extends StatelessWidget {
  const _RevenueAnalyticsSection({required this.distribution});

  final List<_RevenueDistributionItem> distribution;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 2, child: _RevenueTrendCard()),
              const SizedBox(width: 18),
              Expanded(child: _RevenueDistributionCard(items: distribution)),
            ],
          );
        }
        return Column(
          children: [
            const _RevenueTrendCard(),
            const SizedBox(height: 18),
            _RevenueDistributionCard(items: distribution),
          ],
        );
      },
    );
  }
}

class _RevenueTrendCard extends StatelessWidget {
  const _RevenueTrendCard();

  @override
  Widget build(BuildContext context) {
    final heights = [0.65, 0.8, 0.58, 0.5, 0.9, 0.75, 0.82];
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue Trends', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    _RevenuePill(label: 'DAILY', selected: true),
                    const SizedBox(width: 6),
                    _RevenuePill(label: 'WEEKLY'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => Divider(color: _DashboardColors.onSurfaceVariant.withOpacity(0.12), height: 1),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: heights
                        .map(
                          (height) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _RevenueBar(heightFactor: height),
                            ),
                          ),
                        )
                        .toList(),
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

class _RevenuePill extends StatelessWidget {
  const _RevenuePill({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? _DashboardColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : _DashboardColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RevenueBar extends StatelessWidget {
  const _RevenueBar({required this.heightFactor});

  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight * heightFactor,
          decoration: BoxDecoration(
            color: _DashboardColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.6,
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: _DashboardColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RevenueDistributionCard extends StatelessWidget {
  const _RevenueDistributionCard({required this.items});

  final List<_RevenueDistributionItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text('Route Distribution', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'No revenue data yet.',
                      style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
                    ),
                  )
                else
                  for (var index = 0; index < items.length; index++) ...[
                    _RevenueDistributionRow(item: items[index]),
                    if (index != items.length - 1) const SizedBox(height: 12),
                  ],
                const SizedBox(height: 18),
                Container(height: 1, color: _DashboardColors.outlineVariant.withOpacity(0.2)),
                const SizedBox(height: 16),
                const _RevenuePaymentLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueDistributionRow extends StatelessWidget {
  const _RevenueDistributionRow({required this.item});

  final _RevenueDistributionItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${item.percent}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: item.percent / 100,
            minHeight: 8,
            backgroundColor: _DashboardColors.surfaceHighest,
            valueColor: AlwaysStoppedAnimation(item.color),
          ),
        ),
      ],
    );
  }
}

class _RevenuePaymentLegend extends StatelessWidget {
  const _RevenuePaymentLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Breakdown',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: _DashboardColors.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            _RevenueLegendItem(color: _DashboardColors.primary, label: 'Metro Pass'),
            SizedBox(width: 12),
            _RevenueLegendItem(color: _DashboardColors.primaryContainer, label: 'NFC'),
            SizedBox(width: 12),
            _RevenueLegendItem(color: _DashboardColors.secondary, label: 'QR Code'),
          ],
        ),
      ],
    );
  }
}

class _RevenueLegendItem extends StatelessWidget {
  const _RevenueLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _RevenueTransactionsTable extends StatelessWidget {
  const _RevenueTransactionsTable({required this.transactions});

  final List<_RevenueTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _DashboardColors.surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('View All', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _DashboardColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: _DashboardColors.surfaceLow.withOpacity(0.5),
            child: Row(
              children: const [
                _RevenueTableHeader(label: 'Transaction ID', flex: 2),
                _RevenueTableHeader(label: 'Date & Time', flex: 2),
                _RevenueTableHeader(label: 'Route', flex: 2),
                _RevenueTableHeader(label: 'Method', flex: 2),
                _RevenueTableHeader(label: 'Amount', flex: 1),
                _RevenueTableHeader(label: 'Status', flex: 2),
                _RevenueTableHeader(label: '', flex: 1, alignRight: true),
              ],
            ),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No transactions yet.',
                style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: transactions.map((tx) => _RevenueTransactionRow(transaction: tx)).toList(),
            ),
        ],
      ),
    );
  }
}

class _RevenueTableHeader extends StatelessWidget {
  const _RevenueTableHeader({required this.label, required this.flex, this.alignRight = false});

  final String label;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: _DashboardColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RevenueTransactionRow extends StatelessWidget {
  const _RevenueTransactionRow({required this.transaction});

  final _RevenueTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _DashboardColors.surfaceHighest.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              transaction.id,
              style: GoogleFonts.robotoMono(fontSize: 11, color: _DashboardColors.onSurface),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              transaction.dateTime,
              style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              transaction.route,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(transaction.methodIcon, size: 16, color: _DashboardColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(transaction.methodLabel, style: GoogleFonts.inter(fontSize: 11, color: _DashboardColors.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transaction.amount,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 2,
            child: _RevenueStatusChip(status: transaction.status),
          ),
          const Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.more_vert, size: 18, color: _DashboardColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueStatusChip extends StatelessWidget {
  const _RevenueStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    if (status == 'Settled') {
      background = _DashboardColors.secondaryContainer;
      textColor = _DashboardColors.onSecondaryContainer;
    } else if (status == 'Refunded') {
      background = const Color(0xFFFFDAD6);
      textColor = _DashboardColors.error;
    } else {
      background = _DashboardColors.tertiaryFixed;
      textColor = _DashboardColors.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

class _RevenueDistributionItem {
  const _RevenueDistributionItem({required this.label, required this.percent, required this.color});

  final String label;
  final int percent;
  final Color color;
}

class _RevenueTransaction {
  const _RevenueTransaction({
    required this.id,
    required this.dateTime,
    required this.route,
    required this.methodLabel,
    required this.methodIcon,
    required this.amount,
    required this.status,
  });

  final String id;
  final String dateTime;
  final String route;
  final String methodLabel;
  final IconData methodIcon;
  final String amount;
  final String status;
}

const List<_RevenueDistributionItem> _routeDistribution = [
  _RevenueDistributionItem(label: 'Green Line (Main)', percent: 42, color: _DashboardColors.primary),
  _RevenueDistributionItem(label: 'Express 88', percent: 28, color: _DashboardColors.primaryContainer),
  _RevenueDistributionItem(label: 'River Shuttle', percent: 18, color: _DashboardColors.secondary),
  _RevenueDistributionItem(label: 'Airport Connector', percent: 12, color: _DashboardColors.outlineVariant),
];

const List<_RevenueTransaction> _revenueTransactions = [
  _RevenueTransaction(
    id: '#IM-902341',
    dateTime: 'Oct 24, 2023 - 14:21',
    route: 'Green Line South',
    methodLabel: 'I-Metro Pass',
    methodIcon: Icons.contactless,
    amount: '\$2.50',
    status: 'Settled',
  ),
  _RevenueTransaction(
    id: '#IM-902342',
    dateTime: 'Oct 24, 2023 - 14:18',
    route: 'Express 88',
    methodLabel: 'NFC Payment',
    methodIcon: Icons.nfc,
    amount: '\$12.00',
    status: 'Refunded',
  ),
  _RevenueTransaction(
    id: '#IM-902343',
    dateTime: 'Oct 24, 2023 - 14:15',
    route: 'River Shuttle',
    methodLabel: 'QR Code',
    methodIcon: Icons.qr_code_2,
    amount: '\$4.25',
    status: 'Settled',
  ),
  _RevenueTransaction(
    id: '#IM-902344',
    dateTime: 'Oct 24, 2023 - 14:12',
    route: 'Green Line North',
    methodLabel: 'I-Metro Pass',
    methodIcon: Icons.contactless,
    amount: '\$2.50',
    status: 'Flagged',
  ),
];





