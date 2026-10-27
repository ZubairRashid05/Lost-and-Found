import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lost_and_found/model/user.dart';

const authTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Color(0xFF26384C),
);
const authMutedColor = Color(0xFFD1D7DF);
const authAccentColor = Color(0xFF71C9ED);
final authLinkButtonStyle = TextButton.styleFrom(
  foregroundColor: authAccentColor,
  padding: EdgeInsets.zero,
  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
);

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    style: const TextStyle(fontSize: 13, color: Color(0xFF42536A)),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 10, color: authAccentColor),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: authMutedColor),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 28),
      contentPadding: const EdgeInsets.only(bottom: 9),
      isDense: true,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE2E5EA)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: authAccentColor, width: 1.5),
      ),
    ),
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 44,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: authAccentColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: authAccentColor.withValues(alpha: .28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<User>> _loadUsers() async {
    final response = await rootBundle.loadString(
      'lib/assets/database/data.json',
    );
    final data = jsonDecode(response) as Map<String, dynamic>;
    return (data['users'] as List<dynamic>)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final users = await _loadUsers();
      final valid = users.any(
        (user) => user.email == email && user.password == password,
      );
      if (!mounted) return;
      if (valid) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homepage',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 100, 32, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              const Text('Sign In', style: authTitleStyle),
              const SizedBox(height: 7),
              const Text(
                'Hi there! Nice to see you again.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB0)),
              ),
              const SizedBox(height: 25),
              AuthField(
                label: 'Email or Username',
                hint: 'example@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              AuthField(
                label: 'Password',
                hint: 'Your password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: authMutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(label: 'Sign in', onPressed: _handleLogin),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB0)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: authLinkButtonStyle,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
