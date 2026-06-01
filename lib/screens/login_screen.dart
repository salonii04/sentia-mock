import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function() onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await _authService.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      _showMessage('Login failed. Please try again.');
      return;
    }

    // Integration point:
    // The app-level auth gate swaps Login -> existing SentiaShell on success.
    await widget.onLoginSuccess();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openSignup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupScreen(onSignupSuccess: widget.onLoginSuccess),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SentiaBrandHeader(
                      subtitle: 'Your AI Companion for Emotional Wellness',
                    ),
                    const SizedBox(height: 28),
                    _AuthField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                    ),
                    const SizedBox(height: 16),
                    _AuthField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepForest,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.5,
                            color: AppColors.earthBrown,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: _isSubmitting ? null : _openSignup,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.sageGreen,
                            ),
                          ),
                        ),
                      ],
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

class _SentiaBrandHeader extends StatelessWidget {
  final String subtitle;

  const _SentiaBrandHeader({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: AppColors.deepForest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.sageGreen.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 12),
        Text(
          'Sentia',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreenText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.earthBrown,
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreenText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.sageGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
